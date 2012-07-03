require 'thor'

module Xdt
  module CLI
    class App < Thor


      method_option :http, required: true,
                           type: :string,
                           banner: "URI",
                           desc: "HTTP endpoint where patients are posted to"
      method_option :watchdog, type: :string, lazy_default: true, banner: "URI",
                               desc: "HTTP uri that will be called periodically with diagnostic information"
      desc "watch", "watch a directory for GDT files and post extracted patient information to the given HTTP endpoint"
      def watch(directory)
        puts options[:watchdog].inspect
        puts "directory: #{directory.inspect}"
      end

    end


    def self.with_friendly_errors
      yield
    end
  end
end
