require 'rack/utils'
module Jsus
  #
  # Jsus rack middleware.
  #
  # Usage
  # -----
  #
  # `use Jsus::Middleware` in your rack application and all the requests
  # to /javascripts/jsus/* will be redirected to the middleware.
  #
  # Example requests
  # ----------------
  #
  # <dt>`GET /javascripts/jsus/require/Mootools.Core+Mootools.More`</dt>
  # <dd>merges packages named Mootools.Core and Mootools.More with all the
  # dependencies and outputs the result.</dd>
  #
  # <dt>`GET /javascripts/jsus/require/Mootools.More~Mootools.Core`</dt>
  # <dd>returns package Mootools.More with all the dependencies MINUS any of
  # Mootools.Core dependencies.</dd>
  #
  # <dt>`GET /javascripts/jsus/require/Mootools.Core:Class+Mootools.More:Fx`</dt>
  # <dd>same thing but for source files providing Mootools.Core/Class and
  # Mootools.More/Fx</dd>
  #
  # <dt>`GET /javascripts/jsus/include/Mootools.Core`</dt>
  # <dd>generates js file with remote javascript fetching via ajax</dd>
  #
  # @see .settings=
  # @see https://github.com/jsus/jsus-sinatra-app Sinatra example (Github)
  # @see https://github.com/jsus/jsus-rails-app Rails example (Github)
  #
  class Middleware
    include Rack
    class << self
      # Default settings for Middleware
      DEFAULT_SETTINGS = {
        :packages_dir     => ".",
        :cache            => false,
        :cache_path       => nil,
        :prefix           => "jsus",
        :cache_pool       => true,
        :includes_root    => ".",
        :log_method       => nil # :alert, :html, :console, nil
      }.freeze
      
      @@errors = []
      def errors; @@errors; end

      def formated_errors
        return '' unless settings[:log_method]
        
        self.errors.map do |error|
          case settings[:log_method]
            when :alert then "alert(#{error.inspect});"
            when :console then "console.log(#{error.inspect});"
            when :html then "document.body.innerHTML = '<font color=red>' + #{error.inspect} + '</font><br/>' + document.body.innerHTML;"
          end
        end.join("\n") + "\n"
      end
      
      # @return [Hash] Middleware current settings
      # @api public
      def settings
        @@settings ||= DEFAULT_SETTINGS.dup
      end # settings

      # *Merges* given new settings into current settings.
      #
      # @param [Hash] new_settings
      # @option new_settings [String, Array] :packages_dir directory (or array
      #    of directories) containing source files.
      # @option new_settings [Boolean] :cache enable file caching (every request
      #    is written into corresponding file). Note, that it's write-only cache,
      #    you will have to configure your webserver to serve these files.
      # @option new_settings [String] :cache_path path to cache directory
      # @option new_settings [String, nil] :prefix path prefix to use for
      #    request. You can change default "jsus" to anything else or disable it
      #    altogether.
      # @option new_settings [Boolean] :cache_pool whether to cache pool between
      #    requests. Cached pool means that updates to your source files will not
      #    be visible until you restart webserver.
      # @option new_settings [String] :includes_root when generating "includes"
      #    lists, this is the point in filesystem used as relative root.
      # @api public
      def settings=(new_settings)
        settings.merge!(new_settings)
      end # settings=

      # Generates and caches a pool of source files and packages.
      #
      # @return [Jsus::Pool]
      # @api public
      def pool
        @@pool ||= Jsus::Pool.new(settings[:packages_dir])
      end # pool

      # @return [Boolean] whether caching is enabled
      # @api public
      def cache?
        settings[:cache]
      end # cache?

      # @return [Jsus::Util::FileCache] file cache to store results of requests.
      # @api public
      def cache
        @@cache ||= cache? ? Util::FileCache.new(settings[:cache_path]) : nil
      end # cache
    end # class <<self

    # Default rack initialization routine
    # @param [#call] app rack chain caller
    # @api public
    def initialize(app)
      @app = app
    end # initialize

    # Since rack apps are used as singletons and we store some state during
    # request handling, we need to separate state between different calls.
    #
    # Jsus::Middleware#call method dups current rack app and executes
    # Jsus::Middleware#_call on it.
    #
    # @param [Hash] env rack env
    # @return [#each] rack response
    # @api semipublic
    def _call(env)
      self.class.errors.clear
      
      path = Utils.unescape(env["PATH_INFO"])
      return @app.call(env) unless handled_by_jsus?(path)
      path.sub!(path_prefix_regex, "")
      components = path.split("/")
      return @app.call(env) unless components.size >= 2
      if components[0] == "require"
        generate_requires(components[1])
      elsif components[0] == "compressed"
        generate_requires(components[1], :compress => true, :prefix => components[0])
      elsif components[0] == "include"
        generate_includes(components[1], :prefix => components[0])
      else
        not_found!
      end
    end # _call

    # Rack calling point
    #
    # @param [Hash] env rack env
    # @return [#each] rack response
    # @api public
    def call(env)
      dup._call(env)
    end # call

    protected

    # Generates response for /require/ requests.
    #
    # @param [String] path_string path component to required sources
    # @return [#each] rack response
    # @api semipublic
    def generate_requires(path_string, options = {})
      files = path_string_to_files(path_string)
      if !files.empty?
        response = Container.new(*files).map {|f| f.content }.join("\n")
        
        response = Jsus::Compressor.new(response).result if options[:compress]

        cache.write(escape_path_for_cache_key("#{options[:prefix]}/#{path_string}"), response) if cache?
        respond_with(response)
      else
        not_found!
      end
    end # generate_requires

    # Generates response for /include/ requests.
    #
    # @param [String] path_string path component to included sources
    # @return [#each] rack response
    # @api semipublic
    def generate_includes(path_string)
      files = path_string_to_files(path_string)
      if !files.empty?
        paths = Container.new(*files).required_files(self.class.settings[:includes_root])
        respond_with(Jsus::Util::CodeGenerator.generate_includes(paths))
      else
        not_found!
      end
    end # generate_includes

    # Returns list of exlcuded and included source files for given path strings.
    #
    # @param [String] path_string string with + and ~
    # @return [Hash] hash with source files to include and to exclude
    # @api semipublic
    def path_string_to_files(path_string)
      path_args = parse_path_string(path_string.sub(/.js$/, ""))
      files = []
      path_args[:include].each {|tag| files += get_associated_files(tag).to_a }
      path_args[:exclude].each {|tag| files -= get_associated_files(tag).to_a }
      files
    end # path_string_to_files

    def postproc(source)
      [self.class.settings[:postproc]].flatten.each do |processor|
        case processor.strip
        when /^moocompat12$/i
          source.gsub!(/\/\/<1.2compat>.*?\/\/<\/1.2compat>/m, '')
          source.gsub!(/\/\*<1.2compat>\*\/.*?\/\*<\/1.2compat>\*\//m, '')
        when /^mooltie8$/i
          source.gsub!(/\/\/<ltIE8>.*?\/\/<\/ltIE8>/m, '')
          source.gsub!(/\/\*<ltIE8>\*\/.*?\/\*<\/ltIE8>\*\//m, '')
        else
          self.class.errors << "Unknown post-processor: #{processor}"
        end
      end
    end

    # Parses human-readable string with + and ~ operations into a more usable hash.
    # @note + is a space after url decoding
    #
    # @example
    #     parse_path_string("Package:A~Package:C Package:B~Other:D")
    #        => {:include => ["Package/A", "Package/B"],
    #            :exclude => ["Package/C", "Other/D"]}
    # @api semipublic
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

    # Returns a list of associated files for given source file or source package.
    # @param [String] source_file_or_package canonical source file or source
    #    package name or wildcard. E.g. "Mootools.Core", "Mootools.Core/*",
    #   "Mootools.Core/Class", "**/*"
    # @return [Array] list of source files for given input
    # @api semipublic
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
    
    
    
    # Rack response of not found
    # @return [#each] 404 response
    # @api semipublic
    def not_found!
      [404, {"Content-Type" => "text/plain"}, ["Jsus doesn't know anything about this entity"]]
    end # not_found!

    # Respond with given text
    # @param [String] text text to respond with
    # @return [#each] 200 response
    # @api semipublic
    def respond_with(text)
      [200, {"Content-Type" => "text/javascript"}, [self.class.formated_errors + text]]
    end # respond_with

    # Check whether given path is handled by jsus middleware.
    #
    # @param [String] path path
    # @return [Boolean]
    # @api semipublic
    def handled_by_jsus?(path)
      path =~ path_prefix_regex
    end # handled_by_jsus?

    # @return [String] Jsus request path prefix
    # @api semipublic
    def path_prefix
      @path_prefix ||= self.class.settings[:prefix] ? "/javascripts/#{self.class.settings[:prefix]}/" : "/javascripts/"
    end # path_prefix

    # @return [Regexp] Jsus request path regexp
    # @api semipublic
    def path_prefix_regex
      @path_prefix_regex ||= %r{^#{path_prefix}}
    end # path_prefix_regex

    # @return [Jsus::Pool] Jsus session pool
    # @api semipublic
    def pool
      if cache_pool?
        self.class.pool
      else
        @pool ||= Jsus::Pool.new(self.class.settings[:packages_dir])
      end
    end # pool

    # @return [Boolean] whether request is going to be cached
    # @api semipublic
    def cache?
      self.class.cache?
    end # cache?

    # @return [Jsus::Util::FileCache] file cache to store response
    # @api semipublic
    def cache
      self.class.cache
    end # cache

    # @return [Boolean] whether pool is shared between requests
    # @api semipublic
    def cache_pool?
      self.class.settings[:cache_pool]
    end # cache_pool?

    # You might or might not need to do some last minute conversions for your cache
    # key. Default behaviour is merely a nginx hack, you may have to use your own
    # function for your web-server.
    # @param [String] path request path minus the prefix
    # @return [String] normalized cache key for given request path
    # @api semipublic
    def escape_path_for_cache_key(path)
      path.gsub(" ", "+")
    end # escape_path_for_cache_key
  end # class Middleware
end # module Jsus
