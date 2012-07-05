require 'thor'
require 'json'
require 'thread'
require 'directory_watcher'
require 'rest-client'

module Xdt
  module CLI
    class App < Thor
      method_option :uri, required: false,
                          type: :string,
                          banner: "URI",
                          desc: "HTTP endpoint where patients are posted to."
      method_option :watchdog, type: :string,
                               lazy_default: true, banner: "URI",
                               desc: "HTTP uri that will be called periodically with diagnostic information"
      desc "watch", "watch a directory for GDT files and post extracted patient information to the given HTTP endpoint"

      def watch(directory)
        queue = SizedQueue.new(1)

        watcher = DirectoryWatcher.new(directory, glob: '*', interval: 1, stable: 2)
        watcher.add_observer do |*events|
          stable_files = events.select { |e| e.type == :stable }.map(&:path)
          stable_files.each { |f| queue.push(f) }
        end
        watcher.start

        # force file processing to occur on the main thread
        while x = queue.pop do
          process_file(x)
        end
      end


      private

      def process_file(fname)
        data =  Xdt::Parser::RawDocument.open(fname).patient.to_hash
        if options[:uri]
          RestClient.post options[:uri], {:patient => data}, :content_type => :json, :accept => :json
        else
          puts data.to_json
        end
      rescue => e
        warn "error processing #{fname}"
        warn e
      end
    end

    def self.with_friendly_errors
      yield
    end
  end
end
