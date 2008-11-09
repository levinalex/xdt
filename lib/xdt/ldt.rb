# class Xdt::Ldt
#  ldt_block_type '0020', :media_start, "Datenträger Header"
#  ldt_block_type '0021', :media_end, "Datenträger Abschluss"
#  ldt_block_type '8220', :l_package_start, "L-Datenpaket-Header"
#  ldt_block_type '8221', :l_package_end,  "L-Datenpaket-Abschluss"
#  ldt_block_type '8230', :p_package_start, "P-Datenpaket-Header"
#  ldt_block_type '8231', :p_package_end, "P-Datenpaket-Abschluss"
#  ldt_block_type '8201', :lab_report, "Labor-Facharzt-Bericht"
#  ldt_block_type '8202', :lg_report, "LG-Bericht"
#  ldt_block_type '8203', :microbiology_report, "Mikrobiologie-Bericht"
#  ldt_block_type '8204', :referrer_report, "Facharzt-Bericht 'sonstige Einsendepraxen'"
#  ldt_block_type '8218', :electronic_referral, "Elektronische Überweisung"
#  ldt_block_type '8219', :lab_request, "Auftrag an eine Laborgemeinschaft"
# end

require 'date'
require 'xdt/markup'

module Xdt
  module Ldt
    module Package
    end
    
    class LGReport
      
      # only write the file if it contains any sections
      #
      def write_file(filename)
        return false unless @sections.length > 2
        
        File.open(filename, "w+") do |f|
          f.write self.to_s
        end
        
        return true
      end
      
      def section(id, &blk)
        @sections << Xdt::Section.new(id, &blk)
      end
      
      def initialize
        @sections = []
        
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

        yield self if block_given?

        section("8221") do |s|
          overhead = 44
          s.field("9202", (length + overhead).to_s.rjust(8,"0"))
        end

      end

      def length
        @sections.inject(0) { |sum, section| sum + section.length }
      end
      
      def to_s
        @sections.map { |pkg| pkg.to_s }.join
      end
      
    end
  end
end


