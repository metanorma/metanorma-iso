require "metanorma-standoc"

module Asciidoctor
  module ISO
    class Converter < Standoc::Converter
      def title_intro_validate(root)
        title_intro_en = root.at("//title[@type='title-intro' and @language='en']")
        title_intro_fr = root.at("//title[@type='title-intro' and @language='fr']")
        if title_intro_en.nil? && !title_intro_fr.nil?
          @log.add("Style", title_intro_fr, "No English Title Intro!")
        end
        if !title_intro_en.nil? && title_intro_fr.nil?
          @log.add("Style", title_intro_en, "No French Title Intro!")
        end
      end

      def title_main_validate(root)
        title_main_en = root.at("//title[@type='title-main' and @language='en']")
        title_main_fr = root.at("//title[@type='title-main' and @language='fr']")
        if title_main_en.nil? && !title_main_fr.nil?
          @log.add("Style", title_main_fr, "No English Title!")
        end
        if !title_main_en.nil? && title_main_fr.nil?
          @log.add("Style", title_main_en, "No French Title!")
        end
      end

      def title_part_validate(root)
        title_part_en = root.at("//title[@type='title-part' and @language='en']")
        title_part_fr = root.at("//title[@type='title-part' and @language='fr']")
        (title_part_en.nil? && !title_part_fr.nil?) &&
          @log.add("Style", title_part_fr, "No English Title Part!")
        (!title_part_en.nil? && title_part_fr.nil?) &&
          @log.add("Style", title_part_en, "No French Title Part!")
      end

      # ISO/IEC DIR 2, 11.4
      def title_subpart_validate(root)
        docid = root.at("//bibdata/docidentifier[@type = 'ISO']")
        subpart = /-\d+-\d+/.match docid
        iec = root.at("//bibdata/contributor[role/@type = 'publisher']/"\
                      "organization[abbreviation = 'IEC' or "\
                      "name = 'International Electrotechnical Commission']")
        @log.add("Style", docid, "Subpart defined on non-IEC document!") if subpart && !iec
      end

      # ISO/IEC DIR 2, 11.5.2
      def title_names_type_validate(root)
        doctypes = /International\sStandard | Technical\sSpecification |
        Publicly\sAvailable\sSpecification | Technical\sReport | Guide /xi
        title_main_en = root.at("//title[@type='title-main' and @language='en']")
        if !title_main_en.nil? && doctypes.match(title_main_en.text)
          @log.add("Style", title_main_en, "Main Title may name document type")
        end
        title_intro_en = root.at("//title[@type='title-intro' and @language='en']")
        if !title_intro_en.nil? && doctypes.match(title_intro_en.text)
          @log.add("Style", title_intro_en, "Title Intro may name document type")
        end
      end

      # ISO/IEC DIR 2, 22.2
      def title_first_level_validate(root)
        root.xpath(SECTIONS_XPATH).each do |s|
          title = s&.at("./title")&.text || s.name
          s.xpath("./clause | ./terms | ./references").each do |ss|
            subtitle = ss.at("./title")
            !subtitle.nil? && !subtitle&.text&.empty? ||
              @log.add("Style", ss, "#{title}: each first-level subclause must have a title")
          end
        end
      end

      # ISO/IEC DIR 2, 22.2
      def title_all_siblings(xpath, label)
        notitle = false
        withtitle = false
        xpath.each do |s|
          title_all_siblings(s.xpath("./clause | ./terms | ./references"),
                             s&.at("./title")&.text || s["id"])
          subtitle = s.at("./title")
          notitle = notitle || (!subtitle || subtitle.text.empty?)
          withtitle = withtitle || (subtitle && !subtitle.text.empty?)
        end
        notitle && withtitle &&
          @log.add("Style", nil, "#{label}: all subclauses must have a title, or none")
      end

      def title_validate(root)
        title_intro_validate(root)
        title_main_validate(root)
        title_part_validate(root)
        title_subpart_validate(root)
        title_names_type_validate(root)
        title_first_level_validate(root)
        title_all_siblings(root.xpath(SECTIONS_XPATH), "(top level)")
      end
    end
  end
end
