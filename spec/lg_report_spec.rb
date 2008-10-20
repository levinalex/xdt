
describe "creating an LG-report" do
  before do
    @lg = Xdt::Ldt::LGReport.new do |lg|
      lg.section("8202") do |s|
        s.field("8310", "12345") # Anforderungs-ID
        s.field("8301", "09062008") # Eingangsdatum im Labor
        s.field("8302", "10062008") # Berichtsdatum
        s.field("3000", "98") # PAT-ID (Nospec)
        s.field("3103", "10111982") # Geburtsdatum des Pat
        s.field("8401", "??") # Befundart

        s.field("8410", "TPO") # Test-Ident
        s.field("8411", "ANTITPO") # Testbezeichnung
        # s.field("8418", "F") # Tststatus (Fehlt, Korrigiert, Berichtigt)
        s.field("8420", "12.4")
        s.field("8421", "U/l") # Einkeit
        s.field("8480", "Ergebnistext") # Ergebnistext

      end
    end
  end
  
  it "should not raise any errors" do
    proc { @lg.to_s }.should_not raise_error
  end
  
  it "should have the correct string representation" do
    @lg.to_s.should == <<-EOF
01380008220

    EOF
  end
  
  it "should have correct length" do
    @lg.to_s[/9202\d{8}/][-8..-1].to_i.should == @lg.to_s.length
  end
end