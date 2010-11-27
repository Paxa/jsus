#
# Pool class is designed for three purposes:
# * Maintain connections between SourceFiles and/or Packages
# * Resolve dependencies
# * Look up extensions
#
# 


module Jsus
  class Pool

    # Constructors

    #
    # Basic constructor.
    #
    # Accepts an optional directory argument, when it is set, it looks up for 
    # packages from the given directory and if it finds any, adds them to the pool.
    #
    # Directory is considered a Package directory if it contains +package.yml+ file.
    #
    def initialize(dir = nil)
      if dir
        Dir[File.join(dir, '**', 'package.{yml,json}')].each do |package_path|
          Package.new(File.dirname(package_path), :pool => self)
        end
      end
      flush_cache!
    end
    
    
    # 
    # An array containing all the packages in the pool. Unordered.
    #
    def packages
      @packages ||= []
    end

    #
    # Container with all the sources in the pool. It is actually ordered in case you 
    # want to include ALL the source files from the pool.
    #
    def sources
      @sources ||= Container.new
    end

    #
    # Looks up for a file providing given tag or tag key. 
    #
    # If given a source file, returns the input.
    #
    def lookup(source_or_key)
      case source_or_key
        when String
          provides_map[Tag[source_or_key]]
        when Tag
          provides_map[source_or_key]
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
    # Returns an instance of Container which contains needed files sorted.
    #
    def lookup_dependencies(source_or_source_key)
      source = lookup(source_or_source_key)
      result = Container.new
      looked_up = []
      if source
        dependencies = lookup_direct_dependencies(source)
        while !((dependencies - looked_up).empty?)
          dependencies.each { |d| result.push(d); looked_up << d }
          dependencies = dependencies.map {|d| lookup_direct_dependencies(d).to_a }.flatten.uniq
        end
        result.sort!
      end
      result
    end

    #
    # Returns an array with SourceFile-s with extensions for given tag.
    #
    def lookup_extensions(tag_or_tag_key)
      tag = Tag[tag_or_tag_key]
      extensions_map[tag]
    end

    #
    # Pushes an item into a pool.
    #
    # Can be given:
    # * SourceFile
    # * Package (pushing all the child source files into the pool)
    # * Array or Container (pushing all the contained source files into the pool)
    #
    # returns self.
    def <<(source_or_sources_or_package)
      case
      when source_or_sources_or_package.kind_of?(SourceFile)
        source = source_or_sources_or_package        
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
    #
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
    def lookup_direct_dependencies(source_or_source_key)      
      source = lookup(source_or_source_key)
      @cached_dependencies[source] ||= lookup_direct_dependencies!(source)
    end

    #
    # Performs the actual lookup for #lookup_direct_dependencies
    #
    def lookup_direct_dependencies!(source)
      result = if source
        (source.dependencies + source.external_dependencies).map do |dependency|
          result = lookup(dependency)
          puts "#{source.filename} is missing #{dependency.is_a?(SourceFile) ? dependency.filename : dependency.to_s}" if !result && Jsus.verbose?
          result
        end
      else
        []
      end
      Container.new(*result)
    end

    protected

    def provides_map # :nodoc:
      @provides_map ||= {}
    end

    def extensions_map # :nodoc:
      @extensions_map ||= Hash.new{|hash, key| hash[key] = [] }
    end
  end
end