require 'helper'

describe "Xdt" do
  it "should have correct version" do
    assert_equal "2.1.0", Xdt::VERSION
  end
end

describe "an XDT record with an ID and some data" do
  before do
    @field = Xdt::Field.new("8000", "8221")
  end

  it "should have a string representation that includes length and ends in CR LF" do
    assert_equal "01380008221\r\n", @field.to_xdt
  end
end

describe "fixed length field" do
  before do
    @called = false
    @field = Xdt::Field.new("8000", nil, 6) { @called = true; "content" }
  end

  it "should not call when getting length" do
    assert_equal 15, @field.length
    assert_equal false, @called
  end

  it "should have correct string representation" do
    assert_equal "0158000content\r\n", @field.to_xdt
  end
end

describe "date fields" do
  it "should parse from string" do
    @text = "017310301021934\r\n"
    @field = Xdt::Field::DateField.parse(StringScanner.new(@text))
    assert_equal Date.new(1934,2,1), @field.value
    assert_equal "3103", @field.id
    assert_equal @text, @field.to_xdt
  end
end


describe "reading Xdt Fields" do
  describe "with data in a string scanner" do
    before do
      @data = StringScanner.new("01380006301\r\n014810000228")
      @field1 = Xdt::Field.parse(@data)
      @field2 = Xdt::Field.parse(@data)
    end

    it "should create Fields with correct data" do
      assert_kind_of Xdt::Field, @field1
      assert_equal "8000", @field1.id
      assert_equal "6301", @field1.value
      assert_equal "00228", @field2.value
    end

    it "should have read up to EOF" do
      assert @data.eos?
    end
  end
end

describe "reading a document" do
  before do
    @text = File.read("test/examples/qpcn.gdt", encoding: "CP437")
    @scanner = StringScanner.new(@text)
    @xdt = Xdt::Document.parse(@scanner)
  end

  it "should return a document" do
    assert_kind_of Xdt::Document, @xdt
  end

  it "should leave scanner at EOS" do
    assert_equal true, @scanner.eos?
  end

  it "should make parsed fields accessible" do
    assert_kind_of Xdt::Field, @xdt.first("8000")
    assert_equal "6301", @xdt.first("8000").value
    assert_equal "Sierra", @xdt.first("3101").value
  end

  it "should return nil for nonexisting fields" do
    assert_nil @xdt.first("9999")
  end

  it "should serialize to itself" do
    assert_equal @text.encode("utf-8"), @xdt.to_xdt.encode("utf-8")
  end

end

