#!/usr/bin/env ruby

require 'optparse'
require 'net/http'
require 'yaml'

require 'xdt'

module Gdt
  ConfigFilename = ".gdt2http"
  ConfigFile = File.join(ENV['HOME'] || ENV['APPDATA'], ConfigFilename)

  # defaults are used when they are not overwritten in a config file
  # or with command line options
  #
  DefaultConfig = {
    :files => ["**/*.GDT"],
    :endpoint => "http://localhost:3000/gdt",
    :delete_files => true
  }

  class Gdt2Http

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
          puts "#{self.class} #{::Gdt::VERSION}"
          exit
        end
        opts.on "-f", "--files PATTERN", Array,
                    "a list of files or shell globs to look for",
                    "default is '**/*.GDT'" do |arg|
          @options[:files] = arg
        end
        opts.on "-u", "--uri URI", "URI of the HTTP-Endpoint to which the parsed data is sent" do |arg|
          @options[:endpoint] = arg
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

    def handle_file(filename)
      # open and parse the given file
      str = File.read(filename)

      begin
        data = Gdt.new(str)

        begin
          res = ::Net::HTTP.post_form(URI.parse(@options[:endpoint]), data.to_hash )
          puts res.header.to_hash.map { |k,v| "#{k}: #{v}" }
          puts
          case res
          when ::Net::HTTPSuccess
            File.delete(filename) if @options[:delete_files]
            puts res.body
          when ::Net::HTTPClientError
            warn "Client Error"
          when ::Net::HTTPServerError
            warn "Server Error"
          end

        rescue ::Errno::ECONNREFUSED
          puts "Unable to connect to server '#{@options[:endpoint]}' (connection refused)"
        end
      rescue ParseError => e
        warn "Parse error in '#{filename}'"
      end
    end

    # run the application
    #
    def run!(args = ARGV)
      @opts.parse!(args)
      files.each { |f|
        handle_file(f)
      }
    end
  end
end
