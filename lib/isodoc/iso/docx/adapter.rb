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
          @header_footer_renderer = HeaderFooterRenderer.new(@resolver)
          @section_manager = SectionManager.new(@resolver, @header_footer_renderer)
          @toc_builder = TocBuilder.new(@resolver, @inline_renderer, @context)
          @comment_renderer = CommentRenderer.new(@resolver, @inline_renderer)
          @formula_renderer = FormulaRenderer.new(@resolver, @inline_renderer, context: @context)
          @sourcecode_renderer = SourcecodeRenderer.new(@resolver, @inline_renderer)
          @definition_list_renderer = Renderers::DefinitionListRenderer.new(
            resolver: @resolver, context: @context,
            inline_renderer: @inline_renderer, walker: nil,
          )
          @image_renderer = Renderers::ImageRenderer.new(
            resolver: @resolver, context: @context,
            inline_renderer: @inline_renderer, walker: nil,
          )

          build_dispatcher

          @middle_title_renderer = MiddleTitleRenderer.new(
            resolver: @resolver, inline_renderer: @inline_renderer,
          )
          @preface_renderer = PrefaceRenderer.new(
            resolver: @resolver, context: @context,
            inline_renderer: @inline_renderer, walker: @walker,
          )
          @indexsect_renderer = IndexsectRenderer.new(
            resolver: @resolver, inline_renderer: @inline_renderer,
            walker: @walker,
          )
          @colophon_renderer = ColophonRenderer.new(walker: @walker)

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
                image_renderer: @image_renderer.method(:call),
              ),
            Metanorma::Document::Components::IdElements::Image =>
              @image_renderer,
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
            # ── Section renderers (MECE: one per IsoDocument section class) ──
            # Order matters in @simple_renderers? No — lookup_simple_renderer
            # checks exact-class first. Subclasses (IsoAnnexSection etc.) are
            # registered explicitly so they win over the ParagraphBlock entry.
            Metanorma::IsoDocument::Sections::IsoAnnexSection =>
              Renderers::AnnexRenderer.new(
                resolver: @resolver, context: @context,
                inline_renderer: @inline_renderer, walker: @walker,
              ),
            Metanorma::IsoDocument::Sections::IsoTermsSection =>
              Renderers::TermsSectionRenderer.new(
                resolver: @resolver, context: @context,
                inline_renderer: @inline_renderer, walker: @walker,
              ),
            Metanorma::IsoDocument::Sections::IsoClauseSection =>
              Renderers::ClauseRenderer.new(
                resolver: @resolver, context: @context,
                inline_renderer: @inline_renderer, walker: @walker,
              ),
            Metanorma::IsoDocument::Terms::IsoTerm =>
              Renderers::TermRenderer.new(
                resolver: @resolver, context: @context,
                inline_renderer: @inline_renderer, walker: @walker,
              ),
            Metanorma::Document::Components::BibData::BibliographicItem =>
              Renderers::BibliographyRenderer.new(
                resolver: @resolver, context: @context,
                inline_renderer: @inline_renderer, walker: @walker,
              ),
            Metanorma::StandardDocument::Blocks::AmendBlock =>
              Renderers::AmendRenderer.new(
                resolver: @resolver, context: @context,
                inline_renderer: @inline_renderer, walker: @walker,
              ),
          }
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

          @preface_renderer.render(model.preface, doc) if model.preface

          bib_text = BibDataText.new(model)
          header_text = bib_text.header
          copyright_text = bib_text.copyright
          @section_manager.insert_front_matter_section(
            doc, header_text: header_text, copyright_text: copyright_text,
          )

          # ── Section 3: Body (arabic page numbers) ──
          # The reference DOCX layout places the document title on a
          # separate page between front matter and body, using the
          # zzSTDTitle paragraph style. The cover page (CoverTitleA1)
          # also shows the title, but they are different physical pages
          # with different styles.
          @middle_title_renderer.render(model, doc)
          visit_sections(model.sections, doc) if model.sections
          model.annex&.each { |a| dispatch(a, doc) }
          visit_bibliography(model.bibliography, doc) if model.bibliography
          @colophon_renderer.render(model.colophon, doc) if model.colophon
          @indexsect_renderer.render(model.indexsect, doc) if model.indexsect

          @section_manager.apply_body_section(
            doc, header_text: header_text, copyright_text: copyright_text,
          )
        end

        def visit_sections(sections, doc)
          walk_mixed_content(sections, doc)
        end

        def visit_bibliography(bib, doc)
          @context.with_bibliography do
            bib.references&.each { |r| visit_references_section(r, doc) }
            bib.clause&.each { |c| dispatch(c, doc) }
          end
        end

        # ── Middle title page ────────────────────────────────────────
        #
        # The reference DOCX renders the document title on a separate
        # page between front matter and body. Era C uses MainTitle1 for
        # the intro+main combination and MainTitle2 for the part title.
        # Delegated to MiddleTitleRenderer.

        # ── Section visitors ───────────────────────────────────────────

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
          # ── Non-paragraph types ──
          when Metanorma::Document::Components::AncillaryBlocks::FormulaBlock
            visit_formula(node, doc)
          when Metanorma::Document::Components::AncillaryBlocks::SourcecodeBlock
            visit_sourcecode(node, doc)
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
        # place. Adapter methods (visit_bibliography, visit_references_section,
        # etc.) call this to recurse into children; the walker dispatches
        # each child back through +#dispatch+.

        def walk_mixed_content(node, doc)
          @walker.walk(node, doc)
        end
      end
    end
  end
end
