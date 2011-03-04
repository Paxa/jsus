module Jsus
  # Base for any validator class.
  module Validator
    class Base
      # Constructor accepts pool or array or container and adds every file
      # to its source files set.
      def initialize(pool_or_array_or_container)
        self.source_files = pool_or_array_or_container
      end

      # Returns source files for validation
      def source_files
        @source_files ||= []
      end
      alias_method :sources, :source_files

      # Sets source files for validation
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

      # Returns whether or not given sources conform to given set of rules
      def validate
        validation_errors.empty?
      end

      # List of validation errors, override this method on descendant classes.
      def validation_errors
        []
      end
      
      # Shortcut for creating and validating a list of items
      def self.validate(*args)
        new(*args).validate
      end
    end
  end
end