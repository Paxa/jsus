module Jsus
  module Validator
    # Mooforge validator checks every file for the following:
    #   * Presence of header
    #   * Presence of authors field
    #   * Presence of license field
    class Mooforge < Base      
      def validation_errors # :nodoc:
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