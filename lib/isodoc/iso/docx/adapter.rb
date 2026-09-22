# frozen_string_literal: true

require "uniword"
require "metanorma/document"
# Resolves to the canonical copy in lib/metanorma/iso/document.rb (this gem's
# lib precedes metanorma-document's lib in $LOAD_PATH).
require "metanorma/iso/document"

module IsoDoc
  module Iso
    module Docx
      # Converts a Metanorma::Iso::Document::Root model to DOCX/MHTML via Uniword.
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
      # Dispatch is class-keyed via Renderers::Registry (single source of
      # truth). Each content type maps to exactly one Renderer (MECE).
      # Adding a new type = adding one +#register+ call in
      # +#build_registry+ — no edit to existing dispatch logic (OCP).
      #
      # Output format is determined by file extension (.docx or .doc).
      class Adapter
        include ModelUtils

        attr_reader :context, :resolver

        # (model_class, renderer_class) pairs for renderers that share the
        # standard (resolver, context, inline_renderer, walker) constructor.
        # Adding a new block renderer = one line in this table.
        BLOCK_RENDERERS = [
          [Metanorma::Document::Components::MultiParagraph::AdmonitionBlock,
           Renderers::AdmonitionRenderer],
          [Metanorma::Document::Components::MultiParagraph::QuoteBlock,
           Renderers::QuoteRenderer],
          [Metanorma::Document::Components::AncillaryBlocks::ExampleBlock,
           Renderers::ExampleRenderer],
          [Metanorma::Document::Components::Blocks::NoteBlock,
           Renderers::NoteRenderer],
          [Metanorma::Document::Components::Paragraphs::ParagraphBlock,
           Renderers::ParagraphRenderer],
          [Metanorma::Document::Components::Lists::OrderedList,
           Renderers::OrderedListRenderer],
          [Metanorma::Document::Components::Lists::UnorderedList,
           Renderers::UnorderedListRenderer],
          [Metanorma::Document::Components::Tables::TableBlock,
           Renderers::TableRenderer],
        ].freeze

        SECTION_RENDERERS = [
          [Metanorma::Iso::Document::Sections::IsoAnnexSection,
           Renderers::AnnexRenderer],
          [Metanorma::Iso::Document::Sections::IsoTermsSection,
           Renderers::TermsSectionRenderer],
          [Metanorma::Iso::Document::Sections::IsoClauseSection,
           Renderers::ClauseRenderer],
          [Metanorma::Standoc::Document::Sections::StandardReferencesSection,
           Renderers::ReferencesRenderer],
          [Metanorma::Document::Components::Sections::ReferencesSection,
           Renderers::ReferencesRenderer],
          [Metanorma::Iso::Document::Terms::IsoTerm,
           Renderers::TermRenderer],
          [Metanorma::Document::Components::BibData::BibliographicItem,
           Renderers::BibliographyRenderer],
          [Metanorma::Standoc::Document::Blocks::AmendBlock,
           Renderers::AmendRenderer],
        ].freeze

        # (model_class, renderer_class) pairs for renderers with a no-arg
        # constructor (no resolver/context/walker wiring needed).
        SPECIAL_RENDERERS = [
          [Metanorma::Document::Components::EmptyElements::PageBreakElement,
           Renderers::PageBreakRenderer],
          [Metanorma::Document::Components::EmptyElements::HorizontalRuleElement,
           Renderers::HorizontalRuleRenderer],
          [Metanorma::Document::Components::IdElements::Bookmark,
           Renderers::NullRenderer],
        ].freeze

        # @param template [Symbol] :dis or :simple (default :dis)
        # @param template_path [String, nil] explicit template DOCX path
        # @param style_mapping_config [String, nil] explicit YAML config path
        def initialize(template: :dis, template_path: nil,
                       style_mapping_config: nil)
          @template = template
          @template_path = template_path ||
            IsoDoc::Iso::DocxTemplates.template_path(template)
          @style_mapping = DocxStyleMapping.new(
            template: template, config_path: style_mapping_config,
          )
          @context = Context.new
          @resolver = StyleResolver.new(@style_mapping, @context)
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
          build_core_state(doc)
          build_top_level_renderers
          build_internal_renderers
          build_registry
          build_zone_renderers
          wire_comment_lookup
        end

        def build_core_state(doc)
          @context = Context.new
          @resolver = StyleResolver.new(@style_mapping, @context)
          @inline_renderer = InlineRenderer.new(@context, @resolver, doc)
        end

        def build_top_level_renderers
          @cover_renderer = CoverRenderer.new(@resolver, @context)
          @boilerplate_renderer =
            BoilerplateRenderer.new(@resolver, @inline_renderer)
          @header_footer_renderer = HeaderFooterRenderer.new(@resolver)
          @section_manager =
            SectionManager.new(@resolver, @header_footer_renderer)
          @toc_builder = TocBuilder.new(@resolver, @inline_renderer, @context)
          @comment_renderer =
            CommentRenderer.new(@resolver, @inline_renderer)
        end

        def build_internal_renderers
          @walker = Renderers::Walker.new(->(node, d) { dispatch(node, d) })
          @formula_renderer = FormulaRenderer.new(@resolver, @inline_renderer,
                                                  context: @context,
                                                  walker: @walker)
          @sourcecode_renderer =
            SourcecodeRenderer.new(@resolver, @inline_renderer)
          @definition_list_renderer =
            new_renderer(Renderers::DefinitionListRenderer)
          @image_renderer = new_renderer(Renderers::ImageRenderer)
        end

        def build_zone_renderers
          @middle_title_renderer = MiddleTitleRenderer.new(
            resolver: @resolver, inline_renderer: @inline_renderer,
          )
          @preface_renderer = new_renderer(PrefaceRenderer)
          @indexsect_renderer = IndexsectRenderer.new(
            resolver: @resolver, inline_renderer: @inline_renderer,
            walker: @walker
          )
          @colophon_renderer = ColophonRenderer.new(walker: @walker)
        end

        def wire_comment_lookup
          @inline_renderer.comment_id_lookup = method(:lookup_comment_id)
        end

        # Build the Registry of per-content-type renderers. Every content
        # type that the Adapter needs to dispatch is registered here;
        # +#dispatch+ only walks mixed content as a final fallback.
        def build_registry
          @registry = Renderers::Registry.new do |registry|
            register_block_renderers(registry)
            register_section_renderers(registry)
            register_special_renderers(registry)
          end
        end

        def register_block_renderers(registry)
          BLOCK_RENDERERS.each do |model, renderer|
            registry.register(model, new_renderer(renderer))
          end
          register_cached_block_renderers(registry)
        end

        def register_cached_block_renderers(registry)
          register_definition_list(registry)
          register_figure(registry)
          register_image(registry)
          register_sourcecode(registry)
          register_formula(registry)
        end

        def register_definition_list(registry)
          registry.register(
            Metanorma::Document::Components::Lists::DefinitionList,
            @definition_list_renderer,
          )
        end

        def register_figure(registry)
          registry.register(
            Metanorma::Document::Components::AncillaryBlocks::FigureBlock,
            new_renderer(Renderers::FigureRenderer,
                         image_renderer: @image_renderer.method(:call)),
          )
        end

        def register_image(registry)
          registry.register(
            Metanorma::Document::Components::IdElements::Image,
            @image_renderer,
          )
        end

        def register_sourcecode(registry)
          registry.register(
            Metanorma::Document::Components::AncillaryBlocks::SourcecodeBlock,
            @sourcecode_renderer,
          )
        end

        def register_formula(registry)
          registry.register(
            Metanorma::Document::Components::AncillaryBlocks::FormulaBlock,
            @formula_renderer,
          )
        end

        def register_section_renderers(registry)
          SECTION_RENDERERS.each do |model, renderer|
            registry.register(model, new_renderer(renderer))
          end
        end

        def register_special_renderers(registry)
          SPECIAL_RENDERERS.each do |model, renderer|
            registry.register(model, renderer.new)
          end
        end

        def new_renderer(klass, **extras)
          klass.new(
            resolver: @resolver,
            context: @context,
            inline_renderer: @inline_renderer,
            walker: @walker,
            **extras,
          )
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
                  if File.exist?(source)
                    File.read(source, 
                              encoding: "utf-8")
                  else
                    source
                  end
                else
                  source.to_s
                end
          Metanorma::Iso::Document::Root.from_xml(xml)
        end

        def create_document
          if @template_path && File.exist?(@template_path)
            @template_root ||= Uniword.load(@template_path)
            root = @template_root
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
            setup_allocator(root)
            Uniword::Builder::DocumentBuilder.new(root,
                                                  allocator: root.allocator)
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
          root.content_types&.overrides&.reject! do |o|
            o.part_name.to_s == "/docProps/custom.xml" ||
              o.part_name.to_s.include?("customXml/")
          end
          remove_relationships_by_type(root.package_rels, "custom-properties")
          remove_relationships_by_type(root.document_rels, "/customXml")
        end

        def clear_stale_template_content(root)
          root.image_parts = nil
          remove_relationships_by_type(root.document_rels, "/image")
          remove_relationships_by_type(root.document_rels, "/customXml")
        end

        def remove_relationships_by_type(rels, type_fragment)
          return unless rels&.relationships

          rels.relationships.reject! do |rel|
            rel.type.to_s.include?(type_fragment)
          end
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
        #   Middle title (MainTitle1/MainTitle2)
        #   Body sections (Scope, Terms, etc.)
        #   Annexes (each starts with PAGE BREAK)
        #   Bibliography
        #   Colophon
        #   Index
        #   [SECTPR — body section, arabic page numbers]

        def visit_root(model, doc)
          # ── Render annotations (comments) before body traversal ──
          if model.annotation_container
            @comment_renderer.render(model.annotation_container, 
                                     doc)
          end

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
            doc, header_text: header_text, copyright_text: copyright_text
          )

          # ── Section 3: Body (arabic page numbers) ──
          # The reference DOCX layout places the document title on a
          # separate page between front matter and body, using the
          # MainTitle1 (intro+main) and MainTitle2 (title-part) paragraph
          # styles. Delegated to MiddleTitleRenderer.
          @middle_title_renderer.render(model, doc)
          visit_sections(model.sections, doc) if model.sections
          model.annex&.each { |a| dispatch(a, doc) }
          visit_bibliography(model.bibliography, doc) if model.bibliography
          @colophon_renderer.render(model.colophon, doc) if model.colophon
          @indexsect_renderer.render(model.indexsect, doc) if model.indexsect

          @section_manager.apply_body_section(
            doc, header_text: header_text, copyright_text: copyright_text
          )
        end

        def visit_sections(sections, doc)
          render_in_display_order(sections, doc)
        end

        # Walk sections children in +displayorder+ attribute order rather
        # than raw XML order. The presentation XML places <references>
        # at the end of <sections> regardless of its displayorder value,
        # so the walker must reorder to keep "Normative references"
        # between "Scope" and "Terms and definitions".
        def render_in_display_order(sections, doc)
          children = []
          each_ordered_element(sections) do |type, obj|
            next if type == :text
            children << obj
          end
          children.sort_by { |child| display_order_of(child) }.each do |child|
            dispatch(child, doc)
          end
        end

        def display_order_of(node)
          return 999_999 unless node.is_a?(Lutaml::Model::Serializable)
          return 999_999 unless node.class.attributes.key?(:displayorder)

          node.displayorder || 999_999
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

          is_normative = refs_sect.normative.to_s == "true"
          @context.with_normative(is_normative) do
            walk_mixed_content(refs_sect, doc)
          end
        end

        # ── Block visitors (central dispatch) ──────────────────────────
        #
        # Class-keyed dispatch via the Renderers::Registry. Each content
        # type maps to exactly one Renderer instance (MECE). The Registry
        # walks the ancestor chain so subclasses (e.g., IsoClauseSection
        # which inherits from ParagraphBlock) hit the registered renderer
        # for their nearest registered ancestor.
        #
        # Inheritance example: an IsoClauseSection dispatches to its own
        # ClauseRenderer via its explicit entry; subclasses with their
        # own entries always win (exact-class match first).

        # Dispatch entry point used by Renderers::Walker.
        def dispatch(node, doc)
          renderer = @registry.lookup(node.class)
          return renderer.render(node, doc) if renderer

          walk_mixed_content(node, doc)
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
