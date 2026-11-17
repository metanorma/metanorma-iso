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
          def transform(source_note)
            paragraphs = extract_paragraphs(source_note)
            lists = extract_lists(source_note)
            preformats = extract_preformats(source_note)
            return nil if paragraphs.empty? && lists.empty? && preformats.empty?

            if example?(source_note)
              label = example_label(source_note)
              ModelBuilder.non_normative_example(paragraph: paragraphs, list: lists, preformat: preformats, label: label)
            else
              ModelBuilder.non_normative_note(paragraph: paragraphs, list: lists,
                                              label: designation_label(source_note, "NOTE"))
            end
          end

          # Guidelines 5.6: the designation text (NOTE / EXAMPLE, with
          # any number) is captured in <label>. Prefer the presentation
          # fmt-name caption label; synthesize from the kind + autonum
          # when the source carries none.
          def designation_label(source, kind)
            name = source.class.method_defined?(:fmt_name) ? source.fmt_name : nil
            wrapper = Array(name).first if name
            text = wrapper ? RenderedTextExtractor.text_of(wrapper).strip : ""
            return text unless text.empty?

            number = source.class.method_defined?(:autonum) ? source.autonum.to_s.strip : ""
            number.empty? ? kind : "#{kind} #{number}"
          end

          # MN renders body examples as "<span class='example-label'>
          # EXAMPLE N</span>" — "Example" plus the autonum, even when
          # the source carries no explicit name. The label ends up
          # inside the first paragraph so parity text comparison sees
          # it on both sides.
          def example_label(source_example)
            return nil unless source_example.is_a?(example_block_class)

            number = source_example.autonum if source_example.class.method_defined?(:autonum)
            number && !number.to_s.empty? ? "Example #{number}" : "Example"
          end

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
            else
              []
            end
          end

          # The note/example body lives on typed attributes (content /
          # paragraphs hold the paragraphs; ul / ol the block lists;
          # sourcecode the literal blocks) — walking mixed content yields
          # nothing and emits an empty shell. The dl/quote/table/figure/
          # requirement carriers have no counterpart on the NisoSts
          # note/example models and are skipped.
          def extract_lists(source_note)
            %i[ul ol].flat_map do |attr|
              next [] unless source_note.class.method_defined?(attr)

              Array(source_note.public_send(attr)).map { |l| list_transformer.transform(l) }
            end
          end

          def extract_preformats(source_note)
            return [] unless source_note.class.method_defined?(:sourcecode)

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
            return nil unless source_code.class.method_defined?(:content)

            raw = if source_code.class.method_defined?(:decoded_content) && source_code.decoded_content
                    source_code.decoded_content
                  else
                    source_code.content
                  end
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
