require 'spec_helper'

describe Jsus::Util::Validator::Mooforge do
  describe "#validate" do
    let(:input_dir) { "spec/data/MooforgeValidation/app/javascripts/Orwik/Source/Library" }
    let!(:sources) {
      ["Valid.js", "InvalidNoAuthors.js", "InvalidNoLicense.js"].map {|fn| Jsus::SourceFile.from_file("#{input_dir}/#{fn}") }
    }

    it "should return true for valid files" do
      described_class.validate([sources[0]]).should be_true
      described_class.new([sources[0]]).validation_errors.should == []
    end

    it "should return false for files without authors" do
      described_class.validate([sources[1]]).should be_false
      described_class.new([sources[1]]).validation_errors[0].should include(sources[1].filename)
    end

    it "should return false for files without license" do
      described_class.validate([sources[2]]).should be_false
      described_class.new([sources[2]]).validation_errors[0].should include(sources[2].filename)
    end

    it "should return false when some of the files fail" do
      described_class.validate(sources).should be_false
      described_class.new(sources).validation_errors.size.should == 2
    end
  end
end
