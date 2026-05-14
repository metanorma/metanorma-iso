# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      class Transformer::FootnoteCollector
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

          group = build_ordered_fn_group

          @footnotes.each do |text, entry|
            fn = build_ordered_fn
            fn.id = entry[:id]

            fn_label = ::Sts::IsoSts::Label.new
            fn_label.content = ["<sup>#{entry[:number]})</sup>"]
            fn.label = fn_label

            paras = entry[:paragraphs]
            if paras && !paras.empty?
              paras.each { |para| fn.paragraph para }
            else
              fn_para = ::Sts::IsoSts::Paragraph.new
              fn_para.content = [text]
              fn.paragraph fn_para
            end

            group.fn fn
          end

          group
        end

        private

        def build_ordered_fn_group
          inst = ::Sts::IsoSts::FnGroup.new
          inst.instance_variable_set(:@__order_tracking__, true)
          inst.content_type = "footnotes"
          inst
        end

        def build_ordered_fn
          inst = ::Sts::IsoSts::Fn.new
          inst.instance_variable_set(:@__order_tracking__, true)
          inst
        end
      end
    end
  end
end
