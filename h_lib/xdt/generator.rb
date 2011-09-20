module Xdt
  module Generator
    module Generator
      def field(id, *args, &blk)
        idx = elements.index { |(i,v)| i == id.to_s }
        if idx
          elements[idx] = [id.to_s, Field.new(id, *args, &blk)]
        else
          elements << [id.to_s, Field.new(id, *args, &blk)]
        end
      end

      def section(*args, &blk)
        elements << [:section, Section.new(*args, &blk)]
      end

      def to_s
        str = elements.map { |(i,s)| s.to_s }.join || ""
      end

      def length
        elements.inject(0) { |sum, (i,s)| sum + s.length }
      end

      def elements
        @_elements ||= []
      end
    end

    class Document
      include Generator

      def initialize
        yield self
      end
    end

    class Field
      def initialize(id, data, length = nil, &blk)
        @id = id
        @data = data
        @length = length
        @blk = blk
      end

      def length
        (@length || data.to_s.length) + 9
      end

      def data
        @_str ||= @data ? @data.to_s : @blk.call
      end

      def to_s
        str = "#{ '%03d'  % self.length }#{ '%04d' % @id.to_i }#{data.to_s[0...self.length - 9]}\x0D\x0A"
      end
    end

    class Section
      include Generator
      attr_accessor :type

      def initialize(type = nil)
        self.type = type.to_s if type

        field("8000", nil, 4) { '%04d' % self.type.to_i }
        field("8100", nil, 5) { '%05d' % self.length }

        yield self if block_given?
      end
    end
  end

end
