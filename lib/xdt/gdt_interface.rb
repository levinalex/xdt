GDT_ROOT = File.dirname(File.expand_path(__FILE__))

require 'xdt/gdt/parser'
require 'xdt/gdt/field_definitions'

module Gdt
  class Gdt
    def initialize(string)
      @data = GdtFields.new( Parser.parse(string))
    end

    def to_hash
      @data.values
    end
  end

end
