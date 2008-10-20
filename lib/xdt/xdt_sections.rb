module Xdt
  class SectionType
    def initialize(id, name, title, length, type = :string)
      @id = id.to_i
      @name = name
      @title = title
      @type = type
    end
    
    def valid?(contents)
      true
    end
  end
  
  module SectionHandling
    def define_section(id, name, title, &block)
    end
  end
  
  class Section
    class << self
      include Xdt::SectionHandling
      
      alias [] new
    end

    define_section 8220, :l_packet_header, "L-Datenpaket-Header" do |s|
      s.field [9211, 201, 203, 204, 205, 206, 8300, 101, 9106, 8312, 9103], :cardinality => '1'
      s.field 9472, :cardinality => 'n'
      s.field 9300, :cardinality => '?'
      s.field 9301, :cardinality => '?' 
    end
    
    define_section 8221, :l_packet_footer, "L-Datenpaket Abschluss" do |s|
      s.field 9202, :cardinality => '1', :default => proc { |section| section.length + 44 }
    end
    
    def initialize(type)
      @type = type
      @fields = []
      yield self if block_given?
    end
    
    def field(*args)
      @fields << Field.new(*args)
    end
    
    def length
      to_s.length
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