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
          process_file(fname, &block)
        end
      rescue Interrupt => e
        warn "Quitting (Interrupt)... "
      end
    end

    def process_file(fname, &block)
      data =  Xdt::Parser::RawDocument.open(fname).patient.to_hash
      yield data, fname
    rescue => e
      warn "error processing #{fname}"
      warn e
    end
  end
end
