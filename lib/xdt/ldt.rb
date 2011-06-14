# encoding: utf-8
#
module Xdt
  module Ldt
    class TestIdent < Xdt::Document
      has_field "8410", :test_ident
      has_field "8411", :name
      has_field "8420", :value
      has_field "8421", :unit

      def id
        "8410"
      end

      def self.parse(string_scanner)
        # scan until the next block
        rx = /
          [^\A]
          (?=
              (?:\r\n\d{3}8410) |
              \Z
           )
          /xm
        block = string_scanner.scan_until(rx)

        super(StringScanner.new(block))
      end
    end

    class LgReport < Xdt::Document
      has_field "8410", :test_ident, :class => TestIdent
      has_field "8000", nil, :method => nil

      def id
        "80008202"
      end

      def test_idents
        select { |f| f.kind_of?(TestIdent) }
      end

      def each
        yield Xdt::Field.new("8000", "8202")
        # yield Xdt::Field.new("8100", nil, 5) { "%05d" % self.length }
        super
      end

    end

    class Document < Xdt::Document
      has_field "80008202", :section, :class => LgReport

      def lg_reports
        select { |f| f.kind_of?(LgReport) }
      end
    end
  end

end

