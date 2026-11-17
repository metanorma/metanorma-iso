# frozen_string_literal: true
module Metanorma
  module Iso
    module Sts
      module Transformer
        class ListTransformer < Base
          def transform(source_list)
            list_type = if source_list.is_a?(Metanorma::Document::Components::Lists::OrderedList)
                          "arabic"
                        else
                          "bullet"
                        end
            items = Array(source_list.listitem).map { |li| build_list_item(li) }
            ModelBuilder.list(list_type: list_type, list_item: items)
          end

          def transform_def_list(source_dl)
            items = Array(source_dl.dt).zip(Array(source_dl.dd)).map do |dt, dd|
              build_def_item(dt, dd)
            end.compact
            ::Sts::NisoSts::DefList.new(def_item: items)
          end

          private

          def build_list_item(li)
            nested_lists = build_nested_lists(li)

            ::Sts::NisoSts::ListItem.new do |item|
              label = item_label(li)
              item.label ::Sts::NisoSts::Label.new(content: [label]) if label
              Array(li.paragraphs).each do |p|
                item.p paragraph_transformer.transform(p)
                # MN nests the trailing note INSIDE the item's <p>
                # (<p>text<note>…</note></p>); the STS list-item carries
                # it as an all-notes.class member.
                Array(p.note).each do |n|
                  note = note_transformer.transform(n)
                  item.non_normative_note note if note
                end
              end
              nested_lists.each { |l| item.list l }
              append_item_siblings(li, item)
            end
          end

          # MN attaches trailing notes/examples to the list item as typed
          # siblings; the STS list-item model carries them as
          # all-notes.class members.
          def append_item_siblings(li, item)
            Array(li.note).each do |n|
              note = note_transformer.transform(n)
              item.non_normative_note note if note
            end
            Array(li.example).each do |ex|
              example = note_transformer.transform(ex)
              item.non_normative_example example if example
            end
          end

          # The item's marker from the presentation XML (its fmt-name /
          # autonum, e.g. "—" or "1."), nil when absent.
          def item_label(li)
            return nil unless li.class.method_defined?(:fmt_name) && li.fmt_name

            text = RenderedTextExtractor.text_of(li.fmt_name).strip
            text.empty? ? nil : text
          end

          # Recurses into nested <ul>/<ol> children of a list item.
          # MN stores them as typed collection attrs on ListItem.
          def build_nested_lists(li)
            results = []
            [:unordered_lists, :ordered_lists].each do |attr|
              next unless li.class.method_defined?(attr)
              Array(li.public_send(attr)).each do |nested|
                results << transform(nested)
              end
            end
            results
          end

          def build_def_item(dt, dd)
            term_text = RenderedTextExtractor.text_of(dt)
            desc_text = extract_dd_text(dd)
            return nil unless term_text || desc_text

            attrs = {}
            attrs[:term] = ::Sts::NisoSts::Term.new(text: [term_text]) if term_text && !term_text.empty?
            if desc_text && !desc_text.empty?
              attrs[:def] = ::Sts::NisoSts::Def.new(
                paragraph: [::Sts::NisoSts::Paragraph.new(content: [desc_text])]
              )
            end
            ::Sts::NisoSts::DefItem.new(attrs)
          end

          def extract_dd_text(dd)
            return nil unless dd
            ps = dd.p if dd.is_a?(Lutaml::Model::Serializable) && dd.class.method_defined?(:p)
            ps = Array(ps)
            return RenderedTextExtractor.text_of(dd) if ps.empty?
            texts = ps.map { |p| RenderedTextExtractor.text_of(p) }.reject(&:empty?)
            texts.empty? ? nil : texts.join(" ")
          end
        end
      end
    end
  end
end
