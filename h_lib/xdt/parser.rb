module Xdt
  class Parser

    def self.parse(string, &block)
      # find encoding
      string = string.dup.force_encoding("ASCII-8BIT")
      encoding = string.match(/^\d{3}9206(\d)/) ? (Xdt::ENCODINGS[$1.to_i] || Encoding::CP437) : Encoding::CP437

      string.force_encoding(encoding).encode("utf-8")

      string.gsub!("\r\n","\n") # normalize line endings

      string.scan(/^(...)(\d{4})(.*)/) do |len, id, data|
        block.call id.to_i, data
      end

      nil
    end

  end
end

