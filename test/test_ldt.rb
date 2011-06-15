require 'helper'

describe "LDT generation" do
end


describe "LG reports" do
  describe "parsing test results" do
    before do
      @text = array_to_xdt %w(
        8410TSH
        8411TSH
        84201.46
        8460\t<\t2.5
        8421mE/l
        8410FT3
        8411FT3
        84204.50
        84603.5\t-\t8.1
        8421pmol/l
      )
      @data = StringScanner.new(@text)

      @result1 = Xdt::Ldt::TestIdent.parse(@data)
      @result2 = Xdt::Ldt::TestIdent.parse(@data)
    end

    it "should have parsed correctly" do
      assert_equal "TSH", @result1.test_ident
      assert_equal "TSH", @result1.name
      assert_equal "1.46", @result1.value
      assert_equal "mE/l", @result1.unit

      assert_equal "FT3", @result2.test_ident
      assert_equal "FT3", @result2.name
      assert_equal "4.50", @result2.value
      assert_equal "pmol/l", @result2.unit
    end
  end
end

describe "Ldt parsing" do
  before do
    @text = File.read("test/examples/ldt/e1.ldt", encoding: "ASCII-8BIT")
    @ldt = Xdt::Ldt::Document.parse(StringScanner.new(@text))
  end

  it "should serialize to itself" do
    assert_equal @text, @ldt.to_xdt
  end

  it "should have one lg report" do
    assert_equal 1, @ldt.lg_reports.length
    assert_kind_of Xdt::Ldt::LgReport, @ldt.lg_reports[0]
  end

  it "should have 4 tests in lg report" do
    assert_equal 4, @ldt.lg_reports.first.test_idents.length
    assert_equal ["TSH", "FT3", "FT4", "a-TPO"], @ldt.lg_reports.first.test_idents.map(&:name)
  end
end

