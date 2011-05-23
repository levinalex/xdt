require 'xdt'

describe "an XDT record with an ID and some data" do
  before do
    @field = Xdt::Generator::Field.new("8000", "8221")
  end

  it "should have a string representation that includes length and ends in CR LF" do
    @field.to_s.should == "01380008221\r\n"
  end
end


describe "fixed length field" do
  before do
    @called = false
    @field = Xdt::Generator::Field.new("8000", nil, 6) { @called = true; "content" }
  end

  it "should not call when getting length" do
    @field.length.should == 15
    @called.should == false
  end

  it "should have correct string representation" do
    @field.to_s.should == "0158000conten\r\n"
  end
end

describe "creating a XDT block" do
  before do
    @block = Xdt::Generator::Section.new("0020") do |b|
      b.field "9105", "123"
    end
  end

  it "should have a string representation where the length field exists and has the correct value" do
    @block.to_s.should == "01380000020\r\n014810000039\r\n0129105123\r\n"
  end
end

