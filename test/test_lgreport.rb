require 'helper'

describe 'ldt generator' do
  before do
    @expected = File.read("test/fixtures/ldt_lg_report_example.ldt")

    @lg = Xdt::Ldt::LGReport.new do |lg|
      lg.section("8220") do |s|
        s.field("9211", "07/99")
        # s.field("0201", "") # Arztnummer
        s.field("0203", "Name")  # Arztname
        s.field("0204", "Arztgruppe") # Arztgruppe
        s.field("0205", "Street") # Strasse
        s.field("0206", "12345 Berlin") # PLZ Ort
        s.field("8300", "LABOR")
        # s.field("0101", "") # KBV Prüfnummer
        s.field("9106", "3") # Charset (iso-8859-1)
        s.field("8312", "1") # Kundennummer
        s.field("9103", Date.today.strftime("%D%M%Y"))
      end
      lg.section("8202") do |s|
        s.field("8310", "12345") # Anforderungs-ID
        s.field("8301", "09062008") # Eingangsdatum im Labor
        s.field("8302", "10062008") # Berichtsdatum
        s.field("3000", "98") # PAT-ID (Nospec)
        s.field("3103", "10111982") # Geburtsdatum des Pat
        s.field("8401", "E") # Befundart

        s.field("8410", "TPO") # Test-Ident
        s.field("8411", "ANTITPO") # Testbezeichnung
        s.field("8418", "K") # Tststatus (Fehlt, Korrigiert, Berichtigt)
        s.field("8420", "12.4")
        s.field("8421", "U/l") # Einkeit
        s.field("8480", "Ergebnistext") # Ergebnistext
      end
    end
  end

  it "should have generated correct data" do
    assert_equal @expected, @lg.to_xdt
  end

end
