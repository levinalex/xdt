# encoding: utf-8

require 'date'

module Xdt
  module Ldt
    class LGReport < Xdt::Generator::Document
      def initialize
        section("8220") do |s|
          s.field("9211", "07/99")
          # s.field("0201", "") # Arztnummer
          s.field("0203", "Alexander")  # Arztname
          s.field("0204", "Nuklearmediziner") # Arztgruppe
          s.field("0205", "Schönhauser Allee 82") # Strasse
          s.field("0206", "10439 Berlin") # PLZ Ort
          s.field("8300", "LABOR Schoenhauser Allee 82")
          # s.field("0101", "") # KBV Prüfnummer
          s.field("9106", "3") # Charset (iso-8859-1)
          s.field("8312", "1") # Kundennummer
          s.field("9103", Date.today.strftime("%D%M%Y"))
        end

        super

        section("8221") do |s|
          overhead = 44
          s.field("9202", (length + overhead).to_s.rjust(8,"0"))
        end

      end
    end
  end
end
