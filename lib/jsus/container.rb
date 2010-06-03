module Jsus
  class Container
    include Topsortable        

    def initialize(*sources)
      sources.each do |source|
        self << source
      end
    end

    def <<(source)
      sources << source
      sort!
      self
    end

    def sources
      @sources ||= []
    end

    def sources=(new_value)
      @sources = new_value
    end

    def sort!
      self.sources = topsort(:sources)
    end

    # delegate undefined methods to #sources
    (Array.instance_methods - self.instance_methods).each {|m| delegate m, :to => :sources }
  end
end