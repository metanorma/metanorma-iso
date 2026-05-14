# frozen_string_literal: true

require "uniword"
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
            para << "\n"
          when Metanorma::Document::Components::Inline::TabElement
            para << "\t"
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
          when Metanorma::Document::Components::IdElements::Image
            render_inline_image(element, para)
          when Metanorma::Document::Components::IdElements::Bookmark
            render_bookmark(element, para)
          when Metanorma::Document::Components::Inline::Bcp14Element
            render_bold(collect_text(element), para)
          when Metanorma::Document::Components::Inline::SpanElement
            render_span(element, para)
          when Metanorma::Document::Components::Inline::FmtFootnoteContainerElement,
               Metanorma::Document::Components::Inline::FmtFnLabelElement,
               Metanorma::Document::Components::Inline::FmtAnnotationStartElement,
               Metanorma::Document::Components::Inline::FmtAnnotationEndElement,
               Metanorma::Document::Components::Inline::FmtTitleElement,
               Metanorma::Document::Components::Inline::FmtXrefLabelElement,
               Metanorma::Document::Components::Inline::SemxElement,
               Metanorma::Document::Components::Inline::FmtXrefElement
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

        # Render mixed-content children with a character style applied to text runs.
        def render_with_char_style(element, para, style)
          if ordered?(element)
            element.each_mixed_content do |child|
              case child
              when String
                run = Uniword::Builder::RunBuilder.new
                run.text(child).character_style(style)
                para << run.build
              else
                render_inline_element(child, para)
              end
            end
          else
            text = collect_text(element)
            if text && !text.empty?
              run = Uniword::Builder::RunBuilder.new
              run.text(text).character_style(style)
              para << run.build
            end
          end
        end

        def render_italic(element, para)
          run = Uniword::Builder::RunBuilder.new
          run.text(collect_text(element)).italic
          para << run.build
        end

        def render_bold(element, para)
          text = element.is_a?(String) ? element : collect_text(element)
          run = Uniword::Builder::RunBuilder.new
          run.text(text).bold
          para << run.build
        end

        def render_subscript(element, para)
          run = Uniword::Builder::RunBuilder.new
          run.text(collect_text(element)).subscript
          para << run.build
        end

        def render_superscript(element, para)
          run = Uniword::Builder::RunBuilder.new
          run.text(collect_text(element)).superscript
          para << run.build
        end

        def render_monospace(element, para)
          run = Uniword::Builder::RunBuilder.new
          run.text(collect_text(element)).font("Courier New")
          para << run.build
        end

        def render_strikethrough(element, para)
          run = Uniword::Builder::RunBuilder.new
          run.text(collect_text(element)).strike
          para << run.build
        end

        def render_underline(element, para)
          run = Uniword::Builder::RunBuilder.new
          run.text(collect_text(element)).underline
          para << run.build
        end

        def render_keyword(element, para)
          run = Uniword::Builder::RunBuilder.new
          run.text(collect_text(element)).bold.small_caps
          para << run.build
        end

        def render_smallcap(element, para)
          run = Uniword::Builder::RunBuilder.new
          run.text(collect_text(element)).small_caps
          para << run.build
        end

        def render_link(element, para)
          text = collect_text(element)
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
          cite = element.citeas || element.bibitemid
          if cite && !cite.empty?
            link = Uniword::Hyperlink.new(url: "##{cite}", text: text)
            para << link.to_model
          else
            para << text
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
          mathml = extract_mathml(element)
          if mathml && defined?(Plurimath)
            omml = Plurimath::Math.parse(mathml, "mathml").to_ooml
            para << omml
          else
            text = collect_text(element)
            para << text if text && !text.empty?
          end
        rescue StandardError
          text = collect_text(element)
          para << text if text && !text.empty?
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
