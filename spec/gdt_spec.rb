require 'lib/xdt/gdt_interface.rb'

context "reading GDT data from a file" do
  def read_file
    Gdt::Gdt.new(File.read('./spec/examples/BARCQPCN.001'))
  end

  specify "should work without errors" do
    lambda { Gdt::Gdt.new(File.read('./spec/examples/BARCQPCN.001')) }.should_not raise_error
  end

  specify "data should be representable as a hash" do
    read_file.to_hash.should be_instance_of(Hash)
  end
end
