require 'spec_helper'
require 'json'

describe Jsus::Package do
  subject { Jsus::Package.new(input_dir) }
  let(:input_dir) { "spec/data/Basic/app/javascripts/Orwik"}
  let(:output_dir) { "spec/data/Basic/public/javascripts/Orwik" }
  before(:each) { cleanup }
  after(:all) { cleanup }
  context "initialization" do
    let(:input_dir) { "spec/data/OutsideDependencies/app/javascripts/Orwik" }
    let(:output_dir) { "spec/data/OutsideDependencies/public/javascripts/Orwik" }
    context "from a directory" do
      it "should load header from package.yml" do
        subject.name.should == "orwik"
        subject.filename.should == "orwik.js"
      end

      it "should pass pool in options and register itself in the pool" do
        pool = Jsus::Pool.new
        package = Jsus::Package.new(input_dir, :pool => pool)
        package.pool.should == pool
        pool.packages.should include(package)
      end

      it "should set provided modules from source files" do
        subject.provides.should have_exactly(4).items        
        subject.provides_names.should include("Color", "Input", "Input.Color", "Widget")
      end

      it "should set up outside dependencies" do
        subject.dependencies_names.should == ['core/Class']
      end

      it "should set directory field" do
        subject.directory.should == File.expand_path(input_dir)
      end
    end
  end

  describe "#compile" do
    it "should create a merged js package from given files" do
      subject.compile(output_dir)
      File.exists?("#{output_dir}/orwik.js").should be_true
      compiled_content = IO.read("#{output_dir}/orwik.js")
      required_files = Dir["#{input_dir}/**/*.js"].map {|f| IO.read(f) }
      required_files.each {|f| compiled_content.should include(f)}
    end
  end

  describe "#generate_scripts_info" do
    it "should create scripts.json file containing all the info about the package" do
      subject.generate_scripts_info(output_dir)
      File.exists?("#{output_dir}/scripts.json").should be_true
      info = JSON.parse(IO.read("#{output_dir}/scripts.json"))
      info = info["Orwik"]
      info["provides"].should have_exactly(4).items
      info["provides"].should include("Color", "Widget", "Input", "Input.Color")
    end
    
    context "when external dependencies are included" do
      let(:lib_dir) { "spec/data/ChainDependencies/app/javascripts" }
      let(:pool) { Jsus::Pool.new(lib_dir) }
      subject { Jsus::Package.new("spec/data/ExternalDependencies/app/javascripts/Orwik", :pool => pool) }

      it "should show included external dependencies as provided" do
        subject.include_dependencies!
        subject.generate_scripts_info(output_dir)
        info = JSON.parse(IO.read("#{output_dir}/scripts.json"))
        info = info["Orwik"]
        info["provides"].should have_exactly(4).items
        info["provides"].should include("Test", "Hash/Hash", "Class/Class", 'Mash/Mash')
      end

      it "should not show included external dependencies as required" do
        subject.include_dependencies!
        subject.generate_scripts_info(output_dir)
        info = JSON.parse(IO.read("#{output_dir}/scripts.json"))
        info = info["Orwik"]
        info["requires"].should == ["Class"]
      end
    end
  end

  describe "#generate_tree" do
    it "should create a json file containing tree information and dependencies" do
      subject.generate_tree(output_dir)
      File.exists?("#{output_dir}/tree.json").should be_true
      tree = JSON.parse(IO.read("#{output_dir}/tree.json"))
      tree["Library"]["Color"]["provides"].should == ["Color"]
      tree["Widget"]["Widget"]["provides"].should == ["Widget"]
      tree["Widget"]["Input"]["Input"]["requires"].should == ["Widget"]
      tree["Widget"]["Input"]["Input"]["provides"].should == ["Input"]
      tree["Widget"]["Input"]["Input.Color"]["requires"].should have_exactly(2).elements
      tree["Widget"]["Input"]["Input.Color"]["requires"].should include("Input", "Color")
      tree["Widget"]["Input"]["Input.Color"]["provides"].should == ["Input.Color"]
    end
    
    it "should allow different filenames" do
      subject.generate_tree(output_dir, "structure.json")
      File.exists?("#{output_dir}/structure.json").should be_true
      tree = JSON.parse(IO.read("#{output_dir}/structure.json"))
      tree["Library"]["Color"]["provides"].should == ["Color"]
    end
  end
  
  describe "#required_files" do
   it "should list required files in correct order" do
     required_files = subject.required_files
     input_index = required_files.index {|s| s=~ /\/Input.js$/}
     color_index = required_files.index {|s| s=~ /\/Color.js$/}
     input_color_index = required_files.index {|s| s=~ /\/Input.Color.js$/}
     input_index.should < input_color_index
     color_index.should < input_color_index
   end

    it "should not include extensions" do
      required_files = Jsus::Package.new("spec/data/Extensions/app/javascripts/Orwik").required_files
      required_files.should be_empty
    end
  end

  describe "#include_dependencies!" do
    let(:lib_dir) { "spec/data/ChainDependencies/app/javascripts" }
    let(:pool) { Jsus::Pool.new(lib_dir) }
    subject { Jsus::Package.new("spec/data/ExternalDependencies/app/javascripts/Orwik", :pool => pool) }

    it "should include external dependencies into self" do
      subject.include_dependencies!
      subject.should have(3).linked_external_dependencies
      compiled = subject.compile(output_dir)
      ["Class", "Hash", "Mash"].each do |name|
        compiled.should include(IO.read("#{lib_dir}/#{name}/Source/#{name}.js"))
      end
    end
  end

  describe "#include_extensions!" do
    let(:lib_dir) { "spec/data/Extensions/app/javascripts" }
    let(:pool) { Jsus::Pool.new(lib_dir) }
    subject { Jsus::Package.new("spec/data/Extensions/app/javascripts/Core", :pool => pool) }

    it "should include extensions into source files" do
      subject.source_files[0].extensions.should be_empty
      subject.include_extensions!
      subject.source_files[0].extensions.should have_exactly(1).item
    end

  end
end