require 'gli'
require 'json'
require 'thread'
require 'directory_watcher'
require 'rest-client'


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
      while fname = @queue.pop do
        process_file(fname, &block)
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

    desc "watch a directory for GDT files and post extracted patient information to the given HTTP endpoint"
    arg_name "directory"
    command :watch do |c|
      c.flag "uri", type: String, desc: "HTTP endpoint where patients are posted to", arg_name: "URI"

      c.action do |global_options,options,args|
        help_now!('directory is required') if args.empty?
        Xdt::Watcher.new(args).watch! do |patient_data|
          puts patient_data.to_json
          RestClient.post options[:uri], {:patient => patient_data, :ua => Xdt.version}, :content_type => :json, :accept => :json
        end
      end
    end
  end

end
