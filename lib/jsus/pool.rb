module Jsus
  class Pool

    def initialize(dir = nil)
      if dir
        Dir[File.join(dir, '**', 'package.yml')].each do |package_path|
          Package.new(Pathname.new(package_path).parent.to_s, :pool => self)
        end
      end
    end

    def packages
      @packages ||= []
      @packages.uniq!
      @packages
    end

    def sources
      @sources ||= Container.new
    end

    def lookup(source_or_key)
      case source_or_key
      when String
        provides_map[source_or_key]
      when Jsus::SourceFile
        source_or_key
      else
        raise "Illegal lookup query. Expected String or SourceFile, " <<
              "given #{source_or_key.inspect}, an instance of #{source_or_key.class.name}."
      end
    end

    def lookup_direct_dependencies(source_or_source_key)
      source = lookup(source_or_source_key)
      result = source.external_dependencies.map {|d| lookup(d)}
      Container.new(*result)
    end

    def lookup_dependencies(source_or_source_key)
      source = lookup(source_or_source_key)
      result = Container.new
      dependencies = lookup_direct_dependencies(source)
      while !dependencies.empty?
        dependencies.each { |d| result.push(d) }
        dependencies = dependencies.map {|d| lookup_direct_dependencies(d).to_a }.flatten.uniq
      end
      result.sort!
    end

    def <<(source_or_sources_or_package)
      case 
      when source_or_sources_or_package.kind_of?(SourceFile)
        source = source_or_sources_or_package
        sources << source
        source.provides.each {|p| provides_map[p] = source }
      when source_or_sources_or_package.kind_of?(Package)
        package = source_or_sources_or_package
        packages << package
        package.source_files.each {|s| self << s}
      when source_or_sources_or_package.kind_of?(Array) || source_or_sources_or_package.kind_of?(Container)
        sources = source_or_sources_or_package
        sources.each {|s| self << s}
      end
      self
    end

    (Array.instance_methods - self.instance_methods).each {|m| delegate m, :to => :sources }

    protected

    def provides_map
      @provides_map ||= {}
    end
  end
end