require "metanorma-standoc"

module Metanorma
  module Iso
    class Converter < Standoc::Converter
      def title_lang_part(doc, part, lang)
        doc.at("//bibdata/title[@type='title-#{part}' and @language='#{lang}']")
      end

      def title_intro_validate(root)
        title_intro_en = title_lang_part(root, "intro", "en")
        title_intro_fr = title_lang_part(root, "intro", "fr")
        if title_intro_en.nil? && !title_intro_fr.nil?
          @log.add("ISO_10", title_intro_fr)
        end
        if !title_intro_en.nil? && title_intro_fr.nil?
          @log.add("ISO_11", title_intro_en)
        end
      end

      def title_main_validate(root)
        title_main_en = title_lang_part(root, "main", "en")
        title_main_fr = title_lang_part(root, "main", "fr")
        if title_main_en.nil? && !title_main_fr.nil?
          @log.add("ISO_12", title_main_fr)
        end
        if !title_main_en.nil? && title_main_fr.nil?
          @log.add("ISO_13", title_main_en)
        end
      end

      def title_part_validate(root)
        title_part_en = title_lang_part(root, "part", "en")
        title_part_fr = title_lang_part(root, "part", "fr")
        title_part_en.nil? && !title_part_fr.nil? &&
          @log.add("ISO_14", title_part_fr)
        !title_part_en.nil? && title_part_fr.nil? &&
          @log.add("ISO_15", title_part_en)
      end

      # ISO/IEC DIR 2, 11.4
      def title_subpart_validate(root)
        docid = root.at("//bibdata/docidentifier[@type = 'ISO']")
        subpart = /-\d+-\d+/.match docid
        iec = root.at("//bibdata/contributor[role/@type = 'publisher']/" \
                      "organization[abbreviation = 'IEC' or " \
                      "name = 'International Electrotechnical Commission']")
        subpart && !iec and
          @log.add("ISO_16", docid)
      end

      # ISO/IEC DIR 2, 11.5.2
      def title_names_type_validate(root)
        @lang == "en" or return
        doctypes = /International\sStandard | Technical\sSpecification |
        Publicly\sAvailable\sSpecification | Technical\sReport | Guide /xi
        title_main_en = title_lang_part(root, "main", "en")
        !title_main_en.nil? && doctypes.match(title_main_en.text) and
          @log.add("ISO_17", title_main_en)
        title_intro_en = title_lang_part(root, "intro", "en")
        !title_intro_en.nil? && doctypes.match(title_intro_en.text) and
          @log.add("ISO_18", title_intro_en)
      end

      # ISO/IEC DIR 2, 22.2
      def title_first_level_validate(root)
        root.xpath(SECTIONS_XPATH).each do |s|
          title = s&.at("./title")&.text || s.name
          s.xpath("./clause | ./terms | ./references").each do |ss|
            subtitle = ss.at("./title")
            (!subtitle.nil? && !subtitle&.text&.empty?) or
              @log.add("ISO_19", ss, params: [title])
          end
        end
      end

      # ISO/IEC DIR 2, 22.2
      def title_all_siblings(xpath, label)
        notitle = false
        withtitle = false
        xpath.each do |s|
          title_all_siblings(s.xpath("./clause | ./terms | ./references"),
                             s&.at("./title")&.text || s["anchor"])
          subtitle = s.at("./title")
          notitle = notitle || (!subtitle || subtitle.text.empty?)
          withtitle = withtitle || (subtitle && !subtitle.text.empty?)
        end
        notitle && withtitle &&
          @log.add("ISO_20", nil, params: [label])
      end

      # https://www.iso.org/ISO-house-style.html#iso-hs-s-text-r-p-full
      def title_no_full_stop_validate(root)
        root.xpath("//preface//title | //sections//title | //annex//title | " \
                   "//references/title | //preface//name | //sections//name | " \
                   "//annex//name").each do |t|
          style_regex(/\A(?<num>.+\.\Z)/i,
                      "No full stop at end of title or caption",
                      t, t.text.strip)
        end
      end

      def title_validate(root)
        title_intro_validate(root)
        title_main_validate(root)
        title_part_validate(root)
        title_subpart_validate(root)
        title_names_type_validate(root)
        title_first_level_validate(root)
        title_all_siblings(root.xpath(SECTIONS_XPATH), "(top level)")
        title_no_full_stop_validate(root)
      end
    end
  end
end
