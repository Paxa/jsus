module Jsus
  class Pool
    def sources
      @sources ||= Container.new
    end

    def lookup(key)
      @provides_map[key]
    end

    def <<(source)
      sources << source
      @provides_map = sources.inject({}) do |result, source|
        source.provides(:full => true).each {|p| result[p] = source }
        result
      end
      self
    end

    (Array.instance_methods - self.instance_methods).each {|m| delegate m, :to => :sources }
  end
end