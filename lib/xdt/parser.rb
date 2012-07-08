module Xdt
  module Parser

    class XdtRow
      def initialize(id, value, opts = {})
        @id = to_id(id)
        @value = value
      end

      def has_id?(id)
        to_id(id) == @id
      end

      def value
        @value
      end

      def line_length
        @value.length + 9
      end

      def to_xdt
        "#{"%03i" % line_length}#{to_id(@id)}#{@value}\x0D\x0A"
      end

      private

      def to_id(str)
        str.to_s.rjust(4,"0")
      end
    end

    class RawDocument
      RX = /
             \r?\n?     # ignore leading newlines
             (\d{3})    # line length
             (\d{4})    # field id
             (.*?)      # field data
             \r?\n?$    # match data until end of line or EOF
           /x


      def initialize
        @data = []
      end

      def first(code)
        @data.detect { |row| row.has_id?(code) }
      end
      alias_method :[], :first

      def initialize_from_text(text)
        @data = text.scan(RX).map do |len,id,data|
          XdtRow.new(id, data, length: len)
        end
      end

      def patient
        Xdt::Patient.from_document(self)
      end


      def to_xdt
        @data.map(&:to_xdt).join
      end

      def self.open(fname)
        doc = allocate
        doc.initialize_from_text(File.open(fname, encoding: "ISO-8859-1").read)
        doc
      end
    end
  end

end
