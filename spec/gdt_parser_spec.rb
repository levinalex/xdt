# encoding: utf-8

require 'erb'

describe "Valid GDT tokens" do
  before do
    @line = "01380006301\r\n"
  end

  specify "should parse without errors" do
    lambda { Xdt::Parser.parse(@line) }.should_not raise_error
  end

  specify "should return a hash with the correct data" do
    Xdt::Parser.parse(@line).to_hash.should == {8000 => "6301"}
  end

  specify "parser should ignore empty lines" do
    result = nil
    lambda { result = Xdt::Parser.parse(" \r\n\r\n ") }.should_not raise_error
    result.should be_blank
  end
end

# context "Malformed data" do
#   specify "should raise an exception on malformed length" do
#     lambda { Xdt::Parser.parse("01480006301") }.should raise_error(Xdt::ParseError)
#   end
#
#   specify "that does not conform to the format at all should raise an exception" do
#     lambda { Xdt::Parser.parse("useless garbage\\r\\nwith multiple lines\\r\\n") }.should raise_error(Xdt::ParseError)
#   end
# end

describe "a valid Gdt file from Quincy PCNet" do
  before do
    @gdt_data = File.read(File.dirname(__FILE__) + '/examples/BARCQPCN.001')
  end

  specify "should parse without error" do
     lambda { Xdt::Parser.parse( @gdt_data ) }.should_not raise_error
  end


  describe "parsing" do
    before do
      @xdt = Xdt::Parser.parse( @gdt_data )
    end

    it "should contain 14 fields" do
      @xdt.to_hash.length.should equal(14)
    end

    it "should contain correct data" do
      expected = { 8000 => "6301",
        8100 => "00228",
        8315 => "Barcode",
        8316 => "QPCnet",
        9218 => "02.00",
        3000 => "98",
        3101 => "Sierra",
        3102 => "Rudolph",
        3103 => "13041928",
        3105 => "123 130328",
        3106 => "4000 Düsseldorf 12",
        3107 => "Richard-Wagner-Str. 11",
        3108 => "3",
        3110 => "1" }

      @xdt.to_hash.should satisfy { |gdt|
        gdt[3000] == "98" && gdt[8000] == "6301" && gdt[3101] == "Sierra"
        gdt.should == expected
      }
    end

    it "should have a dicom representation" do
      @xdt.to_dicom.should be_instance_of String
    end

    it "should have correct dicom representation" do
      text = File.read("spec/examples/BARCQPCN.dump.expected.erb")
      expected = ERB.new(text).result.to_s.strip
      @xdt.to_dicom.should == expected
    end
  end
end

