module Jsus
  class Container
    include Topsortable        

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
      self.sources = topsort(:sources)
      self
    end

    def inspect
      "#<#{self.class.name}:#{self.object_id} #{self.sources.inspect}>"
    end

    # delegate undefined methods to #sources
    DELEGATED_METHODS = [
                          "==", "map", "map!", "each", "inject", "reject",
                          "detect", "size", "length", "[]", "empty?",
                          "index", "include?"
                        ]
    (DELEGATED_METHODS).each {|m| delegate m, :to => :sources }
  end
end