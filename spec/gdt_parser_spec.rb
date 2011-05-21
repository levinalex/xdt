context "Valid GDT tokens" do
  before do
    @line = "01380006301\r\n"
  end

  specify "should parse without errors" do
    lambda { Gdt::Parser.parse(@line) }.should_not raise_error
  end

  specify "should return a hash with the correct data" do
    Gdt::Parser.parse(@line).should == {8000 => "6301"}
  end

  specify "parser should ignore empty lines" do
    result = nil
    lambda { result = Gdt::Parser.parse(" \r\n\r\n ") }.should_not raise_error
    result.should == {}
  end
end

context "Malformed data" do
  specify "should raise an exception on malformed length" do
    lambda { Gdt::Parser.parse("01480006301") }.should raise_error(Gdt::ParseError)
  end

  specify "that does not conform to the format at all should raise an exception" do
    lambda { Gdt::Parser.parse("useless garbage\r\nwith multiple lines\r\n") }.should raise_error(Gdt::ParseError)
  end
end

context "a valid Gdt file from Quincy PCNet" do
  before do
    @gdt_data = File.read(File.dirname(__FILE__) + '/examples/BARCQPCN.001')
  end

  specify "should parse without error" do
     lambda { Gdt::Parser.parse( @gdt_data ) }.should_not raise_error
  end

  specify "should contain 14 fields" do
    Gdt::Parser.parse( @gdt_data ).length.should equal(14)
  end

  specify "should contain correct data" do
    Gdt::Parser.parse(@gdt_data).should satisfy { |gdt|
      gdt[3000] == "98" && gdt[8000] == "6301" && gdt[3101] == "Sierra"
    }
  end

end
