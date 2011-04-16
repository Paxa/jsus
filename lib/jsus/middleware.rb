require 'rack/utils'
module Jsus
  class Middleware
    include Rack
    class <<self
      DEFAULT_SETTINGS = {
        :packages_dir     => ".",
        :cache            => false,
        :cache_path       => nil,
        :prefix           => "jsus"
      }.freeze

      def settings
        @settings ||= DEFAULT_SETTINGS.dup
      end # settings

      def settings=(new_settings)
        settings.merge!(new_settings)
      end # settings=

      def pool
        @pool ||= Jsus::Pool.new(settings[:packages_dir])
      end # pool
    end # class <<self

    def initialize(app)
      @app = app
    end # initialize

    def call(env)
      path = Utils.unescape(env["PATH_INFO"])
      return @app.call(env) unless handled_by_jsus?(path)
      path.sub!(path_prefix_regex, "")
      components = path.split("/")
      return @app.call(env) unless components.size >= 2
      if components[0] == "package"
        generate_package(components[1].sub(/.js$/, ""))
      elsif components[0] == "require"
        generate_by_tag(components[1..-1].join("/").sub(/.js$/, ""))
      else
        not_found!
      end
    end # call

    protected

    def not_found!
      [404, {"Content-Type" => "text/plain"}, ["Jsus doesn't anything know about this entity"]]
    end # not_found!

    def respond_with(text)
      [200, {"Content-Type" => "text/javascript"}, [text]]
    end # respond_with

    def generate_package(package_name, options = {})
      package = pool.packages.detect {|pkg| pkg.name.downcase == package_name.downcase }
      if package
        package.include_dependencies!
        respond_with(package.compile(nil))
      else
        not_found!
      end
    end # generate_package

    def generate_by_tag(tag, options = {})
      components = tag.split("/")
      components, directives = extract_directives(components, ["exclude"])
      # p [components, directives]
      tag = components.join("/")
      source_file = pool.lookup(tag)
      if source_file
        result = ""
        excluded_dependencies = []
        Array(directives["exclude"]).each do |excluded|
          excluded_dependencies.push(*[pool.lookup(excluded)].compact)
          excluded_dependencies.push(*pool.lookup_dependencies(excluded).to_a)
        end
        dependencies = pool.lookup_dependencies(source_file) - excluded_dependencies
        dependencies = Container.new(*dependencies)
        respond_with(dependencies.map {|d| d.content}.join("\n") + source_file.content)
      else
        not_found!
      end
    end # generate_by_tag

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
      self.class.pool
    end # pool

    def extract_directives(components, directives)
      resulting_directives = {}
      resulting_components = []
      i = 0
      while i < components.size do
        if !directives.include?(components[i])
          resulting_components << components[i]
        else
          j = i + 1
          directive_value = []
          while j < components.size && !directives.include?(components[j]) do
            directive_value << components[j]
            j += 1
          end
          directive = components[i]
          resulting_directives[directive] ||= []
          resulting_directives[directive] << directive_value.join("/")
          i = j - 1
        end
        i += 1
      end
      [resulting_components, resulting_directives]
    end # extract_directives
  end # class Middleware
end # module Jsus