# encoding: utf-8

require 'xdt/app/gdt2http'
require 'webmock/rspec'
require 'tmpdir'

context "gdt2http" do
  before do
    @app = Xdt::App::Gdt2Http
  end

  it "should work" do
    dir = Dir.mktmpdir
    FileUtils.cp("spec/examples/BARCQPCN.001", File.join(dir, "EXAMPLE.GDT"))

    expected = {
             8000 => "6301",
             8100 => "00228",
             8315 => "Barcode",
             8316 => "QPCnet",
             9218 => "02.00",
             3000 => "98",
             3101 => "Sierra",
             3102 => "Rudolph",
             3103 => "13041928",
             3105 => "123 130328",
             3106 => "4000 Düsseldorf 12",
             3107 => "Richard-Wagner-Str. 11",
             3108 => "3",
             3110 => "1" }

    stub_http_request(:post, "foo.local/bar").
      to_return(:status => 200, :body => "", :headers => {}).
      with(:body => expected.to_json)

    @app.new.run!(%W(--uri http://foo.local/bar --files #{dir}/*.GDT))

  end

end
