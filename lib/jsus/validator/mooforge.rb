module Jsus
  module Validator
    class Mooforge < Base
      def validation_errors
        @validation_errors ||= sources.inject([]) do |result, sf|
          if !sf.header
            result << "#{sf.filename} is missing header"
          elsif !sf.header["authors"]
            result << "#{sf.filename} is missing authors"
          elsif !sf.header["license"]
            result << "#{sf.filename} is missing license"
          else
            result
          end          
        end
      end
    end
  end
end