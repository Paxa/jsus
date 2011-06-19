module Jsus
  #
  # Pool class is designed for three purposes:
  # * Maintain connections between SourceFiles and/or Packages
  # * Resolve dependencies
  # * Look up extensions
  #
  class Pool

    # Constructors

    #
    # Basic constructor.
    #
    # @param [Array, String, nil] directory or list of directories to load source
    #   packages from.
    # @api public
    def initialize(dir_or_dirs = nil)
      if dir_or_dirs
        directories = Array(dir_or_dirs)
        directories.each do |dir|
          # '**{,/*/**}' thingie is to resolve problem with not following symlinks
          # one level of symlinks
          # See also: http://stackoverflow.com/questions/357754/can-i-traverse-symlinked-directories-in-ruby-with-a-glob
          Dir[File.join(dir, '**{,/*/**}', 'package.{yml,json}')].uniq.each do |package_path|
            Package.new(File.dirname(package_path), :pool => self)
          end
        end
      end
      flush_cache!
    end


    # @return [Array] array containing all the packages in the pool. Unordered.
    # @api public
    def packages
      @packages ||= []
    end

    # @return [Array] array with all the sources in the pool. Unordered
    # @api public
    def sources
      @sources ||= []
    end

    #
    # Looks up for a file replacing or providing given tag or tag key.
    # Replacement file gets priority.
    #
    # If given a source file, returns the input.
    #
    # @param [String, Jsus::Tag, Jsus::SourceFile]
    # @return [Jsus::SourceFile]
    # @api public
    def lookup(source_or_key)
      case source_or_key
        when String
          lookup(Tag[source_or_key])
        when Tag
          replacement_map[source_or_key] || provides_map[source_or_key]
        when SourceFile
          source_or_key
        else
          raise "Illegal lookup query. Expected String, Tag or SourceFile, " <<
                "given #{source_or_key.inspect}, an instance of #{source_or_key.class.name}."
      end
    end


    #
    # Looks up for dependencies for given file recursively.
    #
    # @param [String, Jsus::Tag, Jsus::SourceFile]
    # @return [Jsus::Container] container with all the dependencies
    # @api public
    def lookup_dependencies(source_or_source_key)
      source = lookup(source_or_source_key)
      result = Container.new
      looked_up = []
      if source
        dependencies = lookup_direct_dependencies(source)
        while !((dependencies - looked_up).empty?)
          dependencies.each { |d| result << d; looked_up << d }
          dependencies = dependencies.map {|d| lookup_direct_dependencies(d).to_a }.flatten.uniq
        end
      end
      result.sort!
    end

    # @param [String, Jsus::Tag]
    # @return [Array] array with source files with extensions for given tag.
    # @api public
    def lookup_extensions(tag_or_tag_key)
      tag = Tag[tag_or_tag_key]
      extensions_map[tag]
    end

    #
    # Pushes an item into a pool.
    #
    # @param [Jsus::SourceFile, Jsus::Package, Array] items to push
    # @return [self]
    # @api public
    def <<(source_or_sources_or_package)
      case
      when source_or_sources_or_package.kind_of?(SourceFile)
        source = source_or_sources_or_package
        add_source_to_trees(source)
        sources << source
        if source.extends
          extensions_map[source.extends] ||= []
          extensions_map[source.extends] << source
        else
          source.provides.each do |p|
            if provides_map[p] && provides_map[p] != source && provides_map[p].filename != source.filename && Jsus.verbose?
              puts "Redeclared #{p.to_s} in #{source.filename} (previously declared in #{provides_map[p].filename})"
            end
            provides_map[p] = source
          end

          replacement_map[source.replaces] = source if source.replaces if source.replaces
        end
      when source_or_sources_or_package.kind_of?(Package)
        package = source_or_sources_or_package
        packages << package
        package.source_files.each {|s| s.pool = self }
        package.extensions.each {|e| e.pool = self }
      when source_or_sources_or_package.kind_of?(Array) || source_or_sources_or_package.kind_of?(Container)
        sources = source_or_sources_or_package
        sources.each {|s| self << s}
      end
      self
    end

    #
    # Drops any cached info
    # @api public
    def flush_cache!
      @cached_dependencies = {}
    end

    (Array.instance_methods - self.instance_methods).each {|m| delegate m, :to => :sources }
    # Private API

    #
    # Looks up direct dependencies for the given source_file or provides tag.
    # You probably will find yourself using #include_dependencies instead.
    # This method caches results locally, use flush_cache! to drop.
    #
    # @param [String, Jsus::Tag, Jsus::SourceFile]
    # @return [Array] array of direct dependencies for given entity
    # @api private
    def lookup_direct_dependencies(source_or_source_key)
      source = lookup(source_or_source_key)
      @cached_dependencies[source] ||= lookup_direct_dependencies!(source)
    end

    #
    # Performs the actual lookup for #lookup_direct_dependencies
    #
    # @param [String, Jsus::Tag, Jsus::SourceFile]
    # @return [Array] array of direct dependencies for given entity
    # @api private
    def lookup_direct_dependencies!(source)
      return [] unless source

      source.dependencies.map do |dependency|
        result = provides_tree.glob("/#{dependency}")
        if (!result || (result.is_a?(Array) && result.empty?)) && Jsus.verbose?
          puts "#{source.filename} is missing #{dependency.is_a?(SourceFile) ? dependency.filename : dependency.to_s}"
        end
        result
      end.flatten.map {|tag| lookup(tag) }
    end

    # @return [Jsus::Util::Tree] tree containing all the sources
    # @api private
    def source_tree
      @source_tree ||= Util::Tree.new
    end

    # @return [Jsus::Util::Tree] tree containing all the provides tags
    # @api private
    def provides_tree
      @provides_tree ||= Util::Tree.new
    end


    # Registers the source in both trees
    # @param [Jsus::SourceFile]
    # @api private
    def add_source_to_trees(source)
      if source.package
        source_tree.insert("/" + source.package.name + "/" + File.basename(source.filename), source)
      else
        source_tree.insert("/" + File.basename(source.filename), source)
      end
      source.provides.each do |tag|
        provides_tree.insert("/" + tag.to_s, tag)
      end
    end

    protected

    # @return [Hash] map of provided tags onto source files. Used to check
    #    redeclaration.
    # @api private
    def provides_map
      @provides_map ||= {}
    end

    # @return [Hash] map of extension tags onto source files. Used to check
    #    redeclaration.
    # @api private
    def extensions_map
      @extensions_map ||= Hash.new{|hash, key| hash[key] = [] }
    end

    # @return [Hash] map of replacement tags onto source files.
    # @api private
    def replacement_map
      @replacement_map ||= {}
    end
  end
end
