# encoding: utf-8
#
module Xdt
  module Ldt

    class TestIdent < Xdt::Document
      has_field "8410", :test_ident
      has_field "8411", :name
      has_field "8420", :value
      has_field "8421", :unit

      def self.parse(string_scanner)
        # scan until the next block
        rx = /
          [^\A]
          \r?\n?
          (?=
              (?:\d{3}8410) |
              \Z
           )
          /xm
        block = string_scanner.scan_until(rx)

        super(StringScanner.new(block))
      end
    end

    class Document < Xdt::Document
    end
  end

end

