require 'asciidoctor/extensions'
module Asciidoctor
  module ISO
    class AltTermInlineMacro < Asciidoctor::Extensions::InlineMacroProcessor
      use_dsl
      named :alt
      parse_content_as :text
      using_format :short

      def process parent, target, attrs
        %{<admitted>#{Asciidoctor::Inline.new(parent, :quoted, attrs['text']).convert}</admitted>}
      end
    end

    class DeprecatedTermInlineMacro < Asciidoctor::Extensions::InlineMacroProcessor
      use_dsl
      named :deprecated
      parse_content_as :text
      using_format :short

      def process parent, target, attrs
        %{<deprecates>#{attrs["text"]}</deprecates>}
      end
    end

    class DomainTermInlineMacro < Asciidoctor::Extensions::InlineMacroProcessor
      use_dsl
      named :domain
      parse_content_as :text
      using_format :short

      def process parent, target, attrs
        %{<domain>#{attrs["text"]}</domain>}
      end
    end
  end
end
