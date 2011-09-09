# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{jsus}
  s.version = "0.3.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Mark Abramov"]
  s.date = %q{2011-06-19}
  s.default_executable = %q{jsus}
  s.description = %q{Javascript packager and dependency resolver}
  s.email = %q{markizko@gmail.com}
  s.executables = ["jsus"]
  s.extra_rdoc_files = [
    "README.md",
    "TODO"
  ]
  s.files = [
    ".document",
    ".rspec",
    ".travis.yml",
    ".yardopts",
    "CHANGELOG",
    "Gemfile",
    "Manifest",
    "README.md",
    "Rakefile",
    "TODO",
    "UNLICENSE",
    "VERSION",
    "autotest/discover.rb",
    "bin/jsus",
    "cucumber.yml",
    "features/command-line/basic_dependency_resolution.feature",
    "features/command-line/compression.feature",
    "features/command-line/extensions.feature",
    "features/command-line/external_dependency_resolution.feature",
    "features/command-line/json_package.feature",
    "features/command-line/mooforge_compatibility_layer.feature",
    "features/command-line/postproc.feature",
    "features/command-line/replacements.feature",
    "features/command-line/structure_json.feature",
    "features/data/Basic/Source/Library/Color.js",
    "features/data/Basic/Source/Widget/Input/Input.Color.js",
    "features/data/Basic/package.yml",
    "features/data/BasicWrongOrder/Source/Library/Color.js",
    "features/data/BasicWrongOrder/Source/Widget/Input/Input.Color.js",
    "features/data/BasicWrongOrder/package.yml",
    "features/data/Compression/Source/Library/Color.js",
    "features/data/Compression/Source/Widget/Input/Input.Color.js",
    "features/data/Compression/package.yml",
    "features/data/Extensions/Mootools/Source/Core.js",
    "features/data/Extensions/Mootools/package.yml",
    "features/data/Extensions/Source/Extensions/MootoolsCore.js",
    "features/data/Extensions/Source/Library/Color.js",
    "features/data/Extensions/package.yml",
    "features/data/ExternalDependency/Mootools/Source/Core.js",
    "features/data/ExternalDependency/Mootools/package.yml",
    "features/data/ExternalDependency/Source/Library/Color.js",
    "features/data/ExternalDependency/Source/Widget/Input/Input.Color.js",
    "features/data/ExternalDependency/package.yml",
    "features/data/ExternalDependencyWithExternalDependency/Leonardo/Source/Core.js",
    "features/data/ExternalDependencyWithExternalDependency/Leonardo/package.yml",
    "features/data/ExternalDependencyWithExternalDependency/Mootools/Source/Core.js",
    "features/data/ExternalDependencyWithExternalDependency/Mootools/package.yml",
    "features/data/ExternalDependencyWithExternalDependency/Source/Library/Color.js",
    "features/data/ExternalDependencyWithExternalDependency/Source/Widget/Input/Input.Color.js",
    "features/data/ExternalDependencyWithExternalDependency/package.yml",
    "features/data/JsonPackage/Source/Library/Color.js",
    "features/data/JsonPackage/Source/Widget/Input/Input.Color.js",
    "features/data/JsonPackage/package.json",
    "features/data/MooforgePlugin/Core/Source/Core.js",
    "features/data/MooforgePlugin/Core/package.yml",
    "features/data/MooforgePlugin/Plugin/Source/plugin-support.js",
    "features/data/MooforgePlugin/Plugin/Source/plugin.js",
    "features/data/MooforgePlugin/Plugin/package.yml",
    "features/data/Postprocessing/MootoolsCompat12/Source/Core.js",
    "features/data/Postprocessing/MootoolsCompat12/package.yml",
    "features/data/Postprocessing/MootoolsLtIE8/Source/Core.js",
    "features/data/Postprocessing/MootoolsLtIE8/package.yml",
    "features/data/Replacements/Mootools/Source/Core.js",
    "features/data/Replacements/Mootools/package.yml",
    "features/data/Replacements/MootoolsFork/Replacements/MootoolsCore.js",
    "features/data/Replacements/MootoolsFork/package.yml",
    "features/data/Replacements/Source/Library/Color.js",
    "features/data/Replacements/package.yml",
    "features/data/compression.min.js",
    "features/data/tmp2/package.js",
    "features/data/tmp2/scripts.json",
    "features/data/tmp2/tree.json",
    "features/step_definitions/cli_steps.rb",
    "features/support/env.rb",
    "jsus.gemspec",
    "lib/jsus.rb",
    "lib/jsus/container.rb",
    "lib/jsus/middleware.rb",
    "lib/jsus/package.rb",
    "lib/jsus/packager.rb",
    "lib/jsus/pool.rb",
    "lib/jsus/source_file.rb",
    "lib/jsus/tag.rb",
    "lib/jsus/compressor.rb",
    "lib/jsus/util.rb",
    "lib/jsus/util/code_generator.rb",
    "lib/jsus/util/documenter.rb",
    "lib/jsus/util/file_cache.rb",
    "lib/jsus/util/inflection.rb",
    "lib/jsus/util/tree.rb",
    "lib/jsus/util/validator.rb",
    "lib/jsus/util/validator/base.rb",
    "lib/jsus/util/validator/mooforge.rb",
    "markup/index_template.haml",
    "markup/stylesheet.css",
    "markup/template.haml",
    "spec/data/Basic/README",
    "spec/data/Basic/app/javascripts/Orwik/Source/Library/Color.js",
    "spec/data/Basic/app/javascripts/Orwik/Source/Widget/Input/Input.Color.js",
    "spec/data/Basic/app/javascripts/Orwik/Source/Widget/Input/Input.js",
    "spec/data/Basic/app/javascripts/Orwik/Source/Widget/Widget.js",
    "spec/data/Basic/app/javascripts/Orwik/package.yml",
    "spec/data/ChainDependencies/app/javascripts/Class/Source/Class.js",
    "spec/data/ChainDependencies/app/javascripts/Class/package.yml",
    "spec/data/ChainDependencies/app/javascripts/Hash/Source/Hash.js",
    "spec/data/ChainDependencies/app/javascripts/Hash/package.yml",
    "spec/data/ChainDependencies/app/javascripts/Mash/Source/Mash.js",
    "spec/data/ChainDependencies/app/javascripts/Mash/package.yml",
    "spec/data/ClassReplacement/Source/Class.js",
    "spec/data/ClassReplacement/package.yml",
    "spec/data/ComplexDependencies/Mootools/Source/Core.js",
    "spec/data/ComplexDependencies/Mootools/package.yml",
    "spec/data/ComplexDependencies/Output/package.js",
    "spec/data/ComplexDependencies/Output/scripts.json",
    "spec/data/ComplexDependencies/Output/tree.json",
    "spec/data/ComplexDependencies/Source/Library/Color.js",
    "spec/data/ComplexDependencies/Source/Widget/Input.js",
    "spec/data/ComplexDependencies/Source/Widget/Input/Input.Color.js",
    "spec/data/ComplexDependencies/package.yml",
    "spec/data/DependenciesWildcards/app/javascripts/Class/Source/Class.js",
    "spec/data/DependenciesWildcards/app/javascripts/Class/package.yml",
    "spec/data/DependenciesWildcards/app/javascripts/Hash/Source/Hash.js",
    "spec/data/DependenciesWildcards/app/javascripts/Hash/package.yml",
    "spec/data/DependenciesWildcards/app/javascripts/Mash/Source/Mash.js",
    "spec/data/DependenciesWildcards/app/javascripts/Mash/package.yml",
    "spec/data/Extensions/app/javascripts/Core/Source/Class.js",
    "spec/data/Extensions/app/javascripts/Core/package.yml",
    "spec/data/Extensions/app/javascripts/Orwik/Extensions/Class.js",
    "spec/data/Extensions/app/javascripts/Orwik/package.yml",
    "spec/data/ExternalDependencies/app/javascripts/Orwik/Source/Test.js",
    "spec/data/ExternalDependencies/app/javascripts/Orwik/package.yml",
    "spec/data/ExternalInternalDependencies/Core/Class/Source/Class.js",
    "spec/data/ExternalInternalDependencies/Core/Class/Source/Type.js",
    "spec/data/ExternalInternalDependencies/Core/Class/package.yml",
    "spec/data/ExternalInternalDependencies/Core/Hash/Source/Hash.js",
    "spec/data/ExternalInternalDependencies/Core/Hash/package.yml",
    "spec/data/ExternalInternalDependencies/Core/Mash/Source/Mash.js",
    "spec/data/ExternalInternalDependencies/Core/Mash/package.yml",
    "spec/data/ExternalInternalDependencies/Test/Source/Library/Color.js",
    "spec/data/ExternalInternalDependencies/Test/Source/Widget/Input/Input.Color.js",
    "spec/data/ExternalInternalDependencies/Test/Source/Widget/Input/Input.js",
    "spec/data/ExternalInternalDependencies/Test/Source/Widget/Widget.js",
    "spec/data/ExternalInternalDependencies/Test/package.yml",
    "spec/data/JsonPackage/Source/Sheet.DOM.js",
    "spec/data/JsonPackage/Source/Sheet.js",
    "spec/data/JsonPackage/Source/SheetParser.CSS.js",
    "spec/data/JsonPackage/Source/sg-regex-tools.js",
    "spec/data/JsonPackage/package.json",
    "spec/data/MooforgeValidation/README",
    "spec/data/MooforgeValidation/app/javascripts/Orwik/Source/Library/InvalidNoAuthors.js",
    "spec/data/MooforgeValidation/app/javascripts/Orwik/Source/Library/InvalidNoLicense.js",
    "spec/data/MooforgeValidation/app/javascripts/Orwik/Source/Library/Valid.js",
    "spec/data/MooforgeValidation/app/javascripts/Orwik/Source/Widget/Input/Input.Color.js",
    "spec/data/MooforgeValidation/app/javascripts/Orwik/Source/Widget/Input/Input.js",
    "spec/data/MooforgeValidation/app/javascripts/Orwik/Source/Widget/Widget.js",
    "spec/data/MooforgeValidation/app/javascripts/Orwik/package.yml",
    "spec/data/OutsideDependencies/README",
    "spec/data/OutsideDependencies/app/javascripts/Core/Source/Class/Class.Extras.js",
    "spec/data/OutsideDependencies/app/javascripts/Core/Source/Class/Class.js",
    "spec/data/OutsideDependencies/app/javascripts/Core/Source/Native/Hash.js",
    "spec/data/OutsideDependencies/app/javascripts/Core/package.yml",
    "spec/data/OutsideDependencies/app/javascripts/Orwik/Source/Library/Color.js",
    "spec/data/OutsideDependencies/app/javascripts/Orwik/Source/Widget/Input/Input.Color.js",
    "spec/data/OutsideDependencies/app/javascripts/Orwik/Source/Widget/Input/Input.js",
    "spec/data/OutsideDependencies/app/javascripts/Orwik/Source/Widget/Widget.js",
    "spec/data/OutsideDependencies/app/javascripts/Orwik/package.yml",
    "spec/data/bad_test_source_one.js",
    "spec/data/bad_test_source_two.js",
    "spec/data/mooforge_quirky_source.js",
    "spec/data/test_source_one.js",
    "spec/data/unicode_source.js",
    "spec/data/unicode_source_with_bom.js",
    "spec/jsus/container_spec.rb",
    "spec/jsus/middleware_spec.rb",
    "spec/jsus/package_spec.rb",
    "spec/jsus/packager_spec.rb",
    "spec/jsus/pool_spec.rb",
    "spec/jsus/source_file_spec.rb",
    "spec/jsus/tag_spec.rb",
    "spec/jsus/util/documenter_spec.rb",
    "spec/jsus/util/file_cache_spec.rb",
    "spec/jsus/util/inflection_spec.rb",
    "spec/jsus/util/tree_spec.rb",
    "spec/jsus/util/validator/base_spec.rb",
    "spec/jsus/util/validator/mooforge_spec.rb",
    "spec/shared/class_stubs.rb",
    "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/markiz/jsus}
  s.licenses = ["Public Domain"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{Javascript packager and dependency resolver}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 0"])
      s.add_runtime_dependency(%q<json_pure>, [">= 0"])
      s.add_runtime_dependency(%q<rgl>, [">= 0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<cucumber>, [">= 0"])
      s.add_development_dependency(%q<jeweler>, [">= 0"])
      s.add_development_dependency(%q<murdoc>, ["~> 0.1.11"])
      s.add_development_dependency(%q<ruby-debug19>, [">= 0"])
      s.add_development_dependency(%q<ruby-debug>, [">= 0"])
      s.add_development_dependency(%q<fssm>, [">= 0"])
      s.add_development_dependency(%q<yui-compressor>, [">= 0"])
      s.add_development_dependency(%q<sinatra>, [">= 0"])
      s.add_development_dependency(%q<rack-test>, [">= 0"])
      s.add_development_dependency(%q<yard>, [">= 0"])
    else
      s.add_dependency(%q<activesupport>, [">= 0"])
      s.add_dependency(%q<json_pure>, [">= 0"])
      s.add_dependency(%q<rgl>, [">= 0"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<cucumber>, [">= 0"])
      s.add_dependency(%q<jeweler>, [">= 0"])
      s.add_dependency(%q<murdoc>, ["~> 0.1.11"])
      s.add_dependency(%q<ruby-debug19>, [">= 0"])
      s.add_dependency(%q<ruby-debug>, [">= 0"])
      s.add_dependency(%q<fssm>, [">= 0"])
      s.add_dependency(%q<yui-compressor>, [">= 0"])
      s.add_dependency(%q<sinatra>, [">= 0"])
      s.add_dependency(%q<rack-test>, [">= 0"])
      s.add_dependency(%q<yard>, [">= 0"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 0"])
    s.add_dependency(%q<json_pure>, [">= 0"])
    s.add_dependency(%q<rgl>, [">= 0"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<cucumber>, [">= 0"])
    s.add_dependency(%q<jeweler>, [">= 0"])
    s.add_dependency(%q<murdoc>, ["~> 0.1.11"])
    s.add_dependency(%q<ruby-debug19>, [">= 0"])
    s.add_dependency(%q<ruby-debug>, [">= 0"])
    s.add_dependency(%q<fssm>, [">= 0"])
    s.add_dependency(%q<yui-compressor>, [">= 0"])
    s.add_dependency(%q<sinatra>, [">= 0"])
    s.add_dependency(%q<rack-test>, [">= 0"])
    s.add_dependency(%q<yard>, [">= 0"])
  end
end

