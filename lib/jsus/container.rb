module Jsus
  class Container
    def initialize(*sources)
      sources.each do |source|
        self << source
      end
    end


    # PRO TIP: #<< sorts upon every invokation
    # #push doesn't
    def <<(source)
      push(source)
      sort!
    end

    def push(source)
      if source
        if source.kind_of?(Array) || source.kind_of?(Container)
          source.each {|s| self.push(s) }
        else
          sources.push(source)
        end
      end
      self
    end

    def flatten      
      map {|item| item.respond_to?(:flatten) ? item.flatten : item }.flatten
    end

    def to_a
      sources
    end

    def sources
      @sources ||= []
    end

    def sources=(new_value)
      @sources = new_value
    end

    def sort!
      self.sources = topsort
      self
    end

    def inspect
      "#<#{self.class.name}:#{self.object_id} #{self.sources.inspect}>"
    end

    def topsort
      graph = RGL::DirectedAdjacencyGraph.new
      provides_map = {}
      # init vertices
      items = self.sources
      items.each do |item|
        graph.add_vertex(item)
        item.provides.each do |provides|
          provides_map[provides] = item
        end
      end
      # init edges
      items.each do |item|
        item.dependencies.each do |dependency|
          if required_item = provides_map[dependency]
            graph.add_edge(required_item, item)
          end
        end
      end
      result = []
      graph.topsort_iterator.each { |item| result << item }
      result
    end

    # delegate undefined methods to #sources
    DELEGATED_METHODS = [
                          "==", "map", "map!", "each", "inject", "reject",
                          "detect", "size", "length", "[]", "empty?",
                          "index", "include?", "select", "-", "+", "|", "&"
                        ]
    (DELEGATED_METHODS).each {|m| delegate m, :to => :sources }
  end
end