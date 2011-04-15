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
    old_stdout = $stdout
    old_stderr = $stderr
    $stdout = IO.new('/dev/null')
    $stderr = IO.new('/dev/null')
    yield
    $stdout = old_stdout
    $stderr = old_stderr
  end

  before(:all) do
    puts(:before_all)
    @server = new_server
    @server_thread = Thread.new { @server.run! }
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
    let(:packages_dir) { File.expand_path("features/data/ExternalDependency") }
    before(:each) { described_class.settings = {:packages_dir => packages_dir} }
    describe "/javascripts/jsus/package/Package.js" do
      let(:path) { "/javascripts/jsus/package/Package.js" }

      it "should be successful" do
        get(path).should be_successful
      end

      it "should respond with type text/javascript" do
        get(path).content_type.should == "text/javascript"
      end

      it "should respond with generated package content" do
        get(path).body.should include("script: Color.js")
        get(path).body.should include("script: Input.Color.js")
      end

      it "should include dependencies by default" do
        get(path).body.should include("script: Core.js")
      end

      it "should preserve correct order" do
        body = get(path).body
        body.index("script: Color.js").should < body.index("script: Input.Color.js")
        body.index("script: Color.js").should > body.index("script: Core.js")
      end
    end

    describe "/javascripts/jsus/require/Package/Input.Color.js" do
      let(:path) { "/javascripts/jsus/require/Package/Input.Color.js" }

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
  end

  describe "for invalid paths" do
    describe "when package is non-existent" do
      let(:path) { "/javascripts/jsus/package/randomshit.js" }
      it "should return 404" do
        get(path).should be_not_found
      end
    end

    describe "when required file is non-existent" do
      let(:path) { "/javascripts/jsus/require/randomshit.js" }
      it "should return 404" do
        get(path).should be_not_found
      end
    end
  end
end
