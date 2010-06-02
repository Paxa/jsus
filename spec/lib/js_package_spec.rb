require 'spec/spec_helper'

describe JsPackage do
  subject { JsPackage.new("spec/data/Basic/app/javascripts/Orwik") }
  before(:each) { cleanup }
  after(:all) { cleanup }
  context "initialization" do
    subject { JsPackage.new("spec/data/OutsideDependencies/app/javascripts/Orwik") }
    context "from a directory" do
      it "should load header from package.yml" do
        subject.name.should == "orwik"
        subject.filename.should == "orwik.js"
      end

      it "should set provided modules from source files" do
        subject.provides.should have_exactly(4).items
        subject.provides.should include("Color", "Input", "Input.Color", "Widget")
      end

      it "should set up outside dependencies" do
        subject.dependencies.should == ['core/Class']
      end

      it "should set up required files in correct order" do
        required_files = subject.required_files
        input_index = required_files.index {|s| s=~ /\/Input.js$/}
        color_index = required_files.index {|s| s=~ /\/Color.js$/}
        input_color_index = required_files.index {|s| s=~ /\/Input.Color.js$/}
        input_index.should < input_color_index
        color_index.should < input_color_index
      end
    end
  end

  describe "#compile" do
    it "should create a merged js package from given files" do

    end
  end
end