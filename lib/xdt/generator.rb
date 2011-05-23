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
        elements.map { |s| s.to_s }.join || ""
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
        (@length || @data.to_s.length) + 9
      end

      def to_s
        data = @data ? @data.to_s : @blk.call
        data = data[0 ... length - 9] # clip at length
        "#{ '%03d'  % self.length }#{ '%04d' % @id.to_i }#{data}\x0D\x0A"
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

