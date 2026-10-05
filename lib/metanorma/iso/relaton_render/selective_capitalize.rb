module Relaton
  module Render
    module Template
      module SelectiveCapitalize
        def selective_capitalize(input, exceptions)
          return nil if input.nil?

          # Convert exceptions to an array if it's not already
          exceptions_array = exceptions.is_a?(Array) ? exceptions : [exceptions]

          # Split the input into words
          words = input.split(/\s+/)

          # Capitalize each word unless it's in the exceptions list
          words.map do |word|
            if exceptions_array.include?(word.downcase)
              word
            else
              word.capitalize
            end
          end.join(" ")
        end
      end
    end
  end
end

# Extend the create_liquid_environment method to register our filter
module Relaton
  module Render
    module Template
      class General
        alias_method :original_create_liquid_environment,
                     :create_liquid_environment

        def create_liquid_environment
          env = original_create_liquid_environment
          env.register_filter(::Relaton::Render::Template::SelectiveCapitalize)
          env
        end
      end
    end
  end
end
