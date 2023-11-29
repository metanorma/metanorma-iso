module IsoDoc
  module Iso
    class PresentationXMLConvert < IsoDoc::PresentationXMLConvert
      def bibdata(docxml)
        super
        editorialgroup_identifier(docxml)
        warning_for_missing_metadata(docxml)
      end

      def warning_for_missing_metadata(docxml)
        return unless @meta.get[:unpublished]

        ret = warning_for_missing_metadata_create(docxml)
        return if ret.empty?

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
        id = UUIDTools::UUID.random_create
        ret = "<review date='#{Date.today}' reviewer='Metanorma' id='_#{id}'>" \
              "<p><strong>Metadata warnings:<strong></p> #{ret}</review>"
        ins = docxml.at(ns("//sections//title")) or return
        ins.children.first.previous = ret
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

      def bibdata_i18n_stage(bib, stage, type, lang: @lang, i18n: @i18n)
        return unless stage

        i18n.get.dig("stage_dict", stage.text).is_a?(Hash) or
          return hash_translate(bib, i18n.get["stage_dict"],
                                "./status/stage", lang)
        stagetype = i18n.get.dig("stage_dict", stage.text, type&.text) and
          tag_translate(stage, lang, stagetype)
      end
    end
  end
end
