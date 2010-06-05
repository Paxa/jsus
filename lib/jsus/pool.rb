require 'ruby-debug'
module Jsus
  class Pool
    def sources
      @sources ||= Container.new
    end

    def lookup(source_or_key)
      case source_or_key
      when String
        @provides_map[source_or_key]
      when Jsus::SourceFile
        source_or_key
      else
        raise "Illegal lookup query. Expected String or SourceFile, given #{source_or_key.class.name}."
      end
    end

    def lookup_direct_dependencies(source_or_source_key, options = {})
      source = lookup(source_or_source_key)
      result = source.dependencies(:full => true).map {|d| lookup(d)}
      case options[:as]
      when :array
        result
      else
        Container.new(*result)
      end
    end

    def lookup_dependencies(source_or_source_key)
      source = lookup(source_or_source_key)
      result = Container.new
      dependencies = lookup_direct_dependencies(source, :as => :array)
      while !dependencies.empty?
        dependencies.each { |d| result.push(d) }
        dependencies = dependencies.map {|d| lookup_direct_dependencies(d, :as => :array) }.flatten.compact.uniq
      end
      result.sort!
    end

    def <<(source)
      sources << source
      @provides_map = sources.inject({}) do |result, source|
        source.provides(:full => true).each {|p| result[p] = source }
        result
      end
      self
    end

    (Array.instance_methods - self.instance_methods).each {|m| delegate m, :to => :sources }
  end
end