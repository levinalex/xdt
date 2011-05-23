module Xdt
  module Generator
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

      def to_s
        header_length = 27

        data = @fields.map { |field| field.to_s }.join
        header = Field.new("8000", '%04d' % @type.to_i).to_s +
          Field.new("8100", '%05d' % (data.length + header_length) ).to_s

        header + data
      end

    end
  end
end

