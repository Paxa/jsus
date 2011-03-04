require "spec_helper"

describe Jsus::Tree::Node do
  describe "#initialize" do
    it "should accept full path" do
      described_class.new("/path/node", nil).full_path.should == "/path/node"
    end

    it "should extract node name" do
      described_class.new("/path/node", nil).name.should == "node"
    end

    it "should set value" do
      described_class.new("/path/node", 123).value.should == 123
    end
  end

  describe "#children" do
    subject { described_class.new("/") }
    
    it "should be initialized with an empty array" do
      subject.children.should == []
    end
  end

  describe "#find_children_matching" do
    subject { described_class.new('/') }
    let(:nodes) { [] }
    before(:each) do
      # [0] /one 1
      # [1] /two 2
      # [2] /one/three 3
      # [3] /one/four 4
      nodes << subject.create_child('one', 1) << subject.create_child('two', 2)
      nodes << nodes[0].create_child('three', 3) << nodes[0].create_child('four', 4)
    end

    it "if it matches a child name, it should return that child" do
      subject.find_children_matching("one").should == [nodes[0]]
    end
    
    it "if it is *, it should return children, not containing other children" do
      subject.find_children_matching("*").should == [nodes[1]]
    end

    it "if it is **, it should return self and children, containing other children" do
      subject.find_children_matching("**").should == [subject, nodes[0]]
    end

    it "should search for occurences with wildcards" do
      nodes[0].find_children_matching("thr*").should == [nodes[2]]
    end
  end
end

describe Jsus::Tree do
  subject { Jsus::Tree.new }

  describe "#root" do
    it "should create node if needed" do
      subject.root.should be_a(Jsus::Tree::Node)
    end

    it "should not recreate node" do
      subject.root.should == subject.root
    end
  end

  describe "#insert" do
    it "should create a node and assign value to it" do
      subject.insert("/hello", "Value")
      subject.root.children.should have_exactly(1).element
      subject.root.children[0].value.should == "Value"
    end
    
    it "should create all underlying nodes if needed" do
      subject.insert("/hello/world", "value")
      subject.root.children[0].children[0].value.should == "value"
    end

    it "should replace value of existing node if it already exists" do
      subject.insert("/hello/world", "value")
      subject.insert("/hello", "other_value")
      subject.root.children.should have_exactly(1).element
      subject.root.children[0].value.should == "other_value"
      subject.root.children[0].children.should have_exactly(1).element
      subject.root.children[0].children[0].value.should == "value"
    end

    it "should not replace value of existing parent nodes" do
      subject.insert("/hello", "value")
      subject.insert("/hello/world", "other")
      subject.root.children[0].value.should == "value"
    end

    it "should return a node" do
      subject.insert("/hello/world", "value").value.should == "value"
    end
  end

  describe "#[]" do
    it "should raise error unless path starts with root" do
      lambda { subject["hello"] }.should raise_error      
    end

    it "should allow to get node by path" do
      subject.insert("/hello/world", 123)
      subject["/hello/world"].value.should == 123
    end

    it "should return nil if node is not found" do
      subject["/hello"].should be_nil
      subject["/hello/world"].should be_nil
    end
  end

  describe "#glob" do
    subject { Jsus::Tree.new }
    let(:nodes) { [] }
    before(:each) do
      nodes << subject.insert("/hello/world/one", 1) <<
               subject.insert("/hello/world/two", 2) <<
               subject.insert("/hello/three", 3)     <<
               subject.insert("/hello/four", 4)
    end

    it "should return the node if exact path is given" do
      subject.glob("/hello/four").should == [nodes[3]]
    end

    it "should return all nodes in given node AND WITHOUT CHILDREN if path with wildcard is given" do
      subject.glob("/hello/*").should =~ [nodes[2], nodes[3]]
    end

    it "should search for children matching wildcards" do
      subject.glob("/hello/thr*").should == [nodes[2]]
    end

    it "should return all nodes in all subtrees and in the given subtree if double wildcard is given" do
      subject.glob("/hello/**/*").should =~ nodes
    end

    it "should not choke when it cannot find anything" do
      subject.glob("/ololo").should == []
      subject.glob("/ololo/mwahaha").should == []
    end
  end

  describe "#traverse" do
    subject { Jsus::Tree.new }
    let(:nodes) { [] }
    before(:each) do
      nodes << subject.insert("/hello/world/one", 1) <<
               subject.insert("/hello/world/two", 2) <<
               subject.insert("/hello/three", 3)     <<
               subject.insert("/hello/four", 4)
    end

    it "should traverse only leaves by default" do
      counter = 0
      subject.traverse { counter += 1 }
      counter.should == 4
    end

    it "should traverse all nodes if given a true argument" do
      counter = 0
      subject.traverse(true) { counter += 1 }
      counter.should == 7    
    end
  end

  describe "#leaves" do
    subject { Jsus::Tree.new }
    let(:nodes) { [] }
    before(:each) do
      nodes << subject.insert("/hello/world/one", 1) <<
               subject.insert("/hello/world/two", 2) <<
               subject.insert("/hello/three", nil)     <<
               subject.insert("/hello/four", 4)
    end
    
    it "should return only the leaves with content by default" do
      subject.leaves.should =~ [nodes[0], nodes[1], nodes[3]]
    end
    
    
    it "should return all the leaves if asked" do
      subject.leaves(false).should =~ nodes
    end
    
  end

end