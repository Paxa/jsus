require 'spec/spec_helper'
describe Jsus::Pool do
  let(:input_dir) { "spec/data/ChainDependencies/app/javascripts" }
  let(:packages) {
    [
      Jsus::Package.new("#{input_dir}/Mash"),
      Jsus::Package.new("#{input_dir}/Class"),
      Jsus::Package.new("#{input_dir}/Hash")
    ]
  }

  let(:sources) {
    packages.map {|p| p.source_files[0] }
  }

  subject { Jsus::Pool.new }

  before(:each) do
    packages.each {|package| subject << package.source_files }
  end

  describe "#lookup" do
    it "should find a source file providing given full name" do
      subject.lookup("Class/Class").should == sources[1]
    end

    it "should return nil if nothing could be found" do
      subject.lookup("Core/WTF").should be_nil
    end
  end

  describe "#lookup_direct_dependencies" do
    it "should return a container with direct dependencies" do
      subject.lookup_direct_dependencies("Mash/Mash").should be_a(Jsus::Container)
      subject.lookup_direct_dependencies("Mash/Mash").should == [sources[2]]
    end

    it "should return results in array if asked" do
      subject.lookup_direct_dependencies("Mash/Mash", :as => :array).should be_an(Array)
      subject.lookup_direct_dependencies("Mash/Mash").should == [sources[2]]
    end
  end

  describe "#lookup_dependencies" do
    it "should return a container with files and dependencies" do
      subject.lookup_dependencies("Mash/Mash").should == [sources[1], sources[2]]
    end
  end
end