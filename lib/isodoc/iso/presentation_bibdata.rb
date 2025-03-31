module IsoDoc
  module Iso
    class PresentationXMLConvert < IsoDoc::PresentationXMLConvert
      def bibdata(docxml)
        super
        editorialgroup_identifier(docxml)
      end

      def editorialgroup_identifier(docxml)
        %w(editorialgroup approvalgroup).each do |v|
          docxml.xpath(ns("//bibdata/ext/#{v}")).each do |a|
            editorialgroup_identifier1(a)
          end
        end
      end

      def editorialgroup_identifier1(group)
        agency = group.xpath(ns("./agency"))&.map(&:text)
        ret = %w(technical-committee subcommittee workgroup)
          .each_with_object([]) do |v, m|
          m << editorialgroup_identifier2(group, v)
        end
        group["identifier"] = (agency + ret.compact).join("/")
      end

      def editorialgroup_identifier2(group, level)
        a = group.at(ns("./#{level}")) or return nil
        type = a["type"]
        type&.casecmp("other")&.zero? and type = ""
        "#{type} #{a['number']}".strip
      end

      def bibdata_i18n(bib)
        hash_translate(bib, @i18n.get["doctype_dict"], "./ext/doctype")
        bibdata_i18n_stage(bib, bib.at(ns("./status/stage")),
                           bib.at(ns("./ext/doctype")))
        hash_translate(bib, @i18n.get["substage_dict"],
                       "./status/substage")
        edition_translate(bib)
      end

      def edition_translate(bibdata)
        super
        @lang == "fr" and e = bibdata.at(ns("./edition[@language = 'fr']")) and
          e.children = e.text.sub(/(\d+)(\p{L}+)/, "\\1<sup>\\2</sup>")
        @docscheme == "1951" and edition_replacement(bibdata)
        edition_printing_date(bibdata)
      end

      def edition_printing_date(bibdata)
        @i18n.get["date_printing"] &&
          pd = bibdata.at(ns("//metanorma-extension/presentation-metadata/" \
                             "printing-date[1]")) or return
        x = @i18n.populate("date_printing", { "var1" => pd.text.to_i })
        bibdata.at(ns("./ext")) << "<date-printing>#{x}</date-printing>"
      end

      def edition_replacement(bibdata)
        e = bibdata.at(ns("./edition[not(@language) or @language = '']"))&.text
        if /^\d+$/.match?(e) && e.to_i > 1
          h = { "var1" => e.to_i, "var2" => e.to_i - 1 }
          x = @i18n.populate("edition_replacement", h)
          bibdata.at(ns("./ext")) << "<edn-replacement>#{x}</edn-replacement>"
        end
      end

      def bibdata_i18n_stage(bib, stage, type, lang: @lang, i18n: @i18n)
        stage or return
        i18n.get.dig("stage_dict", stage.text).is_a?(Hash) or
          return hash_translate(bib, i18n.get["stage_dict"],
                                "./status/stage", lang)
        bibdata_i18n_stage1(stage, type, lang, i18n)
      end

      def bibdata_i18n_stage1(stage, type, lang, i18n)
        stagetype = i18n.get.dig("stage_dict", stage.text, type&.text) or return
        h = i18n.get.dig("stage_draft_variants", stagetype) and h.each do |k, v|
          tag_translate(stage, lang, v)
          stage.next["type"] = k
        end
        tag_translate(stage, lang, stagetype)
      end
    end
  end
end
