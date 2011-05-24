# encoding: utf-8

module Xdt
  module Converter
    module Dicom
      class Generator
        def initialize
          @elems = []
          yield self
        end

        def element(tag,vr,data)
          return unless data
          @elems << "(#{tag}) #{vr}  #{data}"
        end

        def to_s
          @elems.join("\n")
        end
      end

      def to_dicom
        Generator.new do |d|
          d.element("0008,0050", "SH", "00000") # AccessionNumber
          d.element("0008,0005", "CS", "[ISO_IR 100]") # SpecificCharacterSet

          d.element("0010,0010", "PN", dcm_patient_name) # PatientName
          d.element("0010,0020", "LO", self[3000])  # PatientID
          d.element("0010,0030", "DA", dcm_born_on) # PatientBirthDate
          d.element("0010,0040", "CS", dcm_sex)     # PatientSex
          d.element("0020,000d", "UI", ["1.2.826.0.1.3680043.8.1634", "0.0", Time.now.to_i].join("."))
        end.to_s
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
