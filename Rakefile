$LOAD_PATH.unshift './lib'

require 'rubygems'
require 'hoe'
require 'xdt'
require 'spec/rake/spectask'

Hoe.new('xdt', Xdt::VERSION) do |p|
  p.developer('Levin Alexander', 'mail@levinalex.net')
end


Rake.application.instance_eval { @tasks["test"] = nil }

Spec::Rake::SpecTask.new do |t|
  t.warning = true
  t.spec_opts = %w(-c -f specdoc)
end
task :test => :spec


task :cultivate do
  system "touch Manifest.txt; rake check_manifest | grep -v \"(in \" | patch"
  system "rake debug_gem | grep -v \"(in \" > `basename \\`pwd\\``.gemspec"
end

