require "metanorma-standoc"
require_relative "validate_style"
require_relative "validate_requirements"
require_relative "validate_section"
require_relative "validate_title"
require_relative "validate_image"
require_relative "validate_list"
require "nokogiri"
require "jing"
require "iev"

module Metanorma
  module Iso
    class Converter < Standoc::Converter
      def isosubgroup_validate(root)
        root.xpath("//technical-committee/@type").each do |t|
          %w{TC PC JTC JPC}.include?(t.text) or
            @log.add("Document Attributes", nil,
                     "invalid technical committee type #{t}")
        end
        root.xpath("//subcommittee/@type").each do |t|
          %w{SC JSC}.include?(t.text) or
            @log.add("Document Attributes", nil,
                     "invalid subcommittee type #{t}")
        end
      end

      # KILL
      def see_xrefs_validatex(root)
        @lang == "en" or return
        root.xpath("//xref").each do |t|
          preceding = t.at("./preceding-sibling::text()[last()]")
          !preceding.nil? &&
            /\b(see| refer to)\p{Zs}*\Z/mi.match(preceding) or next

          (target = root.at("//*[@anchor = '#{t['target']}']")) || next
          target.at("./ancestor-or-self::*[@obligation = 'normative']") &&
            !target.at("./ancestor::sections") and
            @log.add("Style", t,
                     "'see #{t['target']}' is pointing to a normative section")
        end
      end

      # ISO/IEC DIR 2, 15.5.3, 20.2
      # does not deal with preceding text marked up
      def see_xrefs_validate(root)
        @lang == "en" or return
        anchors = extract_anchor_norm(root)
        root.xpath("//xref").each do |t|
          preceding = t.at("./preceding-sibling::text()[last()]")
          !preceding.nil? &&
            /\b(see| refer to)\p{Zs}*\Z/mi.match(preceding) or next
          anchors[t["target"]] and
            @log.add("Style", t,
                     "'see #{t['target']}' is pointing to a normative section")
        end
      end

      def extract_anchor_norm(root)
        nodes = root.xpath("//annex[@obligation = 'normative'] | " \
          "//references[@obligation = 'normative']")
        ret = nodes.each_with_object({}) do |n, m|
          n["anchor"] and m[n["anchor"]] = true
        end
        nodes.each do |n|
          n.xpath(".//*[@anchor]").each { |n1| ret[n1["anchor"]] = true }
        end
        ret
      end

      # ISO/IEC DIR 2, 15.5.3
      def see_erefs_validate(root)
        @lang == "en" or return
        bibitemids = extract_bibitem_anchors(root)
        root.xpath("//eref").each do |t|
          prec = t.at("./preceding-sibling::text()[last()]")
          !prec.nil? && /\b(see|refer to)\p{Zs}*\Z/mi.match(prec) or next
          unless target = bibitemids[t["bibitemid"]]
            #unless target = root.at("//bibitem[@anchor = '#{t['bibitemid']}']")
            @log.add("Bibliography", t,
                     "'#{t} is not pointing to a real reference")
            next
          end
          #target.at("./ancestor::references[@normative = 'true']") and
          target[:norm] and
            @log.add("Style", t,
                     "'see #{t}' is pointing to a normative reference")
        end
      end

      def extract_bibitem_anchors(root)
        ret = root.xpath("//references[@normative = 'true']//bibitem")
          .each_with_object({}) do |b, m|
          m[b["anchor"]] = { bib: b, norm: true }
        end
        root.xpath("//references[not(@normative = 'true')]//bibitem")
          .each do |b|
          ret[b["anchor"]] = { bib: b, norm: false }
        end
        ret
      end

      # ISO/IEC DIR 2, 10.4
      def locality_erefs_validate(root)
        root.xpath("//eref[descendant::locality]").each do |t|
          if /^(ISO|IEC)/.match?(t["citeas"]) &&
              !/: ?(\d+{4}|–)$/.match?(t["citeas"])
            @log.add("Style", t,
                     "undated reference #{t['citeas']} should not contain " \
                     "specific elements")
          end
        end
      end

      def termdef_warn(text, regex, elem, term, msg)
        regex.match(text) && @log.add("Style", elem, "#{term}: #{msg}")
      end

      # https://www.iso.org/ISO-house-style.html#iso-hs-s-text-r-r-ref_clause3
      def term_xrefs_validate(xmldoc)
        termids = xmldoc
          .xpath("//sections/terms | //sections/clause[.//terms] | " \
                 "//annex[.//terms]").each_with_object({}) do |t, m|
          t.xpath(".//*/@anchor").each { |a| m[a.text] = true }
          t.name == "terms" and m[t["anchor"]] = true
        end
        xmldoc.xpath(".//xref").each do |x|
          term_xrefs_validate1(x, termids)
        end
      end

      def term_xrefs_validate1(xref, termids)
        closest_id = xref.xpath("./ancestor::*[@anchor]")&.last or return
        termids[xref["target"]] && !termids[closest_id["anchor"]] and
          @log.add("Style", xref,
                   "only terms clauses can cross-reference terms clause " \
                   "(#{xref['target']})")
        !termids[xref["target"]] && termids[closest_id["anchor"]] and
          @log.add("Style", xref,
                   "non-terms clauses cannot cross-reference terms clause " \
                   "(#{xref['target']})")
      end

      # require that all assets of a particular type be cross-referenced
      # within the document
      def xrefs_mandate_validate(xmldoc)
        xrefs_mandate_validate1(xmldoc, "//annex", "Annex")
        xrefs_mandate_validate1(xmldoc, "//table", "Table")
        xrefs_mandate_validate1(xmldoc, "//figure", "Figure")
        xrefs_mandate_validate1(xmldoc, "//formula", "Formula")
      end

      def xrefs_mandate_validate1(xmldoc, xpath, name)
        exc = %w(table note example figure).map { |x| "//#{x}#{xpath}" }
          .join(" | ")
        (xmldoc.xpath(xpath) - xmldoc.xpath(exc)).each do |x|
          x["unnumbered"] == "true" and next
          @doc_xrefs[x["anchor"]] or
            @log.add("Style", x, "#{name} #{x['anchor']} has not been " \
                                 "cross-referenced within document",
                     severity: xpath == "//formula" ? 2 : 1)
        end
      end

      # ISO/IEC DIR 2, 16.5.6
      def termdef_style(xmldoc)
        xmldoc.xpath("//term").each do |t|
          para = t.at("./definition/verbal-definition") || return
          term = t.at("./preferred//name").text
          @lang == "en" and termdef_warn(para.text, /\A(the|a)\b/i, t, term,
                                         "term definition starts with article")
          %(Cyrl Latn).include?(@script) and
            termdef_warn(para.text, /\.\Z/i, t, term,
                         "term definition ends with period")
        end
      end

      def doctype_validate(_xmldoc)
        %w(international-standard technical-specification technical-report
           publicly-available-specification international-workshop-agreement
           guide amendment technical-corrigendum committee-document addendum
           recommendation)
          .include? @doctype or
          @log.add("Document Attributes", nil,
                   "#{@doctype} is not a recognised document type")
      end

      def iteration_validate(xmldoc)
        iteration = xmldoc&.at("//bibdata/status/iteration")&.text or return
        /^\d+/.match(iteration) or
          @log.add("Document Attributes", nil,
                   "#{iteration} is not a recognised iteration")
      end

      def bibdata_validate(doc)
        doctype_validate(doc)
        iteration_validate(doc)
      end

      def content_validate(doc)
        super
        root = doc.root
        title_validate(root)
        isosubgroup_validate(root)
        termdef_style(root)
        iso_xref_validate(root)
        bibdata_validate(root)
        bibitem_validate(root)
        figure_validate(root)
        list_validate(doc)
      end

      def list_validate(doc)
        listcount_validate(doc)
        list_punctuation(doc)
      end

      def iso_xref_validate(doc)
        see_xrefs_validate(doc)
        term_xrefs_validate(doc)
        xrefs_mandate_validate(doc)
        see_erefs_validate(doc)
        locality_erefs_validate(doc)
      end

      def bibitem_validate(xmldoc)
        xmldoc.xpath("//bibitem[date/on = '–']").each do |b|
          b.at("./note[@type = 'Unpublished-Status']") or
            @log.add("Style", b,
                     "Reference does not have an " \
                     "associated footnote indicating unpublished status")
        end
      end

      def schema_file
        case @doctype
        when "amendment", "technical-corrigendum" # @amd
          "isostandard-amd.rng"
        else "isostandard-compile.rng"
        end
      end
    end
  end
end
