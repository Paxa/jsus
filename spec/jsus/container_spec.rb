require 'spec_helper'


describe Jsus::Container do
  let(:simple_source)         { Source.new(:provides => [0], :dependencies => [],  :content => "// simple",   :filename => "/home/jsus/simple.js") }
  let(:another_simple_source) { Source.new(:provides => [1], :dependencies => [],  :content => "// simple 2", :filename => "/home/jsus/other/simple2.js") }
  let(:dependant_source)      { Source.new(:provides => [3], :dependencies => [0], :content => "// simple 3", :filename => "/home/dependencies/simple3.js") }

  let(:simple_container)        { Jsus::Container.new(simple_source, another_simple_source) }
  let(:container_with_dependency) { Jsus::Container.new(dependant_source, simple_source) }

  describe "initialization" do
    it "should accept sources as arguments" do
      simple_container.should have_exactly(2).sources
      simple_container.sources.should include(simple_source, another_simple_source)
    end
  end

  describe "#<<" do
    it "should allow multiple items via arrays" do
      container = Jsus::Container.new
      container << [simple_source, another_simple_source]
      container.should have_exactly(2).sources
    end

    it "should allow multiple items via containers" do
      container = Jsus::Container.new
      container << Jsus::Container.new(simple_source, another_simple_source)
      container.should have_exactly(2).sources
    end

  end

  describe "#sources" do
    subject { container_with_dependency }
    it "should always be sorted" do
      subject.index(simple_source).should < subject.sources.index(dependant_source)
      subject << another_simple_source
      subject.index(simple_source).should < subject.sources.index(dependant_source)
    end

    it "should not allow duplicates" do
      subject.should have_exactly(2).sources
      subject << simple_source
      subject.should have_exactly(2).sources
      subject << another_simple_source
      subject.should have_exactly(3).sources
    end

    it "should not allow nils" do
      lambda {
        subject << nil
      }.should_not raise_error
    end
  end

  describe "#required_files" do
    subject { container_with_dependency }
    it "should return includes for all the sources" do
      subject.required_files.should == [simple_source.filename, dependant_source.filename]
    end

    it "should generate routes from given root" do
      subject.required_files("/home/jsus").should == ["simple.js", "../dependencies/simple3.js"]
    end
  end

  context "lazy sorting" do
    subject { container_with_dependency.sort! }

    it "should only call topsort when it's needed" do
      subject.should_not_receive(:topsort)
      subject.sort!
      subject.each {|source| } # no-op
    end

    it "should not call topsort when adding resources" do
      subject.should_not_receive(:topsort)
      subject << simple_source
    end
    
    it "should call topsort for kicker methods" do
      subject << simple_source
      subject.should_receive(:topsort)
      subject.each {|source| }
    end
  end
end