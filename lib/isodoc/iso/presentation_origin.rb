module IsoDoc
  module Iso
    class PresentationXMLConvert < IsoDoc::PresentationXMLConvert
      def origin(docxml)
        short_style_origin(docxml)
        super
        bracketed_refs_processing(docxml)
      end

      def short_style_origin(docxml)
        docxml.xpath(ns("//fmt-origin")).each do |o|
          xref_empty?(o) or next
          fmt_origin_cite_full?(o) and o["style"] ||= "short"
        end
      end

      def fmt_origin_cite_full?(elem)
        sem_xml_descendant?(elem) and return
        id = elem["bibitemid"] or return
        b = @bibitem_lookup[id] or return
        b["type"] != "standard" ||
          !b.at(ns("./docidentifier[not(@type = 'metanorma' or @type = 'metanorma-ordinal')]"))
      end

      # style [1] references as [Reference 1], eref or origin
      def bracketed_refs_processing(docxml)
        (docxml.xpath(ns("//semx[@element = 'eref']")) -
        docxml.xpath(ns("//semx[@element = 'erefstack']//semx[@element = 'eref']")))
          .each { |n| bracket_eref_style(n) }
        docxml.xpath(ns("//semx[@element = 'erefstack']")).each do |n|
          bracket_erefstack_style(n)
        end
        docxml.xpath(ns("//semx[@element = 'origin']")).each do |n|
          bracket_origin_style(n)
        end
      end

      def bracket_eref_style(elem)
        semx = bracket_eref_original(elem) or return
        if semx["style"] == "superscript"
          elem.children.wrap("<sup></sup>")
          remove_preceding_space(elem)
        else
          r = @i18n.reference
          elem.add_first_child l10n("#{r} ")
        end
      end

      # is the eref corresponding to this semx a simple [n] reference?
      def bracket_eref_original(elem)
        semx = elem.document.at("//*[@id = '#{elem['source']}']") or return
        dup = elem.at(ns(".//fmt-eref | .//fmt-xref | .//fmt-origin"))
        non_locality_elems(semx).empty? or return
        /^\[\d+\]$/.match?(semx["citeas"]) or return
        %w(full short).include?(dup["style"]) and return
        semx
      end

      def bracket_erefstack_style(elem)
        semx, erefstack_orig = bracket_erefstack_style_prep(elem)
        semx.empty? and return
        if erefstack_orig && erefstack_orig["style"]
          elem.children.each do |e|
            e.name == "span" and e.remove
            e.text.strip.empty? and e.remove
          end
          elem.children.wrap("<sup></sup>")
          remove_preceding_space(elem)
        else
          r = @i18n.inflect(@i18n.reference, number: "pl")
          elem.add_first_child l10n("#{r} ")
        end
      end

      def bracket_erefstack_style_prep(elem)
        semx = elem.xpath(ns(".//semx[@element = 'eref']"))
          .map { |e| bracket_eref_original(e) }.compact
        erefstack_orig = elem.document.at("//*[@id = '#{elem['source']}']")
        [semx, erefstack_orig]
      end

      def bracket_origin_style(elem)
        bracket_eref_style(elem)
        insert_biblio_callout(elem)
      end

      # TODO share with metanorma dir
      ISO_PUBLISHER_XPATH = <<~XPATH.freeze
        ./contributor[role/@type = 'publisher']/organization[abbreviation = 'ISO' or abbreviation = 'IEC' or name = 'International Organization for Standardization' or name = 'International Electrotechnical Commission']
      XPATH

      def insert_biblio_callout(elem)
        semx = elem.document.at("//*[@id = '#{elem['source']}']") or return
        if ref = @bibitem_lookup[semx["bibitemid"]]
          ref.at(ns(ISO_PUBLISHER_XPATH)) and return
          # is this reference cited with a [n],
          # even if it has its own SDO identifier?
          citeas = ref.at(ns("./docidentifier[@type = 'metanorma-ordinal']")) ||
            ref.at(ns("./docidentifier[@type = 'metanorma']")) ||
            ref.at(ns("./docidentifier[@scope = 'biblio-tag']"))
          citeas = citeas.text
        else
          citeas = semx["citeas"]
        end
        /^\[\d+\]$/.match?(citeas) or return
        elem << <<~XML
          <fmt-xref target='#{semx['bibitemid']}'><sup>#{citeas}</sup></fmt-xref>
        XML
      end

      def remove_preceding_space(elem)
        # Find the preceding text node that has actual content
        prec = elem.at("./preceding-sibling::text()" \
          "[normalize-space(.) != ''][1]") or return
        prec.content.end_with?(" ") and prec.content = prec.content.rstrip
      end
    end
  end
end
