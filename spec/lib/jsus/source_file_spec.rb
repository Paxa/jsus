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
        subject.dependencies.should == []
        subject.provides.should == ["Color"]
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
      source = Jsus::SourceFile.new(:package => 1, :content => 2, :filename => 3,
                                    :relative_filename => 4, :header => 5)
      source.package.should == 1
      source.content.should == 2
      source.filename.should == 3
      source.relative_filename.should == 4
      source.header.should == 5
    end

    it "should register package in pool from constructor" do
      pool = mock("Pool")
      pool.should_receive("<<").with(instance_of(Jsus::SourceFile))
      Jsus::SourceFile.new(:pool => pool)
    end

  end

  describe "#provides" do
    it "should return the stuff it provides in full form" do
      subject.provides.should == ["Core/Chain", "Core/Events", "Core/Options"]
    end

    it "should cut package prefix if asked for short-formed provides" do
      subject.provides(:short => true).should == ["Chain", "Events", "Options"]
    end

    it "should work well when given single string instead of array" do
      subject.header["provides"] = "Mash"
      subject.provides.should == ["Core/Mash"]
    end
  end

  describe "#dependencies" do
    it "should truncate leading slash" do
      subject.dependencies.should == ["Core/Class"]
    end

    it "should cut package prefix if asked for short-formed dependencies" do
      subject.dependencies(:short => true).should == ["Class"]
    end

    it "should work well when given single string instead of array" do
      subject.header["requires"] = "Class"
      subject.dependencies.should == ["Core/Class"]
    end

    it "should not truncate package name in short form for external dependencies" do
      subject.header["requires"] = "Mash/Mash"
      subject.dependencies(:short => true).should == ["Mash/Mash"]
    end

    it "should not prepend package name in full form for external dependencies" do
      subject.header["requires"] = "Mash/Mash"
      subject.dependencies.should == ["Mash/Mash"]
    end
  end
end