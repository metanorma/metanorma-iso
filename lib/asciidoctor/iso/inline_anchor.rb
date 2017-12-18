module Asciidoctor
  module ISO
    module InlineAnchor
      def inline_anchor(node)
        case node.type
        when :xref
          inline_anchor_xref node
        when :link
          inline_anchor_link node
        # when :bibref
          # inline_anchor_bibref node
        # when :ref
          # inline_anchor_ref node
        else
          warn %(asciidoctor: WARNING (#{current_location(node)}): unknown anchor type: #{node.type.inspect})
        end
      end

      def inline_anchor_xref(node)
        xref_contents = node.text
        matched = /^fn: (?<text>.*)?$/.match xref_contents
        if matched.nil?
          format = "footnote"
        else
          format = "inline"
        xref_contents = matched[:text] unless matched.nil?
        end
        xref_attributes = {
          target: node.target.gsub(/^#/, "").gsub(/(.)(\.xml)?#.*$/, "\\1"),
          format: format,
        }

        noko do |xml|
          xml.xref xref_contents, **attr_code(xref_attributes)
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


    end
  end
end
