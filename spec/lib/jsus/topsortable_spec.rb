require 'spec/spec_helper'

class SortableItem
  attr_accessor :value
  attr_accessor :dependencies
  attr_accessor :provides
  def initialize(value)
    @value = value
    @provides = [value]
  end
end

class SortableClass
  include Jsus::Topsortable
  attr_accessor :items
end

describe Jsus::Topsortable do
  subject { SortableClass.new }
  let(:items) { (0..5).map {|i| SortableItem.new(i) } }
  let(:topsorted_values) { subject.topsort_items.map {|item| item.value } }
  before(:each) do
    subject.items = items
  end

  it "should topologically sort items correctly" do
    items[0].dependencies = [1, 2, 3]
    items[1].dependencies = [3, 4, 5]
    items[2].dependencies = [1, 3, 4, 5]
    items[3].dependencies = []
    items[4].dependencies = [3, 5]
    items[5].dependencies = [3]
    topsorted_values.should == [3, 5, 4, 1, 2, 0]
  end

  it "should play well with multiple provides case" do
    items[0].dependencies = [2, 3]
    items[0].provides     = [0, 10 ,20, 30]
    items[1].dependencies = [10, 30]
    items[1].provides     = [1, 21]
    items[2].dependencies = []
    items[2].provides     = [2, 32, 42]
    items[3].dependencies = [42]
    items[3].provides     = [3, 43, 53]
    items[4].dependencies = [21]
    items[4].provides     = [4, 44]
    items[5].dependencies = [43, 32, 44]
    items[5].provides     = [5, 55]
    topsorted_values.should == [2, 3, 0, 1, 4, 5]
  end
end