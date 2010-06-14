require 'spec/spec_helper'

describe Jsus::SourceFile do
  before(:each) { cleanup }
  after(:all) { cleanup }
  let(:package) { Package.new(:name => "Core") }
  subject { Jsus::SourceFile.from_file("spec/data/OutsideDependencies/app/javascripts/Core/Source/Class/Class.Extras.js", :package => package) }
  context "initialization" do
    context "from file" do
      subject { Jsus::SourceFile.from_file('spec/data/test_source_one.js') }
      it "should parse json header" do
        subject.dependencies_names.should == ["Class"]
        subject.provides_names.should == ["Color"]
        subject.description.should == "A library to work with colors"
      end

      it "should set filename field to expanded file name" do
        subject.filename.should == File.expand_path("spec/data/test_source_one.js")
      end

      context "when format is invalid" do
        it "should return nil" do
          Jsus::SourceFile.from_file('spec/data/bad_test_source_one.js').should == nil
          Jsus::SourceFile.from_file('spec/data/bad_test_source_two.js').should == nil
        end
      end

      context "when file does not exist" do
        it "should return nil" do
          Jsus::SourceFile.from_file('spec/data/non-existant-file.js').should == nil
        end
      end
    end

    it "should set all available fields from constructor" do
      source = Jsus::SourceFile.new(:package           => package,
                                    :content           => subject.content,
                                    :filename          => subject.filename,
                                    :relative_filename => subject.relative_filename,
                                    :header            => subject.header)
      source.package.should           == package
      source.content.should           == subject.content
      source.filename.should          == subject.filename
      source.relative_filename.should == subject.relative_filename
      source.header.should            == subject.header
    end

  end

  context "when no package set, " do
    subject { Jsus::SourceFile.from_file("spec/data/test_source_one.js") }
    describe "#package" do
      it "should return nil" do
        subject.package.should be_nil
      end
    end

    describe "#provides_names" do
      it "should return names without leading slash in both forms" do
        subject.provides_names.should == ["Color"]
        subject.provides_names(:short => true).should == ["Color"]
      end
    end

    describe "#dependencies_names" do
      it "should return names without leading slash in both forms" do
        subject.dependencies_names.should == ["Class"]
        subject.dependencies_names(:short => true).should == ["Class"]
      end
    end
    
    describe "#external_dependencies" do
      it "should be empty" do
        subject.external_dependencies.should be_empty
      end
    end
    
    describe "#external_dependencies_names" do
      it "should be empty" do
        subject.external_dependencies_names.should be_empty
      end
    end
  end

  context "when it is in package, " do
    let(:package) { Jsus::Package.new("spec/data/ExternalDependencies/app/javascripts/Orwik") }
    subject { package.source_files[0] }
    describe "#package" do
      it "should return the package" do
        subject.package.should == package
      end
    end

    describe "#provides_names" do
      it "should prepend package name by default and when explicitly asked for long form" do
        subject.provides_names.should == ["Orwik/Test"]
        subject.provides_names(:short => false).should == ["Orwik/Test"]
      end

      it "shouldn't prepend package name in short form" do
        subject.provides_names(:short => true).should == ["Test"]
      end
    end

    describe "#dependencies_names" do
      it "should prepend package names to inner dependencies by default and when explicitly asked for long form" do
        subject.should have_exactly(2).dependencies_names
        subject.dependencies_names.should include("Orwik/Class", "Mash/Mash")
        subject.should have_exactly(2).dependencies_names(:short => false)
        subject.dependencies_names(:short => false).should include("Orwik/Class", "Mash/Mash")
      end

      it "should not prepend package names to inner dependencies in short form" do
        subject.should have_exactly(2).dependencies_names(:short => true)
        subject.dependencies_names(:short => true).should include("Class", "Mash/Mash")
      end
    end
    
    describe "#external_dependencies" do
      it "should include external dependencies" do 
        subject.should have_exactly(1).external_dependencies
        subject.external_dependencies.should include(Jsus::Tag["Mash/Mash"])
      end
      
      it "should not include internal dependencies" do
        subject.external_dependencies.should_not include(Jsus::Tag["Orwik/Class"])
      end
    end
    
    describe "#external_dependencies_names" do
      it "should include names of external dependencies" do
        subject.external_dependencies_names.should include("Mash/Mash")
      end

      it "should not include names of internal dependencies" do
        subject.external_dependencies_names.should_not include("Orwik/Class")
      end
    end
    
  end

  context "when pool is not set, " do
    subject { Jsus::SourceFile.from_file("spec/data/Extensions/app/javascripts/Core/Source/Class.js", :package => Package.new(:name => "Core")) }
    describe "#pool" do
      it "should return nil" do
        subject.pool.should be_nil
      end
    end

    describe "#include_extensions!" do
      it "should do nothing" do
        lambda {
          subject.include_extensions!
        }.should_not change(subject, :extensions)
      end
    end
  end

  context "when pool is set, " do
    let(:pool) { Jsus::Pool.new("spec/data/Extensions/app/javascripts") }
    subject { Jsus::SourceFile.from_file("spec/data/Extensions/app/javascripts/Core/Source/Class.js", :pool => pool, :package => Package.new(:name => "Core")) }
    describe "#pool" do
      it "should return the pool" do
        subject.pool.should == pool
      end
    end

    context "and there are extensions for subject in its pool, " do
      describe "#include_extensions!" do
        it "should add all extensions to @extensions" do
          subject.extensions.should be_empty
          subject.include_extensions!
          subject.extensions.should have_exactly(1).item
        end
      end
    end

    context "and there are no extensions for subject in its pool, " do
      let(:pool) { Jsus::Pool.new }
      describe "#include_extensions!" do
        it "should add all extensions to @extensions" do
          lambda {
            subject.include_extensions!
          }.should_not change(subject, :extensions)
        end
      end
    end
  end

  context "when it is not an extension, " do
    subject { Jsus::SourceFile.from_file("spec/data/Extensions/app/javascripts/Core/Source/Class.js") }

    describe "#extension?" do
      it "should return false" do
        subject.should_not be_an_extension
      end
    end
  end

  context "when it is an extension, " do
    subject { Jsus::SourceFile.from_file("spec/data/Extensions/app/javascripts/Orwik/Extensions/Class.js") }

    describe "#extension?" do
      it "should return true" do
        subject.should be_an_extension
      end
    end
  end

  context "when there are no extensions, " do
    let(:input_dir) { "spec/data/Extensions/app/javascripts" }
    subject { Jsus::SourceFile.from_file("#{input_dir}/Core/Source/Class.js")}

    describe "#required_files" do
      it "should have only the filename itself" do
        subject.required_files.should == [subject.filename]
      end
    end
  end

  context "when there are extensions, " do
    let(:input_dir) { "spec/data/Extensions/app/javascripts" }
    let(:extension) { Jsus::SourceFile.from_file("#{input_dir}/Orwik/Extensions/Class.js") }
    subject { Jsus::SourceFile.from_file("#{input_dir}/Core/Source/Class.js")}
    let(:initial_content) { subject.content }
    before(:each) { initial_content; subject.extensions << extension }

    describe "#required_files" do
      it "should include source_file filename itself" do
        subject.required_files.should include(subject.filename)
      end

      it "should include extensions filenames" do
        subject.required_files.should include(extension.filename)
      end

      it "should put the subject's filename first" do
        subject.required_files[0].should == subject.filename
      end
    end

    describe "#content" do
      it "should have extensions applied to the initial file content" do
        subject.content.should_not == initial_content
        subject.content.index(initial_content).should_not be_nil
        subject.content.index(extension.content).should_not be_nil
        subject.content.index(initial_content).should < subject.content.index(extension.content)
      end
    end
  end
end