GDT_ROOT = File.dirname(File.expand_path(__FILE__))

require File.join(GDT_ROOT, 'gdt', 'parser.rb')
require File.join(GDT_ROOT, 'gdt', 'field_definitions.rb')


module Gdt
  VERSION = '0.0.8'

  class Gdt
    def initialize(string)
      @data = GdtFields.new( Parser.parse(string))
    end

    def to_hash
      @data.values
    end
  end

end
