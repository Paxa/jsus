require 'rack/utils'
module Jsus
  #
  # Rack middleware
  #
  # Just "use Jsus::Middleware" in your rack application and all the requests
  # to /javascripts/jsus/* are redirected to the middleware.
  #
  # Configuration:
  #
  # Use Jsus::Middleware.settings= method to change some settings, such as:
  # :packages_dir - path to where you store your packages
  # :cache - enable simple file caching
  # :cache_path - directory for file caching
  # :prefix - change /jsus/ to something else or remove it altogether (set to nil)
  # :cache_pool - cache js pool between requests. Can save you some time
  #               between requests but annoys a lot during development.
  #
  #
  # Examples:
  #
  # GET /javascripts/jsus/require/Mootools.Core+Mootools.More
  #     merges packages named Mootools.Core and Mootools.More with all the
  #     dependencies and outputs the result.
  #
  # GET /javascripts/jsus/require/Mootools.More~Mootools.Core
  #     returns package Mootools.More with all the dependencies MINUS any of
  #     Mootools.Core dependencies.
  #
  # GET /javascripts/jsus/require/Mootools.Core:Class+Mootools.More:Fx
  #     same thing but for source files providing Mootools.Core/Class and
  #     Mootools.More/Fx
  #
  #
  # Also see sinatra example https://github.com/jsus/jsus-sinatra-app
  #
  class Middleware
    include Rack
    class <<self
      DEFAULT_SETTINGS = {
        :packages_dir     => ".",
        :cache            => false,
        :cache_path       => nil,
        :prefix           => "jsus",
        :cache_pool       => true
      }.freeze

      def settings
        @@settings ||= DEFAULT_SETTINGS.dup
      end # settings

      def settings=(new_settings)
        settings.merge!(new_settings)
      end # settings=

      def pool
        @@pool ||= Jsus::Pool.new(settings[:packages_dir])
      end # pool

      def cache?
        settings[:cache]
      end # cache?

      def cache
        @@cache ||= cache? ? Util::FileCache.new(settings[:cache_path]) : nil
      end # cache
    end # class <<self

    def initialize(app)
      @app = app
    end # initialize

    def _call(env)
      path = Utils.unescape(env["PATH_INFO"])
      return @app.call(env) unless handled_by_jsus?(path)
      path.sub!(path_prefix_regex, "")
      components = path.split("/")
      return @app.call(env) unless components.size >= 2
      if components[0] == "require"
        generate(components[1])
      else
        not_found!
      end
    end # _call

    def call(env)
      dup._call(env)
    end # call

    protected

    def generate(path_string)
      path_args = parse_path_string(path_string.sub(/.js$/, ""))
      files = []
      path_args[:include].each {|tag| files += get_associated_files(tag).to_a }
      path_args[:exclude].each {|tag| files -= get_associated_files(tag).to_a }
      if !files.empty?
        response = Container.new(*files).map {|f| f.content }.join("\n")
        cache.write(path_string, response) if cache?
        respond_with(response)
      else
        not_found!
      end
    end # generate

    # Notice: + is a space after url decoding
    # input:
    # "Package:A~Package:C Package:B~Other:D"
    # output:
    # {:include => ["Package/A", "Package/B"], :exclude => ["Package/C", "Other/D"]}
    def parse_path_string(path_string)
      path_string = " " + path_string unless path_string[0,1] =~ /\+\-/
      included = []
      excluded = []
      path_string.scan(/([ ~])([^ ~]*)/) do |op, arg|
        arg = arg.gsub(":", "/")
        if op == " "
          included << arg
        else
          excluded << arg
        end
      end
      {:include => included, :exclude => excluded}
    end # parse_path_string

    def get_associated_files(source_file_or_package)
      if package = pool.packages.detect {|pkg| pkg.name == source_file_or_package}
        package.include_dependencies!
        package.linked_external_dependencies.to_a + package.source_files.to_a
      elsif source_file = pool.lookup(source_file_or_package)
        pool.lookup_dependencies(source_file).to_a << source_file
      else
        # Try using arg as mask
        mask = source_file_or_package.to_s
        if !(mask =~ /^\s*$/) && !(source_files = pool.provides_tree.glob(mask).compact).empty?
          source_files.map {|source| get_associated_files(source) }.flatten
        else
          # No dice
          []
        end
      end
    end # get_associated_files

    def not_found!
      [404, {"Content-Type" => "text/plain"}, ["Jsus doesn't know anything about this entity"]]
    end # not_found!

    def respond_with(text)
      [200, {"Content-Type" => "text/javascript"}, [text]]
    end # respond_with


    def handled_by_jsus?(path)
      path =~ path_prefix_regex
    end # handled_by_jsus?

    def path_prefix
      @path_prefix ||= self.class.settings[:prefix] ? "/javascripts/#{self.class.settings[:prefix]}/" : "/javascripts/"
    end # path_prefix

    def path_prefix_regex
      @path_prefix_regex ||= %r{^#{path_prefix}}
    end # path_prefix_regex

    def pool
      if cache_pool?
        self.class.pool
      else
        @pool ||= Jsus::Pool.new(self.class.settings[:packages_dir])
      end
    end # pool

    def cache?
      self.class.cache?
    end # cache?

    def cache
      self.class.cache
    end # cache

    def cache_pool?
      self.class.settings[:cache_pool]
    end # cache_pool?
  end # class Middleware
end # module Jsus
