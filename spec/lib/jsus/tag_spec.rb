require 'spec/spec_helper'

describe Jsus::Tag do
  subject { Jsus::Tag.new("Wtf") }

  context "initialization" do  
    it "should set given name" do
      Jsus::Tag.new("Wtf").name.should == "Wtf"
    end

    it "should truncate leading slash with optional period (.)" do
      Jsus::Tag.new("/Class").name.should == "Class"
    end

    it "should parse package name" do
      Jsus::Tag.new("Class").package_name.should == ""
      Jsus::Tag.new("Core/Wtf").package_name.should == "Core"
      Jsus::Tag.new("Core/Subpackage/Wtf").package_name.should == "Core/Subpackage"
    end

    it "should allow explicit package setting" do
      Jsus::Tag.new("Wtf", :package => Package.new(:name => "Core")).name.should == "Core/Wtf"
    end

    it "should set external flag if it looks like an external dependency and not given a package option" do
      Jsus::Tag.new("Core/WTF").should be_external
    end

    it "should not set external flag if it doesn't look like an external dependency and not given a package option" do
      Jsus::Tag.new("WTF").should_not be_external
    end

    it "should set external flag if package from options is not the same as parsed package" do
      Jsus::Tag.new("Core/WTF", :package => Package.new(:name => "Class")).should be_external
    end

    it "should not set external flag if package from options is the same as parsed package" do
      Jsus::Tag.new("Core/WTF", :package => Package.new(:name => "Core")).should_not be_external
    end

    it "should use implcit package setting whenever possible" do
      Jsus::Tag.new("Class/Wtf", :package => Package.new(:name => "Core")).name.should == "Class/Wtf"
    end

    it "should return a given tag if given a tag" do
      Jsus::Tag.new(subject).should == subject
    end
  end

  describe "#name" do
    it "should return full name unless asked for a short form" do
      Jsus::Tag.new("Core/Wtf").name.should == "Core/Wtf"
      Jsus::Tag.new("Core/Subpackage/Wtf").name.should == "Core/Subpackage/Wtf"
    end

    it "should not add slashes if package name is not set" do
      Jsus::Tag.new("Wtf").name.should == "Wtf"
    end

    it "should strip leading slashes" do
      Jsus::Tag.new("./Wtf").name.should == "Wtf"
    end

    it "should remove package from short form of non-external tags" do
      tag = Jsus::Tag.new("Core/WTF")
      tag.external = false
      tag.name(:short => true).should == "WTF"
    end

  end

  describe ".normalize_name_and_options" do
    it "should parse name as full name if no options given" do
      normalized = Jsus::Tag.normalize_name_and_options("Core/Wtf")
      normalized[:name].should == "Wtf"
      normalized[:package_name].should == "Core"
    end

    it "should strip leading slash" do
      Jsus::Tag.normalize_name_and_options("./Core/Wtf")[:package_name].should == "Core"
      Jsus::Tag.normalize_name_and_options("./Core/Wtf")[:name].should == "Wtf"
      Jsus::Tag.normalize_name_and_options("./Wtf")[:name].should == "Wtf"
    end

    it "should use given package name whenever no package name can be restored from name" do
      Jsus::Tag.normalize_name_and_options("Wtf", :package => Package.new(:name => "Core"))[:package_name].should == "Core"
      Jsus::Tag.normalize_name_and_options("./Wtf", :package => Package.new(:name => "Core"))[:package_name].should == "Core"
    end

    it "should parse name as full name whenever possible" do
      Jsus::Tag.normalize_name_and_options("Class/Wtf", :package => Package.new(:name => "Core"))[:package_name].should == "Class"
    end
  end

  context "comparison to other types" do
    it "should consider tags with the same full names equal" do
      Jsus::Tag.new("Core/Wtf").should == Jsus::Tag.new("Core/Wtf")
    end

    it "should work with array operations" do
      ([Jsus::Tag.new("Core/Wtf")] - [Jsus::Tag.new("Core/Wtf")]).should == []
    end
  end

  describe "#empty?" do
    it "should return true when tag is empty" do
      Jsus::Tag.new("").should be_empty
    end
    
    it "should return false when tag is not empty" do
      Jsus::Tag.new("Core/Mash").should_not be_empty
    end
  end


end