require 'helper'

describe "LDT generation" do

  describe "generating a minimal GDT file" do
    before do
      @ldt = Xdt::Ldt.new do |ldt|
        ldt.request_id = "123"
        ldt.patient_id = "98"
        ldt.test("456") do |t|
        end
      end
    end


    it "should have generated a minimal file" do
      expected = %w(
        80006301
      ).map { |l| "#{"%03d" % (l.length+5)}#{l}\r\n" }.join

      assert_equal expected, @ldt.to_xdt.encode("utf-8")
    end

  end

end
