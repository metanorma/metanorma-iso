require 'asciidoctor/extensions'

module Asciidoctor
  module Iso
    class TermRefInlineMacro < Asciidoctor::Extensions::InlineMacroProcessor
      use_dsl

      named :term
      name_positional_attributes 'name', 'termxref'
      using_format :short

      def process(parent, target, attrs)
        "<em>#{attrs['name']}</em> (<termxref>#{attrs['termxref'] || attrs['name']}</termxref>)"
      end
    end
  end
end
