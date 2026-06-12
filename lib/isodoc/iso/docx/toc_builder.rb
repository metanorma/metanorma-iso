# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      # Generates Table of Contents entries from the document model.
      #
      # Walks the model structure to collect section headings at levels 1-3
      # and renders them as TOC1/TOC2/TOC3 paragraphs with PAGEREF fields
      # pointing to the section's bookmark.
      #
      # The TOC appears between the copyright page and the Foreword, as a
      # separate content section within the front matter.
      #
      # Each entry follows the reference DOCX structure:
      #   <w:p>
      #     <w:pPr><w:pStyle w:val="TOC1"/></w:pPr>
      #     <w:r><w:t>Foreword</w:t></w:r>
      #     <w:r><w:tab/></w:r>
      #     <w:r><w:fldChar w:fldCharType="begin"/></w:r>
      #     <w:r><w:instrText> PAGEREF _Toc... \h </w:instrText></w:r>
      #     <w:r><w:fldChar w:fldCharType="separate"/></w:r>
      #     <w:r><w:t>1</w:t></w:r>
      #     <w:r><w:fldChar w:fldCharType="end"/></w:r>
      #   </w:p>
      class TocBuilder
        def initialize(resolver, inline_renderer, context)
          @resolver = resolver
          @inline = inline_renderer
          @context = context
        end

        # Render the TOC heading and all entries.
        def render(model, doc)
          return unless model

          # Render "Contents" heading
          render_toc_heading(doc)

          # Collect entries by walking the model
          entries = collect_entries(model)
          return if entries.empty?

          # Render each TOC entry
          entries.each { |entry| render_toc_entry(entry, doc) }
        end

        private

        def render_toc_heading(doc)
          para = Uniword::Builder::ParagraphBuilder.new
          para.style = @resolver.paragraph_style(:contents_title)
          para << "Contents"
          doc << para

          # Insert Word TOC field instruction so Word can update page numbers
          render_toc_field(doc)
        end

        # Insert a { TOC \o "1-3" } field that Word uses to populate TOC.
        def render_toc_field(doc)
          para = Uniword::Wordprocessingml::Paragraph.new
          # begin fldChar
          para.runs << Uniword::Wordprocessingml::Run.new(
            field_char: Uniword::Wordprocessingml::FieldChar.new(
              field_char_type: "begin",
            ),
          )
          # instrText
          para.runs << Uniword::Wordprocessingml::Run.new(
            instr_text: Uniword::Wordprocessingml::InstrText.new(
              text: ' TOC \\o "1-3" \\h \\z \\u ',
            ),
          )
          # separate fldChar
          para.runs << Uniword::Wordprocessingml::Run.new(
            field_char: Uniword::Wordprocessingml::FieldChar.new(
              field_char_type: "separate",
            ),
          )
          # end fldChar
          para.runs << Uniword::Wordprocessingml::Run.new(
            field_char: Uniword::Wordprocessingml::FieldChar.new(
              field_char_type: "end",
            ),
          )
          doc << para
        end

        TocEntry = Struct.new(:title_text, :level, :bookmark_name, keyword_init: true)

        def collect_entries(model)
          entries = []

          # Preface entries (Foreword, Introduction)
          if model.preface
            add_preface_entries(entries, model.preface)
          end

          # Body entries (Scope, Terms, etc.)
          if model.sections
            add_section_entries(entries, model.sections)
          end

          # Annex entries
          Array(model.annex).each do |annex|
            add_annex_entry(entries, annex)
          end

          # Bibliography entry
          if model.bibliography
            add_bibliography_entry(entries, model.bibliography)
          end

          entries
        end

        def add_preface_entries(entries, preface)
          if preface.foreword
            entries << build_entry(
              preface.foreword, 1,
            )
          end

          if preface.introduction
            entries << build_entry(
              preface.introduction, 1,
            )
          end

          Array(preface.clause).each do |clause|
            add_clause_entries(entries, clause, 1) unless toc_clause?(clause)
          end
        end

        def add_section_entries(entries, sections)
          if sections.class.attributes.key?(:clause)
            Array(sections.clause).each do |clause|
              add_clause_entries(entries, clause, 1)
            end
          end

          if sections.class.attributes.key?(:terms)
            Array(sections.terms).each do |terms_sect|
              entries << build_entry(terms_sect, 1)
            end
          end

          if sections.class.attributes.key?(:definitions)
            Array(sections.definitions).each do |defn|
              entries << build_entry(defn, 1)
            end
          end
        end

        def add_clause_entries(entries, clause, level)
          return if level > 3

          entries << build_entry(clause, level)

          # Recurse into sub-clauses
          if clause.class.attributes.key?(:clause)
            Array(clause.clause).each do |sub|
              add_clause_entries(entries, sub, level + 1)
            end
          end
        end

        def add_annex_entry(entries, annex)
          entries << build_entry(annex, 1)

          if annex.class.attributes.key?(:clause)
            Array(annex.clause).each do |sub|
              add_clause_entries(entries, sub, 2)
            end
          end
        end

        def add_bibliography_entry(entries, bib)
          entries << build_entry(bib, 1)

          if bib.class.attributes.key?(:references)
            Array(bib.references).each do |refs|
              entries << build_entry(refs, 1) if has_title?(refs)
            end
          end
        end

        def build_entry(node, level)
          title = extract_title(node)
          id = node.id if node.class.attributes.key?(:id)
          TocEntry.new(
            title_text: title,
            level: level,
            bookmark_name: id || "_Toc#{object_id}_#{level}",
          )
        end

        def extract_title(node)
          fmt_title = node.fmt_title if node.class.attributes.key?(:fmt_title)
          return collect_text(fmt_title) if fmt_title

          title = node.title if node.class.attributes.key?(:title)
          return collect_text(title) if title

          ""
        end

        def has_title?(node)
          return false unless node

          fmt = node.fmt_title if node.class.attributes.key?(:fmt_title)
          t = node.title if node.class.attributes.key?(:title)
          fmt || t
        end

        def toc_clause?(clause)
          type = clause.type_attr if clause.class.attributes.key?(:type_attr)
          type == "toc"
        end

        def render_toc_entry(entry, doc)
          style = toc_style(entry.level)
          para = Uniword::Builder::ParagraphBuilder.new
          para.style = style

          # Title text
          para << entry.title_text

          # Tab separator
          tab_run = Uniword::Wordprocessingml::Run.new
          tab_run.tab = Uniword::Wordprocessingml::Tab.new
          para << tab_run

          # PAGEREF field
          para << Uniword::Wordprocessingml::Run.new(
            field_char: Uniword::Wordprocessingml::FieldChar.new(
              field_char_type: "begin",
            ),
          )
          para << Uniword::Wordprocessingml::Run.new(
            instr_text: Uniword::Wordprocessingml::InstrText.new(
              text: " PAGEREF #{entry.bookmark_name} \\h ",
            ),
          )
          para << Uniword::Wordprocessingml::Run.new(
            field_char: Uniword::Wordprocessingml::FieldChar.new(
              field_char_type: "separate",
            ),
          )
          para << Uniword::Wordprocessingml::Run.new(text: "")
          para << Uniword::Wordprocessingml::Run.new(
            field_char: Uniword::Wordprocessingml::FieldChar.new(
              field_char_type: "end",
            ),
          )

          doc << para
        end

        def toc_style(level)
          key = :"toc#{level}"
          @resolver.paragraph_style(key) || "TOC#{level}"
        end

        def collect_text(node)
          return node.to_s if node.is_a?(String)
          return "" unless node

          texts = []
          [:text, :content, :content_text].each do |attr|
            next unless node.class.attributes.key?(attr)
            val = node.public_send(attr)
            case val
            when Array then texts.concat(val.grep(String))
            when String then texts << val
            end
          end
          texts.compact.join
        end
      end
    end
  end
end
