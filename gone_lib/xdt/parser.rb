
module Xdt
  class Parser
    include Xdt::Converter::Dicom

    def initialize(lines, encoding)
      @hash = {}
      lines.scan(/^(...)(\d{4})(.*)/) do |len, id, data|
        @hash[id.to_i] = data
      end
    end

    def to_hash
      @hash
    end

    def blank?
      @hash.empty?
    end

    def [](*args)
      @hash[*args]
    end

    def self.parse(string)
      string = string.force_encoding("cp437").encode("utf-8")
      string = string.gsub!("\r\n","\n") # normalize line endings
      new(string, nil)
    end
  end
end

