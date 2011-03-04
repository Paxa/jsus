module Jsus
  #
  # Container is an array that contains source files. Main difference
  # from an array is the fact that container maintains topological
  # sort for the source files.
  #
  class Container
    #
    # Every argument for initializer is pushed into the container.
    #
    def initialize(*sources)
      sources.each do |source|
        push(source)
      end
    end

    # Public API

    # Pushes an item to container
    def push(source)
      if source
        if source.kind_of?(Array) || source.kind_of?(Container)
          source.each {|s| self.push(s) }
        else
          sources.push(source) unless sources.include?(source)
        end
      end
      clear_cache!
      self
    end
    alias_method :<<, :push

    # Flattens the container items.
    def flatten
      map {|item| item.respond_to?(:flatten) ? item.flatten : item }.flatten
    end

    # Contains the source files. Please, don't use sources directly, if you
    # depend on them to be topologically sorted. Use collection methods like
    # inject/reject/map directly on the container instead.
    def sources
      @sources ||= []
    end
    alias_method :to_a, :sources

    def sources=(new_value) # :nodoc:
      @sources = new_value
    end

    # Performs a sort and returns self.
    def sort!
      unless sorted?
        remove_replaced_files!
        self.sources = topsort
        @sorted = true
      end
      self
    end

    # Returns whether collection is sorted already
    def sorted?
      !!@sorted
    end

    # Lists all the required files (dependencies and extensions) for
    # the sources in the container.
    def required_files(root = nil)
      sort!
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
      # init vertices
      items = sources
      items.each {|item| graph.add_vertex(item) }
      # init edges
      items.each do |item|
        item.dependencies.each do |dependency|
          # If we can find items that provide the required dependency...
          # (dependency could be a wildcard as well, hence items)
          dependency_cache[dependency] ||= provides_tree.glob("/" + dependency.to_s).map {|node| node.value }
          # ... we draw an edge from every required item to the dependant item
          dependency_cache[dependency].each do |required_item|
            graph.add_edge(required_item, item)
          end
        end
      end
      result = []
      graph.topsort_iterator.each { |item| result << item }
      result
    end

    def dependency_cache # :nodoc:
      @dependency_cache ||= {}
    end

    def provides_tree # :nodoc:
      @provides_tree ||= provides_tree!
    end

    # Provides tree contains
    def provides_tree! # :nodoc:
      tree = Tree.new
      # Provisions
      sources.each do |file|
        file.provides.each do |tag|
          tree["/#{tag}"] = file
        end
      end
      # Replacements
      sources.each do |file|
        if file.replaces
          tree["/#{file.replaces}"] = file
        end
      end
      tree
    end

    def remove_replaced_files! # :nodoc:
      sources.reject! do |sf|
        !sf.provides.empty? && sf.provides.any? { |tag|
          replacements_tree["/#{tag}"] &&
          replacements_tree["/#{tag}"].value &&
          replacements_tree["/#{tag}"].value != sf
        }
      end
    end

    def replacements_tree # :nodoc:
      @replacements_tree ||= replacements_tree!
    end

    def replacements_tree! # :nodoc:
      tree = Tree.new
      sources.each do |file|
        if file.replaces
          tree["/#{file.replaces}"] = file
        end
      end
      tree
    end

    def clear_cache! # :nodoc:
      @provides_tree = nil
      @replacements_tree = nil
      @dependency_cache = nil
      @sorted = false
    end


    CACHE_CLEAR_METHODS = [
      "map!", "reject!", "inject!"
    ] # :nodoc:

    DELEGATED_METHODS = [
      "==", "to_a", "map", "map!", "each", "inject", "inject!",
      "reject", "reject!", "detect", "size", "length", "[]",
      "empty?", "index", "include?", "select", "-", "+", "|", "&"
    ] # :nodoc:
    # delegates most Enumerable methods to #sources
    (DELEGATED_METHODS).each do |m|
      class_eval <<-EVAL
        def #{m}(*args, &block)
          sort!
          #{"clear_cache!" if CACHE_CLEAR_METHODS.include?(m)}
          self.sources.send(:#{m}, *args, &block)
        end
      EVAL
    end
  end
end