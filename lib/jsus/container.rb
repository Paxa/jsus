#
# Container is an array which contains source files. Main difference
# between it and array is the fact that container maintains topological
# sort for the source files.
#
module Jsus
  class Container
    #
    # Every argument for initializer is pushed into the container.
    #
    def initialize(*sources)
      sources.each do |source|
        push(source)
      end
      sort!
    end

    # Public API

    #
    # Pushes an item to container and sorts container.
    #
    # When given an array or another container, enumerates its contents.
    #
    def <<(source)
      push(source)
      sort!
    end

    # Pushes an item to container *without sorting it*. Use with care.
    def push(source)
      if source
        if source.kind_of?(Array) || source.kind_of?(Container)
          source.each {|s| self.push(s) }
        else
          sources.push(source)
        end
      end
      clear_cache!
      self
    end

    # Flattens the container items.
    def flatten
      map {|item| item.respond_to?(:flatten) ? item.flatten : item }.flatten
    end

    # Contains the source files in the correct order.
    def sources
      @sources ||= []
    end
    alias_method :to_a, :sources

    def sources=(new_value) # :nodoc:
      @sources = new_value
    end

    # Performs a sort and returns self. Executed automatically by #<< .
    def sort!
      self.sources = topsort
      self
    end

    # Lists all the required files (dependencies and extensions) for
    # the sources in the container.
    def required_files(root = nil)
      files = sources.map {|s| s.required_files }.flatten
      if root
        root = Pathname.new(File.expand_path(root))
        files = files.map {|f| Pathname.new(File.expand_path(f)).relative_path_from(root).to_s }
      end
      files
    end

    def inspect # :nodoc:
      "#<#{self.class.name}:#{self.object_id} #{self.sources.inspect}>"
    end

    # Private API

    def topsort # :nodoc:
      graph = RGL::DirectedAdjacencyGraph.new
      provides_map = {}
      # init vertices
      provides_tree = Tree.new
      items = self.sources
      items.each do |item|
        graph.add_vertex(item)
        item.provides.each do |provides|
          provides_map[provides] = item
          provides_tree.insert("/" + provides.to_s, item)
        end
      end
      # init edges
      items.each do |item|
        item.dependencies.each do |dependency|
          cache[dependency] ||= provides_tree.glob("/" + dependency.to_s).map {|node| node.value }
          cache[dependency].each do |required_item|
            graph.add_edge(required_item, item)
          end
        end
      end
      result = []
      graph.topsort_iterator.each { |item| result << item }
      result
    end
    
    def cache # :nodoc:
      @cache ||= {}
    end
    
    def clear_cache! # :nodoc:
      @cache = nil
    end

    DELEGATED_METHODS = [
                          "==", "map", "map!", "each", "inject", "inject!",
                          "reject", "reject!", "detect", "size", "length", "[]",
                          "empty?", "index", "include?", "select", "-", "+", "|", "&"
                        ] # :nodoc:
    # delegates most Enumerable methods to #sources
    (DELEGATED_METHODS).each {|m| delegate m, :to => :sources }
  end
end