# frozen_string_literal: true

require "uniword"
require "metanorma/document"

module IsoDoc
  module Iso
    module Docx
      # Renders inline model elements to Uniword Run objects.
      #
      # Handles mixed-content inline elements (text, em, strong, sub, sup,
      # links, footnotes, math, images) preserving document order via
      # element_order or each_mixed_content.
      #
      # Character styles (rStyles) are applied contextually:
      #   - Hyperlink rStyle on all hyperlink runs
      #   - FootnoteReference rStyle on footnote reference runs
      #   - Span class → character style mapping via StyleResolver
      class InlineRenderer
        include ModelUtils

        attr_accessor :preserve_whitespace

        # Callable that maps annotation target IDs to DOCX comment IDs.
        # Set by the adapter after creating the CommentRenderer.
        attr_writer :comment_id_lookup

        def initialize(context, resolver, doc_builder)
          @context = context
          @resolver = resolver
          @doc = doc_builder
          @footnote_cache = {}
          @preserve_whitespace = false
          @comment_id_lookup = nil
        end

        # Render all inline content from a node into a ParagraphBuilder.
        def render(node, para)
          if ordered?(node)
            render_ordered_inline(node, para)
          else
            render_collection_inline(node, para)
          end
        end

        def render_ordered_inline(node, para)
          walked = false
          each_ordered_element(node) do |type, obj|
            walked = true
            case type
            when :text then add_text(para, obj)
            when :element then render_inline_element(obj, para)
            end
          end
          return if walked

          node.each_mixed_content do |child|
            case child when String then add_text(para, child)
            else render_inline_element(child, para)
            end
          end
        end

        # Fallback: render typed attribute collections when no ordering
        # information is available.
        def render_collection_inline(node, para)
          texts = extract_texts(node)
          texts.each { |t| add_text(para, t) unless t.nil? || t.strip.empty? }

          render_inline_elements(node, para)
        end

        # Central inline dispatch — MECE by design.
        #
        # Subclass types MUST appear before their superclass in the
        # case/when to avoid the superclass branch matching first.
        def render_inline_element(element, para)
          case element
          when Metanorma::Document::Components::Inline::EmRawElement,
               Metanorma::Document::Components::TextElements::EmphasisElement
            render_italic(element, para)
          when Metanorma::Document::Components::Inline::StrongRawElement,
               Metanorma::Document::Components::TextElements::StrongElement
            render_bold(element, para)
          when Metanorma::Document::Components::Inline::SubElement,
               Metanorma::Document::Components::TextElements::SubscriptElement
            render_subscript(element, para)
          when Metanorma::Document::Components::Inline::SupElement,
               Metanorma::Document::Components::TextElements::SuperscriptElement
            render_superscript(element, para)
          when Metanorma::Document::Components::Inline::TtElement,
               Metanorma::Document::Components::TextElements::MonospaceElement
            render_monospace(element, para)
          when Metanorma::Document::Components::TextElements::StrikeElement
            render_strikethrough(element, para)
          when Metanorma::Document::Components::TextElements::UnderlineElement
            render_underline(element, para)
          when Metanorma::Document::Components::TextElements::KeywordElement
            render_keyword(element, para)
          when Metanorma::Document::Components::TextElements::SmallCapsElement,
               Metanorma::Document::Components::Inline::SmallCapElement
            render_smallcap(element, para)
          when Metanorma::Document::Components::Inline::BrElement
            br_run = Uniword::Wordprocessingml::Run.new
            br_run.break = Uniword::Wordprocessingml::Break.new
            para << br_run
          when Metanorma::Document::Components::Inline::TabElement
            tab_run = Uniword::Wordprocessingml::Run.new
            tab_run.tab = Uniword::Wordprocessingml::Tab.new
            para << tab_run
          when Metanorma::Document::Components::EmptyElements::PageBreakElement
            para << Uniword::Builder.page_break
          when Metanorma::Document::Components::Inline::LinkElement
            render_link(element, para)
          when Metanorma::Document::Components::Inline::XrefElement
            render_xref(element, para)
          when Metanorma::Document::Components::Inline::ErefElement
            render_eref(element, para)
          when Metanorma::Document::Components::Inline::FnElement
            render_footnote(element, para)
          when Metanorma::Document::Components::Inline::FmtStemElement,
               Metanorma::Document::Components::Inline::StemInlineElement,
               Metanorma::Document::Components::TextElements::StemElement
            render_stem(element, para)
          when Metanorma::Document::Components::Inline::MathElement
            # Skip — math is handled by render_stem on the parent stem element
          when Metanorma::Document::Components::Inline::AsciimathElement
            text = element.text if element.class.attributes.key?(:text)
            add_text_with_char_style(para, text, :stem) if text.is_a?(String) && !text.empty?
          when Metanorma::Document::Components::IdElements::Image
            render_inline_image(element, para)
          when Metanorma::Document::Components::IdElements::Bookmark
            render_bookmark(element, para)
          when Metanorma::Document::Components::Inline::Bcp14Element
            render_bold(collect_text(element), para)
          when Metanorma::Document::Components::Inline::SpanElement
            render_span(element, para)
          when Metanorma::Document::Components::Inline::SemxElement
            render_semx(element, para)
          when Metanorma::Document::Components::Paragraphs::ParagraphBlock
            render_mixed_inline_fallback(element, para)
          when Metanorma::IsoDocument::RawParagraph
            render_raw_paragraph(element, para)
          when Metanorma::Document::Components::Inline::FmtXrefElement
            render_fmt_xref(element, para)
          when Metanorma::Document::Components::Inline::FmtXrefLabelElement
            nil
          when Metanorma::Document::Components::Inline::FmtFootnoteContainerElement,
               Metanorma::Document::Components::Inline::FmtFnLabelElement,
               Metanorma::Document::Components::Inline::FmtAnnotationStartElement
            render_annotation_start(element, para)
          when Metanorma::Document::Components::Inline::FmtAnnotationEndElement
            render_annotation_end(element, para)
          when Metanorma::Document::Components::Inline::FmtTitleElement,
               Metanorma::Document::Components::Inline::FmtNameElement
            render_mixed_inline_fallback(element, para)
          when Metanorma::IsoDocument::Terms::TermExpression
            Array(element.name).each { |n| render(n, para) }
          when Metanorma::IsoDocument::Terms::TermNameElement
            render(element, para)
          when Metanorma::Document::Components::Inline::VariantTitleElement
            render_mixed_inline_fallback(element, para)
          else
            text = collect_text(element)
            add_text(para, text) if text && !text.empty?
          end
        end

        # Render inline content for headings, skipping fmt-caption-delim spans
        # that contain tab separators between section numbers and title text.
        def render_heading(node, para)
          if ordered?(node)
            render_heading_ordered(node, para)
          else
            render(node, para)
          end
        end

        private

        def render_heading_ordered(node, para)
          walked = false
          each_ordered_element(node) do |type, obj|
            walked = true
            case type
            when :text then para << obj
            when :element
              next if caption_delim_span?(obj)
              render_inline_element(obj, para)
            end
          end
          return if walked

          render(node, para)
        end

        def caption_delim_span?(element)
          return false unless element.is_a?(Metanorma::Document::Components::Inline::SpanElement)

          cls = element.class_attr
          cls == "fmt-caption-delim"
        end

        # SpanElement with a class attribute maps to a DOCX character style.
        # Presentation XML uses spans like <span class="stdpublisher">ISO</span>
        # where the class value IS the DOCX character styleId.
        def render_span(element, para)
          style = @resolver.span_class_style(element.class_attr)
          if style
            render_with_char_style(element, para, style)
          else
            render_mixed_inline_fallback(element, para)
          end
        end

        def render_with_char_style(element, para, style)
          if ordered?(element)
            element.each_mixed_content do |child|
              case child
              when String
                next if child.nil? || child.empty?

                add_text_with_char_style(para, child, style)
              else
                render_inline_element(child, para)
              end
            end
          else
            text = collect_text(element)
            if text && !text.empty?
              add_text_with_char_style(para, text, style)
            end
          end
        end

        def render_italic(element, para)
          if element.is_a?(String)
            text = element
          elsif ordered?(element) && has_rich_children?(element)
            render_with_run_format(element, para) { |run| run.properties.italic = Uniword::Properties::Italic.new }
            return
          else
            text = collect_text(element)
          end
          return if text.nil? || text.to_s.empty?

          run = Uniword::Builder::RunBuilder.new
          run.text(text.to_s).italic
          para << run.build
        end

        def render_bold(element, para)
          if element.is_a?(String)
            text = element
          elsif ordered?(element) && has_rich_children?(element)
            render_with_run_format(element, para) { |run| run.properties.bold = Uniword::Properties::Bold.new }
            return
          else
            text = collect_text(element)
          end
          return if text.nil? || text.to_s.empty?

          run = Uniword::Builder::RunBuilder.new
          run.text(text.to_s).bold
          para << run.build
        end

        def render_with_run_format(element, para, &formatter)
          temp = Uniword::Builder::ParagraphBuilder.new
          render_mixed_inline_fallback(element, temp)
          temp.model.runs.each do |run|
            run.properties ||= Uniword::Wordprocessingml::RunProperties.new
            formatter.call(run)
            para << run
          end
        end

        def has_rich_children?(element)
          eo = element.element_order
          return false unless eo.is_a?(Array) && !eo.empty?

          eo.any? { |e| e.element? && e.name != "text" }
        end

        def render_subscript(element, para)
          text = collect_text(element)
          return if text.nil? || text.empty?

          run = Uniword::Builder::RunBuilder.new
          run.text(text).subscript
          para << run.build
        end

        def render_superscript(element, para)
          text = collect_text(element)
          return if text.nil? || text.empty?

          run = Uniword::Builder::RunBuilder.new
          run.text(text).superscript
          para << run.build
        end

        def render_monospace(element, para)
          text = collect_text(element)
          return if text.nil? || text.empty?

          # Apply character style for inline code if available
          style = @resolver.character_style(:inline_code)
          if style
            add_text_with_char_style(para, text, style)
          else
            run = Uniword::Builder::RunBuilder.new
            run.text(text).font("Courier New")
            para << run.build
          end
        end

        def render_strikethrough(element, para)
          text = collect_text(element)
          return if text.nil? || text.empty?

          run = Uniword::Builder::RunBuilder.new
          run.text(text).strike
          para << run.build
        end

        def render_underline(element, para)
          text = collect_text(element)
          return if text.nil? || text.empty?

          run = Uniword::Builder::RunBuilder.new
          run.text(text).underline
          para << run.build
        end

        def render_keyword(element, para)
          text = collect_text(element)
          return if text.nil? || text.empty?

          run = Uniword::Builder::RunBuilder.new
          run.text(text).bold.small_caps
          para << run.build
        end

        def render_smallcap(element, para)
          text = collect_text(element)
          return if text.nil? || text.empty?

          run = Uniword::Builder::RunBuilder.new
          run.text(text).small_caps
          para << run.build
        end

        def render_link(element, para)
          text = collect_text(element)
          target = element.target

          if text.nil? || text.empty?
            text = target
            text = text.sub(/\Amailto:/, "") if text&.start_with?("mailto:")
          end
          return if text.nil? || text.empty?

          if target
            link = Uniword::Hyperlink.new(url: target, text: text)
            model = link.to_model(allocator: @doc.allocator)
            apply_hyperlink_style(model)
            para << model
          else
            run = Uniword::Builder::RunBuilder.new
            run.text(text).underline.color("0000FF")
            para << run.build
          end
        end

        def render_xref(element, para)
          text = collect_text(element)
          return if text.nil? || text.empty?

          target = element.target
          if target
            link = Uniword::Hyperlink.new(anchor: target, text: text)
            link_model = link.to_model(allocator: @doc.allocator)
            apply_hyperlink_style(link_model)
            para << link_model
          else
            run = Uniword::Builder::RunBuilder.new
            run.text(text).underline.color("0000FF")
            para << run.build
          end
        end

        def render_eref(element, para)
          text = collect_text(element)
          return if text.nil? || text.empty?

          cite = element.citeas || element.bibitemid
          if cite && !cite.empty?
            link = Uniword::Hyperlink.new(url: "##{cite}", text: text)
            link_model = link.to_model(allocator: @doc.allocator)
            apply_hyperlink_style(link_model)
            para << link_model
          else
            para << text
          end
        end

        def render_fmt_xref(element, para)
          target = element.target
          if target
            link_model = Uniword::Wordprocessingml::Hyperlink.new
            link_model.anchor = target

            temp = Uniword::Builder::ParagraphBuilder.new
            render_mixed_inline_fallback(element, temp)
            temp.model.runs.each { |r| link_model.runs << r }

            if link_model.runs.empty?
              text = collect_text(element)
              if text && !text.empty?
                run = Uniword::Wordprocessingml::Run.new(text: text)
                link_model.runs << run
              end
            end

            apply_hyperlink_style(link_model) unless link_model.runs.empty?
            para << link_model unless link_model.runs.empty?
          else
            render_mixed_inline_fallback(element, para)
          end
        end

        def render_footnote(element, para)
          text = extract_footnote_text(element)
          return if text.nil? || text.empty?

          if @footnote_cache.key?(text)
            id = @footnote_cache[text]
            fn_run = Uniword::Wordprocessingml::Run.new(
              footnote_reference: Uniword::Wordprocessingml::FootnoteReference.new(id: id.to_s),
            )
            apply_run_char_style(fn_run, :footnote_reference)
            para << fn_run
            return
          end

          fn_run = @doc.footnote(text)
          fn_id = fn_run.footnote_reference&.id
          @footnote_cache[text] = fn_id if fn_id
          apply_run_char_style(fn_run, :footnote_reference)
          para << fn_run
        end

        def extract_footnote_text(element)
          p_children = element.p
          if p_children && !p_children.empty?
            return p_children.map { |p| collect_text(p) }.join(" ")
          end

          collect_text(element)
        end

        def render_stem(element, para)
          text = stem_fallback_text(element)
          add_text_with_char_style(para, text, :stem) if text && !text.empty?
        rescue StandardError
          text = stem_fallback_text(element)
          add_text_with_char_style(para, text, :stem) if text && !text.empty?
        end

        def stem_fallback_text(element)
          if element.class.attributes.key?(:asciimath)
            am = element.asciimath
            return am if am.is_a?(String) && !am.empty?
          end
          collect_text(element)
        end

        def render_inline_image(element, para)
          src = element.source
          return unless src

          width = parse_dimension(element.width)
          height = parse_dimension(element.height)
          alt = element.alt

          begin
            if src.start_with?("data:")
              path = extract_data_uri_to_tempfile(src)
            elsif File.exist?(src)
              path = src
            else
              para << (alt || "[Image]")
              return
            end

            run = Uniword::Builder::ImageBuilder.create_run(
              @doc, path,
              width: width, height: height,
              alt_text: alt
            )
            para << run
          rescue StandardError
            para << (alt || "[Image]")
          end
        end

        def apply_hyperlink_style(hyperlink_model)
          style = @resolver.character_style(:hyperlink)
          return unless style

          hyperlink_model.runs.each do |run|
            run.properties ||= Uniword::Wordprocessingml::RunProperties.new
            run.properties.style = Uniword::Properties::RunStyleReference.new(
              value: style,
            )
          end
        end

        # Apply a character style from the resolver by key name.
        def apply_run_char_style(run, style_key)
          style = @resolver.character_style(style_key)
          return unless style

          run.properties ||= Uniword::Wordprocessingml::RunProperties.new
          run.properties.style = Uniword::Properties::RunStyleReference.new(
            value: style,
          )
        end

        # Add text with a character style (rStyle) applied.
        def add_text_with_char_style(para, text, style_key)
          style = style_key.is_a?(String) ? style_key : @resolver.character_style(style_key)

          if style
            run = Uniword::Wordprocessingml::Run.new(text: text.to_s)
            run.properties = Uniword::Wordprocessingml::RunProperties.new(
              style: Uniword::Properties::RunStyleReference.new(value: style),
            )
            para << run
          else
            add_text(para, text)
          end
        end

        def render_bookmark(element, para)
          name = element.id || element.name
          return unless name

          id = @context.next_bookmark_id.to_s
          para << Uniword::Wordprocessingml::BookmarkStart.new(id: id, name: name)
          para << Uniword::Wordprocessingml::BookmarkEnd.new(id: id)
        end

        def render_raw_paragraph(element, para)
          return unless element.content

          wrapped = "<p>#{element.content}</p>"
          parsed = Metanorma::Document::Components::Paragraphs::ParagraphBlock.from_xml(wrapped)
          render_mixed_inline_fallback(parsed, para)
        rescue StandardError
          para << element.content
        end

        def render_semx(element, para)
          case element.element_attr
          when "link"
            nil
          else
            render_mixed_inline_fallback(element, para)
          end
        end

        def render_mixed_inline_fallback(element, para)
          if ordered?(element)
            element.each_mixed_content do |child|
              case child
              when String then add_text(para, child)
              else render_inline_element(child, para)
              end
            end
          else
            text = collect_text(element)
            add_text(para, text) if text && !text.empty?
          end
        end

        def render_inline_elements(node, para)
          return unless node.is_a?(Lutaml::Model::Serializable)

          inline_attrs = %i[em strong sub sup tt underline strike keyword
                            smallcap xref eref link fn fmt_stem bookmark
                            image br span concept bcp14]
          inline_attrs.each do |attr|
            next unless node.class.attributes.key?(attr)

            val = node.public_send(attr)
            next if val.nil?

            Array(val).each { |el| render_inline_element(el, para) }
          end
        end

        def add_text(para, text)
          return if text.nil?

          if @preserve_whitespace
            add_preserved_text(para, text.to_s)
          else
            normalized = text.to_s.gsub(/[ \t]+/, " ")
            para << normalized unless normalized.empty?
          end
        end

        # Split text on newlines and insert <w:br/> runs between lines.
        # This is essential for sourcecode blocks where newlines must be
        # preserved as line breaks in the DOCX output.
        def add_preserved_text(para, text)
          return if text.empty?

          lines = text.split("\n", -1)
          lines.each_with_index do |line, i|
            unless i.zero?
              br_run = Uniword::Wordprocessingml::Run.new
              br_run.break = Uniword::Wordprocessingml::Break.new
              para << br_run
            end
            para << line unless line.empty?
          end
        end

        # Render a comment range start marker for the given annotation element.
        # The FmtAnnotationStartElement has a `target` attribute that maps to
        # the fmt-annotation-body ID, which CommentRenderer maps to a DOCX
        # comment ID.
        #
        # Note: CommentRangeStart/End markers are added to the paragraph's
        # element_order directly if the builder doesn't accept them via <<.
        def render_annotation_start(element, para)
          target_id = element.target if element.class.attributes.key?(:target)
          return unless target_id

          comment_id = lookup_comment_id(target_id)
          return unless comment_id

          marker = Uniword::Wordprocessingml::CommentRangeStart.new(id: comment_id)
          para << marker
        rescue ArgumentError
          # ParagraphBuilder doesn't accept this type — skip silently.
          # Comment definitions are still created in comments.xml.
          nil
        end

        # Render a comment range end marker and comment reference.
        def render_annotation_end(element, para)
          target_id = element.target if element.class.attributes.key?(:target)
          return unless target_id

          comment_id = lookup_comment_id(target_id)
          return unless comment_id

          end_marker = Uniword::Wordprocessingml::CommentRangeEnd.new(id: comment_id)
          para << end_marker

          ref_run = Uniword::Wordprocessingml::Run.new(
            comment_reference: Uniword::Wordprocessingml::CommentReference.new(
              id: comment_id,
            ),
          )
          apply_run_char_style(ref_run, :comment_reference)
          para << ref_run
        rescue ArgumentError
          nil
        end

        def lookup_comment_id(annotation_target_id)
          return nil unless @comment_id_lookup

          @comment_id_lookup.call(annotation_target_id)
        end
      end
    end
  end
end
