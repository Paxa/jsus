require 'rubygems'
require 'rgl/adjacency'
require 'json'
require 'js_source_file'
require 'js_package'


class JsBundler
  def initialize(directory)
    
  end



  # Topological sort for packages and source files
  def self.topsort(items)
    graph = RGL::DirectedAdjacencyGraph.new
    provides_hash = {}
    # init vertices
    items.each do |item|
      graph.add_vertex(item)
      item.provides.each do |provides|
        provides_hash[provides] = item
      end
    end
    # init edges
    items.each do |item|
      item.dependencies.each do |dependency|
        if required_item = provides_hash[dependency]
          graph.add_edge(required_item, item)
        end
      end
    end
    result = []
    graph.topsort_iterator.each { |item| result << item }
    result
  end

end