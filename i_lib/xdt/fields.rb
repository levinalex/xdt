module Xdt
  ENCODINGS = { 1 => Encoding::US_ASCII,
                2 => Encoding::IBM437,
                3 => Encoding::ISO8859_1 }
  DEFAULT_ENCODING = Encoding::IBM437

  class Field
    attr_reader :id, :value

    RX = /
           \r?\n?     # ignore leading newlines
           (\d{3})    # line length
           (\d{4})    # field id
           (.*?)      # field data
           \r?\n?$    # match data until end of line or EOF
         /x

    def initialize(id, value, length=nil, &blk)
      @id = "%04s" % id
      @value = value
      @length = length
      @block = blk
    end

    def length
      (@length || formatted_value.length) + 9
    end


    def value
      @value || @block.call
    end

    def formatted_value
      value.to_str
    end


    def to_xdt
      "#{"%03d" % length}#{id}#{formatted_value}\r\n"
    end

    def self.parse(scanner)
      str = scanner.scan(RX)
      return new($2, parse_value($3)) if str && str.match(RX)
    end

    def self.parse_value(value)
      value
    end


    class DateField < Field
      def self.parse_value(value)
        Date.strptime(value, "%d%m%Y")
      end

      def formatted_value
        value.strftime("%d%m%Y")
      end
    end

    class CharsetField < Field
      def self.parse_value(value)
        ENCODINGS[value.to_i] || DEFAULT_ENCODING
      end

      def formatted_value
        ENCODINGS.invert[Encoding.find(value.to_s)].to_s
      end

      def length
        value == DEFAULT_ENCODING ? 0 : super
      end

      def to_xdt
        value == DEFAULT_ENCODING ? "" : super
      end
    end

    class GenderField < Field
      def self.parse_value(value)
        { "1" => :male, "2" => :female }[value]
      end

      def formatted_value
        case value.to_s
          when /^m/i then "1"
          when /^f/i then "2"
          else nil
        end
      end

    end
  end
end
