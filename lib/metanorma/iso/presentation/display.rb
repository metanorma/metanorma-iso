# frozen_string_literal: true

module Metanorma
  module Iso
    module Presentation
      # Project semantic rich content into existing typed presentation slots.
      class Display
        Inline = Metanorma::Document::Components::Inline

        def initialize(tree)
          @tree = tree
        end

        def apply
          @targets = @tree.nodes.to_h { |node| [@tree.value(node, :id), node] }
          @tree.nodes.each { |node| @tree.ensure_text_order!(node) }
          @tree.nodes.each do |node|
            format_xrefs(node)
            format_heading(node) if @tree.value(node, :title)
            format_caption(node) if node.class.attributes.key?(:fmt_name) && @tree.label(node)
            order_children(node)
          end
        end

        private

        def format_xrefs(node)
          xrefs = Array(@tree.value(node, :xref))
          return if xrefs.empty?
          unless node.class.attributes.key?(:semx) && node.element_order&.any?
            raise Transformer::UnsupportedContent, "Cross-references require native mixed-content order"
          end

          generated = xrefs.to_h { |xref| [xref.id, reference_display(xref)] }
          existing = Array(@tree.value(node, :semx))
          order, semx, xref_index, semx_index = [], [], 0, 0
          node.element_order.each do |entry|
            if entry.element? && entry.name == "semx"
              item = existing[semx_index]
              semx_index += 1
              next if item && generated.key?(item.source) && item.element_attr == "xref"

              semx << item
            end
            order << entry
            next unless entry.element? && entry.name == "xref"

            xref = xrefs.fetch(xref_index)
            xref_index += 1
            semx << generated.fetch(xref.id)
            order << element("semx")
          end
          unless xref_index == xrefs.length
            raise Transformer::UnsupportedContent, "Cross-reference missing from native mixed-content order"
          end
          node.semx = semx
          node.element_order = order
        end

        def reference_display(xref)
          if xref.location&.any? || (xref.format && !%w[local global].include?(xref.format))
            raise Transformer::UnsupportedContent, "Native ISO cross-reference location/format is unsupported"
          end
          label = @tree.label(@targets[xref.target]) if @targets[xref.target]
          authored = Array(xref.text).join
          local = xref.format == "local"
          text = if !authored.empty?
                   authored
                 elsif label
                   local ? label.local : (label.global || label.local)
                 end
          unless text
            raise Transformer::UnsupportedContent, "LADL target label missing for ISO cross-reference #{xref.target}"
          end
          direction = if authored.empty? && label
                        local ? label.direction : (label.global_direction || label.direction)
                      end
          span = Inline::SpanElement.new(text: [text],
                                        style: direction && "direction: #{direction}; unicode-bidi: isolate")
          @tree.ensure_text_order!(span)
          display = Inline::FmtXrefElement.new(target: xref.target, span: [span])
          display.element_order = [element("span")]
          semx = Inline::SemxElement.new(element_attr: "xref", source: xref.id, fmt_xref: [display])
          semx.element_order = [element("fmt-xref")]
          semx
        end

        def format_heading(node)
          return unless node.class.attributes.key?(:fmt_title)

          label = @tree.label(node)
          if numbered_section?(node) && !flag?(node, :unnumbered) && (!label || label.local.to_s.empty?)
            raise Transformer::UnsupportedContent, "LADL label missing for ISO section #{@tree.value(node, :id)}"
          end
          title = @tree.value(node, :title)
          span = project(title)
          prefix = label && label_span(label.local, label.direction)
          spans = [prefix, span].compact
          heading = Inline::FmtTitleElement.new(span: spans)
          heading.element_order = spans.map { element("span") }
          node.fmt_title = heading
        end

        def format_caption(node)
          label = @tree.label(node)
          spans = [label_span(label.local, label.direction)]
          name = @tree.value(node, :name)
          if name
            spans << Inline::SpanElement.new(text: [" — "])
            @tree.ensure_text_order!(spans.last)
            spans << project(name)
          end
          caption = Inline::FmtNameElement.new(span: spans)
          caption.element_order = spans.map { element("span") }
          node.fmt_name = caption
        end

        # A span declares the same rich inline vocabulary as an authored title.
        # Transfer typed children and exact framework order, not flattened text.
        def project(source)
          attrs = source.class.attributes.keys & Inline::SpanElement.attributes.keys
          span = Inline::SpanElement.new(**attrs.to_h { |key| [key, source.public_send(key)] })
          span.element_order = source.element_order if source.element_order&.any?
          @tree.ensure_text_order!(span)
          span
        end

        def label_span(text, direction)
          span = Inline::SpanElement.new(class_attr: "fmt-caption-label",
                                        text: ["#{text} "],
                                        style: direction && "direction: #{direction}; unicode-bidi: isolate")
          @tree.ensure_text_order!(span)
          span
        end

        def order_children(node)
          @tree.content_children(node).each_with_index do |child, index|
            child.displayorder ||= index + 1 if child.class.attributes.key?(:displayorder)
          end
        end

        def numbered_section?(node)
          node.is_a?(Metanorma::Standoc::Document::Sections::ClauseSection) ||
            node.is_a?(Metanorma::Standoc::Document::Sections::AnnexSection)
        end

        def flag?(node, name)
          [true, "true"].include?(@tree.value(node, name))
        end

        def element(name)
          Lutaml::Xml::Element.new("Element", name)
        end
      end
    end
  end
end
