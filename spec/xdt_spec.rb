require 'lib/xdt'

describe "an XDT record with an ID and some data" do
  before do
    @field = Xdt::Field.new("8000", "8221")
  end

  it "should have a string representation that includes length and ends in CR LF" do
    @field.to_s.should == "01380008221\r\n"
  end
end

describe "creating a XDT block" do
  before do
    @block = Xdt::Section.new("0020") do |b|
      b.field "9105", "123"
    end
  end

  it "should have a string representation where the length field exists and has the correct value" do
    @block.to_s.should == "01380000020\r\n014810000039\r\n0129105123\r\n"
  end
end
