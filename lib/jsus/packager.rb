module Jsus
  class Packager
    attr_accessor :container

    def initialize(*sources)
      self.container = Container.new(*sources)
    end

    def sources
      container.sources
    end

    def pack(output_file = nil)
      result = sources.map {|s| s.content }.join("\n")

      if output_file
        FileUtils.mkdir_p(File.dirname(output_file))
        File.open(output_file, "w") {|f| f << result }
      end
      
      result
    end

    
  end
end