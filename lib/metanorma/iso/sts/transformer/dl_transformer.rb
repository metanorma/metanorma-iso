# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      module Transformer
        # Converts MN `<dl>`/`<dt>`/`<dd>` to STS `<def-list>`/`<def-item>`.
        # Follows mnconvert's pattern (mn2xml.xsl lines 5327-5528): each
        # dt/dd pair becomes a def-item with term + def children. Notes
        # inside dl are extracted as siblings after the def-list.
        class DlTransformer < Base
          def transform(source_dl)
            def_items = pair_dt_dd(source_dl)
            ModelBuilder.def_list(id: source_dl.id, def_items: def_items)
          end

          private

          def pair_dt_dd(source_dl)
            dts = Array(source_dl.dt)
            dds = Array(source_dl.dd)
            dts.each_with_index.map do |dt, i|
              build_def_item(dt, dds[i])
            end
          end

          def build_def_item(dt, dd)
            attrs = {}
            attrs[:id] = dt.id if dt.class.method_defined?(:id) && dt.id

            term_text = RenderedTextExtractor.text_of(dt)
            term = term_text.nil? || term_text.empty? ? nil : ModelBuilder.term(content: [term_text])

            defn = dd ? build_def(dd) : nil

            attrs[:term] = term if term
            attrs[:defn] = defn if defn
            ModelBuilder.def_item(**attrs)
          end

          def build_def(dd)
            paragraphs = Array(dd.p).map { |p| paragraph_transformer.transform(p) }
            ModelBuilder.def(paragraph: paragraphs)
          end
        end
      end
    end
  end
end
