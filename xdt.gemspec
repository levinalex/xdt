Gem::Specification.new do |s|
  s.name = %q{xdt}
  s.version = "1.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Levin Alexander"]
  s.date = %q{2008-11-09}
  s.default_executable = %q{gdt2http}
  s.description = %q{xDT is a library that reads and writes LDT, GDT and BDT data.}
  s.email = ["mail@levinalex.net"]
  s.executables = ["gdt2http"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]
  s.files = [".DS_Store", "History.txt", "Manifest.txt", "README.txt", "Rakefile", "bin/gdt2http", "lib/gdt/field_definitions.rb", "lib/gdt/field_handling.rb", "lib/gdt/parser.rb", "lib/gdt2http.rb", "lib/gdt_interface.rb", "lib/xdt.rb", "lib/xdt/ldt.rb", "lib/xdt/markup.rb", "lib/xdt/xdt_fields.rb", "lib/xdt/xdt_sections.rb", "spec/examples/BARCQPCN.001", "spec/gdt_field_definitions_spec.rb", "spec/gdt_parser_spec.rb", "spec/gdt_spec.rb", "spec/lg_report_spec.rb", "spec/xdt_spec.rb", "xdt.gemspec"]
  s.has_rdoc = true
  s.homepage = %q{http://levinalex.net/src/xdt}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{xdt}
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{xDT is a library that reads and writes LDT, GDT and BDT data.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if current_version >= 3 then
      s.add_development_dependency(%q<hoe>, [">= 1.8.0"])
    else
      s.add_dependency(%q<hoe>, [">= 1.8.0"])
    end
  else
    s.add_dependency(%q<hoe>, [">= 1.8.0"])
  end
end
