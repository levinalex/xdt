require 'date'
require File.join(File.dirname(__FILE__), 'field_handling.rb')

module Gdt
  class GdtFields < AbstractField
    
    field 3000, :nr, "Patientennummer/Patientenkennung", (0..10), :alnum
    field 3100, :name_prefix, "Namenszusatz/Vorsatzwort des Patienten", (0..15)
    field 3101, :last_name, "Name des Patienten", (0..28)
    field 3102, :first_name, "Vorname des Patienten", (0..28)
    field 3103, :birthday, "Geburtsdatum des Patienten", 8, :datum
    field 3104, :title, "Titel des Patienten", (0..15)
    field 3105, :insurance_id, "Versichertennummer des Patienten", (0..12)
    field 3106, :patient_postal_code_city, "Wohnort des Patienten", (0..30)
    field 3107, :patient_street, "Strasse des Patienten", (0..28)
    field 3108, :insurance_type, "Versichertenart MFR", 1, :num
    field 3110, :sex, "Geschlecht des Patienten", 1, :num
    # ...

    field 8000, :gdt_type, "Satzidentifikation", 4
    field 8100, :gdt_length, "Satzlänge", 5, :num
    field 8315, :receiver_id, "GDT-ID des Empfängers", (0..8) # violates spec, should be "8"
    field 8316, :sender_id, "GDT-ID des Senders", (0..8) # violates the spec, should be "8"
    # ...

    field 9218, :gdt_version, "Version GDT", 5


    # bogus fields to suppress errors
    field 9901, :unknown, "unknown", (0..60), :alnum
    field 8402, :unknown, "unknown", (0..60), :alnum
    

  end
end
