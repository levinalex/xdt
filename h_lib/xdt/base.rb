require 'set'

module Xdt
  ENCODINGS = { 1 => Encoding::US_ASCII, 2 => Encoding::IBM437, 3 => Encoding::ISO8859_1 }

  module ClassMethods

    def has_field(id, name, opts = {})
      @@fields ||= {}
      @@fields[id] = name

      converter = TYPES[opts[:format]]

      define_method name do
        val = get(id)
        val = converter[:read].call(val) if converter
        val
      end

      define_method "#{name}=" do |val|
        val = converter[:write].call(val) if converter
        set(id, val)
      end
    end

    def defined_field(id)
      @@fields ||= {}
      @@fields[id]
    end

    def ignored_fields(*ids)
      @@ignored ||= Set.new
      @@ignored |= ids
    end

    def ignored?(id)
      @@ignored.include?(id)
    end
  end


  class GdtDocument < Generator::Section
    extend ClassMethods

    def set(*args)
      field(*args)
    end

    def get(id)
      k, v = elements.find { |(i,v)| i == id }
      v && v.data
    end


    def self.parse(string)
      @gdt = new do |gdt|
        Parser.parse(string) do |field, value|
          next if ignored?(field)

          gdt.set(field, value)
        end
      end

      @gdt
    end

  end
end

