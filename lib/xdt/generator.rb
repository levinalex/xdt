module Xdt
  module Generator
    class Document
      def initialize
        yield self
      end

      def field(*args)
        elements << Field.new(*args)
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

    class Field
      def initialize(id, data)
        @id = id
        @data = data.to_s
      end

      def length
        @data.length + 9
      end

      def to_s
        "#{ '%03d'  % self.length }#{ '%04d' % @id.to_i }#{@data}\x0D\x0A"
      end
    end

    class Section
      def initialize(type)
        @type = type
        @fields = []

        yield self
      end

      def field(*args)
        @fields << Field.new(*args)
      end

      def fields
        [
          Field.new("8000", '%04d' % @type.to_i),
          Field.new("8100", '%05d' % (self.length)),
          *@fields
        ]
      end

      def length
        header_length = 27
        @fields.inject(header_length) { |sum,f| sum + f.length }
      end

      def to_s
        fields.map { |f| f.to_s }.join
      end

    end
  end
end

