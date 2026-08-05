# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      class Transformer::FootnoteCollector
        # Use the NisoSts::Fn / NisoSts::FnGroup pair (not TbxIsoTml::*).
        # The NisoSts::Back#fn_group attribute is typed as NisoSts::FnGroup,
        # and NisoSts::FnGroup's :fn collection is typed as NisoSts::Fn.
        # Passing a TbxIsoTml::Fn would hit a lutaml-model type-mismatch
        # (silently reusing NisoSts::Fn's transformation on the wrong
        # value class) — see TODO.fixup-sts/21 for the diagnosis.
        FN_GROUP_CLASS = ::Sts::NisoSts::FnGroup
        FN_CLASS = ::Sts::NisoSts::Fn

        def initialize
          @footnotes = {}
          @counter = 0
        end

        def register(footnote_text, paragraphs: nil)
          normalized = footnote_text.strip
          if @footnotes.key?(normalized)
            @footnotes[normalized]
          else
            @counter += 1
            entry = { id: "fn_#{@counter}", number: @counter,
                      paragraphs: paragraphs }
            @footnotes[normalized] = entry
            entry
          end
        end

        def lookup(footnote_text)
          @footnotes[footnote_text.strip]
        end

        def empty?
          @footnotes.empty?
        end

        def count
          @footnotes.size
        end

        def fn_group
          return nil if @footnotes.empty?

          group = FN_GROUP_CLASS.new

          @footnotes.each do |text, entry|
            fn = FN_CLASS.new
            fn.id = entry[:id]

            fn_label = ::Sts::NisoSts::Label.new
            fn_label.content = ["<sup>#{entry[:number]})</sup>"]
            fn.label = fn_label

            paras = entry[:paragraphs]
            if paras && !paras.empty?
              paras.each { |para| fn.paragraph para }
            else
              fn_para = ::Sts::NisoSts::Paragraph.new
              fn_para.text = [text]
              fn.paragraph fn_para
            end

            group.fn fn
          end

          group
        end
      end
    end
  end
end
