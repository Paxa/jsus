module Jsus
  module Validator      
    class Base
      def initialize(pool_or_array_or_container)
        self.source_files = pool_or_array_or_container
      end
    
      def source_files
        @source_files ||= []
      end
      alias_method :sources, :source_files
    
      def source_files=(pool_or_array_or_container)
        case pool_or_array_or_container
        when Pool
          @source_files = pool_or_array_or_container.sources.to_a
        when Array
          @source_files = pool_or_array_or_container
        when Container
          @source_files = pool_or_array_or_container.to_a
        end
      end
      alias_method :sources=, :source_files=
    
      def validate
        validation_errors.empty?
      end
      
      def validation_errors
        []
      end
      
      def self.validate(*args)
        new(*args).validate
      end
    end
  end
end