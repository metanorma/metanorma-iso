# frozen_string_literal: true
module Metanorma
  module Iso
    module Sts
      module Transformer
        class TableTransformer < Base
          def transform(source_table)
            attrs = {}
            attrs[:id] = source_table.id if source_table.class.method_defined?(:id) && source_table.id
            label = table_label(source_table)
            attrs[:label] = label if label
            caption = table_caption(source_table)
            attrs[:caption] = caption if caption
            table = build_table(source_table)
            attrs[:table] = [table] if table
            ::Sts::TbxIsoTml::TableWrap.new(attrs)
          end

          private

          # "Table 2" from the presentation XML autonum attribute.
          def table_label(source_table)
            return nil unless source_table.class.method_defined?(:autonum) && source_table.autonum

            "Table #{source_table.autonum}"
          end

          def table_caption(source_table)
            return nil unless source_table.class.method_defined?(:name) && source_table.name

            text = RenderedTextExtractor.text_of(source_table.name).strip
            return nil if text.empty?

            ::Sts::NisoSts::Caption.new(
              title: ::Sts::NisoSts::Title.new(content: [text])
            )
          end

          def build_table(source_table)
            attrs = {}
            if source_table.class.method_defined?(:thead) && source_table.thead
              attrs[:thead] = build_section(source_table.thead, ::Sts::TbxIsoTml::Thead)
            end
            if source_table.class.method_defined?(:tbody) && source_table.tbody
              attrs[:tbody] = build_section(source_table.tbody, ::Sts::TbxIsoTml::Tbody)
            end
            ::Sts::TbxIsoTml::Table.new(attrs)
          end

          def build_section(source_section, klass)
            trs = Array(source_section.tr).map { |tr| build_tr(tr) }
            klass.new(tr: trs)
          end

          def build_tr(tr)
            th_cells = Array(tr.th).map { |c| build_cell(c, ::Sts::TbxIsoTml::Th) }
            td_cells = Array(tr.td).map { |c| build_cell(c, ::Sts::TbxIsoTml::Td) }
            attrs = {}
            attrs[:th] = th_cells if th_cells.any?
            attrs[:td] = td_cells if td_cells.any?
            ::Sts::TbxIsoTml::Tr.new(attrs)
          end

          def build_cell(cell, klass)
            entries = cell_entries(cell)
            fns = cell_footnotes(cell)
            klass.new do |c|
              entries.each do |kind, value|
                case kind
                when :text then c.content value
                when :inline_formula then c.inline_formula value
                when :monospace then c.monospace value
                when :bold then c.bold value
                when :italic then c.italic value
                end
              end
              fns.each { |fn| c.fn fn }
            end
          end

          # Extracts <fn> footnotes from the cell. MN table cells with
          # footnote:[...] in AsciiDoc produce an inline <fn> carrying
          # the footnote body (with paragraphs and math). STS preserves
          # the footnote as a sibling <fn> element inside the cell so
          # the renderer can show its content.
          def cell_footnotes(cell)
            return [] unless cell.class.method_defined?(:each_mixed_content)

            cell.each_mixed_content.filter_map do |node|
              next if node.is_a?(String)
              next unless node.is_a?(Metanorma::Document::Components::Inline::FnElement)

              build_fn(node)
            end
          end

          def build_fn(fn_element)
            paragraphs = Array(fn_element.p).map.with_index { |p, i| build_fn_paragraph(p, fn_element, first: i.zero?) }
            return nil if paragraphs.empty?

            attrs = { id: fn_element.id, p: paragraphs }
            label = fn_label(fn_element)
            attrs[:label] = ::Sts::NisoSts::Label.new(content: [label]) if label
            ::Sts::TbxIsoTml::Fn.new(attrs)
          end

          # Fn#p is typed as Sts::NisoSts::Paragraph (uses :text attr).
          # Our paragraph_transformer produces Sts::NisoSts::Paragraph.
          # Convert by extracting text — footnote bodies in MN table
          # cells drop inline math, so we accept text-only. The fn's
          # reference letter prefixes the first paragraph to match
          # MN's "<sup>a</sup> body" rendering.
          def build_fn_paragraph(mn_p, fn_element, first:)
            iso_p = paragraph_transformer.transform(mn_p)
            text = extract_paragraph_text(iso_p)
            label = fn_label(fn_element)
            text = "#{label} #{text}" if first && label && !text.empty?
            ::Sts::NisoSts::Paragraph.new(text: [text])
          end

          def extract_paragraph_text(iso_paragraph)
            parts = []
            iso_paragraph.element_order.each do |entry|
              if entry.node_type == :text
                parts << entry.text_content.to_s
              elsif entry.node_type == :element && entry.name == "inline-formula"
                # Best-effort: extract any mi/mn/mo text from the math
                parts << extract_formula_text(iso_paragraph)
              end
            end
            parts.join.strip
          end

          def extract_formula_text(iso_paragraph)
            Array(iso_paragraph.inline_formula).map do |f|
              math = f.math
              next "" unless math
              extract_math_text(math.to_xml)
            end.join
          end

          # Strip comments and MathML/XML tags from a math element's
          # serialised XML so the parity validator compares only the
          # visible text. Comment stripping uses String#index (linear,
          # correct for multi-char terminators); tag stripping uses
          # simple non-nested character classes.
          def extract_math_text(math_xml)
            stripped = strip_xml_comments(math_xml.to_s)
            stripped
              .gsub(%r{</?\w+:[^>]*>}, " ")
              .gsub(/<\/?[^>]*>/, " ")
              .gsub(/\s+/, " ")
              .strip
          end

          # Removes every `<!-- ... -->` comment from +str+. Linear in
          # the input size; correct for comments containing `>` (which
          # the previous regex-based stripper would prematurely match).
          # An unterminated comment runs to end-of-string.
          def strip_xml_comments(str)
            result = String.new
            pos = 0
            while (open_idx = str.index("<!--", pos))
              result << str[pos, open_idx - pos]
              close_idx = str.index("-->", open_idx + 4)
              break if close_idx.nil?
              pos = close_idx + 3
            end
            result << str[pos..] unless pos.nil? || pos >= str.length
            result
          end

          def fn_label(fn_element)
            ref = fn_element.reference
            ref.to_s unless ref.nil? || ref.to_s.empty?
          end

          # Walks the cell's mixed content in document order and produces
          # an array of [:text, String] | [:inline_formula, InlineFormula] |
          # [:monospace|:bold|:italic, model] tuples. The builder in
          # build_cell routes them to the correct typed collection on the
          # Td/Th model, preserving cross-type ordering via lutaml-model's
          # mixed_content element_order.
          def cell_entries(cell)
            entries = []
            current_text = nil
            flush = lambda do
              return if current_text.nil?
              entries << [:text, current_text]
              current_text = nil
            end

            walk_cell(cell) do |kind, node, text|
              case kind
              when :text
                current_text = (current_text || "") + text
              when :stem
                formula = build_inline_formula(node)
                if formula
                  flush.call
                  entries << [:inline_formula, formula]
                else
                  mirror_text = cell_mirror_text(node)
                  current_text = (current_text || "") + mirror_text if mirror_text && !mirror_text.empty?
                end
              when :monospace
                flush.call
                entries << [:monospace, ::Sts::NisoSts::Monospace.new(content: [text])]
              when :bold
                flush.call
                entries << [:bold, ::Sts::TbxIsoTml::Bold.new(value: [text])]
              when :italic
                flush.call
                entries << [:italic, ::Sts::TbxIsoTml::Italic.new(value: [text])]
              end
            end
            flush.call
            entries
          end

          def walk_cell(cell)
            return unless cell.class.method_defined?(:each_mixed_content)

            @cell_stem_mirrors = build_cell_stem_mirrors(cell)

            cell.each_mixed_content do |node|
              if node.is_a?(String)
                yield(:text, node, node)
                next
              end

              case node.class.name&.split("::")&.last
              when "StemInlineElement", "StemBlockElement"
                yield(:stem, node, nil)
              when "FmtStemElement"
                next
              when "AsciimathElement"
                next
              when "TtElement", "MonospaceElement"
                yield(:monospace, node, RenderedTextExtractor.text_of(node))
              when "StrongRawElement", "StrongElement"
                yield(:bold, node, RenderedTextExtractor.text_of(node))
              when "EmRawElement", "EmElement"
                yield(:italic, node, RenderedTextExtractor.text_of(node))
              else
                text = RenderedTextExtractor.text_of(node)
                yield(:text, node, text) if text && !text.empty?
              end
            end
          end

          def build_inline_formula(stem_node)
            mirror = @cell_stem_mirrors && @cell_stem_mirrors[stem_node.id]
            source = mirror || stem_node
            ::Metanorma::Iso::Sts::MathmlBuilder.inline_formula_from_stem(
              source,
              klass: ::Sts::NisoSts::InlineFormula
            )
          end

          def build_cell_stem_mirrors(cell)
            map = {}
            return map unless cell.class.method_defined?(:each_mixed_content)

            cell.each_mixed_content do |node|
              next unless node.is_a?(Metanorma::Document::Components::Inline::FmtStemElement)
              Array(node.semx).each do |semx|
                source = semx.source if semx.is_a?(Metanorma::Document::Components::Inline::SemxElement)
                map[source] = node if source && !source.empty?
              end
            end
            map
          end

          def cell_mirror_text(stem_node)
            mirror = @cell_stem_mirrors && @cell_stem_mirrors[stem_node.id]
            return nil unless mirror

            Array(mirror.semx).map do |semx|
              next nil unless semx.is_a?(Metanorma::Document::Components::Inline::SemxElement)
              semx.text
            end.compact.join
          rescue StandardError
            nil
          end
        end
      end
    end
  end
end
