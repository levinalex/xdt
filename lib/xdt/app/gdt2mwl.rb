#!/usr/bin/env ruby

require 'optparse'
require 'yaml'
require 'json'
require 'tempfile'

# require 'xdt'

module Xdt::App
  ConfigFilename = ".gdt2mwl"
  ConfigFile = File.join(ENV['HOME'] || ENV['APPDATA'], ConfigFilename)

  # defaults are used when they are not overwritten in a config file
  # or with command line options
  #
  DefaultConfig = {
    :files => ["**/*.GDT"],
    :delete_files => true
  }

  class Gdt2Mwl

    # load configuration from configfile, merge with
    # default options
    #
    def load_configuration
     # try to read configuration from file
      @options_from_file = YAML.load_file(ConfigFile) || {} rescue {}

      # if an option is not given on the command line
      # it is taken from the config file, or the default is used
      @options = Hash.new() { |h,k| @options_from_file[k] || DefaultConfig[k] }
    end

    # parse command line options
    #
    def initialize
      load_configuration

      @opts = OptionParser.new do |opts|
        opts.on "-V","--version","Display version and exit" do
          puts "#{self.class} #{::Xdt::VERSION}"
          exit
        end
        opts.on "-f", "--files PATTERN", Array,
                    "a list of files or shell globs to look for",
                    "default is '**/*.GDT'" do |arg|
          @options[:files] = arg
        end
        opts.on "-d", "--directory DIR" do |arg|
          @options[:dir] = arg
        end
        opts.on_tail "-p", "--print-config", "Print the current configuration",
                                             "in a format that can be used as a configuration file" do
          puts @options_from_file.merge(@options).to_yaml
          exit
        end
      end
    end

    def files
      @options[:files].map { |p| Dir.glob(p) }.flatten.compact.uniq
    end

    def handle_file(filename, idx)
      str = File.read(filename)
      data = Xdt::Parser.parse(str)

      file_id = data[3000] || rand(10e10).to_s
      dcmdata = data.to_dicom

      dumpfile = Tempfile.new("dcmdump")
      dumpfile.write(dcmdata)
      dumpfile.close

      outpath = File.join(@options[:dir], "worklist", "%s.wl" % file_id)

      `dump2dcm #{dumpfile.path} #{outpath}`

      dumpfile.unlink

      # File.delete(filename) if @options[:delete_files]
    end

    # run the application
    #
    def run!(args = ARGV)
      @opts.parse!(args)

      raise "Directory must be provided" unless @options[:dir] and Dir.exist?(@options[:dir])

      files.each_with_index { |f,i|
        handle_file(f,i)
      }

      # cleanup worklist folder
      existing_files = Dir[File.join(@options[:dir], "worklist", "*.wl")].sort_by { |f| File.mtime(f) }.reverse # newest first
      puts existing_files

      to_delete = existing_files[30 .. -1] || []
      to_delete.each do |f|
        File.delete(f)
      end
    end
  end
end
