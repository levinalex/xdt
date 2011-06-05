$LOAD_PATH.unshift './lib'

require 'bundler'
Bundler::GemHelper.install_tasks

require 'xdt'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new do |t|
end

task :test => :spec
task :default => :test

