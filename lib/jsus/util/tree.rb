module Jsus
  module Util
    #
    # Jsus::Tree is a basic hierarchical tree structure class
    # What it does, basically, is maintaining hierarchical filesystem-like
    # structure (with node names like /namespace/inner/item) and supporting
    # lookups via #glob method.
    #
    # @example
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
    class Tree
      PATH_SEPARATOR = "/"


      class <<self
        # Utility functions

        # Splits path into components
        #     Jsus::Tree.components_from_path("/hello/world") # => ["hello", "world"]
        # @api semipublic
        def components_from_path(path)
          raise "Empty path given: #{path.inspect}" if !path || path == ""
          path = path.to_s.dup
          path.split(PATH_SEPARATOR).reject {|comp| comp == "" }
        end
        alias_method :get_path_components, :components_from_path

        # Joins components into a pathspec
        #     Jsus::Tree.path_from_components(["hello", "world"]) # => "/hello/world"
        def path_from_components(components)
          "#{PATH_SEPARATOR}#{components.join(PATH_SEPARATOR)}"
        end
      end

      #
      # Jsus::Tree node class.
      # Most of the time you only need to extract #value from the node,
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
        # @param [String] full_path full path to node
        # @param [Object] value
        # @api public
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
        # @api semipublic
        def full_path=(full_path)
          @full_path = full_path
          @path_components = Tree.get_path_components(full_path)
          @name = @path_components[-1]
        end

        # @return [Array] node's direct descendants
        # @api public
        def children
          @children ||= []
        end

        # @param [String] name basename
        # @return [Jsus::Util::Tree::Node] direct node child with given basename
        # @api public
        def find_child(name)
          children.detect {|child| child.name == name }
        end

        # Creates a child with given name and value
        # @param [String] name node name
        # @param [Object] value
        # @return [Jsus::Util::Tree::Node]
        # @api public
        def create_child(name, value = nil)
          full_path = Tree.path_from_components(path_components + [name])
          node = Node.new(full_path, value)
          children << node
          node.parent = self
          node
        end

        # Finds a child with given name or creates a child with given name and
        # value.
        #
        # @param [String] name
        # @param [Object] value
        # @api public
        def find_or_create_child(name, value = nil)
          find_child(name) || create_child(name, value)
        end

        # Finds children matching the given pathspec
        # Pathspec format:
        #    '**' -- this node and all the children nodes that have children
        #    'smth*' -- nodes beginning with smth
        #    'smth*else' -- nodes beginning with smth and ending with else
        #    <string without asterisks> -- plain node lookup by name
        #
        # @param [String] pathspec
        # @return [Array] array with search results
        # @api public
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

        # @return [Boolean] whether this node has children
        # @api public
        def has_children?
          !children.empty?
        end
      end

      # @return [Jsus::Util::Tree::Node] root node of the tree
      # @api public
      def root
        @root ||= Node.new("/", nil)
      end

      # Looks up a node by direct path. Does not support wildcards
      # @param [String] path
      # @return [Jsus::Util::Tree::Node]
      # @api public
      def lookup(path)
        path_components = self.class.get_path_components(path)
        path_components.inject(root) do |result, component|
          if result
            result.find_child(component)
          end
        end
      end

      # @see lookup
      # @param [String] path
      # @return [Jsus::Util::Tree::Node]
      # @note returns nil when node has no assigned value
      # @api public
      def [](path)
        node = lookup(path)
        node ? node.value : nil
      end



      # Searches for nodes by a given pathspec
      # @see Jsus::Util::Tree::Node#find_children_matching for more details
      # @param [String] pathspec
      # @return [Array] nodes for given pathspec
      # @api semipublic
      def find_nodes_matching(pathspec)
        self.class.get_path_components(pathspec).inject([root]) do |nodes, component|
          nodes.map {|node| node.find_children_matching(component) }.flatten
        end
      end

      # @param [String] pathspec
      # @return [Array] values for nodes matching given pathspec
      # @see Jsus::Util::Tree::Node#find_children_matching for more details
      # @api public
      def glob(pathspec)
        find_nodes_matching(pathspec).map {|node| node.value }
      end

      # Inserts a node with given value into the tree
      # @param [String] full node path
      # @param [Object] value
      # @api public
      def insert(full_path, value = nil)
        node = create_all_nodes_if_needed(full_path)
        node.value = value
        node
      end
      alias_method :[]=, :insert

      # Traverses the tree (BFS).
      # @param [Boolean] whether to traverse non-leaves nodes
      # @yield traversed node
      # @api public
      def traverse(all_nodes = false)
        node_list = [root]
        while !node_list.empty?
          node = node_list.shift
          yield node if all_nodes || !node.has_children?
          node.children.each {|child| node_list << child }
        end
      end

      # @param [Boolean] whether to return only leaves with values
      # @return [Array] list of leaves
      # @api public
      def leaves(only_with_value = true)
        result = []
        traverse {|node| result << node if !only_with_value || node.value }
        result
      end

      protected

      # @api private
      def create_all_nodes_if_needed(full_path)
        self.class.get_path_components(full_path).inject(root) do |result, component|
          result.find_or_create_child(component)
        end
      end

    end
  end
end
