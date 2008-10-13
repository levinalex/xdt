context "Gdt field ids should map to names" do
  field_names = { 
    # 0102
    # 0103
    # 0132
    3000 => :nr,
    3100 => :name_prefix,
    3101 => :last_name,
    3102 => :first_name,
    3103 => :birthday,
    3104 => :title,
    3105 => :insurance_id,
    3106 => :patient_postal_code_city,
    3107 => :patient_street,
    3108 => :insurance_type,
    3110 => :sex,
    # 3622
    # 3623
    # 3628
    # 6200
    8000 => :gdt_type,
    8100 => :gdt_length,
    8315 => :receiver_id,
    8316 => :sender_id,

    9218 => :gdt_version
  }
    
  field_names.each do |id, name|
    specify("#{id.to_s} => #{name.inspect}") do
      Gdt::GdtFields.lookup(id).should == name
    end
  end
end

context "Parsing a Hash with Gdt-Data" do
  setup do
    @parsed_data = Gdt::GdtFields.new( { 3000 => "98", 3101 => "Sierra", 3110 => "2" } )
  end
  
  specify "should convert field IDs to names" do
    @parsed_data.last_name.should == "Sierra"
    @parsed_data.nr.should == "98"
  end
  specify "should convert numeric fields to numbers" do
    @parsed_data.sex.should == 2
  end
end

context "Unknown field IDs" do
  setup do
    @c = Class.new(Gdt::AbstractField) do |c|
      # no fields are defined
    end
  end
  specify "should raise an error on parsing" do
    lambda { @c.new( { 42 => "data" } ) }.should raise_error(ArgumentError)
  end
end

context "Fields with a fixed length" do
  setup do
    @c = Class.new(Gdt::AbstractField) do |c|
      c.field 1, :number, "some number", 2, :num
    end
  end
  
  specify "should raise no error if the length is correct" do
    @c.new( { 1 => "03" } ).number.should == 3
  end
  specify "should raise an error if the length is to small or too long" do
    lambda { @c.new( { 1 => "0" } ) }.should raise_error(ArgumentError)
    lambda { @c.new( { 1 => "045" } ) }.should raise_error(ArgumentError)
  end
end

context "Fields with a maximum length" do
  setup do
    @c = Class.new(Gdt::AbstractField) do |c|
      c.field 1, :data, "a string", (0..21), :alnum
    end
  end

  specify "should allow empty strings" do
    @c.new( { 1 => "" } ).data.should == ""
  end
  specify "should allow fields inside the bounds" do
    lambda { @c.new( { 1 => "exactly 21 characters" } ).data }.should_not raise_error
    lambda { @c.new( { 1 => "fewer characters" } ).data }.should_not raise_error
  end
  specify "should raise an error if length is too big" do
    lambda { @c.new( { 1 => "exactly 22 characters!" } ).data }.should raise_error(ArgumentError)
  end
end

context "Date fields" do
  setup do
    @c = Class.new(Gdt::AbstractField) do |c|
      c.field 1, :data, "a date field", 8, :datum
    end
  end
  
  specify "should return an instance of the Date class" do
    @c.new( { 1 => "31011994" }).data.should == Date.parse("1994-01-31")
  end
end
