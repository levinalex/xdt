# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'xdt/version'

Gem::Specification.new do |s|
  s.name = "xdt"
  s.version = Xdt::VERSION

  s.authors = ["Levin Alexander"]
  s.email = ["mail@levinalex.net"]

  s.summary = %q{xDT is a library that reads and writes LDT, GDT and BDT data.}
  s.description = %q{xDT is a library that reads and writes LDT, GDT and BDT data.}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  s.homepage = "http://github.com/levinalex/xdt"
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{xdt}
  s.rubygems_version = %q{1.2.0}

  s.add_dependency "json", "~> 1.4.0"
  s.add_dependency "activesupport", "~> 3.0.0"
  s.add_dependency "rake"

  s.add_development_dependency "minitest", "~> 2.2.0"
  s.add_development_dependency "webmock"
end

