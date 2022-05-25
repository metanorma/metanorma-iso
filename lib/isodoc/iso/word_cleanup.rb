module IsoDoc
  module Iso
    class WordConvert < IsoDoc::WordConvert
      def figure_cleanup(xml)
        super
        xml.xpath("//div[@class = 'figure']//table[@class = 'dl']").each do |t|
          t["class"] = "figdl"
          d = t.add_previous_sibling("<div class='figdl' "\
                                     "style='page-break-after:avoid;'/>")
          t.parent = d.first
        end
      end

      # force Annex h2 down to be p.h2Annex, so it is not picked up by ToC
      def word_annex_cleanup1(docxml, lvl)
        docxml.xpath("//h#{lvl}[ancestor::*[@class = 'Section3']]").each do |h2|
          h2.name = "p"
          h2["class"] = "h#{lvl}Annex"
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
        style_cleanup1(docxml)
      end

      def style_cleanup1(docxml)
        docxml.xpath("//*[@class = 'example']").each do |p|
          p["class"] = "Example"
        end
        docxml.xpath("//*[@class = 'zzHelp']/p[not(@class)]").each do |p|
          p["class"] = "zzHelp"
        end
      end

      def authority_hdr_cleanup(docxml)
        docxml&.xpath("//div[@class = 'boilerplate-license']")&.each do |d|
          d.xpath(".//h1").each do |p|
            p.name = "p"
            p["class"] = "zzWarningHdr"
          end
        end
        docxml&.xpath("//div[@class = 'boilerplate-copyright']")&.each do |d|
          d.xpath(".//h1").each do |p|
            p.name = "p"
            p["class"] = "zzCopyrightHdr"
          end
        end
      end

      def authority_cleanup(docxml)
        insert = docxml.at("//div[@id = 'boilerplate-license-destination']")
        auth = docxml&.at("//div[@class = 'boilerplate-license']")&.remove
        auth&.xpath(".//p[not(@class)]")&.each { |p| p["class"] = "zzWarning" }
        auth and insert and insert.children = auth
        insert = docxml.at("//div[@id = 'boilerplate-copyright-destination']")
        auth = docxml&.at("//div[@class = 'boilerplate-copyright']")&.remove
        auth&.xpath(".//p[not(@class)]")&.each do |p|
          p["class"] = "zzCopyright"
        end
        auth&.xpath(".//p[@id = 'boilerplate-message']")&.each do |p|
          p["class"] = "zzCopyright1"
        end
        auth&.xpath(".//p[@id = 'boilerplate-address']")&.each do |p|
          p["class"] = "zzAddress"
        end
        auth&.xpath(".//p[@id = 'boilerplate-place']")&.each do |p|
          p["class"] = "zzCopyright1"
        end
        auth and insert and insert.children = auth
        coverpage_note_cleanup(docxml)
      end

      def word_cleanup(docxml)
        authority_hdr_cleanup(docxml)
        super
        style_cleanup(docxml)
        docxml
      end

      # supply missing annex title
      def make_WordToC(docxml, level)
        toc = ""
        xpath = (1..level).each.map { |i| "//h#{i}" }.join (" | ")
        docxml.xpath(xpath).each do |h|
          x = ""
          x = @anchor[h.parent["id"]][:xref] if h["class"] == "ANNEX"
          toc += word_toc_entry(h.name[1].to_i, x + header_strip(h))
        end
        toc.sub(/(<p class="MsoToc1">)/,
                %{\\1#{word_toc_preface(level)}}) + WORD_TOC_SUFFIX1
      end
    end
  end
end
