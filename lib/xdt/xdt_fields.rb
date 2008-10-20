require 'xdt/markup'

module Xdt
  class FieldType
    def initialize(id, name, title, length, type = :string)
      @id = id.to_i
      @name = name
      @title = title
      @type = type
    end
    
    def valid?(contents)
      true
    end
  end
  
  module FieldHandling
    def define_field(id, *args)
      @defined_fields ||= Hash.new { |h,k| raise "Redefined Field #{k}" }
      @defined_fields[id.to_i] = Xdt::FieldType.new(id, *args)
    end
  end
  
  module Fields
    def included(other)
      define_field 101, :kbv_id, "KBV-Prüfnummer", 8, :alnum

      define_field 201, :physician_id, "Arztnummer", (7..9), :num
      define_field 203, :physician_name, "Arztname", (0..60), :alnum
      define_field 204, :physician_define_field, "Arztgruppe", (0..60), :alnum
      define_field 205, :street, "Strasse", (0..60), :alnum
      define_field 206, :zip, "PLZ Ort", (0..60), :alnum

      define_field 3000, :nr, "Patientennummer/Patientenkennung", (0..10), :alnum
      define_field 3100, :name_prefix, "Namenszusatz/Vorsatzwort des Patienten", (0..15)
      define_field 3101, :last_name, "Name des Patienten", (0..28)
      define_field 3102, :first_name, "Vorname des Patienten", (0..28)
      define_field 3103, :birthday, "Geburtsdatum des Patienten", 8, :date
      define_field 3104, :title, "Titel des Patienten", (0..15)
      define_field 3105, :insurance_id, "Versichertennummer des Patienten", (0..12)
      define_field 3106, :patient_postal_code_city, "Wohnort des Patienten", (0..30)
      define_field 3107, :patient_street, "Strasse des Patienten", (0..28)
      define_field 3108, :insurance_type, "Versichertenart MFR", 1, :num
      define_field 3110, :sex, "Geschlecht des Patienten", 1, :num

      define_field 8000, :gdt_type, "Satzidentifikation", 4
      define_field 8100, :gdt_length, "Satzlänge", 5, :num
      define_field 8315, :receiver_id, "GDT-ID des Empfängers", (0..8) # violates spec, should be "8"
      define_field 8316, :sender_id, "GDT-ID des Senders", (0..8) # violates the spec, should be "8"

      define_field 9218, :gdt_version, "Version GDT", 5
    end
  end
  
  class Field
    class << self
      include Xdt::FieldHandling
    end
    
    include Xdt::Fields    

    def initialize(type, data)
      @id = type
      @data = data.to_s
    end
    
    def length
      @data.length + 9
    end
    
    def to_s
      "#{ '%03d'  % self.length }#{ '%04d' % @id.to_i }#{@data}\x0D\x0A"
    end
  end
end