#!/usr/bin/env rake
require "bundler/gem_tasks"

$LOAD_PATH.unshift './lib'
require 'xdt'

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'test'
end

task :default => :test

