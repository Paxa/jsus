require 'spec/spec_helper'
describe Jsus::Pool do
  let(:package) { Jsus::Package.new("spec/data/OutsideDependencies/app/javascripts/Core") }
  subject { Jsus::Pool.new }

  before(:each) do
    subject << package.source_files
  end

  describe "#lookup" do
    it "should find a source file providing given full name" do
      subject.lookup("Core/Hash").should be_kind_of(Jsus::SourceFile)
    end

    it "should return nil if nothing could be found" do
      subject.lookup("Core/WTF").should be_nil
    end
  end
end