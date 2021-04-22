module Asciidoctor
  module ISO
    class Converter < Standoc::Converter
      # DRG directives 3.7; but anticipated by standoc
      def subfigure_validate(xmldoc)
        xmldoc.xpath("//figure//figure").each do |f|
          { footnote: "fn", note: "note", key: "dl" }.each do |k, v|
            f.xpath(".//#{v}").each do |n|
              @log.add("Style", n, "#{k} is not permitted in a subfigure")
            end
          end
        end
      end

      def image_name_prefix(xmldoc)
        std = xmldoc&.at("//bibdata/ext/structuredidentifier/project-number") or
          return
        num = xmldoc&.at("//bibdata/docnumber")&.text or return
        ed = xmldoc&.at("//bibdata/edition")&.text || "1"
        prefix = num
        std["part"] and prefix += "-#{std['part']}"
        prefix += "_ed#{ed}"
        amd = std["amendment"] and prefix += "amd#{amd}"
        prefix
      end

      def image_name_suffix(xmldoc)
        case xmldoc&.at("//bibdata/language")&.text
        when "fr" then "_f"
        when "de" then "_d"
        when "ru" then "_r"
        when "es" then "_s"
        when "ar" then "_a"
        when "en" then "_e"
        else
          "_e"
        end
      end

      def disjunct_error(img, cond1, cond2, msg1, msg2)
        cond1 && !cond2 and
          @log.add("Style", img, "image name #{img['src']} #{msg1}")
        !cond1 && cond2 and
          @log.add("Style", img, "image name #{img['src']} #{msg2}")
      end

      def image_name_parse(img, prefix)
        m = %r[(SL)?#{prefix}fig(?<tab>Tab)?(?<annex>[A-Z])?(Text)?(?<num>\d+)
            (?<subfig>[a-z])?(?<key>_key\d+)?(?<lang>_[a-z])?$]x
          .match(File.basename(img["src"], ".*"))
        m.nil? and
          @log.add("Style", img,
                   "image name #{img['src']} does not match DRG requirements")
        m
      end

      def image_name_validate1(i, prefix)
        m = image_name_parse(i, prefix) or return
        warn i["src"]
        disjunct_error(i, i.at("./ancestor::table"), !m[:tab].nil?,
                       "is under a table but is not so labelled",
                       "is labelled as under a table but is not")
        disjunct_error(i, i.at("./ancestor::annex"), !m[:annex].nil?,
                       "is under an annex but is not so labelled",
                       "is labelled as under an annex but is not")
        disjunct_error(i, i.xpath("./ancestor::figure").size > 1, !m[:subfig].nil?,
                       "does not have a subfigure letter but is a subfigure",
                       "has a subfigure letter but is not a subfigure")
        lang = image_name_suffix(i.document.root)
        (m[:lang] || "_e") == lang or
          @log.add("Style", i,
                   "image name #{i['src']} expected to have suffix #{lang}")
      end

      # DRG directives 3.2
      def image_name_validate(xmldoc)
        prefix = image_name_prefix(xmldoc) or return
        xmldoc.xpath("//image").each do |i|
          next if i["src"].start_with?("data:")

          if /^ISO_\d+_/.match?(File.basename(i["src"]))
          elsif /^(SL)?#{prefix}fig/.match?(File.basename(i["src"]))
            image_name_validate1(i, prefix)
          else
            @log.add("Style", i,
                     "image name #{i['src']} does not match DRG requirements: expect #{prefix}fig")
          end
        end
      end

      def figure_validate(xmldoc)
        image_name_validate(xmldoc)
        subfigure_validate(xmldoc)
      end
    end
  end
end
