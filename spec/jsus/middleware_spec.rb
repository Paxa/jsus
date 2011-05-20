require 'spec_helper'
require 'sinatra/base'
require 'rack/test'

describe Jsus::Middleware do
  include Rack::Test::Methods
  def new_server
    Sinatra.new do
      use Jsus::Middleware
      set :port, 4567
      set :raise_errors, true
      set :show_exceptions, false
      get("/") { "Ping" }
    end
  end

  def suppress_output
    old_stdout, old_stderr = $stdout, $stderr
    $stdout, $stderr = IO.new('/dev/null'), IO.new('/dev/null')
    yield
    $stdout, $stderr = old_stdout, old_stderr
  end

  before(:all) do
    @server = new_server
    @server_thread = Thread.new { suppress_output { @server.run! } }
  end

  after(:all) { @server_thread.kill }

  let(:app) { Rack::Lint.new(@server) }

  it "should not override non-jsus calls" do
    get("/").body.should == "Ping"
  end

  describe "settings" do
    it "should have some defaults" do
      described_class.settings.should be_a(Hash)
    end

    it "should merge settings, instead of full overriding on .settings=" do
      described_class.settings = {:hello => :world}
      described_class.settings = {:people => :worthless}
      described_class.settings.should include({:hello => :world, :people => :worthless})
    end
  end

  context "for basic package with an external dependency" do
    let(:packages_dir) { File.expand_path("spec/data/ComplexDependencies") }
    before(:each) { described_class.settings = {:packages_dir => packages_dir} }

    describe "/javascripts/jsus/require/Package.js" do
      let(:path) { "/javascripts/jsus/require/Package.js" }

      it "should be successful" do
        get(path).should be_successful
      end

      it "should respond with type text/javascript" do
        get(path).content_type.should == "text/javascript"
      end

      it "should respond with generated package content" do
        get(path).body.should include("script: Input.js")
        get(path).body.should include("script: Color.js")
        get(path).body.should include("script: Input.Color.js")
      end

      it "should include dependencies by default" do
        get(path).body.should include("script: Core.js")
      end

      it "should preserve correct order" do
        body = get(path).body
        body.index("script: Core.js").should < body.index("script: Color.js")
        body.index("script: Color.js").should < body.index("script: Input.Color.js")
        body.index("script: Input.js").should < body.index("script: Input.Color.js")
      end
    end

    describe "using ~Tags" do
      let(:path) { "/javascripts/jsus/require/Package~Package:Color.js" }

      it "should be successful" do
        get(path).should be_successful
      end

      it "should respond with type text/javascript" do
        get(path).content_type.should == "text/javascript"
      end

      it "should respond with generated content" do
        get(path).body.should include("script: Input.Color.js")
      end

      it "should not include dependencies mentioned in exclude directive" do
        get(path).body.should_not include("script: Color.js")
        get(path).body.should_not include("script: Core.js")
      end

      it "should not fail when used with non-existent tag" do
        result = get("/javascripts/jsus/require/Package~Package:Colorful.js")
        result.should be_successful
        result.body.should include("script: Input.Color.js")
      end

      it "should be chainable" do
        result = get("/javascripts/jsus/require/Package~Mootools:Core~Package:Input.js")
        result.should be_successful
        result.body.should include("script: Input.Color.js")
        result.body.should include("script: Color.js")
        result.body.should_not include("script: Input.js")
        result.body.should_not include("script: Core.js")
      end
    end

    describe "using +Tags" do
      let(:path) { "/javascripts/jsus/require/Package:Color+Package:Input.js" }

      it "should be successful" do
        get(path).should be_successful
      end

      it "should respond with type text/javascript" do
        get(path).content_type.should == "text/javascript"
      end

      it "should respond with generated content" do
        get(path).body.should include("script: Color.js")
        get(path).body.should include("script: Input.js")
      end

      it "should not include files not mentioned in include directive" do
        get(path).body.should_not include("script: Input.Color.js")
      end

      it "should not fail when used with non-existent tag" do
        result = get("/javascripts/jsus/require/Package:Color+Package:Colorful.js")
        result.should be_successful
        result.body.should include("script: Color.js")
      end

      it "should be chainable" do
        result = get("/javascripts/jsus/require/Package:Color+Package:Input~Mootools:Core.js")
        result.should be_successful
        result.body.should include("script: Input.js")
        result.body.should include("script: Color.js")
        result.body.should_not include("script: Input.Color.js")
        result.body.should_not include("script: Core.js")
      end
    end

    describe "/javascripts/jsus/require/Package:Input.Color.js" do
      let(:path) { "/javascripts/jsus/require/Package:Input.Color.js" }

      it "should be successful" do
        get(path).should be_successful
      end

      it "should respond with type text/javascript" do
        get(path).content_type.should == "text/javascript"
      end

      it "should respond with generated content" do
        get(path).body.should include("script: Input.Color.js")
      end

      it "should include dependencies by default" do
        get(path).body.should include("script: Color.js")
        get(path).body.should include("script: Core.js")
      end

      it "should preserve correct order" do
        body = get(path).body
        body.index("script: Color.js").should < body.index("script: Input.Color.js")
        body.index("script: Color.js").should > body.index("script: Core.js")
      end
    end


    describe "using wildcard /javascripts/jsus/require/Package:Input.*.js" do
      let(:path) { "/javascripts/jsus/require/Package:Input.*.js" }

      it "should be successful" do
        get(path).should be_successful
      end

      it "should respond with type text/javascript" do
        get(path).content_type.should == "text/javascript"
      end

      it "should respond with generated content" do
        get(path).body.should include("script: Input.Color.js")
      end

      it "should include dependencies by default" do
        get(path).body.should include("script: Color.js")
        get(path).body.should include("script: Core.js")
      end

      it "should preserve correct order" do
        body = get(path).body
        body.index("script: Color.js").should < body.index("script: Input.Color.js")
        body.index("script: Color.js").should > body.index("script: Core.js")
      end
    end

    describe "using /include/ pattern" do
      let(:path) { "/javascripts/jsus/include/Package:Input.Color.js" }

      it "should be successful" do
        get(path).should be_successful
      end

      it "should respond with type text/javascript" do
        get(path).content_type.should == "text/javascript"
      end

      it "should contain filenames for required files" do
        get(path).body.should include("/Color.js")
        get(path).body.should include("/Input.js")
        get(path).body.should include("/Input.Color.js")
      end

      it "should respect :includes_root setting" do
        old_settings = Jsus::Middleware.settings
        Jsus::Middleware.settings = {:includes_root => File.expand_path("../../data/ComplexDependencies/Mootools/Source", __FILE__)}
        get(path).body.should include("../../Source/Library/Color.js")
        Jsus::Middleware.settings = old_settings
      end
    end
  end

  describe "for invalid paths" do
    describe "when package is non-existent" do
      let(:path) { "/javascripts/jsus/require/randomshit.js" }
      it "should return 404" do
        get(path).should be_not_found
      end
    end

    describe "when required file is non-existent" do
      let(:path) { "/javascripts/jsus/require/nonexistent:randomshit.js" }
      it "should return 404" do
        get(path).should be_not_found
      end
    end

    describe "when given random gibberish" do
      let(:path) { "/javascripts/jsus/require/+++---asda~~:sda_s+__+-dr928213dasasda=d%20%32%13__=_-=--/asa/sd/.asd13/.js" }
      it "should return 404" do
        get(path).should be_not_found
      end
    end
  end

  describe "caching" do
    let(:cache_path) { "spec/tmp" }
    before(:each) { Jsus::Middleware.settings = {:cache => true, :cache_path => cache_path} }
    after(:each) { FileUtils.rm_rf(cache_path) }
    let(:path) { "/javascripts/jsus/require/Package.js" }
    it "should save output of requests to files" do
      result = get(path).body
      File.exists?("#{cache_path}/Package.js").should be_true
      File.read("#{cache_path}/Package.js").should == result
    end
  end
end
