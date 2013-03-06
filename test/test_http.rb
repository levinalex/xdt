require 'helper'

describe 'http' do

  before do
    @fname = "test/examples/gdt2_1-1.txt"
    params = Map.new("output" => { "value" => STDOUT },
                     "uri" => { "value" => "http://localhost/gdt" },
                     "delete" => { "value" => nil } )

    @handler = Xdt::XdtHandler.new(params)
  end

  it "should post files" do
    result_stub = stub_request(:post, "http://localhost/gdt").
      with(:body => { "about" => { "hostname" => Socket.gethostname,
                                   "name" => Xdt.version },
                      "patient"=>{ "id" => "02345",
                                   "last_name" => "Mustermann",
                                   "given_name" => "Franz",
                                   "born_on" => "1945-10-01",
                                   "gender" => "male" }}).
      to_return(:status => 200, :body => "", :headers => {})

    @handler.handle(@fname)

    assert_requested(result_stub)
  end

end
