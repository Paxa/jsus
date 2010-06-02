require 'spec/spec_helper'

describe JsBundler do
  subject { JsBundler.new(input_dir) }
  let(:input_dir) { "spec/data/Basic/app/javascripts" }
  let(:output_dir) { "spec/data/Basic/public/javascripts" }
  before(:each) { cleanup }
  after(:all) { cleanup }
  context "initialization" do
    context "from a directory" do
      subject { JsBundler.new("spec/data/Basic/") }
      it "should load packages" do
        subject.packages.map {|p| p.name}.should == ["orwik"]
        subject.packages.map {|p| p.relative_directory }.should == ["Orwik"]
      end
    end
  end

  describe "#required_files" do
    it "should return an array with correctly sorted required files" do
      files = subject.required_files
      color_index = files.find_index {|f| f =~ /\/Color.js/}
      input_index = files.find_index {|f| f =~ /\/Input.js/}
      input_color_index = files.find_index {|f| f =~ /\/Input.Color.js/}
      color_index.should < input_color_index
      input_index.should < input_color_index
    end
  end

  describe "#compile" do
    it "should generate scripts.json file with all the dependencies and provides for each package" do
      subject.compile(output_dir)
      File.exists?("#{output_dir}/Orwik/scripts.json").should be_true
    end
    
    it "should generate js file for each package" do
      subject.compile(output_dir)
      File.exists?("#{output_dir}/Orwik/orwik.js").should be_true
    end

    it "should generate tree.json file for each package" do
      subject.compile(output_dir)
      File.exists?("#{output_dir}/Orwik/tree.json").should be_true
    end
  end
end