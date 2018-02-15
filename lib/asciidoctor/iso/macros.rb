require 'asciidoctor/extensions'
module Asciidoctor
  module ISO
    class AltTermInlineMacro < Asciidoctor::Extensions::InlineMacroProcessor
      use_dsl
      named :alt
      parse_content_as :text
      using_format :short

      def process parent, target, attrs
        %{<alt>#{Asciidoctor::Inline.new(parent, :quoted, attrs['text']).convert}</alt>}
      end
    end

    class DeprecatedTermInlineMacro < Asciidoctor::Extensions::InlineMacroProcessor
      use_dsl
      named :deprecated
      parse_content_as :text
      def process parent, target, attributes
        %{<deprecated>#{attrs["text"]}</deprecated>}
      end
    end

  end
end
