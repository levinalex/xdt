require 'date'
require 'iconv'

module Gdt

  class GdtField < Struct.new(:name, :description, :length, :type, :rules)
    TYPES = {
      :num => lambda { |v| v.to_i },
      :alnum => lambda { |v| ::Iconv.new("UTF-8","CP850").iconv(v) },
      :datum => lambda { |v| ::Date.new(*v.scan(/(..)(..)(....)/)[0].map {|x| x.to_i }.reverse) rescue nil }
    }

    def type=(value)
      raise ArgumentError, "unrecognized data type '#{value.inspect}'" unless TYPES.include?(value)
      @type = value
    end
    def type
      @type || :alnum
    end

    def length=(value)
      if value
        @length = (Range === value) ? value : Range.new(value,value)
      else
        @length = nil
      end
    end

    def verify_and_convert(value)
      # check length
      #
      if @length
        message = "the field #{name.inspect} does not have the correct length, expected (#{@length.inspect})"
        # ignore length checks for now
        # raise ArgumentError, message unless @length.include?(value.length)
      end
      TYPES[self.type].call(value)
    end

  end

  class AbstractField
    
    def self.field(gdt_id, name, description, length, type = :alnum, rules = nil) 
      field = (fields[gdt_id] ||= GdtField.new)

      field.name = name
      field.type = type
      field.length = length

      define_method name do
        values[name]
      end
    end

    def self.lookup(field_id)
      @gdt_fields[field_id].name
    end
    def self.fields
      @gdt_fields ||= Hash.new
    end

    def values
      @values ||= Hash.new
    end

    def set_field(gdt_id, value)
      field = self.class.fields[gdt_id]
      raise ArgumentError, "undefined field '#{gdt_id}'" unless field

      values[field.name] = field.verify_and_convert(value)
    end

    def initialize(gdt_hash)
      gdt_hash.each { |gdt_id, value|
        set_field(gdt_id, value)
      }
    end
  end
end

