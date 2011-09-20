# encoding: utf-8

module Xdt
  module Converter
    class DicomModalityWorklist
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
          @elems.join("\n").encode("iso-8859-1")
        end
      end

      def initialize(gdt)
        @gdt = gdt

        @dcm = Generator.new do |d|
          d.element("0008,0050", "SH", "00001") # AccessionNumber
          d.element("0008,0005", "CS", "[ISO_IR 100]") # SpecificCharacterSet

          d.element("0010,0010", "PN", dcm_patient_name) # PatientName
          d.element("0010,0020", "LO", @gdt.patient_id)  # PatientID
          d.element("0010,0030", "DA", dcm_born_on) # PatientBirthDate
          d.element("0010,0040", "CS", dcm_sex)     # PatientSex

          # d.element("0020,000d", "UI", ["1.2.826.0.1.3680043.8.1634", "0.0", Time.now.to_i].join("."))

          d.element("0020,000d", "UI"  "1.2.276.0.7230010.3.2.102")
          d.element("0032,1032", "PN"  "")
          d.element("0032,1060", "LO"  "")

          d.element("0040,0100", "SQ")
            d.element("fffe,e000", "-")
              d.element("0008,0060", "CS", "US")

              d.element("0032,1070", "LO")
              d.element("0040,0001", "AE",  "AB45")
              d.element("0040,0002", "DA", Time.now.strftime("%Y%m%d"))
              d.element("0040,0003", "TM", Time.now.strftime("%H%M00"))
              d.element("0040,0006", "PN", "")
              d.element("0040,0007", "LO", "")
              d.element("0040,0009", "SH", "SPD1342")
              d.element("0040,0010", "SH", "STNAB89")
              d.element("0040,0011", "SH", "B67F66")
              d.element("0040,0012", "LO")
              d.element("0040,0400", "LT")
            d.element("fffe,e00d", "-")
          d.element("fffe,e0dd", "-")

          d.element("0040,1001", "SH", "RP488M9439")
          d.element("0040,1003", "SH", "HIGH")

        end
      end


      def to_s
        @dcm.to_s
      end


      private

      def dcm_patient_name
        [@gdt.patient_last_name, @gdt.patient_given_name].join("^")
      end

      def dcm_born_on
        return unless @gdt.patient_born_on
        @gdt.patient_born_on.strftime("%Y%m%d")
      end

      def dcm_sex
        sex = @gdt.patient_gender
        case sex
          when :male then "M"
          when :female then "F"
          else nil
        end

      end
    end
  end
end
