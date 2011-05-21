$LOAD_PATH.unshift './lib'

require 'bundler'
Bundler::GemHelper.install_tasks

require 'xdt'
require 'spec/rake/spectask'

Spec::Rake::SpecTask.new do |t|
  t.warning = true
  t.spec_opts = %w(-c -f specdoc)
end
task :test => :spec
task :default => :test

