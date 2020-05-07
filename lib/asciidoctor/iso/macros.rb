# frozen_string_literal: true

require 'asciidoctor/extensions'

module Asciidoctor
  module Iso
    # Macro to transform `term[X,Y]` into em, termxref xml
    class TermRefInlineMacro < Asciidoctor::Extensions::InlineMacroProcessor
      use_dsl

      named :term
      name_positional_attributes 'name', 'termxref'
      using_format :short

      def process(_parent, _target, attrs)
        termref = attrs['termxref'] || attrs['name']
        defaultref = attrs['termxref'].nil? ? ' defaultref' : ''
        "<em>#{attrs['name']}</em> (<termxref#{defaultref}>#{termref}</termxref>)"
      end
    end
  end
end
