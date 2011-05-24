# encoding: utf-8

module Xdt
  module Converter
    module Dicom
      class Generator
        def initialize
          @elems = []
          yield self
        end

        def element(tag,vr,data = :blank)
          if data
            data = nil if data == :blank
            @elems << "(#{tag}) #{vr}  #{data}".strip
          end
        end

        def to_s
          @elems.join("\n")
        end
      end

      def to_dicom
        text = Generator.new do |d|
          d.element("0008,0050", "SH", "00001") # AccessionNumber
          d.element("0008,0005", "CS", "[ISO_IR 100]") # SpecificCharacterSet

          d.element("0010,0010", "PN", dcm_patient_name) # PatientName
          d.element("0010,0020", "LO", self[3000])  # PatientID
          d.element("0010,0030", "DA", dcm_born_on) # PatientBirthDate
          d.element("0010,0040", "CS", dcm_sex)     # PatientSex

          # d.element("0020,000d", "UI", ["1.2.826.0.1.3680043.8.1634", "0.0", Time.now.to_i].join("."))

          d.element("0020,000d", "UI"  "1.2.276.0.7230010.3.2.102")
          d.element("0032,1032", "PN"  "NEWMAN")
          d.element("0032,1060", "LO"  "EXAM5464")

          d.element("0040,0100", "SQ")
            d.element("fffe,e000", "-")
              d.element("0008,0060", "CS", "US")

              d.element("0032,1070", "LO")
              d.element("0040,0001", "AE",  "AB45")
              d.element("0040,0002", "DA", "19960406")
              d.element("0040,0003", "TM", "160700")
              d.element("0040,0006", "PN", "ROSS")
              d.element("0040,0007", "LO", "EXAM04")
              d.element("0040,0009", "SH",  "SPD1342")
              d.element("0040,0010", "SH", "STNAB89")
              d.element("0040,0011", "SH", "B67F66")
              d.element("0040,0012", "LO")
              d.element("0040,0400", "LT")


            d.element("fffe,e00d", "-")
          d.element("fffe,e0dd", "-")
          d.element("0040,1001", "SH", "RP488M9439")
          d.element("0040,1003", "SH", "HIGH")


        end.to_s
        p text
        text
      end


      private

      def dcm_patient_name
        [self[3101], self[3102]].join("^")
      end

      def dcm_born_on
        return unless self[3103]
        date = self[3103]
        date.scan(/(\d{2})(\d{2})(\d{4})/).flatten.reverse.join
      end

      def dcm_sex
        sex = self[3110]
        case sex
          when "1" then "M"
          when "2" then "F"
          else nil
        end

      end
    end
  end
end
