require 'spec/spec_helper'
describe Jsus::Pool do
  let(:input_dir) { "spec/data/ChainDependencies/app/javascripts" }
  let(:packages) {
    [
      Jsus::Package.new("#{input_dir}/Mash",  :pool => subject),
      Jsus::Package.new("#{input_dir}/Class", :pool => subject),
      Jsus::Package.new("#{input_dir}/Hash",  :pool => subject)
    ]
  }

  let(:sources) {
    packages.map {|p| p.source_files[0] }    
  }

  subject { Jsus::Pool.new }

  context "initialization" do
    context "without any arguments" do
      subject { Jsus::Pool.new }
      it "should be available" do
        lambda {
          subject
        }.should_not raise_error
      end
    end

    context "from directory" do
      subject { Jsus::Pool.new(input_dir)}
      it "should search for packages recursively and add them to itself" do
        subject.should have_exactly(3).packages
        subject.packages.map {|p| p.name }.should include("Mash", "Hash", "Class")
      end

      it "should add all the source files to pool" do
        subject.should have_exactly(3).sources
        subject.sources.map {|s| s.provides }.flatten.should include("Mash/Mash", "Hash/Hash", "Class/Class")
      end
    end
  end


  describe "#lookup" do
    before(:each) do
      packages.each {|package| subject << package.source_files }
    end

    it "should find a source file providing given full name" do
      subject.lookup("Class/Class").should == sources[1]
    end

    it "should return nil if nothing could be found" do
      subject.lookup("Core/WTF").should be_nil
    end
  end

  describe "#lookup_direct_dependencies" do
    before(:each) do
      packages.each {|package| subject << package.source_files }
    end

    it "should return a container with direct dependencies" do
      subject.lookup_direct_dependencies("Mash/Mash").should be_a(Jsus::Container)
      subject.lookup_direct_dependencies("Mash/Mash").should == [sources[2]]
    end
  end

  describe "#lookup_dependencies" do
    before(:each) do
      packages.each {|package| subject << package.source_files }
    end

    it "should return a container with files and dependencies" do
      subject.lookup_dependencies("Mash/Mash").should == [sources[1], sources[2]]
    end
  end
end