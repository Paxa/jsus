require 'spec_helper'

describe Jsus::Util::Logger do
  subject { described_class.new("/dev/null") }

  context "buffering" do
    it "should store incoming messages in the buffer" do
      subject.info "Something happened"
      subject.buffer.should == [[Logger::INFO, "Something happened"]]
    end

    it "should not store messages not crossing the threshold" do
      subject.level = Logger::FATAL
      subject.info "Something happened"
      subject.buffer.should == []
    end

    it "should allow block form logging" do
      subject.info { "Something happened" }
      subject.buffer.should == [[Logger::INFO, "Something happened"]]
    end
  end # context "buffering"
end
