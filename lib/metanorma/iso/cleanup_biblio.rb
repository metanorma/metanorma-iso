module Metanorma
  module ISO
    class Converter < Standoc::Converter
      def id_prefix(prefix, id)
        # we're just inheriting the prefixes from parent doc
        @amd and return id.text
        prefix.join("/") + (id.text.match?(%{^/}) ? "" : " ") + id.text
      end

      def get_id_prefix(xmldoc)
        xmldoc.xpath("//bibdata/contributor[role/@type = 'publisher']" \
                     "/organization").each_with_object([]) do |x, prefix|
          x1 = x.at("abbreviation")&.text || x.at("name")&.text
          prefix << x1
        end
      end

      # ISO as a prefix goes first
      def docidentifier_cleanup(xmldoc)
        prefix = get_id_prefix(xmldoc)
        id = xmldoc.at("//bibdata/ext/structuredidentifier/project-number") and
          id.content = id_prefix(prefix, id)
      end

      def format_ref(ref, type)
        ref = ref.sub(/ \(All Parts\)/i, "")
        super
      end

      PUBLISHER = "./contributor[role/@type = 'publisher']/organization".freeze

      def pub_class(bib)
        return 1 if bib.at("#{PUBLISHER}[abbreviation = 'ISO']")
        return 1 if bib.at("#{PUBLISHER}[name = 'International Organization " \
                           "for Standardization']")
        return 2 if bib.at("#{PUBLISHER}[abbreviation = 'IEC']")
        return 2 if bib.at("#{PUBLISHER}[name = 'International " \
                           "Electrotechnical Commission']")
        return 3 if bib.at("./docidentifier[@type]" \
                           "[not(#{skip_docid} or @type = 'metanorma')]") ||
          bib.at("./docidentifier[not(@type)]")

        4
      end

      def sort_biblio(bib)
        bib.sort { |a, b| sort_biblio_key(a) <=> sort_biblio_key(b) }
      end

      # sort by: doc class (ISO, IEC, other standard (not DOI &c), other
      # then standard class (docid class other than DOI &c)
      # then docnumber if present, numeric sort
      #      else alphanumeric metanorma id (abbreviation)
      # then doc part number if present, numeric sort
      # then doc id (not DOI &c)
      # then title
      def sort_biblio_key(bib)
        pubclass = pub_class(bib)
        num = bib.at("./docnumber")&.text
        id = bib.at("./docidentifier[@primary]") ||
          bib.at("./docidentifier[not(#{skip_docid} or @type = 'metanorma')]")
        metaid = bib.at("./docidentifier[@type = 'metanorma']")&.text
        abbrid = metaid unless /^\[\d+\]$/.match?(metaid)
        /\d-(?<partid>\d+)/ =~ id&.text
        type = id["type"] if id
        title = bib.at("./title[@type = 'main']")&.text ||
          bib.at("./title")&.text || bib&.at("./formattedref")&.text
        "#{pubclass} :: #{type} :: " \
          "#{num.nil? ? abbrid : sprintf('%09d', num.to_i)} :: " \
          "#{sprintf('%09d', partid.to_i)} :: #{id&.text} :: #{title}"
      end

      def bibitem_cleanup(xmldoc)
        super
        unpublished_note(xmldoc)
        withdrawn_note(xmldoc)
      end

      def unpublished_note(xmldoc)
        xmldoc.xpath("//bibitem[not(./ancestor::bibitem)]" \
                     "[not(note[@type = 'Unpublished-Status'])]").each do |b|
          pub_class(b) > 2 and next
          ((s = b.at("./status/stage")) && s.text.match?(/\d/) &&
           (s.text.to_i < 60)) or next
          insert_unpub_note(b, @i18n.under_preparation
            .sub("%", b.at("docidentifier").text))
        end
      end

      def withdrawn_note(xmldoc)
        xmldoc.xpath("//bibitem[not(note[@type = 'Unpublished-Status'])]")
          .each do |b|
            withdrawn_ref?(b) or next
            if id = replacement_standard(b)
              insert_unpub_note(b, @i18n.cancelled_and_replaced.sub("%", id))
            else insert_unpub_note(b, @i18n.withdrawn)
            end
          end
      end

      def withdrawn_ref?(biblio)
        pub_class(biblio) > 2 and return false
        (s = biblio.at("./status/stage")) && (s.text.to_i == 95) &&
          (t = biblio.at("./status/substage")) && (t.text.to_i == 99)
      end

      def replacement_standard(biblio)
        r = biblio.at("./relation[@type = 'updates']/bibitem") or return nil
        id = r.at("./formattedref | ./docidentifier[@primary = 'true'] | " \
                  "./docidentifier | ./formattedref") or return nil
        id.text
      end

      def insert_unpub_note(biblio, msg)
        biblio.at("./language | ./script | ./abstract | ./status")
          .previous = %(<note type="Unpublished-Status"><p>#{msg}</p></note>)
      end
    end
  end
end
