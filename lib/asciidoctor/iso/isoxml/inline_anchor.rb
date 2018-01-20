module Asciidoctor
  module ISO
    module ISOXML
      module InlineAnchor
        def inline_anchor(node)
          case node.type
          when :xref
            inline_anchor_xref node
          when :link
            inline_anchor_link node
          when :bibref
            inline_anchor_bibref node
          else
            warning(node, "unknown anchor type", node.type.inspect)
          end
        end

        def inline_anchor_xref(node)
          format = "inline"
          xref_contents = node.text
          matched = /^fn(:  (?<text>.*))?$/.match node.text
          unless matched.nil?
            format = "footnote"
            xref_contents = matched[:text]
          end
          target = node.target.gsub(/^#/, "").gsub(/(.)(\.xml)?#.*$/, "\\1")
          noko do |xml|
            xml.xref xref_contents, **attr_code(target: target, format: format)
          end.join
        end

        def inline_anchor_link(node)
          eref_contents = node.target == node.text ? nil : node.text
          eref_attributes = {
            target: node.target,
          }
          noko do |xml|
            xml.eref eref_contents, **attr_code(eref_attributes)
          end.join
        end

        def inline_anchor_bibref(node)
          eref_contents = node.target == node.text ? nil : node.text
          eref_attributes = {
            anchor: node.target,
          }
          noko do |xml|
            xml.ref eref_contents, **attr_code(eref_attributes)
          end.join
        end

        def inline_callout(node)
          noko do |xml|
            xml.ref node.text
          end.join
        end
      end
    end
  end
end
