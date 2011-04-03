module Jsus
  module Util
    # Various inflection helpers
    module Inflection
      class <<self
        # Converts strings with various punctuation to pascal case
        #     hello_world  => HelloWorld
        #     Oh.My.God    => OhMyGod
        #     iAmCamelCase => IAmCamelCase
        #     some_Weird_._punctuation => SomeWeirdPunctuation
        def random_case_to_mixed_case(string)
          string.split(/[^a-zA-Z]+/).map {|chunk| chunk[0,1].upcase + chunk[1..-1] }.join
        end # random_case_to_mixed_case

        # Same as #random_case_to_mixed_case, but preserves dots
        # color.fx => Color.Fx
        def random_case_to_mixed_case_preserve_dots(string)
          string.split(/[^a-zA-Z\.]+/).map {|chunk| capitalize(chunk) }.
                 map {|chunk| chunk.split(".").map {|c| capitalize(c)}.join(".") }.join
        end # random_case_to_mixed_case

        # Capitalizes first letter (doesn't do anything else to other letters, unlike String#capitalize)
        def capitalize(string)
          string[0,1].capitalize + string[1..-1].to_s
        end # capitalize

        # Downcases first letter
        def decapitalize(string)
          string[0,1].downcase + string[1..-1].to_s
        end # decapitalize

        # Translates MixedCase string to camel-case
        def snake_case(string)
          decapitalize(string.gsub(/(.)([A-Z])([a-z]+)/) {|match| "#{match[1]}_#{match[2].downcase}#{match[3]}"})
        end # snake_case
      end # class <<self
    end # module Inflection
  end # module Util
end # module Jsus