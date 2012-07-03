# -*- encoding: utf-8 -*-
require File.expand_path('../lib/xdt/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Levin Alexander"]
  gem.email         = ["mail@levinalex.net"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "xdt"
  gem.require_paths = ["lib"]
  gem.version       = Xdt::VERSION

  gem.add_dependency "thor"
  gem.add_dependency "rake"
  gem.add_dependency "directory_watcher"
  gem.add_dependency "rev"
  gem.add_dependency "rest-client"

  gem.add_development_dependency "minitest"
end
