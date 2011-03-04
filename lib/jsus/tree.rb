#
# Jsus::Tree is a basic hierarchical tree structure class
# What it does, basically, is maintaining hierarchical filesystem-like
# structure (with node names like /namespace/inner/item) and supporting
# lookups via #glob method. 
#
# Example:
#
#     tree = Jsus::Tree.new
#     tree["/folder/item_0"] = "Hello"
#     tree["/folder/item_1"] = "World"
#     tree["/other/soul"]    = "Empty"
#     tree.glob("/*")         # => 3 Jsus::Node-s (`root`, `folder`, `other`)
#     tree.glob("/**/*")      # => 6 Jsus::Node-s (`root`, `folder`, `other`, `item_0`, `item_1`, `soul`)
#     tree["/something"]      # => nil
#     tree["/folder/item_1"]  # => Jsus::Node
#     tree["/other/soul"] = nil
#     tree.leaves(true)       # => 2 Jsus::Node-s (no `soul` node)
#     tree.leaves(false)      # => 3 Jsus::Node-s
#

module Jsus
  class Tree
    PATH_SEPARATOR = "/"

    
    class <<self
      # Utility functions
    
      # Splits path into components
      #     Jsus::Tree.components_from_path("/hello/world") # => ["hello", "world"]
      def components_from_path(path)
        raise "Path should start with root (got: #{path})" unless path && path[0,1] == PATH_SEPARATOR
        path = path.dup
        path[0,1] = ""
        path.split(PATH_SEPARATOR)
      end
      alias_method :get_path_components, :components_from_path

      # Joins components into a pathspec
      #     Jsus::Tree.path_from_components(["hello", "world"]) # => "/hello/world"
      def path_from_components(components)
        "#{PATH_SEPARATOR}#{components.join(PATH_SEPARATOR)}"
      end
    end
    
    #
    # Jsus::Tree node class
    # Most of the time you only need to extract #value from the node
    # although sometimes you might need to refer to #parent node and #full_path
    #
    class Node
      # Contains assigned value
      attr_accessor :value
      # Contains reference to parent node, nil for root node
      attr_accessor :parent
      # Contains array with path components
      attr_accessor :path_components

      # Initializes full path and value for the node
      def initialize(full_path, value = nil)
        self.full_path = full_path
        self.value = value
      end

      # Contains full path to the node, such as '/hello/world'
      attr_reader :full_path
      # Contains node basename, such as 'world' for '/hello/world'
      attr_reader :name
      # Assigns node's full path and automatically deduces path components,
      # basename etc.
      def full_path=(full_path)
        @full_path = full_path
        @path_components = Tree.get_path_components(full_path)
        @name = @path_components[-1]
      end

      # Returns node's direct descendants
      def children
        @children ||= []
      end

      # Finds a node child by basename
      def find_child(name)
        children.detect {|child| child.name == name }
      end

      # Creates a child with given name and value
      def create_child(name, value = nil)
        full_path = Tree.path_from_components(path_components + [name])
        node = Node.new(full_path, value)
        children << node
        node.parent = self
        node
      end

      # Finds a child with given name or creates a child with given name and
      # value
      def find_or_create_child(name, value = nil)
        find_child(name) || create_child(name, value)
      end

      # Finds children matching the given pathspec
      # Pathspec format:
      #    '**' -- this node and all the children nodes that have children
      #    'smth*' -- nodes beginning with smth
      #    'smth*else' -- nodes beginning with smth and ending with else
      #    <string without asterisks> -- plain node lookup by name
      # Returns array with search results      
      def find_children_matching(pathspec)
        case pathspec
          when "**"
            [self] + children.select {|child| child.has_children? }
          when /\*/
            regexp = Regexp.new("^" + Regexp.escape(pathspec).gsub("\\*", ".*") + "$")
            children.select {|child| !child.has_children? && child.name =~ regexp }
          else
            [find_child(pathspec)].compact
        end
      end
      
      # Returns whether this node has children
      def has_children?
        !children.empty?
      end
    end

    # Root node of the tree
    def root
      @root ||= Node.new("/", nil)
    end

    # Looks up a node by direct path. Does not support wildcards
    def [](path)
      path_components = self.class.get_path_components(path)
      path_components.inject(root) do |result, component|
        if result
          result.find_child(component)
        end
      end
    end

    # Searches for nodes by a given pathspec
    # See Jsus::Node#find_children_matching for more details
    def glob(pathspec)
      self.class.get_path_components(pathspec).inject([root]) do |nodes, component|
        nodes.map {|node| node.find_children_matching(component) }.flatten
      end
    end

    # Inserts a node with given value into the tree
    def insert(full_path, value = nil)
      node = create_all_nodes_if_needed(full_path)
      node.value = value
      node
    end
    alias_method :[]=, :insert

    # Traverses the tree.
    # When given true as the argument, traverses all nodes.
    # Otherwise, only leaves.
    def traverse(all_nodes = false)
      node_list = [root]
      while !node_list.empty?
        node = node_list.shift
        yield node if all_nodes || !node.has_children?
        node.children.each {|child| node_list << child }
      end
    end
    
    # Returns a list of leaves. 
    # Returns only leaves with set values by default
    def leaves(only_with_value = true)
      result = []
      traverse {|node| result << node if !only_with_value || node.value }
      result
    end

    protected
    
    def create_all_nodes_if_needed(full_path) # :nodoc:
      self.class.get_path_components(full_path).inject(root) do |result, component|
        result.find_or_create_child(component)
      end
    end

  end

end