
module Gdt
  
  class ParseError < ArgumentError
  end
  
  class Parser
    def self.parse(string)
      # canonical line endings
      string.gsub!("\r\n","\n")
      
      string.split(/\n/).
      # ignore empty lines and lines consisting only of whitespace
      delete_if { |line| line =~ /^\s*$/ }.
      inject({}) do |h, line|
        # parse the line into tokens
        #
        length, type, data = line.scan(/(\d{3})(\d{4})(.*)/).first

        raise ParseError, "line does not match expected GDT format: '#{line}'" unless length && type && data
        
        length = length.to_i
        type = type.to_i

        # 3 bytes length + 4 bytes record id + data length (bytes) + CR LF
        expected_length = 3 + 4 + data.length + 2
        
        raise ParseError, "wrong length in GDT data: '#{line}'" unless length == expected_length

        h[type] = data
        h
      end
    end

  end
end
