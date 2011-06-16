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


      def initialize(id, name, value, unit)
        super() do
          self.test_ident = id
          self.name = name
          self.value = value
          self.unit = unit
          yield self if block_given?
        end
      end
    end

    class LgReport < Xdt::Document
      has_field "8410", :test_ident, :class => TestIdent
      has_field "8000", nil, :method => nil
      has_field "8310", :request_id
      has_field "8301", :requested_on, :class => Xdt::Field::DateField
      has_field "8302", :finished_on, :class => Xdt::Field::DateField
      has_field "3000", :patient_id
      has_field "8401", :result_type

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

      def result(id, name, value, unit)
        @elements << [:foo, TestIdent.new(id, name, value, unit)]
      end

    end

    class Document < Xdt::Document
      has_field "80008202", :lg_report, :class => LgReport

      def lg_reports
        select { |f| f.kind_of?(LgReport) }
      end

      def lg_report(*args)
        report = LgReport.new(*args)
        yield report if block_given?
        @elements << ["80008202", report]
        nil
      end

      # def initialize
      #   section("8220") do |s|
      #     s.field("9211", "07/99")
      #     # s.field("0201", "") # Arztnummer
      #     s.field("0203", "Alexander")  # Arztname
      #     s.field("0204", "Nuklearmediziner") # Arztgruppe
      #     s.field("0205", "Schönhauser Allee 82") # Strasse
      #     s.field("0206", "10439 Berlin") # PLZ Ort
      #     s.field("8300", "LABOR Schoenhauser Allee 82")
      #     # s.field("0101", "") # KBV Prüfnummer
      #     s.field("9106", "3") # Charset (iso-8859-1)
      #     s.field("8312", "1") # Kundennummer
      #     s.field("9103", Date.today.strftime("%D%M%Y"))
      #   end

      #   super

      #   section("8221") do |s|
      #     s.field("9202", nil, 8) { self.length.to_s.rjust(8, "0") }
      #   end


      # end


    end
  end

end

