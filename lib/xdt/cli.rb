require 'gli'
require 'json'
require 'thread'
require 'socket'
require 'directory_watcher'
require 'rest-client'
require 'securerandom'


module Xdt
  class Watcher
    def initialize(dirs)
      @queue = SizedQueue.new(1)
      dirs.each do |directory|
        watcher = DirectoryWatcher.new(directory, glob: '*', interval: 1, stable: 2)
        watcher.add_observer do |*events|
          stable_files = events.select { |e| e.type == :stable }.map(&:path)
          stable_files.each { |f| @queue.push(f) }
        end
        watcher.start
      end
    end

    def watch!(&block)
      begin
        while fname = @queue.pop do
          process_file(fname, &block)
        end
      rescue Interrupt => e
        puts "Quitting (Interrupt)... "
      end
    end

    def process_file(fname, &block)
      data =  Xdt::Parser::RawDocument.open(fname).patient.to_hash
      yield data
    rescue => e
      warn "error processing #{fname}"
      warn e
    end
  end

  module CLI
    extend GLI::App
    program_desc "XDT parser"
    version Xdt::VERSION

    flag [:config,:c], default_value: File.join(ENV['HOME'],'.xdt'),
                       desc: "stores configuration and authentication data",
                       arg_name: "FILE"

    desc "watch a directory for GDT files and post extracted patient information to the given HTTP endpoint"
    arg_name "directory"

    around do |global_options,command,options,args,code|
      fname = global_options[:config]
      global_options[:config] = if fname && File.exist?(fname)
                                  YAML.load_file(fname)
                                else
                                  {}
                                end
      global_options[:config]["uuid"] ||= SecureRandom.uuid

      code.call

      File.open(fname, "w+") { |f| f.write(global_options[:config].to_yaml) }
    end


    command :watch do |c|
      c.flag [:uri,:e], type: String,
                        desc: "HTTP endpoint where patients are posted to",
                        arg_name: "URI"

      c.action do |global_options,options,args|
        help_now!('directory is required') if args.empty?
        Xdt::Watcher.new(args).watch! do |patient_data|
          puts patient_data.to_json
          opts = { uuid: global_options[:config]["uuid"], hostname: Socket.gethostname, name: Xdt.version }

          RestClient.post options[:uri], {:patient => patient_data, :about => opts }, :content_type => :json, :accept => :json
        end
      end
    end
  end

end
