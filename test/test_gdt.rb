# encoding: utf-8

require 'helper'

describe "parsing a GDT file" do
  before do
    @text = "01480006301\r\n014810000228\r\n0168315Foo\r\n0153101Sierra\r\n"
    @gdt = Xdt::Gdt::Document.parse(StringScanner.new(@text))
  end

  it "should have correct type" do
    assert_equal "6301", @gdt.type
  end

  it "should not store length field" do
    assert_equal nil, @gdt.first("8100")
  end

  it "should have correct length when serializing" do
    @expected = %w(
      80006301
      810000054
      8315Foo
      3101Sierra
    ).map { |l| "#{"%03d" % (l.length+5)}#{l}\r\n" }.join

    assert_equal 54, @gdt.to_xdt.length
    assert_equal @expected, @gdt.to_xdt
  end
end

describe "GDT parser" do
  before do
    @text = File.read("test/examples/qpcn.gdt", encoding: "ASCII-8BIT")
    @gdt = Xdt::Gdt::Document.parse(StringScanner.new(@text))
  end

  it "should not raise" do
    assert @gdt
  end

  it "should have correct patient information" do
    assert_equal "Sierra", @gdt.patient_last_name
    assert_equal "Rudolph", @gdt.patient_given_name
  end

  it "should serialize to itself" do
    assert_equal @text.force_encoding("cp437"), @gdt.to_xdt
  end

  # it "should have correct dicom representation" do
  #   text = File.read("test/examples/qpcn.mwl.expected.erb")
  #   expected = ERB.new(text).result.to_s.strip
  #   assert_equal expected, Xdt::Converter::DicomModalityWorklist.new(@gdt).to_s
  # end

  describe "when data is changed" do
    before do
      @old_length = @gdt.to_xdt.match(/8100(\d+)/)[1].to_i
      @gdt.patient_last_name = "Peter"
    end

    it "should have had correct length before" do
      assert_equal 228, @old_length
    end

    it "should contain changed name" do
      assert_match(/3101Peter\r\n/, @gdt.to_xdt)
    end

    it "should not contain original name" do
      assert_nil(@gdt.to_xdt =~ /Sierra/)
    end

    it "should have updated length" do
      assert_match(/014810000#{@old_length - 1}/, @gdt.to_xdt)
    end

    it "should reencode output when setting charset" do
      @gdt.charset = "cp437"
      assert_match(Regexp.new("D\\x81sseldorf".force_encoding("ASCII-8BIT")), @gdt.to_xdt.force_encoding("ASCII-8BIT"))
      @gdt.charset = "iso-8859-1"
      assert_match(Regexp.new("D\\xfcsseldorf".force_encoding("ASCII-8BIT")), @gdt.to_xdt.force_encoding("ASCII-8BIT"))
    end
  end
end

describe "generating a minimal gdt file" do
  before do
    @gdt = Xdt::Gdt::SendPatientInformation.new("98", "Sierra", "Rudolph", Date.new(1960,3,12))
  end

  it "should generate an object" do
    assert @gdt
  end

  it "should have a defined gdt version" do
    assert_equal "02.10", @gdt.version
  end

  it "should return born_on as a date" do
    assert_equal Date.new(1960,3,12), @gdt.patient_born_on
  end

  it "should have CP437 charset" do
    assert_equal Encoding::CP437, @gdt.charset
  end

  it "should have type of 6301" do
    assert_equal "6301", @gdt.type
  end

  it "should serialize to a minimal GDT file" do
    expected = %w(
      01380006301
      014810000100
      014921802.10
      011300098
      0153101Sierra
      0163102Rudolph
      017310312031960
    ).map { |l| l + "\r\n" }.join

    assert_equal expected, @gdt.to_xdt
  end
end

describe "generating a complete GDT file" do
  before do
    @gdt = Xdt::Gdt::SendPatientInformation.new("123", "Lastname", "Firstname", Date.new(1958,12,24)) do |gdt|
      gdt.receiver_gdt_id = "RCV"
      gdt.sender_gdt_id = "SNDR"
      gdt.charset = "CP437"
      gdt.patient_name_prefix = "Freiherr von"
      gdt.patient_title = "Dr."
      gdt.patient_city = "12345 Ort"
      gdt.patient_street = "Челло Iñtërnâtiônàlizætiøn"
      gdt.patient_gender = :male
    end
  end

  it "should generate correct data" do
    expected = %w(
        80006301
        810000236
        92062
        921802.10
        3000123
        3101Lastname
        3102Firstname
        310324121958
        8315RCV
        8316SNDR
        3100Freiherr\ von
        3104Dr.
        310612345\ Ort
        3107?????\ Iñtërnâtiônàlizæti?n
        31101
    ).map { |l| "#{"%03d" % (l.length+5)}#{l}\r\n" }.join

    assert_equal expected, @gdt.to_xdt.encode("utf-8")
  end

  it "should have patient hash" do
    expected = { "id" => "123",
      "last_name" => "Lastname",
      "given_name" => "Firstname",
      "gender" => :male,
      "name_prefix" => "Freiherr von",
      "title" => "Dr.",
      "born_on" => Date.new(1958,12,24) }
    assert_equal expected, @gdt.patient_hash

  end
end

Dir["test/examples/**/*.gdt.txt"].each do |f|

  describe "parsing example file #{f}" do
    before do
      @text = File.read(f).force_encoding("ASCII-8BIT")
      @gdt = Xdt::Gdt::Document.parse(StringScanner.new(@text))
    end

    it "should extract patient information correctly" do
      @expected = File.read(f.gsub("gdt.txt", "expected.txt"))
      assert_equal JSON.load(@gdt.patient_hash.to_json), JSON.load(@expected)
    end
  end
end


