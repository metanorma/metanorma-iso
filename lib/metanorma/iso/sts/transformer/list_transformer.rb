# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      class Transformer::ListTransformer < Transformer::Base
        OL_TYPE_MAP = {
          "arabic" => "order",
          "loweralpha" => "alpha-lower",
          "upperalpha" => "alpha-upper",
          "lowerroman" => "roman-lower",
          "upperroman" => "roman-upper",
        }.freeze

        def transform(source)
          build_ordered(::Sts::IsoSts::List) do |list|
            list.id = source.id if source.id && !source.id.start_with?("_")
            list.list_type = list_type_for(source)

            source.listitem&.each do |li|
              list.list_item transform_list_item(li)
            end
          end
        end

        private

        def list_type_for(source)
          case source
          when Metanorma::Document::Components::Lists::UnorderedList
            "bullet"
          when Metanorma::Document::Components::Lists::OrderedList
            OL_TYPE_MAP[source.type] || "order"
          end
        end

        def transform_list_item(li)
          build_ordered(::Sts::IsoSts::ListItem) do |item|
            item.id = li.id if li.id && !li.id.start_with?("_")

            if li.content_text && !li.content_text.empty?
              item.p paragraph_transformer.transform(
                build_text_paragraph(li.content_text),
              )
            elsif li.paragraphs && !li.paragraphs.empty?
              li.paragraphs.each do |para|
                item.p paragraph_transformer.transform(para)
              end
            end

            li.unordered_lists&.each { |ul| item.list transform(ul) }
            li.ordered_lists&.each { |ol| item.list transform(ol) }
          end
        end

        def build_text_paragraph(text_array)
          text = text_array.is_a?(Array) ? text_array.join : text_array.to_s
          para = Metanorma::Document::Components::Paragraphs::ParagraphBlock.new
          para.text = [text]
          para
        end
      end
    end
  end
end
