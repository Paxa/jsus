require 'spec/spec_helper'

describe JsSourceFile do
  context "initialization" do
    context "from file" do
      subject { JsSourceFile.from_file('spec/data/test_source_one.js') }
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
          JsSourceFile.from_file('spec/data/bad_test_source_one.js').should == nil
          JsSourceFile.from_file('spec/data/bad_test_source_two.js').should == nil
        end
      end

      context "when file does not exist" do
        it "should return nil" do
          JsSourceFile.from_file('spec/data/non-existant-file.js').should == nil
        end
      end
    end
  end
end