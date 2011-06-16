module Xdt::Gdt
  class Document < Xdt::Document
    has_field 8000, :type, :method =>:set_type
    has_field 8100, nil, :method => nil # length

    has_field 3000, :patient_id
    has_field 3100, :patient_name_prefix
    has_field 3101, :patient_last_name
    has_field 3102, :patient_given_name
    has_field 3103, :patient_born_on, :class => Xdt::Field::DateField
    has_field 3104, :patient_title
    has_field 3106, :patient_city
    has_field 3107, :patient_street
    has_field 3110, :patient_gender, :class => Xdt::Field::GenderField
    has_field 8315, :receiver_gdt_id
    has_field 8316, :sender_gdt_id
    has_field 9206, :charset, :class => Xdt::Field::CharsetField
    has_field 9218, :version


    def initialize!
      super
      self.charset = Encoding::IBM437
    end

    def type
      @type
    end

    def to_xdt
      super.encode(self.charset, :invalid => :replace, :undef => :replace)
    end

    def each
      yield Xdt::Field.new("8000", @type)
      yield Xdt::Field.new("8100", nil, 5) { "%05d" % self.length }
      super
    end

    def set_type(field)
      @type = field.value
    end

    def patient_hash
      [:id, :last_name, :given_name, :gender, :name_prefix, :title, :born_on].inject({}) do |h,k|
        val = self.send("patient_#{k}")
        h[k.to_s] = val if val
        h
      end
    end
  end

  class SendPatientInformation < Xdt::Gdt::Document
    def initialize(patient_id, patient_last_name, patient_given_name, patient_born_on)
      @type = "6301"
      super() do
        self.version = "02.10"
        self.patient_id = patient_id
        self.patient_last_name = patient_last_name
        self.patient_given_name = patient_given_name
        self.patient_born_on = patient_born_on
        yield self if block_given?
      end
    end
  end
end

