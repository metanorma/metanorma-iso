module IsoDoc
  module Iso
    class PresentationXMLConvert < IsoDoc::PresentationXMLConvert
      def comments(docxml)
        warning_for_missing_metadata(docxml)
        super
      end

      def warning_for_missing_metadata(docxml)
        @meta.get[:unpublished] or return
        ret = warning_for_missing_metadata_create(docxml)
        ret.empty? and return
        warning_for_missing_metadata_post(docxml, ret)
      end

      def warning_for_missing_metadata_create(docxml)
        ret = ""
        docxml.at(ns("//bibdata/ext//secretariat")) or
          ret += "<p>Secretariat is missing.</p>"
        docxml.at(ns("//bibdata/ext//editorialgroup")) or
          ret += "<p>Editorial groups are missing.</p>"
        docxml.at(ns("//bibdata/date[@type = 'published' or @type = 'issued' " \
                     "or @type = 'created']")) ||
          docxml.at(ns("//bibdata/version/revision-date")) or
          ret += "<p>Document date is missing.</p>"
        ret
      end

      def warning_for_missing_metadata_post(docxml, ret)
        from = docxml.at(ns("//sections/*/@id"))&.text or return
        ret = <<~REVIEW
          <annotation date='#{Date.today}' reviewer='Metanorma' #{add_id_text} from='#{from}' to='#{from}'>
          <p><strong>Metadata warnings:</strong></p> #{ret}
          </annotation>
        REVIEW
        unless ins = docxml.at(ns("//annotation-container"))
          docxml.root << "<annotation-container></annotation-container>"
          ins = docxml.at(ns("//annotation-container"))
        end
        ins.add_first_child ret
      end

      # Redo Amendment annex titles as numbered
      def annex(isoxml)
        amd?(isoxml) and @suppressheadingnumbers = @oldsuppressheadingnumbers
        super
        amd?(isoxml) and @suppressheadingnumbers = true
      end

      # Redo Amendment annex subclause titles as numbered
      def clause(docxml)
        super
        # docxml.xpath(ns("//annex//appendix")).each { |f| clause1(f) }
        amd?(docxml) or return
        @suppressheadingnumbers = @oldsuppressheadingnumbers
        docxml.xpath(ns("//annex//clause | //annex//appendix")).each do |f|
          f.xpath(ns("./fmt-title | ./fmt-xref-label")).each(&:remove)
          clause1(f)
        end
        @suppressheadingnumbers = true
      end

      def clause1(node)
        !node.at(ns("./title")) &&
          !%w(sections preface bibliography).include?(node.parent.name) and
          node["inline-header"] = "true"
        super
        clause1_section_prefix(node)
      end

      def clause1_section_prefix(node)
        if node["type"] == "section" &&
            c = node.at(ns("./fmt-title//span[@class = 'fmt-caption-delim']"))
          c.add_first_child(":")
          t = node.at(ns("./fmt-title"))
          # French l10n needs tab to be treated as space
          t.replace @i18n.l10n(to_xml(t).gsub("<tab/>", "<tab> </tab>"))
            .gsub(%r{<tab>[^<]+</tab>}, "<tab/>")
        end
      end

      def toc_title(docxml)
        %w(amendment technical-corrigendum).include?(@doctype) and return
        super
      end

      def middle_title(docxml)
        @meta.get[:doctitlemain].nil? || @meta.get[:doctitlemain].empty? and
          return
        s = docxml.at(ns("//sections")) or return
        ret = "#{middle_title_main}#{middle_title_amd}"
        s.add_first_child ret
      end

      def middle_title_main
        ret = "<span class='boldtitle'>#{@meta.get[:doctitleintro]}"
        @meta.get[:doctitleintro] && @meta.get[:doctitlemain] and
          ret += " &#x2014; "
        ret += @meta.get[:doctitlemain]
        @meta.get[:doctitlemain] &&
          (@meta.get[:doctitlepart] || @meta.get[:doctitlecomplementary]) and
          ret += " &#x2014; "
        ret += "</span>#{middle_title_part}"
        "<p class='zzSTDTitle1'>#{ret}</p>"
      end

      def middle_title_part
        ret = ""
        if a = @meta.get[:doctitlecomplementary]
          ret += "<span class='boldtitle'>#{a}</span>"
        elsif a = @meta.get[:doctitlepart]
          b = @meta.get[:doctitlepartlabel] and
            ret += "<span class='nonboldtitle'>#{b}:</span> "
          ret += "<span class='boldtitle'>#{a}</span>"
        end
        ret
      end

      def middle_title_amd
        ret = ""
        if a = @meta.get[:doctitleamdlabel]
          ret += "<p class='zzSTDTitle2'>#{a}"
          a = @meta.get[:doctitleamd] and ret += ": #{a}"
          ret += "</p>"
        end
        a = @meta.get[:doctitlecorrlabel] and
          ret += "<p class='zzSTDTitle2'>#{a}</p>"
        ret
      end

      def move_norm_ref_to_sections(docxml)
        amd?(docxml) or super
      end

      def enable_indexsect
        true
      end
    end
  end
end
