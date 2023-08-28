module IsoDoc
  module Iso
    module BaseConvert
      def annex(node, out)
        amd?(node.document) and
          @suppressheadingnumbers = @oldsuppressheadingnumbers
        super
        amd?(node.document) and @suppressheadingnumbers = true
      end

      def foreword(clause, out)
        @foreword = true
        page_break(out)
        out.div **attr_code(id: clause["id"]) do |s|
          clause_name(nil, clause.at(ns("./title")) || @i18n.foreword, s,
                      { class: "ForewordTitle" })
          clause.elements.each { |e| parse(e, s) unless e.name == "title" }
        end
        @foreword = false
      end
    end
  end
end
