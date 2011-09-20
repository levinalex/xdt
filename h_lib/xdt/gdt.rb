module Xdt
  class Gdt < GdtDocument
    has_field 3000, :patient_id
    has_field 3100, :patient_name_prefix
    has_field 3101, :patient_last_name
    has_field 3102, :patient_given_name
    has_field 3103, :patient_born_on, :format => :date
    has_field 3104, :patient_title
    has_field 3106, :patient_city
    has_field 3107, :patient_street
    has_field 3110, :patient_gender, :format => :gender
    has_field 8000, :type
    has_field 8315, :receiver_gdt_id
    has_field 8316, :sender_gdt_id
    has_field 9206, :charset, :format => :encoding
    has_field 9218, :version

    ignored_fields

    def to_s
      super.encode(self.charset, :invalid => :replace, :undef => :replace)
    end

    def patient_hash
      [:id, :last_name, :given_name, :gender, :name_prefix, :title, :born_on].inject({}) do |h,k|
        val = self.send("patient_#{k}")
        h[k.to_s] = val if val
        h
      end
    end

    def self.generate(*args, &block)
      new(*args, &block)
    end

    class SendPatientInformation < Gdt
      def initialize(id, last_name, given_name, born_on, &blk)
        super(6310) do |gdt|
          gdt.version = "02.10"
          gdt.patient_id = id
          gdt.patient_last_name = last_name
          gdt.patient_given_name = given_name
          gdt.patient_born_on = born_on
          yield gdt if block_given?
        end
      end
    end
  end
end

