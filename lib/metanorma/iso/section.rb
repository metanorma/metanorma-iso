require "htmlentities"
require "uri" if /^2\./.match?(RUBY_VERSION)

module Metanorma
  module Iso
    class Converter < Standoc::Converter

      def scope_parse(attrs, xml, node)
        attrs = attrs.merge(type: "scope") unless @amd
        clause_parse(attrs, xml, node)
      end

      def support_appendix?(_node)
        true
      end

      def patent_notice_parse(xml, node)
        # xml.patent_notice do |xml_section|
        #  xml_section << node.content
        # end
        xml << node.content
      end

      def sectiontype(node, level = true)
        return nil if @amd

        ret = sectiontype_streamline(sectiontype1(node))
        return ret if ret == "terms and definitions" && @vocab

        super
      end

      def term_def_subclause_parse(attrs, xml, node)
        node.role == "term" and
          return term_def_subclause_parse1(attrs, xml, node)
        super
      end

      # in ISO, term has subterm, unless
      # there is no definition to the term (subclauses start immediately),
      # or it is labelled as "grouping"
      def term_contains_subclauses(node)
        !node.sections? and return false
        node.level != node.blocks[0].level ||
          node.role == "grouping"
      end
    end
  end
end
