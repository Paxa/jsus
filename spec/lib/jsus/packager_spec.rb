require 'spec_helper'


describe Jsus::Packager do 
  let(:simple_source)         { Source.new(:provides => [0], :dependencies => [],  :content => "// simple") }
  let(:another_simple_source) { Source.new(:provides => [1], :dependencies => [],  :content => "// simple 2") }
  let(:dependant_source)      { Source.new(:provides => [3], :dependencies => [0], :content => "// simple 3") }

  let(:simple_package)          { Jsus::Packager.new(simple_source, another_simple_source) }
  let(:package_with_dependency) { Jsus::Packager.new(dependant_source, simple_source) }

  before(:each) { cleanup }
  after(:each)  { cleanup }

  describe "initialization" do
    it "should accept sources as arguments" do
      simple_package.should have_exactly(2).sources
      simple_package.sources.should include(simple_source, another_simple_source)
    end
  end

  describe "#pack" do
    subject { Jsus::Packager.new(simple_source) }    
    it "should concatenate source files" do
      simple_package.pack.should include(simple_source.content, another_simple_source.content)
    end

    it "should output to file if given a filename" do
      simple_package.pack("spec/tmp/test.js")
      IO.read("spec/tmp/test.js").should include(simple_source.content, another_simple_source.content)
    end

    it "should resolve dependencies" do
      package_with_dependency.pack.should == "#{simple_source.content}\n#{dependant_source.content}"
    end
  end
end