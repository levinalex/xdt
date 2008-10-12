require 'rubygems'
require 'hoe'
require './lib/xdt.rb'
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
