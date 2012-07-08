module Xdt::Ldt


  class LGSection < Xdt::Parser::RawDocument
    def field(id, value, opts = {}, &block)
      @data << Xdt::Parser::XdtRow.new(id, value, opts, &block)
    end
  end

  class LGReport < Xdt::Parser::RawDocument
    def initialize(&block)
      super do |x|
        yield x
        x.section("8221") do |s|
          s.field("9202", nil, length: 8) do "%08d" % x.xdt_length end
        end
      end
    end

    def section(id, &block)
      @data << Xdt::Parser::XdtRow.new(8000,id)
      s = LGSection.new(&block)

      @data << Xdt::Parser::XdtRow.new(8100, "%05d" % (s.to_xdt.length + 27))
      @data << s
    end
  end
end
