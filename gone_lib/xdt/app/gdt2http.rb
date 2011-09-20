#!/usr/bin/env ruby

require 'optparse'
require 'net/http'
require 'yaml'
require 'json'

require 'xdt'

module Xdt::App
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
          puts "#{self.class} #{::Xdt::VERSION}"
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
        data = Xdt::Parser.parse(str)

        begin
          url = URI.parse(@options[:endpoint])
          req = Net::HTTP::Post.new(url.path, {'Content-Type' =>'application/json'})
          req.body = data.to_hash.to_json
          res = Net::HTTP.new(url.host, url.port).start {|http| http.request(req) }

          puts res.to_hash.map { |k,v| "#{k}: #{v}" }
          case res
          when ::Net::HTTPSuccess
            File.delete(filename) if @options[:delete_files]
          when ::Net::HTTPClientError
            warn "Client Error"
          when ::Net::HTTPServerError
            warn "Server Error"
          end

        rescue ::Errno::ECONNREFUSED
          puts "Unable to connect to server '#{@options[:endpoint]}' (connection refused)"
        end
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
