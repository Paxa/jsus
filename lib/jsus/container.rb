module Jsus
  class Container
    include Topsortable        

    def initialize(*sources)
      sources.each do |source|
        self << source
      end
    end

    def <<(source)
      if source
        if source.kind_of?(Array) || source.kind_of?(Container)
          source.each {|s| self << s }
        else
          sources << source
          sort!
        end
      end
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

    def inspect
      "#<#{self.class.name}:#{self.object_id} #{self.sources.inspect}>"
    end

    # delegate undefined methods to #sources
    (Array.instance_methods - self.instance_methods).each {|m| delegate m, :to => :sources }
  end
end