require 'spec/spec_helper'


class Source
  attr_accessor :provides
  attr_accessor :dependencies
  attr_accessor :content

  def initialize(options = {})
    options.each do |attr, value|
      send("#{attr}=", value)
    end
  end
end


describe Jsus::Container do
  let(:simple_source)         { Source.new(:provides => [0], :dependencies => [],  :content => "// simple") }
  let(:another_simple_source) { Source.new(:provides => [1], :dependencies => [],  :content => "// simple 2") }
  let(:dependant_source)      { Source.new(:provides => [3], :dependencies => [0], :content => "// simple 3") }

  let(:simple_container)        { Jsus::Container.new(simple_source, another_simple_source) }
  let(:container_with_dependency) { Jsus::Container.new(dependant_source, simple_source) }

  describe "initialization" do
    it "should accept sources as arguments" do
      simple_container.should have_exactly(2).sources
      simple_container.sources.should include(simple_source, another_simple_source)
    end
  end

  describe "#sources" do
    subject { container_with_dependency }
    it "should always be sorted" do
      subject.sources.index(simple_source).should < subject.sources.index(dependant_source)
      subject << another_simple_source
      subject.sources.index(simple_source).should < subject.sources.index(dependant_source)
    end
  end
end