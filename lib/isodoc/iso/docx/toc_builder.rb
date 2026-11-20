# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      # Generates Table of Contents entries from the document model.
      #
      # Walks the model structure to collect section headings and renders
      # them as TOC1/TOC2/TOC3 paragraphs with PAGEREF fields pointing to
      # the section's bookmark.
      #
      # The TOC appears between the copyright page and the Foreword, as a
      # separate content section within the front matter.
      #
      # The entries are wrapped in a single TOC field result: the field
      # begin + instruction + separate open the first entry paragraph and
      # the field end closes the last one, so Word's update-F9 replaces
      # the static entries in place.
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
        include ModelUtils

        # The Word TOC field instruction. The static entries are emitted
        # as the field RESULT (between the separate and the end), so a
        # Word field refresh replaces them wholesale instead of
        # duplicating them.
        #
        # \o "1-3" selects heading 1-3 and \t adds the unnumbered
        # heading styles at level 1, so a refresh yields the entries
        # cached here. \u is omitted: it also selects every paragraph
        # style with an outline level, which pulls in the annex
        # sub-clause styles (a2/a3) and the main-title style.
        TOC_FIELD_INSTRUCTION = ' TOC \\o "1-3" \\h \\z \\t ' \
                                '"Foreword Title,1,Intro Title,1,ANNEX,1,Biblio Title,1" '

        def initialize(resolver, inline_renderer, context)
          @resolver = resolver
          @inline = inline_renderer
          @context = context
        end

        # Render the TOC heading and all entries.
        #
        # The entries form the result of a single TOC field: the field
        # begin + instruction + separate open the first entry paragraph
        # and the field end closes the last one. Word's update-F9
        # therefore regenerates the ToC in place instead of appending a
        # second copy below the static entries (the field and the entries
        # are no longer separate blocks).
        def render(model, doc)
          return unless model

          # Render "Contents" heading
          render_toc_heading(doc)

          # Collect entries by walking the model
          entries = collect_entries(model)
          return if entries.empty?

          # Render each TOC entry, wrapping them in the TOC field result
          entries.each_with_index do |entry, index|
            render_toc_entry(entry, doc,
                             open_field: index.zero?,
                             close_field: index == entries.size - 1)
          end

          request_field_refresh(doc)
        end

        private

        # The cached page numbers are placeholders; w:updateFields makes
        # Word recompute them (and the TOC) when the document is opened.
        def request_field_refresh(doc)
          doc.model.settings ||= Uniword::Wordprocessingml::Settings.new
          doc.model.settings.update_fields = Uniword::Wordprocessingml::UpdateFields.new
        end

        def render_toc_heading(doc)
          para = Uniword::Builder::ParagraphBuilder.new
          para.style = @resolver.paragraph_style(:contents_title)
          para << "Contents"
          doc << para
        end

        # A TOC entry holds a reference to the source clause/section node
        # so that the heading's full fmt-title (autonum + delimiter + title)
        # can be rendered inline by the InlineRenderer — preserving the
        # structural separation between section number, tab, and title text.
        TocEntry = Struct.new(:source, :level, :bookmark_name, keyword_init: true)

        def collect_entries(model)
          entries = []

          # Preface entries (Foreword, Introduction)
          if model.preface
            add_preface_entries(entries, model.preface)
          end

          # Body entries (Scope, Terms, etc.) — sorted by displayorder
          # so the TOC matches body order.
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
          # Walk top-level children in displayorder so the TOC matches
          # body order. The presentation XML places <references> at the
          # end of <sections> regardless of its displayorder value, so
          # without sorting the Normative references entry would appear
          # at the end of the TOC instead of between Scope and Terms.
          top_level = []
          top_level += Array(sections.clause) if sections.class.attributes.key?(:clause)
          top_level += Array(sections.references) if sections.class.attributes.key?(:references)
          top_level += Array(sections.terms) if sections.class.attributes.key?(:terms)
          top_level += Array(sections.definitions) if sections.class.attributes.key?(:definitions)

          top_level.sort_by { |node| display_order_of(node) }.each do |node|
            case node
            when Metanorma::Iso::Document::Sections::IsoClauseSection,
                 Metanorma::Standoc::Document::Sections::StandardReferencesSection,
                 Metanorma::Document::Components::Sections::ReferencesSection
              add_clause_entries(entries, node, 1)
            when Metanorma::Iso::Document::Sections::IsoTermsSection
              entries << build_entry(node, 1)
            else
              entries << build_entry(node, 1)
            end
          end
        end

        def display_order_of(node)
          return 999_999 unless node.is_a?(Lutaml::Model::Serializable)
          return 999_999 unless node.class.attributes.key?(:displayorder)

          node.displayorder || 999_999
        end

        def add_clause_entries(entries, clause, level)
          return if level > 3

          title = section_heading(clause)
          entries << build_entry(clause, level) if title && !@inline.heading_body_empty?(title)

          # Recurse into sub-clauses
          if clause.class.attributes.key?(:clause)
            Array(clause.clause).each do |sub|
              add_clause_entries(entries, sub, level + 1)
            end
          end
        end

        def section_heading(node)
          fmt = node.fmt_title if node.class.attributes.key?(:fmt_title)
          title = node.title if node.class.attributes.key?(:title)
          fmt || title
        end

        # The ToC lists the annex entry alone. Annex sub-clauses are
        # excluded (level >= 2 under an annex), matching the PDF engine's
        # rule — entries under an ancestor-or-self annex at level >= 2
        # are skipped — and the annex ToC composition ruling of
        # 2026-10-26, so both output engines agree.
        #
        # An annex with no heading text renders through the untitled
        # path, which carries its _Toc twin on the clause number. A
        # number-only title still lists the annex; with no visible
        # number and no toc variant-title there is no text to list and
        # no entry is written.
        def add_annex_entry(entries, annex)
          title = section_heading(annex)
          if title && !@inline.heading_body_empty?(title)
            entries << build_entry(annex, 1)
          elsif (title && @inline.heading_number_text(title)) || toc_variant_title(annex)
            entry = build_untitled_annex_entry(annex)
            entries << entry if entry
          end
        end

        def build_untitled_annex_entry(annex)
          id = attribute_value(annex, :anchor) || attribute_value(annex, :id)
          return unless id

          TocEntry.new(source: annex, level: 1, bookmark_name: toc_bookmark_for(id, 1))
        end

        def add_bibliography_entry(entries, bib)
          # The <bibliography> wrapper (BibliographySection) carries no
          # title attributes — emitting it renders an entry paragraph
          # with no heading text and a PAGEREF to a bookmark that no
          # body heading carries (the empty bar before "Bibliography"
          # in the ToC). The titled <references> child provides the
          # entry; skip the wrapper when it cannot render a title.
          entries << build_entry(bib, 1) if has_title?(bib)

          if bib.class.attributes.key?(:references)
            Array(bib.references).each do |refs|
              entries << build_entry(refs, 1) if has_title?(refs)
            end
          end
        end

        def build_entry(node, level)
          id = attribute_value(node, :anchor) || attribute_value(node, :id)
          TocEntry.new(
            source: node,
            level: level,
            bookmark_name: toc_bookmark_for(id, level),
          )
        end

        # The heading renderers bookmark the registered id with a _Toc
        # twin; the entry points at the twin. A node with no id keeps a
        # synthetic name (it has no heading bookmark to share).
        def toc_bookmark_for(id, level)
          return "_Toc#{object_id}_#{level}" unless id

          @context.toc_targets << id
          Context.toc_bookmark_name(id)
        end

        def has_title?(node)
          return false unless node

          fmt = node.fmt_title if node.class.attributes.key?(:fmt_title)
          t = node.title if node.class.attributes.key?(:title)
          fmt || t
        end

        def toc_clause?(clause)
          # The model maps the XML @type attribute to +type+; there is no
          # +type_attr+ attribute, so testing for it silently disabled
          # the exclusion and leaked the auto-generated Contents clause
          # into the ToC as a spurious self-entry.
          return false unless clause.class.attributes.key?(:type)

          clause.type == "toc"
        end

        # Render the TOC entry: heading text (with autonum + tab + title
        # as separate runs), then a tab, then the PAGEREF field.
        #
        # +open_field+ emits the TOC field begin + instruction + separate
        # at the start of the paragraph (first entry), +close_field+
        # emits the TOC field end at the end of it (last entry) — the
        # entries together form the field result.
        def render_toc_entry(entry, doc, open_field: false, close_field: false)
          para = Uniword::Builder::ParagraphBuilder.new
          para.style = toc_style(entry.level)

          if open_field
            para << field_char_run("begin")
            para << instr_text_run(TOC_FIELD_INSTRUCTION)
            para << field_char_run("separate")
          end

          # The text, tab and page number form one hyperlink to the
          # heading's _Toc bookmark, so the entry is clickable.
          runs = HyperlinkRuns.new(entry.bookmark_name, para)
          render_toc_heading_text(entry.source, runs)
          append_tab(runs)

          # PAGEREF field with a placeholder result: the static result
          # is "1" until Word refreshes the fields (w:updateFields, see
          # request_field_refresh), when the entry's bookmark yields the
          # real page number.
          runs << field_char_run("begin")
          runs << instr_text_run(" PAGEREF #{entry.bookmark_name} \\h ")
          runs << field_char_run("separate")
          runs << Uniword::Wordprocessingml::Run.new(text: "1")
          runs << field_char_run("end")

          para << field_char_run("end") if close_field

          doc << para
        end

        # Render the source node's title content inline. ToC entries use
        # the single-line composition: the presentation XML carries
        # variant-title[@type='toc'] (label + tab + title, with no line
        # breaks), which is what the PDF engine consumes for its ToC.
        # fmt-title carries the display form — for annexes it embeds
        # <br/> breaks and the obligation line, which would render the
        # ToC entry as a multi-line paragraph — so it is only a fallback
        # for nodes that carry no ToC variant title.
        #
        # The composition is rendered through a HeadingTextSink: the
        # label → title separator must not reach Word as a tab. The ToC
        # styles carry a single tab stop (the right-hand page-number
        # stop), and a tab with no stop ahead of the pen jumps to the
        # next one in order — carrying the entire heading text to the
        # right margin behind a dot leader (metanorma-pdfa#119). The
        # separator is therefore flattened to a space, matching the
        # inline flow the PDF ToC composes.
        def render_toc_heading_text(node, runs)
          sink = HeadingTextSink.new(runs)
          render_toc_heading_source(node, sink)
        end

        def render_toc_heading_source(node, sink)
          if (variant = toc_variant_title(node))
            @inline.render(variant, sink)
          elsif node.class.attributes.key?(:fmt_title) && node.fmt_title
            @inline.render(node.fmt_title, sink)
          elsif node.class.attributes.key?(:title) && node.title
            @inline.render(node.title, sink)
          end
        end

        # Collects an entry's runs into its hyperlink and appends the
        # hyperlink to the paragraph on its first run. An element that is
        # not a run (a bookmark, a nested link) goes to the paragraph in
        # arrival order; hyperlinks cannot nest, so it closes the current
        # hyperlink and the runs that follow open a new one to the same
        # anchor. The text order of the entry is therefore preserved.
        class HyperlinkRuns
          def initialize(anchor, para)
            @anchor = anchor
            @para = para
            @open_link = nil
          end

          def <<(element)
            element = Uniword::Wordprocessingml::Run.new(text: element) if element.is_a?(String)
            element = element.build if element.is_a?(Uniword::Builder::RunBuilder)
            if element.is_a?(Uniword::Wordprocessingml::Run)
              open_link.runs << element
            else
              @open_link = nil
              @para << element
            end
            self
          end

          private

          def open_link
            @open_link ||= Uniword::Wordprocessingml::Hyperlink.new(
              anchor: @anchor, history: "1",
            ).tap { |link| @para << link }
          end
        end

        # Inline renderer sink for ToC entry headings. Forwards runs to
        # the entry paragraph, rewriting tab runs into a single space:
        # the only tab in a ToC entry paragraph is the page-number tab.
        class HeadingTextSink
          SPACE = " "

          def initialize(para)
            @para = para
          end

          def <<(element)
            @para << flatten_tab(element)
            self
          end

          private

          def flatten_tab(element)
            return element unless element.is_a?(Uniword::Wordprocessingml::Run)
            return element unless element.tab

            Uniword::Wordprocessingml::Run.new(text: SPACE)
          end
        end

        def toc_variant_title(node)
          return unless node.class.attributes.key?(:variant_title)

          Array(node.variant_title).find { |v| v.type == "toc" }
        end

        def append_tab(para)
          tab_run = Uniword::Wordprocessingml::Run.new
          tab_run.tab = Uniword::Wordprocessingml::Tab.new
          para << tab_run
        end

        def field_char_run(type)
          Uniword::Wordprocessingml::Run.new(
            field_char: Uniword::Wordprocessingml::FieldChar.new(
              fldCharType: type,
            ),
          )
        end

        def instr_text_run(text)
          Uniword::Wordprocessingml::Run.new(
            instr_text: Uniword::Wordprocessingml::InstrText.new(text: text),
          )
        end

        def toc_style(level)
          key = :"toc#{level}"
          @resolver.paragraph_style(key)
        end
      end
    end
  end
end
