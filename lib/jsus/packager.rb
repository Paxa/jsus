#
# Packager is a plain simple class accepting several source files 
# and joining their contents.
#
# It uses Container for storage which means it automatically sorts sources.
#
module Jsus
  class Packager
    attr_accessor :container  # :nodoc:

    # 
    # Inits packager with the given sources.
    #
    def initialize(*sources)
      self.container = Container.new(*sources)
    end

    def sources # :nodoc:
      container
    end

    # 
    # Concatenates all the sources' contents into a single string.
    # If given a filename, outputs into a file.
    #
    # Returns the concatenation.
    #
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