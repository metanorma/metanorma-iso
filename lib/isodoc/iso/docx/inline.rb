# frozen_string_literal: true

require "uniword"
require "metanorma/document"
require_relative "model_utils"

module IsoDoc
  module Iso
    module Docx
      # Renders inline model elements to Uniword Run objects.
      #
      # Handles mixed-content inline elements (text, em, strong, sub, sup,
      # links, footnotes, math, images) preserving document order via
      # element_order or each_mixed_content.
      class InlineRenderer
        include ModelUtils

        def initialize(context, resolver, doc_builder)
          @context = context
          @resolver = resolver
          @doc = doc_builder
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
            when :text then para << obj
            when :element then render_inline_element(obj, para)
            end
          end
          return if walked

          node.each_mixed_content do |child|
            case child
            when String then para << child
            else render_inline_element(child, para)
            end
          end
        end

        # Fallback: render typed attribute collections when no ordering
        # information is available.
        def render_collection_inline(node, para)
          texts = extract_texts(node)
          texts.each { |t| para << t unless t.nil? || t.strip.empty? }

          render_inline_elements(node, para)
        end

        # Central inline dispatch — MECE by design.
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
            para << text if text.is_a?(String) && !text.empty?
          when Metanorma::Document::Components::IdElements::Image
            render_inline_image(element, para)
          when Metanorma::Document::Components::IdElements::Bookmark
            render_bookmark(element, para)
          when Metanorma::Document::Components::Inline::Bcp14Element
            render_bold(collect_text(element), para)
          when Metanorma::Document::Components::Inline::SpanElement
            render_span(element, para)
          when Metanorma::Document::Components::Inline::SemxElement
            render_mixed_inline_fallback(element, para)
          when Metanorma::Document::Components::Paragraphs::ParagraphBlock
            render_mixed_inline_fallback(element, para)
          when Metanorma::IsoDocument::RawParagraph
            render_raw_paragraph(element, para)
          when Metanorma::Document::Components::Inline::FmtXrefElement
            render_fmt_xref(element, para)
          when Metanorma::Document::Components::Inline::FmtFootnoteContainerElement,
               Metanorma::Document::Components::Inline::FmtFnLabelElement,
               Metanorma::Document::Components::Inline::FmtAnnotationStartElement,
               Metanorma::Document::Components::Inline::FmtAnnotationEndElement,
               Metanorma::Document::Components::Inline::FmtTitleElement,
               Metanorma::Document::Components::Inline::FmtXrefLabelElement
            render_mixed_inline_fallback(element, para)
          else
            text = collect_text(element)
            para << text if text && !text.empty?
          end
        end

        private

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

                run = Uniword::Wordprocessingml::Run.new(text: child)
                run.properties = Uniword::Wordprocessingml::RunProperties.new(
                  style: Uniword::Properties::RunStyleReference.new(value: style),
                )
                para << run
              else
                render_inline_element(child, para)
              end
            end
          else
            text = collect_text(element)
            if text && !text.empty?
              run = Uniword::Wordprocessingml::Run.new(text: text)
              run.properties = Uniword::Wordprocessingml::RunProperties.new(
                style: Uniword::Properties::RunStyleReference.new(value: style),
              )
              para << run
            end
          end
        end

        def render_italic(element, para)
          text = collect_text(element)
          return if text.nil? || text.empty?

          run = Uniword::Builder::RunBuilder.new
          run.text(text).italic
          para << run.build
        end

        def render_bold(element, para)
          text = element.is_a?(String) ? element : collect_text(element)
          return if text.nil? || text.empty?

          run = Uniword::Builder::RunBuilder.new
          run.text(text).bold
          para << run.build
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

          run = Uniword::Builder::RunBuilder.new
          run.text(text).font("Courier New")
          para << run.build
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
          return if text.nil? || text.empty?

          target = element.target
          if target
            link = Uniword::Hyperlink.new(url: target, text: text)
            para << link.to_model
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
            para << link.to_model
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
            para << link.to_model
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

            para << link_model unless link_model.runs.empty?
          else
            render_mixed_inline_fallback(element, para)
          end
        end

        def render_footnote(element, para)
          text = extract_footnote_text(element)
          fn_run = @doc.footnote(text)
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
          para << text if text && !text.empty?
        rescue StandardError
          text = stem_fallback_text(element)
          para << text if text && !text.empty?
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

          unless File.exist?(src)
            para << (alt || "[Image: #{src}]")
            return
          end

          run = Uniword::Builder::ImageBuilder.create_run(
            @doc, src,
            width: width, height: height,
            alt_text: alt
          )
          para << run
        rescue StandardError
          para << (alt || "[Image]")
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

        def render_mixed_inline_fallback(element, para)
          if ordered?(element)
            element.each_mixed_content do |child|
              case child
              when String then para << child
              else render_inline_element(child, para)
              end
            end
          else
            text = collect_text(element)
            para << text if text && !text.empty?
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

        def extract_mathml(element)
          # MathElement objects store inner MathML in :content (no <math> wrapper)
          if element.class.attributes.key?(:math)
            math_els = element.math
            if math_els.is_a?(Array) && !math_els.empty?
              math_el = math_els.first
              if math_el.class.attributes.key?(:content) && math_el.content.is_a?(String)
                return "<math>#{math_el.content}</math>"
              end
            end
          end

          content = element.content if element.class.attributes.key?(:content)
          if content.is_a?(String)
            math = extract_math_tag(content)
            return math if math
          end

          inner_html = element.inner_html if element.class.attributes.key?(:inner_html)
          if inner_html.is_a?(String)
            math = extract_math_tag(inner_html)
            return math if math
          end

          nil
        end

        # Extract <math ...>...</math> from a string using regex.
        # No XML parsing needed — we just need the raw MathML markup.
        def extract_math_tag(text)
          match = text.match(/<(?:m:)?math[^>]*>.*<\/(?:m:)?math>/m)
          match && match[0]
        end
      end
    end
  end
end
