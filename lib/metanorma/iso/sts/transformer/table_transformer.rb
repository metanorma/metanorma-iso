# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      class Transformer::TableTransformer < Transformer::Base
        def transform_wrap(table)
          build_ordered(::Sts::TbxIsoTml::TableWrap) do |tw|
            tw.id = id_for(table)

            table_label = label_for(table)
            tw.label table_label if table_label

            if table.name
              caption = build_ordered(::Sts::NisoSts::Caption) do |c|
                inline_transformer.apply_inline_content(table.name, c)
              end
              tw.caption caption
            end

            tw.table transform(table)

            if table.note && !table.note.empty?
              table.note.each do |n|
                tw.non_normative_note note_transformer.transform(n)
              end
            end
          end
        end

        def transform(table)
          build_ordered(::Sts::TbxIsoTml::Table) do |t|
            t.width = table.width if table.width
            t.summary = table.summary if table.summary

            if table.colgroup
              cg = build_ordered(::Sts::TbxIsoTml::Colgroup) do |colgroup|
                Array(table.colgroup.col).each do |col|
                  c = ::Sts::TbxIsoTml::Col.new
                  c.width = col.width if col.width
                  colgroup.col c
                end
              end
              t.colgroup cg
            end

            if table.thead
              t.thead transform_section(table.thead,
                                        ::Sts::TbxIsoTml::Thead)
            end
            if table.tbody
              t.tbody transform_section(table.tbody,
                                        ::Sts::TbxIsoTml::Tbody)
            end
            if table.tfoot
              t.tfoot transform_section(table.tfoot,
                                        ::Sts::TbxIsoTml::Tfoot)
            end
          end
        end

        private

        def transform_section(section, klass)
          inst = klass.new
          Array(section.tr).each do |tr|
            row = build_ordered(::Sts::TbxIsoTml::Tr) do |r|
              Array(tr.th).each { |th| r.th transform_cell(th, ::Sts::TbxIsoTml::Th) }
              Array(tr.td).each { |td| r.td transform_cell(td, ::Sts::TbxIsoTml::Td) }
            end
            inst.tr row
          end
          inst
        end

        def transform_cell(cell, klass)
          c = klass.new
          c.id = cell.id if cell.id && !cell.id.start_with?("_")
          c.colspan = cell.colspan.to_s if cell.colspan
          c.rowspan = cell.rowspan.to_s if cell.rowspan
          c.align = cell.align if cell.align
          c.valign = cell.valign if cell.valign

          if cell.element_order && !cell.element_order.empty?
            inline_transformer.apply_inline_content(cell, c)
          elsif cell.text && !cell.text.empty?
            c.content Array(cell.text).join
          end
          c
        end

        def label_for(table)
          autonum = table.autonum if table.class.method_defined?(:autonum)
          autonum && !autonum.to_s.empty? ? ::Sts::IsoSts::Label.new(content: [autonum.to_s]) : nil
        end
      end
    end
  end
end
