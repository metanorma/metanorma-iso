# frozen_string_literal: true

require "uniword"
require "metanorma/document"
require "metanorma/iso_document"

module IsoDoc
  module Iso
    module Docx
      # Converts a Metanorma::IsoDocument::Root model to DOCX or MHTML via Uniword.
      #
      # Architecture:
      #   metanorma-document model → Adapter → Uniword builders → DOCX/MHTML
      #
      # The Adapter delegates to specialized renderer objects:
      #   - CoverRenderer      — cover page from bibdata
      #   - BoilerplateRenderer — copyright, license, address
      #   - SectionManager     — section breaks, headers, footers
      #   - TocBuilder         — table of contents entries
      #   - InlineRenderer     — inline element rendering
      #
      # Output format is determined by file extension (.docx or .doc).
      #
      # Uses case/when dispatch on model class (type-driven, no reflection).
      # Each element type maps to exactly one visitor method (MECE).
      # New element types are added by extending the case statement
      # and adding a new visitor method (open/closed principle).
      class Adapter
        include ModelUtils

        attr_reader :context, :resolver

        # @param template [Symbol] :dis or :simple (default :dis)
        # @param template_path [String, nil] explicit template DOCX path
        # @param style_mapping_config [String, nil] explicit YAML config path
        def initialize(template: :dis, template_path: nil, style_mapping_config: nil)
          @template = template
          @template_path = template_path || IsoDoc::Iso::DocxTemplates.template_path(template)
          @style_mapping = DocxStyleMapping.new(
            template: template, config_path: style_mapping_config,
          )
          @context = Context.new
          @resolver = StyleResolver.new(@style_mapping, @context)
          @inline_renderer = nil
          @cover_renderer = nil
          @boilerplate_renderer = nil
          @section_manager = nil
          @toc_builder = nil
        end

        # Convert an XML string or file path to DOCX (.docx) or MHTML (.doc).
        def convert(xml_input, output_path)
          doc_model = parse_xml(xml_input)
          doc = create_document
          reset_state(doc)
          visit_root(doc_model, doc)
          apply_custom_properties(doc_model, doc)
          save_document(doc.model, output_path)
        end

        # Convert an already-parsed model to DOCX or MHTML.
        def convert_model(model, output_path)
          doc = create_document
          reset_state(doc)
          visit_root(model, doc)
          apply_custom_properties(model, doc)
          save_document(doc.model, output_path)
        end

        private

        def reset_state(doc)
          @context = Context.new
          @resolver = StyleResolver.new(@style_mapping, @context)
          @inline_renderer = InlineRenderer.new(@context, @resolver, doc)
          @cover_renderer = CoverRenderer.new(@resolver, @context)
          @boilerplate_renderer = BoilerplateRenderer.new(@resolver, @inline_renderer)
          @section_manager = SectionManager.new(@resolver)
          @toc_builder = TocBuilder.new(@resolver, @inline_renderer, @context)
        end

        def save_document(model, output_path)
          Uniword::DocumentWriter.new(model).save(output_path)
        rescue StandardError => e
          warn "[metanorma-iso] DOCX save failed: #{e.message}"
          raise
        end

        def parse_xml(source)
          xml = case source
                when String
                  File.exist?(source) ? File.read(source, encoding: "utf-8") : source
                else
                  source.to_s
                end
          Metanorma::IsoDocument::Root.from_xml(xml)
        end

        def create_document
          if @template_path && File.exist?(@template_path)
            @template_root ||= Uniword.load(@template_path)
            root = @template_root
            if root.body
              root.body.paragraphs.clear
              root.body.tables.clear
              root.body.structured_document_tags.clear
              root.body.element_order = [] if root.body.element_order
              root.body.section_properties = nil
            end
            clear_user_footnotes(root)
            clear_user_endnotes(root)
            root.custom_properties = nil
            root.custom_xml_items = nil
            clear_custom_xml_references(root)
            clear_stale_template_content(root)
            Uniword::Builder::DocumentBuilder.new(root)
          else
            Uniword::Builder::DocumentBuilder.new
          end
        end

        def clear_user_footnotes(root)
          return unless root.footnotes

          root.footnotes.footnote_entries.reject! do |e|
            e.type != "separator" && e.type != "continuationSeparator"
          end
          root.footnotes.element_order = [] if root.footnotes.element_order
        end

        def clear_user_endnotes(root)
          return unless root.endnotes

          root.endnotes.endnote_entries.reject! do |e|
            e.type != "separator" && e.type != "continuationSeparator"
          end
          root.endnotes.element_order = [] if root.endnotes.element_order
        end

        def clear_custom_xml_references(root)
          if root.content_types&.overrides
            root.content_types.overrides.reject! do |o|
              o.part_name.to_s == "/docProps/custom.xml" ||
                o.part_name.to_s.include?("customXml/")
            end
          end
          if root.package_rels&.relationships
            root.package_rels.relationships.reject! do |r|
              r.type.to_s.include?("custom-properties")
            end
          end
        end

        def clear_stale_template_content(root)
          root.image_parts = nil
        end

        def apply_custom_properties(model, doc)
          props = DocumentProperties.new(model).build
          doc.model.custom_properties = props if props
        end

        # ── Root-level visitors ────────────────────────────────────────
        #
        # The document has three sections with different page numbering:
        #   1. Cover page (no numbering)
        #   2. Front matter (roman numerals: TOC, Foreword, Introduction)
        #   3. Body (arabic starting at 1: Scope through Bibliography)
        #
        # Layout:
        #   Cover page content (from bibdata)
        #   Warning/license (from boilerplate)
        #   [SECTPR — end of cover section]
        #   Copyright page (from boilerplate)
        #   [PAGE BREAK]
        #   TOC heading + entries
        #   [PAGE BREAK]
        #   Foreword
        #   [PAGE BREAK]
        #   Introduction
        #   [SECTPR — end of front matter, roman numerals]
        #   Middle title (zzSTDTitle)
        #   Body sections (Scope, Terms, etc.)
        #   Annexes (each starts with PAGE BREAK)
        #   Bibliography
        #   Colophon
        #   Index
        #   [SECTPR — body section, arabic page numbers]

        def visit_root(model, doc)
          # ── Section 1: Cover page ──
          @cover_renderer.render(model.bibdata, doc)
          @boilerplate_renderer.render_license(model.boilerplate, doc)
          @section_manager.insert_cover_section(doc)

          # ── Copyright page (still cover section's next page) ──
          @boilerplate_renderer.render_copyright(model.boilerplate, doc)
          doc.page_break

          # ── Section 2: Front matter (roman numerals) ──
          @toc_builder.render(model, doc)
          doc.page_break

          visit_preface(model.preface, doc) if model.preface

          header_text = build_header_text(model)
          copyright_text = build_copyright_text(model)
          @section_manager.insert_front_matter_section(
            doc, header_text: header_text, copyright_text: copyright_text,
          )

          # ── Section 3: Body (arabic page numbers) ──
          render_middle_title(model, doc)
          visit_sections(model.sections, doc) if model.sections
          model.annex&.each { |a| visit_annex(a, doc) }
          visit_bibliography(model.bibliography, doc) if model.bibliography
          visit_colophon(model.colophon, doc) if model.colophon
          visit_indexsect(model.indexsect, doc) if model.indexsect

          @section_manager.apply_body_section(
            doc, header_text: header_text, copyright_text: copyright_text,
          )
        end

        def visit_preface(preface, doc)
          if preface.foreword
            @context.with_foreword do
              visit_foreword(preface.foreword, doc)
              doc.page_break if preface.introduction || preface.clause&.any?
            end
          end

          if preface.introduction
            @context.with_introduction do
              visit_introduction(preface.introduction, doc)
            end
          end

          preface.clause&.each do |c|
            type = c.type if c.class.attributes.key?(:type)
            if type == "toc"
              # Already handled by TocBuilder
            else
              visit_clause(c, doc)
            end
          end
        end

        def visit_sections(sections, doc)
          walk_mixed_content(sections, doc)
        end

        def visit_bibliography(bib, doc)
          @context.with_bibliography do
            bib.references&.each { |r| visit_references_section(r, doc) }
            bib.clause&.each { |c| visit_clause(c, doc) }
          end
        end

        def visit_indexsect(section, doc)
          walk_mixed_content(section, doc)
        end

        def visit_colophon(colophon, doc)
          return unless colophon

          Array(colophon.clause).each do |clause|
            walk_mixed_content(clause, doc)
          end
        end

        # ── Middle title page ────────────────────────────────────────
        #
        # The reference DOCX renders the full document title on a
        # separate page between front matter and body, using zzSTDTitle.

        def render_middle_title(model, doc)
          bib = model.bibdata
          return unless bib

          title_text = build_full_title(bib)
          return unless title_text && !title_text.empty?

          para = Uniword::Builder::ParagraphBuilder.new
          para.style = @resolver.paragraph_style(:title)
          para << title_text
          doc << para
        end

        # ── Section visitors ───────────────────────────────────────────

        def visit_foreword(foreword, doc)
          title = foreword.fmt_title || foreword.title
          if title
            para = Uniword::Builder::ParagraphBuilder.new
            para.style = @resolver.paragraph_style(:foreword)
            @inline_renderer.render(title, para)
            doc << para
          end
          walk_mixed_content(foreword, doc)
        end

        def visit_introduction(intro, doc)
          title = intro.fmt_title || intro.title
          if title
            para = Uniword::Builder::ParagraphBuilder.new
            para.style = @resolver.paragraph_style(:introduction)
            @inline_renderer.render(title, para)
            doc << para
          end
          walk_mixed_content(intro, doc)
        end

        def visit_clause(clause, doc)
          @context.section_depth += 1
          render_section_title(clause, doc)
          walk_mixed_content(clause, doc)
        ensure
          @context.section_depth -= 1
        end

        def visit_annex(annex, doc)
          doc.page_break
          @context.with_annex do
            render_annex_title(annex, doc)
            walk_mixed_content(annex, doc)
          end
        end

        def visit_terms_section(terms_sect, doc)
          title = terms_sect.fmt_title || terms_sect.title
          if title
            para = Uniword::Builder::ParagraphBuilder.new
            para.style = @resolver.heading_style(1)
            @inline_renderer.render(title, para)
            doc << para
          end
          walk_mixed_content(terms_sect, doc)
        end

        def visit_definitions(definitions, doc)
          title = definitions.fmt_title || definitions.title
          if title
            para = Uniword::Builder::ParagraphBuilder.new
            para.style = @resolver.heading_style(1)
            @inline_renderer.render(title, para)
            doc << para
          end
          walk_mixed_content(definitions, doc)
        end

        def visit_references_section(refs_sect, doc)
          title = refs_sect.fmt_title || refs_sect.title
          if title
            para = Uniword::Builder::ParagraphBuilder.new
            para.style = @resolver.heading_style(2)
            @inline_renderer.render(title, para)
            doc << para
          end

          is_normative = refs_sect.normative == "true"
          @context.with_normative(is_normative) do
            walk_mixed_content(refs_sect, doc)
          end
        end

        # ── Bibliography visitors ──────────────────────────────────────

        def visit_bibliographic_item(bibitem, doc)
          para = Uniword::Builder::ParagraphBuilder.new
          para.style = bib_item_style
          insert_bibitem_bookmark(bibitem, para)
          render_bib_item_content(bibitem, para)
          doc << para
        end

        def bib_item_style
          if @context.in_normative
            @resolver.paragraph_style(:ref_norm) ||
              @resolver.paragraph_style(:normref)
          else
            @resolver.paragraph_style(:biblio_entry) ||
              @resolver.paragraph_style(:list_paragraph)
          end
        end

        def insert_bibitem_bookmark(bibitem, para)
          id = bibitem.anchor || bibitem.id
          return unless id

          bm_id = @context.next_bookmark_id.to_s
          para << Uniword::Wordprocessingml::BookmarkStart.new(id: bm_id, name: id)
          para << Uniword::Wordprocessingml::BookmarkEnd.new(id: bm_id)
        end

        def render_bib_item_content(bibitem, para)
          tag = bibitem.biblio_tag
          if tag
            @inline_renderer.render(tag, para)
          else
            text = collect_text(bibitem)
            para << text if text && !text.empty?
          end
        end

        # ── Term visitors ─────────────────────────────────────────────

        def visit_term(term, doc)
          fmt_name = term.fmt_name
          if fmt_name
            name_para = Uniword::Builder::ParagraphBuilder.new
            name_para.style = @resolver.paragraph_style(:term_num)
            insert_bookmark(term, name_para)
            @inline_renderer.render(fmt_name, name_para)
            doc << name_para
          end

          preferred = term.fmt_preferred || term.preferred
          Array(preferred).each do |pref|
            style = fmt_name ? @resolver.paragraph_style(:terms) :
              @resolver.paragraph_style(:term_num)
            render_term_name(pref, doc, style)
          end

          admitted = term.fmt_admitted || term.admitted
          Array(admitted).each do |adm|
            render_term_name(adm, doc, @resolver.paragraph_style(:alt_terms))
          end

          deprecates = term.fmt_deprecates || term.deprecates
          Array(deprecates).each do |dep|
            render_term_name_with_prefix(dep, doc,
                                         @resolver.paragraph_style(:deprecated_term),
                                         "DEPRECATED: ")
          end

          render_term_definitions(term, doc)
          render_term_notes(term, doc)
          render_term_examples(term, doc)

          walk_mixed_content(term, doc)
        end

        def render_term_name(designation, doc, style)
          para = Uniword::Builder::ParagraphBuilder.new
          para.style = style
          @inline_renderer.render(designation, para)
          doc << para
        end

        def render_term_name_with_prefix(designation, doc, style, prefix)
          para = Uniword::Builder::ParagraphBuilder.new
          para.style = style
          run = Uniword::Builder::RunBuilder.new
          run.text(prefix)
          para << run.build
          @inline_renderer.render(designation, para)
          doc << para
        end

        def render_term_definitions(term, doc)
          Array(term.definition).each { |defn| walk_mixed_content(defn, doc) }
        end

        def render_term_notes(term, doc)
          Array(term.termnote).each do |tn|
            @context.with_note do
              para = Uniword::Builder::ParagraphBuilder.new
              para.style = @resolver.paragraph_style(:note)
              @inline_renderer.render(tn, para)
              doc << para
            end
          end
        end

        def render_term_examples(term, doc)
          Array(term.termexample).each do |te|
            @context.with_example do
              name = te.fmt_name || te.name
              if name
                name_para = Uniword::Builder::ParagraphBuilder.new
                name_para.style = @resolver.paragraph_style(:example)
                @inline_renderer.render(name, name_para)
                doc << name_para
              end
              walk_mixed_content(te, doc)
            end
          end
        end

        # ── Block visitors (central dispatch) ──────────────────────────
        #
        # MECE by design: each element type maps to exactly one handler.
        # Subclass types must appear BEFORE their superclass in the
        # case/when to avoid the superclass branch matching first.

        def visit_block(block, doc)
          case block
          # ── Subclasses MUST appear before their superclass ──
          # AdmonitionBlock < ParagraphsBlock < ParagraphWithFootnote < ParagraphBlock
          when Metanorma::Document::Components::MultiParagraph::AdmonitionBlock
            visit_admonition(block, doc)
          when Metanorma::Document::Components::MultiParagraph::QuoteBlock
            visit_quote(block, doc)
          # ExampleBlock < ParagraphsBlock < ParagraphWithFootnote < ParagraphBlock
          when Metanorma::Document::Components::AncillaryBlocks::ExampleBlock
            visit_example(block, doc)
          # IsoClauseSection < ParagraphBlock (via complex chain)
          when Metanorma::IsoDocument::Sections::IsoAnnexSection
            visit_annex(block, doc)
          when Metanorma::IsoDocument::Sections::IsoTermsSection
            visit_terms_section(block, doc)
          when Metanorma::IsoDocument::Sections::IsoClauseSection
            visit_clause(block, doc)
          # IsoTerm < ParagraphBlock
          when Metanorma::IsoDocument::Terms::IsoTerm
            visit_term(block, doc)
          # Base paragraph — must come AFTER all paragraph subclasses
          when Metanorma::Document::Components::Paragraphs::ParagraphBlock
            visit_paragraph(block, doc)
          # ── Non-paragraph types ──
          when Metanorma::Document::Components::Tables::TableBlock
            visit_table(block, doc)
          when Metanorma::Document::Components::Lists::UnorderedList
            visit_unordered_list(block, doc)
          when Metanorma::Document::Components::Lists::OrderedList
            visit_ordered_list(block, doc)
          when Metanorma::Document::Components::Lists::DefinitionList
            visit_definition_list(block, doc)
          when Metanorma::Document::Components::AncillaryBlocks::FigureBlock
            visit_figure(block, doc)
          when Metanorma::Document::Components::AncillaryBlocks::FormulaBlock
            visit_formula(block, doc)
          when Metanorma::Document::Components::Blocks::NoteBlock
            visit_note(block, doc)
          when Metanorma::Document::Components::AncillaryBlocks::SourcecodeBlock
            visit_sourcecode(block, doc)
          when Metanorma::Document::Components::BibData::BibliographicItem
            visit_bibliographic_item(block, doc)
          when Metanorma::Document::Components::EmptyElements::PageBreakElement
            doc.page_break
          when Metanorma::Document::Components::EmptyElements::HorizontalRuleElement
            doc.horizontal_rule
          when Metanorma::Document::Components::IdElements::Bookmark
            nil
          else
            walk_mixed_content(block, doc)
          end
        end

        # ── Block visitor implementations ──────────────────────────────

        def visit_paragraph(p, doc)
          para = Uniword::Builder::ParagraphBuilder.new
          style = resolve_paragraph_style(p)
          para.style = style if style
          para.align = p.alignment if p.alignment

          # Check for class_attr that maps to a specific style
          context_style = @resolver.context_body_style
          para.style = context_style if context_style && !style

          @inline_renderer.render(p, para)
          doc << para
        end

        def visit_table(table, doc)
          name = table.fmt_name || table.name
          if name
            title_para = Uniword::Builder::ParagraphBuilder.new
            title_para.style = @resolver.table_title_style
            @inline_renderer.render(name, title_para)
            doc << title_para
          end

          tbl = Uniword::Builder::TableBuilder.new

          @context.with_table do
            render_table_section(table.thead, tbl, :header)
            render_table_section(table.tbody, tbl, :body)
            render_table_section(table.tfoot, tbl, :body)
          end

          ensure_table_structure(tbl.model, table.width)
          doc << tbl
        end

        def ensure_table_structure(table_model, width)
          unless table_model.properties
            table_model.properties = Uniword::Wordprocessingml::TableProperties.new
          end
          unless table_model.properties.table_width
            table_model.properties.table_width =
              Uniword::Properties::TableWidth.new(
                w: parse_twips(width) || 0, type: "dxa",
              )
          end
          unless table_model.properties.table_look
            table_model.properties.table_look =
              Uniword::Properties::TableLook.new(
                val: "04A0",
                first_row: 1,
                last_row: 0,
                first_column: 1,
                last_column: 0,
                no_h_band: 0,
                no_v_band: 1,
              )
          end

          return if table_model.grid

          cols = table_model.rows.map { |r| (r.cells&.count || 0) }.max || 0
          total_width = parse_twips(width) || 9000
          col_width = cols > 0 ? (total_width / cols) : 0
          grid_cols = Array.new(cols) do
            Uniword::Wordprocessingml::GridCol.new(width: col_width)
          end
          table_model.grid = Uniword::Wordprocessingml::TableGrid.new(columns: grid_cols)
        end

        def visit_figure(figure, doc)
          # Render the figure's image (or subfigures)
          if figure.image
            visit_image_element(figure.image, doc)
          end

          # Check for nested subfigures
          if figure.class.attributes.key?(:figure)
            Array(figure.figure).each do |subfig|
              visit_figure(subfig, doc)
            end
          end

          name = figure.fmt_name || figure.name
          return unless name

          title_para = Uniword::Builder::ParagraphBuilder.new
          title_para.style = @resolver.figure_title_style
          @inline_renderer.render(name, title_para)
          doc << title_para
        end

        def visit_image_element(image, doc)
          path = image.source
          return unless path

          width = parse_dimension(image.width)
          height = parse_dimension(image.height)
          alt = image.alt

          begin
            doc.image(path, width: width, height: height, alt_text: alt)
          rescue StandardError
            para = Uniword::Builder::ParagraphBuilder.new
            para << (alt || "[Image: #{File.basename(path)}]")
            doc << para
          end
        end

        def visit_note(note, doc)
          @context.with_note do
            para = Uniword::Builder::ParagraphBuilder.new
            para.style = @resolver.paragraph_style(:note)
            @inline_renderer.render(note, para)
            doc << para
          end
        end

        def visit_example(example, doc)
          @context.with_example do
            name = example.fmt_name || example.name
            if name
              name_para = Uniword::Builder::ParagraphBuilder.new
              name_para.style = @resolver.paragraph_style(:example)
              @inline_renderer.render(name, name_para)
              doc << name_para
            end
            walk_mixed_content(example, doc)
          end
        end

        def visit_admonition(admonition, doc)
          # Use context-aware style: warning vs admonition
          style = resolve_admonition_style(admonition)

          # Render title if present (some admonitions have formatted names)
          if admonition.class.attributes.key?(:fmt_name)
            name = admonition.fmt_name
            if name
              title_para = Uniword::Builder::ParagraphBuilder.new
              title_para.style = @resolver.paragraph_style(:warning_header) ||
                @resolver.paragraph_style(:admonition_title)
              @inline_renderer.render(name, title_para)
              doc << title_para
            end
          end

          # Render body
          para = Uniword::Builder::ParagraphBuilder.new
          para.style = style
          @inline_renderer.render(admonition, para)
          doc << para
        end

        def visit_unordered_list(list, doc)
          num_id = @resolver.numbering_id(:dash_list)
          Array(list.listitem).each do |item|
            render_numbered_item(item, doc, num_id, 0)
          end
        end

        def visit_ordered_list(list, doc)
          num_id = numbering_for_type(list.type)
          Array(list.listitem).each do |item|
            render_numbered_item(item, doc, num_id, 0)
          end
        end

        def visit_definition_list(dl, doc)
          dt_items = dl.dt
          dd_items = dl.dd
          Array(dt_items).each_with_index do |dt, i|
            term_para = Uniword::Builder::ParagraphBuilder.new
            @inline_renderer.render(dt, term_para)
            doc << term_para

            dd = dd_items.is_a?(Array) ? dd_items[i] : dd_items
            walk_mixed_content(dd, doc) if dd
          end
        end

        def visit_sourcecode(sourcecode, doc)
          para = Uniword::Builder::ParagraphBuilder.new
          para.style = @resolver.paragraph_style(:sourcecode)
          @inline_renderer.preserve_whitespace = true
          @inline_renderer.render(sourcecode, para)
          @inline_renderer.preserve_whitespace = false
          doc << para
        end

        def visit_formula(formula, doc)
          para = Uniword::Builder::ParagraphBuilder.new
          para.style = @resolver.paragraph_style(:formula)

          stem = formula.fmt_stem || formula.stem
          if stem
            @inline_renderer.render(stem, para)
          else
            @inline_renderer.render(formula, para)
          end

          # Render formula name/label if present (e.g., "(1)")
          name = formula.fmt_name
          if name
            @inline_renderer.render(name, para)
          end

          doc << para
        end

        def visit_quote(quote, doc)
          para = Uniword::Builder::ParagraphBuilder.new
          para.style = @resolver.paragraph_style(:quote)
          para.indent(left: 720, right: 720)
          @inline_renderer.render(quote, para)
          doc << para
        end

        # ── Tree walking ───────────────────────────────────────────────

        def walk_mixed_content(node, doc)
          return unless node

          walked = false
          each_ordered_element(node) do |type, obj|
            walked = true
            next if type == :text

            visit_block(obj, doc)
          end
          return if walked

          fallback_walk(node, doc)
        end

        def fallback_walk(node, doc)
          return unless node.is_a?(Lutaml::Model::Serializable)

          block_attrs = %i[
            paragraphs tables figures formulas examples notes
            admonitions sourcecode_blocks quote_blocks
            definition_lists unordered_lists ordered_lists
            clause terms definitions references term
            p annex
          ]
          block_attrs.each do |attr|
            next unless node.class.attributes.key?(attr)

            val = node.public_send(attr)
            next if val.nil?

            Array(val).each { |b| visit_block(b, doc) }
          end
        end

        # ── Title rendering ────────────────────────────────────────────

        def render_section_title(clause, doc)
          title = clause.fmt_title || clause.title
          return unless title

          depth = @context.section_depth
          para = Uniword::Builder::ParagraphBuilder.new
          para.style = @resolver.heading_style([depth, 6].min)
          insert_bookmark(clause, para)
          @inline_renderer.render_heading(title, para)
          doc << para
        end

        def render_annex_title(annex, doc)
          title = annex.fmt_title || annex.title
          return unless title

          para = Uniword::Builder::ParagraphBuilder.new
          para.style = @resolver.paragraph_style(:annex)
          insert_bookmark(annex, para)
          @inline_renderer.render(title, para)
          doc << para
        end

        def insert_bookmark(node, para)
          id = node.id
          return unless id

          bm_id = @context.next_bookmark_id.to_s
          para << Uniword::Wordprocessingml::BookmarkStart.new(id: bm_id, name: id)
          para << Uniword::Wordprocessingml::BookmarkEnd.new(id: bm_id)
        end

        # ── Table helpers ──────────────────────────────────────────────

        def render_table_section(section, tbl, _row_type)
          return unless section

          rows = section.tr
          return unless rows

          Array(rows).each do |tr|
            tbl.row do |row|
              cells = Array(tr.th) + Array(tr.td)
              cells.each do |cell|
                next unless cell
                col_span = cell.colspan
                row.cell do |c|
                  c.column_span(col_span.to_i) if col_span
                  render_cell_content(cell, c)
                end
              end
            end
          end
        end

        # Render a table cell's content, handling both simple inline content
        # and block-level content (paragraphs, notes, examples).
        def render_cell_content(cell, cell_builder)
          if cell_has_block_content?(cell)
            render_cell_block_content(cell, cell_builder)
          else
            cell_para = Uniword::Builder::ParagraphBuilder.new
            @inline_renderer.render(cell, cell_para)
            cell_builder << cell_para
          end
        end

        # Check if a cell has block-level elements (notes, examples,
        # multiple paragraphs, lists) that require multi-paragraph rendering.
        def cell_has_block_content?(cell)
          return false unless ordered?(cell)

          cell.element_order.any? do |el|
            next false unless el.element?

            name = el.name
            %w[note example p ol ul dl sourcecode quote].include?(name)
          end
        end

        # Render a cell with block-level content, creating multiple paragraphs.
        def render_cell_block_content(cell, cell_builder)
          each_ordered_element(cell) do |type, obj|
            case type
            when :text
              next if obj.nil? || obj.strip.empty?
              cell_para = Uniword::Builder::ParagraphBuilder.new
              cell_para << obj
              cell_builder << cell_para
            when :element
              render_cell_element(obj, cell_builder)
            end
          end
        end

        # Render a block element inside a table cell.
        def render_cell_element(element, cell_builder)
          case element
          when Metanorma::Document::Components::Paragraphs::ParagraphBlock
            cell_para = Uniword::Builder::ParagraphBuilder.new
            @inline_renderer.render(element, cell_para)
            cell_builder << cell_para
          when Metanorma::Document::Components::Blocks::NoteBlock
            cell_para = Uniword::Builder::ParagraphBuilder.new
            cell_para.style = @resolver.paragraph_style(:note)
            @inline_renderer.render(element, cell_para)
            cell_builder << cell_para
          when Metanorma::Document::Components::Lists::UnorderedList
            num_id = @resolver.numbering_id(:dash_list)
            Array(element.listitem).each do |item|
              render_cell_list_item(item, cell_builder, num_id)
            end
          when Metanorma::Document::Components::Lists::OrderedList
            num_id = @resolver.numbering_id(:decimal_list)
            Array(element.listitem).each do |item|
              render_cell_list_item(item, cell_builder, num_id)
            end
          else
            cell_para = Uniword::Builder::ParagraphBuilder.new
            @inline_renderer.render(element, cell_para)
            cell_builder << cell_para
          end
        end

        def render_cell_list_item(item, cell_builder, num_id)
          para = Uniword::Builder::ParagraphBuilder.new
          para.numbering(num_id, 0) if num_id
          paragraphs = item.paragraphs
          if paragraphs && !paragraphs.empty?
            paragraphs.each { |p| @inline_renderer.render(p, para) }
          else
            @inline_renderer.render(item, para)
          end
          cell_builder << para
        end

        # ── List helpers ───────────────────────────────────────────────

        def render_numbered_item(item, doc, num_id, level)
          paragraphs = item.paragraphs
          if paragraphs && !paragraphs.empty?
            para = Uniword::Builder::ParagraphBuilder.new
            para.numbering(num_id, level) if num_id
            paragraphs.each { |p| @inline_renderer.render(p, para) }
            doc << para
          else
            para = Uniword::Builder::ParagraphBuilder.new
            para.numbering(num_id, level) if num_id
            @inline_renderer.render(item, para)
            doc << para
          end
        end

        def numbering_for_type(type_attr)
          case type_attr
          when "arabic", "decimal" then @resolver.numbering_id(:decimal_list)
          when "alpha", "loweralpha" then @resolver.numbering_id(:alpha_list)
          when "roman", "lowerroman" then @resolver.numbering_id(:decimal_list)
          else @resolver.numbering_id(:decimal_list)
          end
        end

        # ── Style resolution ───────────────────────────────────────────

        def resolve_paragraph_style(node)
          cls = node.class_attr
          return @resolver.paragraph_style(cls.to_sym) if cls

          type = node.type if node.class.attributes.key?(:type)
          if type == "floating-title"
            depth = (node.depth || 1).to_i
            return @resolver.heading_style(depth)
          end

          nil
        end

        def resolve_admonition_style(admonition)
          type = admonition.type if admonition.class.attributes.key?(:type)
          if type == "warning"
            @resolver.paragraph_style(:warning) ||
              @resolver.paragraph_style(:admonition)
          else
            @resolver.paragraph_style(:admonition)
          end
        end

        # ── Header/footer text helpers ─────────────────────────────────

        def build_header_text(model)
          bib = model.bibdata
          return "" unless bib

          identifiers = Array(bib.doc_identifier) if bib.class.attributes.key?(:doc_identifier)
          primary = identifiers&.find { |d| extract_prop(d, :primary) == "true" } ||
            identifiers&.first
          return "" unless primary

          id = extract_prop(primary, :value)
          return "" unless id

          # Extract year from copyright
          year = extract_copyright_year(bib)
          id_with_year = year ? "#{id}:#{year}" : id
          "#{id_with_year}(#{content_language(bib)})"
        end

        def build_copyright_text(model)
          bib = model.bibdata
          return "© ISO 2026 – All rights reserved" unless bib

          year = extract_copyright_year(bib) || "2026"
          holder = extract_copyright_holder(bib) || "ISO"
          "© #{holder} #{year} – All rights reserved"
        end

        def build_full_title(bib)
          return nil unless bib&.class&.attributes&.key?(:titles)

          localized = if bib.titles.respond_to?(:for_language)
                        bib.titles.for_language("en")
                      end
          localized ||= bib.titles.per_language&.first if bib.titles.respond_to?(:per_language)

          title_text = localized&.to_s
          (title_text.nil? || title_text.empty?) ? nil : title_text
        end

        def extract_copyright_year(bib)
          copyrights = Array(bib.copyright) if bib.class.attributes.key?(:copyright)
          return nil unless copyrights&.first

          from = copyrights.first.from if copyrights.first.class.attributes.key?(:from)
          return nil unless from

          extract_prop(from)
        end

        def extract_copyright_holder(bib)
          copyrights = Array(bib.copyright) if bib.class.attributes.key?(:copyright)
          return nil unless copyrights&.first

          owner = copyrights.first.owner if copyrights.first.class.attributes.key?(:owner)
          org = Array(owner).first
          return nil unless org

          names = org.name if org.class.attributes.key?(:name)
          Array(names).first&.content || "ISO"
        end

        def content_language(bib)
          langs = Array(bib.language) if bib.class.attributes.key?(:language)
          lang = langs&.first
          if lang.is_a?(String)
            lang
          elsif lang.is_a?(Lutaml::Model::Serializable)
            extract_prop(lang)
          else
            "en"
          end
        end

        def extract_prop(node, attr = nil)
          return nil unless node
          return node.public_send(attr) if attr && node.class.attributes.key?(attr)

          if node.is_a?(String)
            node
          elsif node.is_a?(Lutaml::Model::Serializable)
            [:content, :value, :text].each do |a|
              next unless node.class.attributes.key?(a)
              val = node.public_send(a)
              return val.to_s if val.is_a?(String)
              return Array(val).first.to_s if val.is_a?(Array) && !val.empty?
            end
            node.to_s
          end
        end
      end
    end
  end
end
