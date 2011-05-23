module Xdt
  module Generator
    module Generator
      def field(*args, &blk)
        elements << Field.new(*args, &blk)
      end

      def section(*args, &blk)
        elements << Section.new(*args, &blk)
      end

      def to_s
        str = elements.map { |s| s.to_s }.join || ""
      end

      def length
        elements.inject(0) { |sum, s| sum + s.length }
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
        str = "#{ '%03d'  % self.length }#{ '%04d' % @id.to_i }#{data[0...self.length - 9]}\x0D\x0A"
        str = str.encode("iso-8859-1", :invalid => :replace, :undef => :replace)
      end
    end

    class Section
      include Generator

      def initialize(type)
        @type = type

        field("8000", '%04d' % @type.to_i)
        field("8100", nil, 5) { '%05d' % self.length }

        yield self
      end
    end
  end
end

