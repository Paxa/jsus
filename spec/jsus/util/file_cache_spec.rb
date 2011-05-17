# encoding: utf-8
require 'spec_helper'
require 'fileutils'

describe Jsus::Util::FileCache do
  subject { described_class.new(cache_dir) }
  let(:key) { "random-key-#{rand(1000000)}" }
  let(:value) { "Hello, world!" }
  let(:cache_dir) { File.expand_path("spec/tmp") }
  after(:each) { FileUtils.rm_rf(cache_dir) }
  describe "#write" do
    it "should create a file with given contents and return the filename" do
      fn = subject.write(key, value)
      File.exists?(fn).should be_true
    end

    it "should not write to relative paths" do
      FileUtils.rm_f("/tmp/test")
      key = "../../../../../../../../../../../../../../../../tmp/test"
      fn = subject.write(key, value)
      File.exists?("/tmp/test").should be_false
    end
  end

  describe "#read" do
    it "should return filename of file for given cache key" do
      fn = subject.write(key, value)
      subject.read(key).should == fn
    end

    it "should return nil if cache is empty" do
      subject.read(key).should == nil
    end

    it "should not read from relative paths" do
      key = "../../../../../../../../../../../../../../../../tmp/test"
      File.open("/tmp/test", "w+") {|f| f.puts "Hello, world!" }
      subject.read(key).should == nil
    end
  end

  describe "#fetch" do
    it "should return filename with given cached data if it already exists" do
      fn = subject.write(key, value)
      subject.fetch(key) { "Hello, world!" }.should == fn
      File.read(fn).should == value
    end

    it "should write data to cache if it isn't there yet" do
      fn = subject.fetch(key) { value }
      File.read(fn).should == value
    end
  end

  describe "#delete" do
    it "should delete file with cached data for given key" do
      fn = subject.write(key, value)
      File.exists?(fn).should be_true
      subject.delete(key)
      File.exists?(fn).should be_false
    end

    it "should not do anything if data for given key isn't there yet" do
      lambda { subject.delete(key) }.should_not raise_error
    end
  end
end
