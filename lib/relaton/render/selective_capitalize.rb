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
          end.join(' ')
        end
      end
    end
  end
end

# Extend the customise_liquid method to register our filter
module Relaton
  module Render
    module Template
      class General
        alias_method :original_customise_liquid, :customise_liquid
        
        def customise_liquid
          original_customise_liquid
          # Register our filter
          ::Liquid::Template.register_filter(::Relaton::Render::Template::SelectiveCapitalize)
        end
      end
    end
  end
end
