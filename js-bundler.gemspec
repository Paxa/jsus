# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{js-bundler}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Markiz, idea by Inviz (http://github.com/Inviz)"]
  s.date = %q{2010-06-03}
  s.default_executable = %q{js-bundle}
  s.description = %q{Bundler/compiler for js-files that resolves dependencies and can compile everything into one file, providing all the neccessary meta-info.}
  s.email = %q{markizko@gmail.com}
  s.executables = ["js-bundle"]
  s.extra_rdoc_files = ["CHANGELOG", "LICENSE", "README", "bin/js-bundle", "lib/js-bundler.rb", "lib/js_bundler.rb", "lib/js_bundler/bundler.rb", "lib/js_bundler/package.rb", "lib/js_bundler/source_file.rb"]
  s.files = ["CHANGELOG", "LICENSE", "Manifest", "README", "Rakefile", "bin/js-bundle", "js-bundler.gemspec", "lib/js-bundler.rb", "lib/js_bundler.rb", "lib/js_bundler/bundler.rb", "lib/js_bundler/package.rb", "lib/js_bundler/source_file.rb", "spec/data/Basic/README", "spec/data/Basic/app/javascripts/Orwik/Source/Library/Color.js", "spec/data/Basic/app/javascripts/Orwik/Source/Widget/Input/Input.Color.js", "spec/data/Basic/app/javascripts/Orwik/Source/Widget/Input/Input.js", "spec/data/Basic/app/javascripts/Orwik/Source/Widget/Widget.js", "spec/data/Basic/app/javascripts/Orwik/package.yml", "spec/data/OutsideDependencies/README", "spec/data/OutsideDependencies/app/javascripts/Core/Source/Class/Class.Extras.js", "spec/data/OutsideDependencies/app/javascripts/Core/Source/Class/Class.js", "spec/data/OutsideDependencies/app/javascripts/Core/Source/Native/Hash.js", "spec/data/OutsideDependencies/app/javascripts/Core/package.yml", "spec/data/OutsideDependencies/app/javascripts/Orwik/Source/Library/Color.js", "spec/data/OutsideDependencies/app/javascripts/Orwik/Source/Widget/Input/Input.Color.js", "spec/data/OutsideDependencies/app/javascripts/Orwik/Source/Widget/Input/Input.js", "spec/data/OutsideDependencies/app/javascripts/Orwik/Source/Widget/Widget.js", "spec/data/OutsideDependencies/app/javascripts/Orwik/package.yml", "spec/data/bad_test_source_one.js", "spec/data/bad_test_source_two.js", "spec/data/test_source_one.js", "spec/lib/js_bundler/bundler_spec.rb", "spec/lib/js_bundler/package_spec.rb", "spec/lib/js_bundler/source_file_spec.rb", "spec/spec.opts", "spec/spec_helper.rb"]
  s.homepage = %q{http://github.com/markiz/js-bundler}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Js-bundler", "--main", "README"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{js-bundler}
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Bundler/compiler for js-files that resolves dependencies and can compile everything into one file, providing all the neccessary meta-info.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 0"])
      s.add_runtime_dependency(%q<json_pure>, [">= 0"])
      s.add_runtime_dependency(%q<rgl>, [">= 0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
    else
      s.add_dependency(%q<activesupport>, [">= 0"])
      s.add_dependency(%q<json_pure>, [">= 0"])
      s.add_dependency(%q<rgl>, [">= 0"])
      s.add_dependency(%q<rake>, [">= 0"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 0"])
    s.add_dependency(%q<json_pure>, [">= 0"])
    s.add_dependency(%q<rgl>, [">= 0"])
    s.add_dependency(%q<rake>, [">= 0"])
  end
end
