require 'spec/spec_helper'

describe JsBundler do
  subject { JsBundler.new("spec/data/Basic/") }

  context "initialization" do
    context "from a directory" do
      subject { JsBundler.new("spec/data/Basic/") }
      it "should load packages" do
        pending
        subject.packages.map {|p| p.name}.should == ["orwik"]
      end
    end
  end

  describe "#loaded_files" do
    it "should return an array with correctly sorted loaded files"
  end

  describe "#compile" do
    it "should generate script.json file with all the dependencies and provides for each package"
    it "should generate js file for every package"
  end

  describe "#generate_tree" do
    it "should generate tree.json file"
  end
end