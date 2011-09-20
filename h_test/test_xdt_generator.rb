# encoding: utf-8
require 'helper'

describe "creating a XDT block" do
  before do
    @block = Xdt::Generator::Section.new("0020") do |b|
      b.field "9105", "123"
    end
  end

  it "should have a string representation where the length field exists and has the correct value" do
    assert_equal "01380000020\r\n014810000039\r\n0129105123\r\n", @block.to_s
  end
end

