# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{jsus}
  s.version = "0.1.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Markiz, idea by Inviz (http://github.com/Inviz)"]
  s.date = %q{2010-08-30}
  s.default_executable = %q{jsus}
  s.description = %q{Packager/compiler for js-files that resolves dependencies and can compile everything into one file, providing all the neccessary meta-info.}
  s.email = %q{markizko@gmail.com}
  s.executables = ["jsus"]
  s.extra_rdoc_files = ["CHANGELOG", "LICENSE", "README", "TODO", "bin/jsus", "lib/jsus.rb", "lib/jsus/container.rb", "lib/jsus/package.rb", "lib/jsus/packager.rb", "lib/jsus/pool.rb", "lib/jsus/source_file.rb", "lib/jsus/tag.rb"]
  s.files = ["CHANGELOG", "LICENSE", "Manifest", "README", "Rakefile", "TODO", "bin/jsus", "jsus.gemspec", "lib/jsus.rb", "lib/jsus/container.rb", "lib/jsus/package.rb", "lib/jsus/packager.rb", "lib/jsus/pool.rb", "lib/jsus/source_file.rb", "lib/jsus/tag.rb", "spec/data/Basic/README", "spec/data/Basic/app/javascripts/Orwik/Source/Library/Color.js", "spec/data/Basic/app/javascripts/Orwik/Source/Widget/Input/Input.Color.js", "spec/data/Basic/app/javascripts/Orwik/Source/Widget/Input/Input.js", "spec/data/Basic/app/javascripts/Orwik/Source/Widget/Widget.js", "spec/data/Basic/app/javascripts/Orwik/package.yml", "spec/data/ChainDependencies/app/javascripts/Class/Source/Class.js", "spec/data/ChainDependencies/app/javascripts/Class/package.yml", "spec/data/ChainDependencies/app/javascripts/Hash/Source/Hash.js", "spec/data/ChainDependencies/app/javascripts/Hash/package.yml", "spec/data/ChainDependencies/app/javascripts/Mash/Source/Mash.js", "spec/data/ChainDependencies/app/javascripts/Mash/package.yml", "spec/data/Extensions/app/javascripts/Core/Source/Class.js", "spec/data/Extensions/app/javascripts/Core/package.yml", "spec/data/Extensions/app/javascripts/Orwik/Extensions/Class.js", "spec/data/Extensions/app/javascripts/Orwik/package.yml", "spec/data/ExternalDependencies/app/javascripts/Orwik/Source/Test.js", "spec/data/ExternalDependencies/app/javascripts/Orwik/package.yml", "spec/data/ExternalInternalDependencies/Core/Class/Source/Class.js", "spec/data/ExternalInternalDependencies/Core/Class/Source/Type.js", "spec/data/ExternalInternalDependencies/Core/Class/package.yml", "spec/data/ExternalInternalDependencies/Core/Hash/Source/Hash.js", "spec/data/ExternalInternalDependencies/Core/Hash/package.yml", "spec/data/ExternalInternalDependencies/Core/Mash/Source/Mash.js", "spec/data/ExternalInternalDependencies/Core/Mash/package.yml", "spec/data/ExternalInternalDependencies/Test/Source/Library/Color.js", "spec/data/ExternalInternalDependencies/Test/Source/Widget/Input/Input.Color.js", "spec/data/ExternalInternalDependencies/Test/Source/Widget/Input/Input.js", "spec/data/ExternalInternalDependencies/Test/Source/Widget/Widget.js", "spec/data/ExternalInternalDependencies/Test/package.yml", "spec/data/OutsideDependencies/README", "spec/data/OutsideDependencies/app/javascripts/Core/Source/Class/Class.Extras.js", "spec/data/OutsideDependencies/app/javascripts/Core/Source/Class/Class.js", "spec/data/OutsideDependencies/app/javascripts/Core/Source/Native/Hash.js", "spec/data/OutsideDependencies/app/javascripts/Core/package.yml", "spec/data/OutsideDependencies/app/javascripts/Orwik/Source/Library/Color.js", "spec/data/OutsideDependencies/app/javascripts/Orwik/Source/Widget/Input/Input.Color.js", "spec/data/OutsideDependencies/app/javascripts/Orwik/Source/Widget/Input/Input.js", "spec/data/OutsideDependencies/app/javascripts/Orwik/Source/Widget/Widget.js", "spec/data/OutsideDependencies/app/javascripts/Orwik/package.yml", "spec/data/bad_test_source_one.js", "spec/data/bad_test_source_two.js", "spec/data/test_source_one.js", "spec/lib/jsus/container_spec.rb", "spec/lib/jsus/package_spec.rb", "spec/lib/jsus/packager_spec.rb", "spec/lib/jsus/pool_spec.rb", "spec/lib/jsus/source_file_spec.rb", "spec/lib/jsus/tag_spec.rb", "spec/shared/class_stubs.rb", "spec/spec_helper.rb"]
  s.homepage = %q{http://github.com/markiz/jsus}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Jsus", "--main", "README"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{jsus}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Packager/compiler for js-files that resolves dependencies and can compile everything into one file, providing all the neccessary meta-info.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 0"])
      s.add_runtime_dependency(%q<json_pure>, [">= 0"])
      s.add_runtime_dependency(%q<rgl>, [">= 0"])
      s.add_runtime_dependency(%q<choice>, [">= 0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
    else
      s.add_dependency(%q<activesupport>, [">= 0"])
      s.add_dependency(%q<json_pure>, [">= 0"])
      s.add_dependency(%q<rgl>, [">= 0"])
      s.add_dependency(%q<choice>, [">= 0"])
      s.add_dependency(%q<rake>, [">= 0"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 0"])
    s.add_dependency(%q<json_pure>, [">= 0"])
    s.add_dependency(%q<rgl>, [">= 0"])
    s.add_dependency(%q<choice>, [">= 0"])
    s.add_dependency(%q<rake>, [">= 0"])
  end
end
