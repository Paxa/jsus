module Jsus
  class Tree
    PATH_SEPARATOR = "/"

    # Utility functions
    def self.get_path_components(path)
      raise "Path should start with root (got: #{path})" unless path && path[0,1] == PATH_SEPARATOR
      path = path.dup
      path[0,1] = ""
      path.split(PATH_SEPARATOR)
    end

    def self.path_from_components(components)
      "#{PATH_SEPARATOR}#{components.join(PATH_SEPARATOR)}"
    end


    class Node
      attr_accessor :value
      attr_accessor :parent
      attr_accessor :path_components

      def initialize(full_path, value = nil)
        self.full_path = full_path
        self.value = value
      end

      attr_reader :full_path
      attr_reader :name
      def full_path=(full_path)
        @full_path = full_path
        @path_components = Tree.get_path_components(full_path)
        @name = @path_components[-1]
      end

      def children
        @children ||= []
      end

      def find_child(name)
        children.detect {|child| child.name == name }
      end

      def create_child(name, value = nil)
        full_path = Tree.path_from_components(path_components + [name])
        node = Node.new(full_path, value)
        children << node
        node.parent = self
        node
      end

      def find_or_create_child(name, value = nil)
        find_child(name) || create_child(name, value)
      end

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

      def has_children?
        !children.empty?
      end
    end


    def root
      @root ||= Node.new("/", nil)
    end

    def [](path)
      path_components = self.class.get_path_components(path)
      path_components.inject(root) do |result, component|
        if result
          result.find_child(component)
        end
      end
    end

    def glob(pathspec)
      self.class.get_path_components(pathspec).inject([root]) do |nodes, component|
        nodes.map {|node| node.find_children_matching(component) }.flatten
      end
    end

    def insert(full_path, value = nil)
      node = create_all_nodes_if_needed(full_path)
      node.value = value
      node
    end
    alias_method :[]=, :insert

    def traverse(all_nodes = false)
      node_list = [root]
      while !node_list.empty?
        node = node_list.shift
        yield node if all_nodes || !node.has_children?
        node.children.each {|child| node_list << child }
      end
    end

    def leaves(only_with_value = true)
      result = []
      traverse {|node| result << node if !only_with_value || node.value }
      result
    end


    def create_all_nodes_if_needed(full_path)
      self.class.get_path_components(full_path).inject(root) do |result, component|
        result.find_or_create_child(component)
      end
    end

  end

end