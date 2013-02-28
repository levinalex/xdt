# -*- encoding: utf-8 -*-
require File.expand_path('../lib/xdt/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Levin Alexander"]
  gem.email         = ["mail@levinalex.net"]
  gem.description   = "read/write GDT/LDT files"
  gem.summary       = "read/write GDT/LDT files"

  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "xdt"
  gem.require_paths = ["lib"]
  gem.version       = Xdt::VERSION

  gem.add_dependency "gli", "~> 2.0.0.rc4"
  gem.add_dependency "rake"
  gem.add_dependency "directory_watcher"
  gem.add_dependency "rest-client"
  gem.add_dependency "json"

  gem.add_development_dependency "minitest"
end
