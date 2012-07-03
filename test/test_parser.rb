require 'helper'

describe 'xdt parser' do
  describe "parsing example files" do

    before do
      @document = Xdt::Parser::RawDocument.open("test/examples/gdt2_1-1.txt")
    end

    it "should have correct type" do
      assert_equal "6301", @document[8000].value
    end

    it "should have correct patient information" do
      assert_kind_of Xdt::Patient, @document.patient
      assert_equal "Mustermann", @document.patient.last_name
      assert_equal "Franz", @document.patient.given_name
      assert_equal Date.new(1945,10,01), @document.patient.born_on
      assert_equal :male, @document.patient.gender
    end

    it "should represent patient information as a hash" do
      expected = { assigned_id: "02345",
                   last_name: "Mustermann",
                   given_name: "Franz",
                   gender: :male,
                   born_on: Date.new(1945,10,01) }

      assert_equal expected, @document.patient.to_hash
    end

  end

end
