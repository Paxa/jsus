require 'spec_helper'

describe Jsus::Util::Inflection do
  subject { described_class }
  describe ".snake_case" do
    it "should convert HelloWorld into hello_world" do
      subject.snake_case("HelloWorld").should == "hello_world"
    end

    it "should convert hello_world into hello_world" do
      subject.snake_case("hello_world").should == "hello_world"
    end

    it "should convert 'hello world' into hello_world" do
      subject.snake_case("hello world").should == "hello_world"
    end
  end

  describe "#random_case_to_mixed_case" do
    it "should convert hello_world to HelloWorld" do
      subject.random_case_to_mixed_case("hello_world").should == "HelloWorld"
    end

    it "should convert Oh.My.God to OhMyGod" do
      subject.random_case_to_mixed_case("Oh.My.God").should == "OhMyGod"
    end

    it "should convert iAmCamelCase to IAmCamelCase" do
      subject.random_case_to_mixed_case("iAmCamelCase").should == "IAmCamelCase"
    end

    it "should convert some._Weird_..punctuation to SomeWeirdPunctuation" do
      subject.random_case_to_mixed_case("some._Weird_..punctuation").should == "SomeWeirdPunctuation"
    end
  end

  describe "#random_case_to_mixed_case_preserve_dots" do
    it "should preserve dots" do
      subject.random_case_to_mixed_case_preserve_dots("color.fx").should == "Color.Fx"
    end
  end
end
