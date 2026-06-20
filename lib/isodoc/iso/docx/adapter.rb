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
          apply_core_properties(doc_model, doc)
          save_document(doc.model, output_path)
        end

        # Convert an already-parsed model to DOCX or MHTML.
        def convert_model(model, output_path)
          doc = create_document
          reset_state(doc)
          visit_root(model, doc)
          apply_custom_properties(model, doc)
          apply_core_properties(model, doc)
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
          @comment_renderer = CommentRenderer.new(@resolver, @inline_renderer)
          @formula_renderer = FormulaRenderer.new(@resolver, @inline_renderer, context: @context)
          @sourcecode_renderer = SourcecodeRenderer.new(@resolver, @inline_renderer)
          @definition_list_renderer = Renderers::DefinitionListRenderer.new(
            resolver: @resolver, context: @context,
            inline_renderer: @inline_renderer, walker: nil,
          )

          build_dispatcher

          # Wire comment ID lookup from CommentRenderer into InlineRenderer
          @inline_renderer.comment_id_lookup = method(:lookup_comment_id)
        end

        # Build the dispatcher: a Walker paired with a Registry of
        # per-content-type renderers. Simple renderers (Note, Example,
        # Admonition, Quote, DefinitionList, Figure) are instantiated
        # from Renderers::*; complex types still dispatch to adapter
        # via the +#adapter_dispatch+ fallback.
        def build_dispatcher
          dispatch_fn = ->(node, doc) { dispatch(node, doc) }
          @walker = Renderers::Walker.new(dispatch_fn)
          @simple_renderers = {
            Metanorma::Document::Components::MultiParagraph::AdmonitionBlock =>
              Renderers::AdmonitionRenderer.new(
                resolver: @resolver, context: @context,
                inline_renderer: @inline_renderer, walker: @walker,
              ),
            Metanorma::Document::Components::MultiParagraph::QuoteBlock =>
              Renderers::QuoteRenderer.new(
                resolver: @resolver, context: @context,
                inline_renderer: @inline_renderer, walker: @walker,
              ),
            Metanorma::Document::Components::AncillaryBlocks::ExampleBlock =>
              Renderers::ExampleRenderer.new(
                resolver: @resolver, context: @context,
                inline_renderer: @inline_renderer, walker: @walker,
              ),
            Metanorma::Document::Components::Lists::DefinitionList =>
              @definition_list_renderer,
            Metanorma::Document::Components::AncillaryBlocks::FigureBlock =>
              Renderers::FigureRenderer.new(
                resolver: @resolver, context: @context,
                inline_renderer: @inline_renderer, walker: @walker,
                image_renderer: method(:render_image_via_adapter),
              ),
            Metanorma::Document::Components::Blocks::NoteBlock =>
              Renderers::NoteRenderer.new(
                resolver: @resolver, context: @context,
                inline_renderer: @inline_renderer, walker: @walker,
              ),
            Metanorma::Document::Components::Paragraphs::ParagraphBlock =>
              Renderers::ParagraphRenderer.new(
                resolver: @resolver, context: @context,
                inline_renderer: @inline_renderer, walker: @walker,
              ),
            Metanorma::Document::Components::Lists::OrderedList =>
              Renderers::ListRenderer.new(
                resolver: @resolver, context: @context,
                inline_renderer: @inline_renderer, walker: @walker,
              ),
            Metanorma::Document::Components::Lists::UnorderedList =>
              Renderers::ListRenderer.new(
                resolver: @resolver, context: @context,
                inline_renderer: @inline_renderer, walker: @walker,
              ),
            Metanorma::Document::Components::Tables::TableBlock =>
              Renderers::TableRenderer.new(
                resolver: @resolver, context: @context,
                inline_renderer: @inline_renderer, walker: @walker,
              ),
          }
        end

        # Adapter-side image rendering, exposed as a callable so that
        # FigureRenderer can stay decoupled from file-system concerns
        # (data URIs, Dimension style selection, fallbacks).
        def render_image_via_adapter(image, doc)
          visit_image_element(image, doc)
        end

        def lookup_comment_id(annotation_target_id)
          @comment_renderer.lookup_comment_id(annotation_target_id)
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
            setup_allocator(root)
            if root.body
              root.body.paragraphs.clear
              root.body.tables.clear
              root.body.structured_document_tags.clear
              root.body.bookmark_starts.clear
              root.body.bookmark_ends.clear
              root.body.element_order = [] if root.body.element_order
              root.body.section_properties = nil
            end
            clear_user_footnotes(root)
            clear_user_endnotes(root)
            root.custom_properties = nil
            root.custom_xml_items = nil
            clear_custom_xml_references(root)
            clear_stale_template_content(root)
            Uniword::Builder::DocumentBuilder.new(root, allocator: root.allocator)
          else
            Uniword::Builder::DocumentBuilder.new
          end
        end

        # Create and seed an IdAllocator on the root so that hyperlink,
        # image, and other relationship-bearing elements get proper rId
        # references instead of raw URLs. The allocator is seeded from the
        # template's existing relationships to avoid rId collisions.
        def setup_allocator(root)
          return if root.allocator

          allocator = Uniword::Docx::IdAllocator.new
          if root.document_rels&.relationships
            allocator.seed_from_rels(root.document_rels.relationships)
          end
          root.allocator = allocator
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

        def apply_core_properties(model, doc)
          doc.model.core_properties = CorePropertiesBuilder.new(model).build
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
          # ── Render annotations (comments) before body traversal ──
          @comment_renderer.render(model.annotation_container, doc) if model.annotation_container

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
          # The reference DOCX layout places the document title on a
          # separate page between front matter and body, using the
          # zzSTDTitle paragraph style. The cover page (CoverTitleA1)
          # also shows the title, but they are different physical pages
          # with different styles.
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
        # This is distinct from the cover page title (CoverTitleA1):
        # both pages exist in the standard ISO layout.
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
          @context.section_depth += 1
          @context.with_annex do
            render_annex_title(annex, doc)
            walk_mixed_content(annex, doc)
          end
        ensure
          @context.section_depth -= 1
        end

        def visit_terms_section(terms_sect, doc)
          title = terms_sect.fmt_title || terms_sect.title
          if title
            para = Uniword::Builder::ParagraphBuilder.new
            para.style = @resolver.heading_style(1)
            @inline_renderer.render_heading(title, para)
            doc << para
          end
          walk_mixed_content(terms_sect, doc)
        end

        def visit_definitions(definitions, doc)
          title = definitions.fmt_title || definitions.title
          if title
            para = Uniword::Builder::ParagraphBuilder.new
            para.style = @resolver.heading_style(1)
            @inline_renderer.render_heading(title, para)
            doc << para
          end
          walk_mixed_content(definitions, doc)
        end

        def visit_references_section(refs_sect, doc)
          title = refs_sect.fmt_title || refs_sect.title
          if title
            para = Uniword::Builder::ParagraphBuilder.new
            para.style = @resolver.paragraph_style(:bibliography)
            @inline_renderer.render_heading(title, para)
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
          with_bibitem_bookmark(bibitem, para) do
            render_bib_item_content(bibitem, para)
          end
          doc << para
        end

        def bib_item_style
          key = @context.in_normative ? :ref_norm : :biblio_entry
          @resolver.paragraph_style(key)
        end

        def with_bibitem_bookmark(bibitem, para)
          name = bibitem_bookmark_name(bibitem)
          return yield unless name

          bm_id = @context.next_bookmark_id.to_s
          para << Uniword::Wordprocessingml::BookmarkStart.new(id: bm_id, name: name)
          yield
          para << Uniword::Wordprocessingml::BookmarkEnd.new(id: bm_id)
        end

        def bibitem_bookmark_name(bibitem)
          if bibitem.class.attributes.key?(:anchor) && bibitem.anchor
            return bibitem.anchor
          end
          return bibitem.id if bibitem.class.attributes.key?(:id) && bibitem.id
          nil
        end

        def render_bib_item_content(bibitem, para)
          tag = bibitem.biblio_tag
          if tag
            @inline_renderer.render(tag, para)
          else
            text = collect_text(bibitem)
            para << text if text && !text.empty?
          end
          render_formatted_ref(bibitem, para)
        end

        def render_formatted_ref(bibitem, para)
          return unless bibitem.class.attributes.key?(:formatted_ref)

          ref = bibitem.formatted_ref
          return unless ref

          @inline_renderer.render(ref, para)
        end

        # ── Term visitors ─────────────────────────────────────────────

        def visit_term(term, doc)
          fmt_name = term.fmt_name
          if fmt_name
            name_para = Uniword::Builder::ParagraphBuilder.new
            name_para.style = @resolver.paragraph_style(:term_num)
            with_bookmark(term, name_para) do
              @inline_renderer.render_heading(fmt_name, name_para)
            end
            doc << name_para
          end

          preferred = term.fmt_preferred || term.preferred
          Array(preferred).each do |pref|
            style = fmt_name ? @resolver.paragraph_style(:terms) :
              @resolver.paragraph_style(:term_num)
            render_term_designation_list(pref, doc, style)
          end

          admitted = term.fmt_admitted || term.admitted
          Array(admitted).each do |adm|
            render_term_designation_list(adm, doc,
                                         @resolver.paragraph_style(:alt_terms))
          end

          deprecates = term.fmt_deprecates || term.deprecates
          Array(deprecates).each do |dep|
            render_term_designation_list(dep, doc,
                                         @resolver.paragraph_style(:deprecated_term),
                                         prefix: deprecated_prefix(dep))
          end

          render_term_definitions(term, doc)
          render_term_notes(term, doc)
          render_term_examples(term, doc)
        end

        def render_term_designation_list(designation, doc, style, prefix: nil)
          return unless designation

          paragraphs = designation_paragraphs(designation)
          if paragraphs.empty?
            render_term_name_with_prefix(designation, doc, style, prefix)
            return
          end

          paragraphs.each do |p|
            para = Uniword::Builder::ParagraphBuilder.new
            para.style = style
            if prefix
              run = Uniword::Builder::RunBuilder.new
              run.text(prefix)
              para << run.build
            end
            @inline_renderer.render(p, para)
            doc << para
          end
        end

        # Extract the inner <p> children from a fmt-* designation element.
        # Returns [] for elements that are themselves paragraph-like (used
        # by the fallback path).
        def designation_paragraphs(designation)
          return [] unless designation.class.attributes.key?(:p)

          Array(designation.p)
        end

        # The "DEPRECATED: " prefix is added only when the source content
        # doesn't already include it (presentation XML sometimes embeds
        # the label inside <fmt-deprecates><p>DEPRECATED: ...</p></fmt-deprecates>).
        DEPRECATED_PREFIX = "DEPRECATED: "
        private_constant :DEPRECATED_PREFIX

        def deprecated_prefix(designation)
          text = collect_all_text(designation)
          return nil if text&.start_with?(DEPRECATED_PREFIX) || text&.include?(DEPRECATED_PREFIX)

          DEPRECATED_PREFIX
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
          if prefix
            run = Uniword::Builder::RunBuilder.new
            run.text(prefix)
            para << run.build
          end
          @inline_renderer.render(designation, para)
          doc << para
        end

        def render_term_definitions(term, doc)
          definitions = if term.class.attributes.key?(:fmt_definition) &&
                            term.fmt_definition
                          Array(term.fmt_definition)
                        else
                          Array(term.definition)
                        end
          definitions.each { |defn| walk_mixed_content(defn, doc) }
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
        # Class-keyed dispatch via the Renderers::Registry. Simple content
        # types (Note, Example, Admonition, Quote, DefinitionList, Figure)
        # are dispatched to their own Renderer classes. Complex types
        # fall through to adapter-side +visit_*+ methods.
        #
        # Inheritance: the Registry walks the ancestor chain, so an
        # IsoClauseSection (a ParagraphBlock subclass) dispatches to
        # +visit_clause+ via its explicit entry; subclasses with their
        # own entries always win (exact-class match first).

        # Dispatch entry point used by Renderers::Walker and visit_block.
        # Looks up by node class, then walks the ancestor chain so that
        # subclasses (e.g., ParagraphWithFootnote < ParagraphBlock) hit
        # the registered renderer without each subclass needing its own
        # entry.
        def dispatch(node, doc)
          renderer = lookup_simple_renderer(node.class)
          return renderer.render(node, doc) if renderer

          adapter_dispatch(node, doc)
        end

        def lookup_simple_renderer(klass)
          return @simple_renderers[klass] if @simple_renderers[klass]

          klass.ancestors.each do |ancestor|
            return @simple_renderers[ancestor] if @simple_renderers[ancestor]
          end
          nil
        end

        # Adapter-side dispatch for complex content types that still
        # have their +visit_*+ methods defined here.
        def adapter_dispatch(node, doc)
          case node
          # ── Subclasses MUST appear before their superclass ──
          when Metanorma::IsoDocument::Sections::IsoAnnexSection
            visit_annex(node, doc)
          when Metanorma::IsoDocument::Sections::IsoTermsSection
            visit_terms_section(node, doc)
          when Metanorma::IsoDocument::Sections::IsoClauseSection
            visit_clause(node, doc)
          # IsoTerm < ParagraphBlock
          when Metanorma::IsoDocument::Terms::IsoTerm
            visit_term(node, doc)
          # ── Non-paragraph types ──
          when Metanorma::Document::Components::AncillaryBlocks::FormulaBlock
            visit_formula(node, doc)
          when Metanorma::Document::Components::AncillaryBlocks::SourcecodeBlock
            visit_sourcecode(node, doc)
          when Metanorma::Document::Components::BibData::BibliographicItem
            visit_bibliographic_item(node, doc)
          when Metanorma::Document::Components::EmptyElements::PageBreakElement
            doc.page_break
          when Metanorma::Document::Components::EmptyElements::HorizontalRuleElement
            doc.horizontal_rule
          when Metanorma::Document::Components::IdElements::Bookmark
            nil
          else
            walk_mixed_content(node, doc)
          end
        end

        def visit_block(block, doc)
          dispatch(block, doc)
        end

        # ── Block visitor implementations ──────────────────────────────

        def visit_image_element(image, doc)
          src = image.source
          return unless src

          width = parse_dimension(image.width)
          height = parse_dimension(image.height)
          alt = image.alt

          path = resolve_image_source(src)
          unless path
            render_image_fallback(doc, alt, src)
            return
          end

          begin
            run = Uniword::Builder::ImageBuilder.create_run(
              doc, path,
              width: width, height: height,
              alt_text: alt
            )
            para = Uniword::Builder::ParagraphBuilder.new
            para.style = dimension_style_for(width)
            para << run
            doc << para
          rescue StandardError
            render_image_fallback(doc, alt, src)
          end
        end

        # Era C: pick Dimension50/75/100 based on image width relative
        # to the page body width. Images without explicit width default
        # to Dimension100 (full width).
        def dimension_style_for(width)
          pct = width_percentage(width)
          key = if pct.nil? || pct >= 90 then :dimension_100
                elsif pct >= 60         then :dimension_75
                else                          :dimension_50
                end
          @resolver.paragraph_style(key)
        end

        def width_percentage(width)
          return nil unless width && width.is_a?(Numeric) && width.positive?
          body_width = @context.body_width
          return nil unless body_width && body_width.positive?
          (width.to_f / body_width * 100).round
        end

        # Resolve an image source (data URI or file path) to a readable
        # local file path. Returns nil if the source cannot be resolved.
        def resolve_image_source(src)
          return extract_data_uri_to_tempfile(src) if src.to_s.start_with?("data:")
          return src if File.exist?(src)

          nil
        end

        def render_image_fallback(doc, alt, src)
          para = Uniword::Builder::ParagraphBuilder.new
          text = alt || "[Image: #{File.basename(src.to_s)}]"
          para << text
          doc << para
        end

        def visit_sourcecode(sourcecode, doc)
          @sourcecode_renderer.render(sourcecode, doc)
        end

        def visit_formula(formula, doc)
          @context.with_formula do
            @formula_renderer.render(formula, doc)
            dispatch_formula_extras(formula, doc)
          end
        end

        # Dispatch formula children that the FormulaRenderer does not
        # handle itself (everything except +stem+/+fmt_stem+ and
        # +name+/+fmt_name+). Wrapping happens in +#visit_formula+ so
        # these children see +zone == :formula+ via Context.
        def dispatch_formula_extras(formula, doc)
          walk_collection(formula, :dl, doc)
          walk_collection(formula, :p, doc)
        end

        def walk_collection(parent, attr, doc)
          return unless parent.class.attributes.key?(attr)
          value = parent.public_send(attr)
          return unless value
          Array(value).each { |child| dispatch(child, doc) }
        end

        # ── Tree walking ───────────────────────────────────────────────
        #
        # Delegates to Renderers::Walker so traversal logic lives in one
        # place. Adapter methods (visit_foreword, visit_introduction,
        # visit_clause, etc.) call this to recurse into children; the
        # walker dispatches each child back through +#dispatch+.

        def walk_mixed_content(node, doc)
          @walker.walk(node, doc)
        end

        # ── Title rendering ────────────────────────────────────────────

        def render_section_title(clause, doc)
          title = clause.fmt_title || clause.title
          return unless title
          return if heading_body_empty?(title)

          depth = @context.section_depth
          para = Uniword::Builder::ParagraphBuilder.new
          para.style = @resolver.heading_style([depth, 6].min)
          with_bookmark(clause, para) do
            @inline_renderer.render_heading(title, para)
          end
          doc << para
        end

        def render_annex_title(annex, doc)
          title = annex.fmt_title || annex.title
          return unless title
          return if heading_body_empty?(title)

          para = Uniword::Builder::ParagraphBuilder.new
          para.style = @resolver.paragraph_style(:annex)
          with_bookmark(annex, para) do
            @inline_renderer.render_heading(title, para)
          end
          doc << para
        end

        # Whether a heading has no body text after autonum carriers are
        # stripped. Untitled sub-clauses (whose <fmt-title> contains only
        # the section number + delimiter) should not emit a heading
        # paragraph at all — the body paragraph follows directly.
        def heading_body_empty?(title)
          @inline_renderer.heading_body_empty?(title)
        end

        # Wrap a paragraph's content with a bookmark range so Word can
        # scroll hyperlink targets to the right position.
        def with_bookmark(node, para)
          name = bookmark_name(node)
          return yield unless name

          bm_id = @context.next_bookmark_id.to_s
          para << Uniword::Wordprocessingml::BookmarkStart.new(id: bm_id, name: name)
          yield
          para << Uniword::Wordprocessingml::BookmarkEnd.new(id: bm_id)
        end

        def bookmark_name(node)
          return nil unless node.class.attributes.key?(:id)
          node.id
        end

        # ── Style resolution ───────────────────────────────────────────


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

          titles = bib.titles
          localized = titles_for_language(titles, "en")

          title_text = localized&.to_s
          (title_text.nil? || title_text.empty?) ? nil : title_text
        end

        # Pick the English title from a TitleCollection. TitleCollection
        # is the canonical type from metanorma-iso-document; we use is_a?
        # rather than respond_to? to avoid duck-typing.
        def titles_for_language(titles, lang)
          return nil unless titles
          return titles.for_language(lang) if titles.is_a?(Metanorma::IsoDocument::Metadata::TitleCollection)

          nil
        rescue StandardError
          nil
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
