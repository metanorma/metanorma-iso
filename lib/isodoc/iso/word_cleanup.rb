module IsoDoc
  module Iso
    class WordConvert < IsoDoc::WordConvert
      def figure_cleanup(xml)
        super
        xml.xpath("//div[@class = 'figure']//table[@class = 'dl']").each do |t|
          t["class"] = "figdl"
          d = t.add_previous_sibling("<div class='figdl' " \
                                     "style='page-break-after:avoid;'/>")
          t.parent = d.first
        end
      end

      def word_annex_cleanup1(docxml, lvl)
        docxml.xpath("//h#{lvl}[ancestor::*[@class = 'Section3']]").each do |h2|
          h2.name = "p"
          h2["class"] = "a#{lvl}"
        end
      end

      def word_annex_cleanup(docxml)
        (2..6).each { |i| word_annex_cleanup1(docxml, i) }
      end

      def word_annex_cleanup_h1(docxml)
        docxml.xpath("//h1[@class = 'Annex']").each do |h|
          h.name = "p"
          h["class"] = "ANNEX"
        end
        %w(BiblioTitle ForewordTitle IntroTitle).each do |s|
          docxml.xpath("//*[@class = '#{s}']").each do |h|
            h.name = "p"
          end
        end
      end

      def style_cleanup(docxml)
        word_annex_cleanup_h1(docxml)
        figure_style(docxml)
        new_styles(docxml)
        index_cleanup(docxml)
      end

      def index_cleanup(docxml)
        docxml.xpath("//div[@class = 'index']").each do |i|
          i.xpath(".//p | .//li").each do |p|
            p["style"] ||= ""
            p["style"] += "margin-bottom:0px;"
          end
        end
      end

      def figure_style(docxml)
        docxml.xpath("//div[@class = 'figure']").each do |f|
          f["style"] ||= ""
          f["style"] += "text-align:center;"
        end
      end

      def quote_style(docxml)
        docxml.xpath("//div[@class = 'Quote' or @class = 'Note' or " \
                     "@class = 'Example' or @class = 'Admonition']").each do |d|
                       quote_style1(d)
                     end
      end

      def quote_style1(div)
        div.xpath(".//li").each do |p|
          p["style"] ||= ""
          p["style"] += "font-size:#{default_fonts({})[:smallerfontsize]};"
        end
      end

      def sourcecode_style
        "Code"
      end

      STYLESMAP = {
        example: "Example",
        note: "Note",
        Sourcecode: "Code",
        tabletitle: "Tabletitle",
        Biblio: "MsoNormal",
        figure: "MsoNormal",
        SourceTitle: "FigureTitle",
      }.freeze

      def new_styles(docxml)
        self.class::STYLESMAP.each do |k, v|
          docxml.xpath("//*[@class = '#{k}']").each { |s| s["class"] = v }
        end
        docxml.xpath("//div[@class = 'Section3']//p[@class = 'Tabletitle']")
          .each { |t| t["class"] = "AnnexTableTitle" }
        docxml.xpath("//*[@class = 'zzHelp']/p[not(@class)]").each do |p|
          p["class"] = "zzHelp"
        end
        quote_style(docxml)
      end

      def authority_hdr_cleanup(docxml)
        { "boilerplate-license": "zzWarningHdr",
          "boilerplate-copyright": "zzCopyrightHdr" }.each do |k, v|
            docxml.xpath("//div[@class = '#{k}']").each do |d|
              d.xpath(".//h1").each do |p|
                p.name = "p"
                p["class"] = v
              end
            end
          end
      end

      def authority_cleanup(docxml)
        authority_license_cleanup(docxml)
        authority_copyright_cleanup(docxml)
        coverpage_note_cleanup(docxml)
      end

      def authority_copyright_cleanup(docxml)
        auth = docxml.at("//div[@class = 'boilerplate-copyright']") or return
        authority_copyright_style(auth)
        authority_copyright_populate(docxml, auth)
      end

      def authority_copyright_style(auth)
        auth.xpath(".//p[not(@class)]").each { |p| p["class"] = "zzCopyright" }
        auth.xpath(".//p[@class = 'Tablebody']").each do |p|
          p["class"] = "zzCopyright"
        end
        auth.xpath(".//p[@id = 'boilerplate-message']").each do |p|
          p["class"] = "zzCopyright1"
        end
        auth.xpath(".//p[@id = 'boilerplate-address']").each do |p|
          p["class"] = "zzAddress"
        end
        auth.xpath(".//p[@id = 'boilerplate-place']").each do |p|
          p["class"] = "zzCopyright1"
        end
        auth.children = "<div class='zzCopyrightContainer'>#{to_xml(auth.children)}</div>"
      end

      def authority_copyright_populate(doc, auth)
        i = doc.at("//div[@id = 'boilerplate-copyright-default-destination']")
        j = doc.at("//div[@id = 'boilerplate-copyright-append-destination']")
        default = auth.at(".//div[@id = 'boilerplate-copyright-default']")
        default and i and i.children = default.remove
        j and j.children = auth.remove
      end

      def authority_license_cleanup(docxml)
        dest = docxml.at("//div[@id = 'boilerplate-license-destination']") or
          return
        auth = docxml.at("//div[@class = 'boilerplate-license']") or return
        auth.xpath(".//p[not(@class)]").each { |p| p["class"] = "zzWarning" }
        dest.children = auth.remove
      end

      def word_cleanup(docxml)
        authority_hdr_cleanup(docxml)
        super
        remove_toc_variants(docxml)
        definition_spacing(docxml)
        style_cleanup(docxml)
        docxml
      end

      # The HTML TOC has already consumed these variants. Word ignores
      # display:none on the paragraphs and prints them above annex titles.
      def remove_toc_variants(docxml)
        docxml.xpath("//p[@class = 'variant-title-toc']").each(&:remove)
      end

      DESIGNATION_XPATH =
        "preceding-sibling::*[1][self::p[@class = 'Terms' or " \
        "@class = 'AltTerms' or @class = 'AdmittedTerm' or " \
        "@class = 'DeprecatedTerms']]".freeze

      # Matches the 12pt gap the DOCX term renderer puts before a definition.
      def definition_spacing(docxml)
        docxml.xpath(".//p[@class = 'Definition'][#{DESIGNATION_XPATH}]")
          .each { |para| add_definition_gap(para) }
        docxml.xpath(".//div[@class = 'ol_wrap' or @class = 'ul_wrap']" \
                     "[#{DESIGNATION_XPATH}]").each do |wrap|
          item = wrap.at(".//li") or next
          add_definition_gap(item.at("./p") || item)
        end
      end

      def add_definition_gap(node)
        style = node["style"].to_s.strip
        return if style.include?("margin-top:12.0pt")

        style += ";" unless style.empty? || style.end_with?(";")
        node["style"] = "#{style}margin-top:12.0pt;"
      end

      def word_fn_cleanup(docxml)
        super
        footnote_anchor_space(docxml)
      end

      # Html2Doc inserts the footnote anchor directly before this content.
      def footnote_anchor_space(docxml)
        targets = docxml.xpath("//*[@id]")
          .each_with_object({}) { |node, ids| ids[node["id"]] ||= node }
        docxml.xpath("//a[@class = 'FootnoteRef']/@href").each do |href|
          id = href.value.delete_prefix("#")
          note = !id.empty? && targets[id] or next
          para = note.at(".//p") || note
          next if footnote_starts_with_space?(para)

          para.prepend_child(Nokogiri::XML::Text.new(" ", docxml))
        end
      end

      def footnote_starts_with_space?(para)
        first = para.at_xpath("(.//text() | .//img)[1]")
        first&.text? && first.text.match?(/\A[[:space:]]/)
      end

      # supply missing annex title
      def make_WordToC(docxml, level)
        toc = ""
        s = docxml.at("//div[@class = 'TOC']") and toc = to_xml(s.children)
        xpath = (1..level).each.map { |i| "//h#{i}" }.join (" | ")
        annexid = 0
        docxml.xpath(xpath).each do |h|
          x = ""
          if %w(ANNEX Annex).include?(h["class"])
            x, annexid = annex_toc(annexid)
          end
          toc += word_toc_entry(h.name[1].to_i, x + header_strip(h))
        end
        toc.sub(/(<p class="MsoToc1">)/,
                %{\\1#{word_toc_preface(level)}}) + WORD_TOC_SUFFIX1
      end

      # do not use in IEC, BSI, where Word does not use list to generate
      # "Annex A"
      def annex_toc(annexid)
        @iso_publisher or return ""
        annexid += 1
        x = "#{@i18n.annex} #{('@'.ord + annexid).chr} "
        [x, annexid]
      end
    end
  end
end
