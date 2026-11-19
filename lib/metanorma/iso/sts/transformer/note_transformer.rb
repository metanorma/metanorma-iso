# frozen_string_literal: true

require "cgi"

module Metanorma
  module Iso
    module Sts
      module Transformer
        # Converts MN <note> / <example> blocks (outside term entries)
        # to STS <non-normative-note> / <non-normative-example>.
        # Guidelines 5.6: the designation (NOTE / EXAMPLE, with any
        # number) is captured in <label>. Term entries use "Note N to
        # entry:" via TermTransformer.
        class NoteTransformer < Base
          # List-carrying attributes across the block classes served by
          # this transformer, in grammar order. Read through the typed
          # registry guard (extract_lists) — not every class declares
          # every slot.
          LIST_ATTRS = %i[ul ol list].freeze

          def transform(source_note)
            paragraphs = extract_paragraphs(source_note)
            lists = extract_lists(source_note)
            preformats = extract_preformats(source_note)
            return nil if paragraphs.empty? && lists.empty? && preformats.empty?

            if example?(source_note)
              label = designation_label(source_note, "EXAMPLE")
              ModelBuilder.non_normative_example(paragraph: paragraphs, list: lists, preformat: preformats, label: label)
            elsif source_note.is_a?(admonition_block_class)
              ModelBuilder.non_normative_note(paragraph: paragraphs, list: lists,
                                              label: admonition_label(source_note))
            else
              ModelBuilder.non_normative_note(paragraph: paragraphs, list: lists,
                                              label: designation_label(source_note, "NOTE"))
            end
          end

          # Guidelines 5.6: the designation text (NOTE / EXAMPLE, with
          # any number) is captured in <label>. Prefer the presentation
          # fmt-name caption label; synthesize from the kind + autonum
          # when the source carries none. The number can live only in
          # the rendered caption ("EXAMPLE <autonum>1</autonum>") —
          # recover it there when the element carries no @autonum.
          # Only blocks that declare @autonum answer it (QuoteBlock /
          # AdmonitionBlock have no autonum slot — the guarded read
          # keeps unknown block shapes from crashing the dispatch).
          def designation_label(source, kind)
            number = attribute_string(source, :autonum)
            number = caption_number(source) if number.empty?
            number.empty? ? kind : "#{kind} #{number}"
          end

          def caption_number(source)
            return "" unless source.class.attributes.key?(:fmt_name) && source.fmt_name

            text = RenderedTextExtractor.text_of(source.fmt_name).to_s.strip
            # Anchored-prefix match on the reversed string stays linear —
            # an end-anchored \d+\z scan backtracks quadratically.
            text.reverse[/\A\d+/]&.reverse || ""
          end

          # MN renders body examples as "<span class='example-label'>
          # EXAMPLE N</span>" — "Example" plus the autonum, even when

          # SourcecodeBlock stores its text in body.content (the bare
          # `content` attribute is nil for parsed documents). The body's
          # content is markup-encoded by the model's roundtrip contract;
          # decoded_content (metanorma-document >= 0.3.1) unwraps it —
          # with a local decode as the fallback for older releases.
          def transform_preformat(source_code)
            text = preformat_text(source_code)
            return nil if text.nil? || text.empty?

            ::Sts::NisoSts::Preformat.new(content: [text])
          end

          private

          # Guarded attribute read: only classes that declare the
          # attribute answer it, so blocks lacking a slot (e.g. an
          # autonum on QuoteBlock) yield "" instead of raising.
          def attribute_string(source, attr)
            return "" unless source.class.attributes.key?(attr)

            source.public_send(attr).to_s.strip
          end

          # mnconvert renders an admonition's designation as the block's
          # type, upcased (<admonition type="editorial"> yields
          # <label>EDITORIAL</label>); an untyped admonition carries no
          # designation at all.
          def admonition_label(source)
            type = attribute_string(source, :type)
            type.empty? ? nil : type.upcase
          end

          def example?(source_note)
            source_note.is_a?(example_block_class)
          end

          def extract_paragraphs(source_note)
            case source_note
            when example_block_class
              Array(source_note.paragraphs).map { |p| paragraph_transformer.transform(p) }
            when note_block_class
              Array(source_note.content)
                .select { |p| p.is_a?(paragraph_block_class) }
                .map { |p| paragraph_transformer.transform(p) }
            when admonition_block_class, quote_block_class
              Array(source_note.paragraphs).map { |p| paragraph_transformer.transform(p) }
            else
              []
            end
          end

          # The note/example/admonition body lives on typed attributes
          # (content / paragraphs hold the paragraphs; ul / ol / list the
          # block lists; sourcecode the literal blocks) — walking mixed
          # content yields nothing and emits an empty shell. Each
          # attribute is read only where the class declares it (the
          # AdmonitionBlock carries no list slots; the ExampleBlock's
          # grammar spells unordered lists both <list> and <ul>) — the
          # guarded read keeps unknown block shapes from crashing the
          # dispatch: blocks without the expected structure render what
          # they have and skip the rest. The dl/quote/table/figure/
          # requirement carriers have no counterpart on the NisoSts
          # note/example models and are skipped.
          def extract_lists(source_note)
            LIST_ATTRS.flat_map do |attr|
              next [] unless source_note.class.attributes.key?(attr)
              Array(source_note.public_send(attr)).map { |l| list_transformer.transform(l) }
            end
          end

          # Only ExampleBlock carries sourcecode children (NoteBlock has
          # none — the typed interface, not a probe).
          def extract_preformats(source_note)
            return [] unless source_note.is_a?(example_block_class)

            Array(source_note.sourcecode).filter_map { |sc| transform_preformat(sc) }
          end

          def preformat_text(source_code)
            return unless source_code.is_a?(sourcecode_block_class)

            body = source_code.body
            return decoded_sourcecode_text(source_code) unless body

            content = body.content if body.is_a?(Lutaml::Model::Serializable)
            return CGI.unescapeHTML(Array(content).join) if content && !content.to_s.empty?

            decoded_sourcecode_text(source_code)
          end

          # SourcecodeBlock keeps its literal on the plain +content+
          # attribute (map_content); decoded_content unwraps the markup
          # encoding on metanorma-document >= 0.3.1, with a local decode
          # as the fallback for older releases.
          def decoded_sourcecode_text(source_code)
            # SourcecodeBlock#body carries the markup-encoded code text;
            # the markup entities decode locally (CGI.unescapeHTML).
            raw = source_code.body || source_code.content
            return nil if raw.nil?

            text = CGI.unescapeHTML(Array(raw).join)
            text.empty? ? nil : text
          end

          def note_block_class
            Metanorma::Document::Components::Blocks::NoteBlock
          end

          def example_block_class
            Metanorma::Document::Components::AncillaryBlocks::ExampleBlock
          end

          def admonition_block_class
            Metanorma::Document::Components::MultiParagraph::AdmonitionBlock
          end

          def quote_block_class
            Metanorma::Document::Components::MultiParagraph::QuoteBlock
          end

          def sourcecode_block_class
            Metanorma::Document::Components::AncillaryBlocks::SourcecodeBlock
          end

          def paragraph_block_class
            Metanorma::Document::Components::Paragraphs::ParagraphBlock
          end
        end
      end
    end
  end
end
