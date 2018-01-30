module Asciidoctor
  module ISO
      module InlineAnchor
        class << self
          @@refids = Set.new

          def is_refid?(x)
            @@refids.include? x
          end
        end

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
          f = "inline"
          c = node.text
          matched = /^fn(:  (?<text>.*))?$/.match node.text
          unless matched.nil?
            f = "footnote"
            c = matched[:text]
          end
          t = node.target.gsub(/^#/, "").gsub(%r{(.)(\.xml)?#.*$}, "\\1")
            noko { |xml| xml.xref c, **attr_code(target: t, type: f) }.join
        end

        def inline_anchor_link(node)
          contents = node.target == node.text ? nil : node.text
          attributes = { "target": node.target }
          noko do |xml|
            xml.link contents, **attr_code(attributes)
          end.join
        end

        def inline_anchor_bibref(node)
          eref_contents = node.target == node.text ? nil : node.text
          eref_attributes = { id: node.target }
          @@refids << node.target
          noko do |xml|
            xml.ref eref_contents, **attr_code(eref_attributes)
          end.join
        end

        def inline_callout(node)
          noko do |xml|
            xml.callout node.text
          end.join
        end
      end
    end
  end
