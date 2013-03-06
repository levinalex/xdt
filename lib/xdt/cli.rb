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
        warn "watching: #{directory.to_s}"
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
          begin
            yield(fname)
          rescue => e
            warn "error processing #{fname}"
            warn e
          end
        end
      rescue Interrupt => e
        warn "Quitting (Interrupt)... "
      end
    end
  end

  class XdtHandler
    def initialize(params)
      @params = params
    end

    def handle(fname)
      data = Xdt::Parser::RawDocument.open(fname).patient.to_hash

      @params[:output].value.puts data.to_json
      opts = { hostname: Socket.gethostname, name: Xdt.version }

      if @params[:uri].value
        RestClient.post( @params[:uri].value, {:patient => data, :about => opts }.to_json, :content_type => :json, :accept => :json)
      end

      if @params['delete'].value
        File.delete(fname)
      end
    end
  end
end
