require 'strscan'
require 'active_support/core_ext/class/attribute.rb'

module Xdt

  class Document
    class_attribute :known_fields #  :instance_writer => false

    module ClassMethods
      def has_field(id, name, opts = {})
        klass = opts.fetch(:class, Xdt::Field)
        method = opts.fetch(:method, :append_field)

        val = self.known_fields || {}
        val[id.to_s] = [method, klass]
        self.known_fields = val

        if name
          define_method("#{name}=") do |v|
            replace_field_value(id.to_s, v)
          end

          define_method(name) do
            first(id.to_s).value
          end

        end

        nil
      end


      def get_field(id)
        hash = self.known_fields || {}
        hash[id] || [:append_field, Xdt::Field]
      end

      def with_field(id)
        yield get_field(id)
      end
    end

    include Enumerable
    extend ClassMethods

    def initialize
      @elements ||= []
    end

    def first(id)
      i, field = @elements.find { |(i,f)| i == id }
      field
    end

    def each
      @elements.each { |(id,elem)| yield elem }
    end

    def to_xdt
      map { |elem| elem.to_xdt }.join
    end

    def append_field(field)
      @elements << [field.id, field] if field
    end

    def replace_field_value(id, *args)
      self.class.with_field(id) do |method,klass|
        field = klass.new(id, *args)

        idx = @elements.index { |(i,v)| i == id }
        if idx
          @elements[idx] = [field.id, field]
        else
          append_field(field)
        end
      end
    end


    def self.parse(string_scanner)
      data = string_scanner.string
      encoding = data.match(/^\d{3}9206(\d)/) ? (Xdt::ENCODINGS[$1.to_i] || Encoding::CP437) : Encoding::CP437
      string_scanner.string = data.force_encoding(encoding).encode("utf-8")

      document = new

      while next_field = Xdt::Field.parse(string_scanner.dup)
        method, klass = with_field(next_field.id) do |method,klass|
          field = klass.parse(string_scanner)
          document.send(method, field) if method
        end
      end

      document
    end
  end
end

