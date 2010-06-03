require 'yaml'
require 'pathname'
require 'rubygems'
require 'json'
require 'active_support/ordered_hash'
require 'rgl/adjacency'
require 'rgl/topsort'

require 'jsus/source_file'
require 'jsus/package'
require 'jsus/bundler'

module Jsus
  # Shortcut for Bundler.new
  def self.new(*args, &block)
    Bundler.new(*args, &block)
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