
module Xdt
  class Parser
    def initialize(lines, encoding)
      @hash = {}
      lines.scan(/^(...)(\d{4})(.*)/) do |len, id, data|
        @hash[id.to_i] = data
      end
    end

    def to_hash
      @hash
    end

    def self.parse(string)
      string = string.gsub!("\r\n","\n") # normalize line endings
      new(string, nil).to_hash
    end

  end

end
