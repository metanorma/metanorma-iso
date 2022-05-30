require "date"
require "nokogiri"
require "htmlentities"
require "json"
require "pathname"

module Metanorma
  module ISO
    class Converter < Standoc::Converter
      PRE_NORMREF_FOOTNOTES = "//preface//fn | "\
                              "//clause[@type = 'scope']//fn".freeze

      NORMREF_FOOTNOTES =
        "//references[@normative = 'true']//fn".freeze

      POST_NORMREF_FOOTNOTES =
        "//sections//clause[not(@type = 'scope')]//fn | "\
        "//annex//fn | "\
        "//references[@normative = 'false']//fn".freeze

      def other_footnote_renumber(xmldoc)
        seen = {}
        i = 0
        [PRE_NORMREF_FOOTNOTES, NORMREF_FOOTNOTES,
         POST_NORMREF_FOOTNOTES].each do |xpath|
          xmldoc.xpath(xpath).each do |fn|
            i, seen = other_footnote_renumber1(fn, i, seen)
          end
        end
      end

      def id_prefix(prefix, id)
        # we're just inheriting the prefixes from parent doc
        return id.text if @amd

        prefix.join("/") + (id.text.match?(%{^/}) ? "" : " ") + id.text
      end

      def get_id_prefix(xmldoc)
        xmldoc.xpath("//bibdata/contributor[role/@type = 'publisher']"\
                     "/organization").each_with_object([]) do |x, prefix|
          x1 = x.at("abbreviation")&.text || x.at("name")&.text
          # (x1 == "ISO" and prefix.unshift("ISO")) or prefix << x1
          prefix << x1
        end
      end

      # ISO as a prefix goes first
      def docidentifier_cleanup(xmldoc)
        prefix = get_id_prefix(xmldoc)
        id = xmldoc.at("//bibdata/docidentifier[@type = 'ISO']") or return
        id.content = id_prefix(prefix, id)
        id = xmldoc.at("//bibdata/ext/structuredidentifier/project-number") and
          id.content = id_prefix(prefix, id)
        %w(iso-with-lang iso-reference iso-undated).each do |t|
          id = xmldoc.at("//bibdata/docidentifier[@type = '#{t}']") and
            id.content = id_prefix(prefix, id)
        end
      end

      def format_ref(ref, type)
        ref = ref.sub(/ \(All Parts\)/i, "")
        super
      end

      TERM_CLAUSE =
        "//sections//terms | "\
        "//sections//clause[descendant::terms][not(descendant::definitions)]"
          .freeze

      PUBLISHER = "./contributor[role/@type = 'publisher']/organization".freeze

      OTHERIDS = "@type = 'DOI' or @type = 'metanorma' or @type = 'ISSN' or "\
                 "@type = 'ISBN'".freeze

      def pub_class(bib)
        return 1 if bib.at("#{PUBLISHER}[abbreviation = 'ISO']")
        return 1 if bib.at("#{PUBLISHER}[name = 'International Organization "\
                           "for Standardization']")
        return 2 if bib.at("#{PUBLISHER}[abbreviation = 'IEC']")
        return 2 if bib.at("#{PUBLISHER}[name = 'International "\
                           "Electrotechnical Commission']")
        return 3 if bib.at("./docidentifier[@type][not(#{OTHERIDS})]")

        4
      end

      def sort_biblio(bib)
        bib.sort do |a, b|
          sort_biblio_key(a) <=> sort_biblio_key(b)
        end
      end

      # TODO sort by authors
      # sort by: doc class (ISO, IEC, other standard (not DOI &c), other
      # then standard class (docid class other than DOI &c)
      # then docnumber if present, numeric sort
      #      else alphanumeric metanorma id (abbreviation)
      # then doc part number if present, numeric sort
      # then doc id (not DOI &c)
      # then title
      def sort_biblio_key(bib)
        pubclass = pub_class(bib)
        num = bib&.at("./docnumber")&.text
        id = bib&.at("./docidentifier[not(#{OTHERIDS})]")
        metaid = bib&.at("./docidentifier[@type = 'metanorma']")&.text
        abbrid = metaid unless /^\[\d+\]$/.match?(metaid)
        /\d-(?<partid>\d+)/ =~ id&.text
        type = id["type"] if id
        title = bib&.at("./title[@type = 'main']")&.text ||
          bib&.at("./title")&.text || bib&.at("./formattedref")&.text
        "#{pubclass} :: #{type} :: "\
          "#{num.nil? ? abbrid : sprintf('%09d', num.to_i)} :: "\
          "#{sprintf('%09d', partid.to_i)} :: #{id&.text} :: #{title}"
      end

      def sections_cleanup(xml)
        super
        return unless @amd

        xml.xpath("//*[@inline-header]").each do |h|
          h.delete("inline-header")
        end
      end

      def boilerplate_file(_xmldoc)
        file = case @lang
               when "fr" then "boilerplate-fr.xml"
               when "ru" then "boilerplate-ru.xml"
               else "boilerplate.xml"
               end
        File.join(@libdir, file)
      end

      def footnote_cleanup(xmldoc)
        unpub_footnotes(xmldoc)
        super
      end

      def unpub_footnotes(xmldoc)
        xmldoc.xpath("//bibitem/note[@type = 'Unpublished-Status']").each do |n|
          e = xmldoc.at("//eref[@bibitemid = '#{n.parent['id']}']") or next
          fn = n.children.to_xml
          n.elements&.first&.name == "p" or fn = "<p>#{fn}</p>"
          e.next = "<fn>#{fn}</fn>"
        end
      end

      def bibitem_cleanup(xmldoc)
        super
        unpublished_note(xmldoc)
        withdrawn_note(xmldoc)
      end

      def unpublished_note(xmldoc)
        xmldoc.xpath("//bibitem[not(./ancestor::bibitem)]"\
                     "[not(note[@type = 'Unpublished-Status'])]").each do |b|
          next if pub_class(b) > 2
          next unless (s = b.at("./status/stage")) && (s.text.to_i < 60)

          id = b.at("docidentifier").text
          insert_unpub_note(b, @i18n.under_preparation.sub(/%/, id))
        end
      end

      def withdrawn_note(xmldoc)
        xmldoc.xpath("//bibitem[not(note[@type = 'Unpublished-Status'])]")
          .each do |b|
            next unless withdrawn_ref?(b)

            if id = replacement_standard(b)
              insert_unpub_note(b, @i18n.cancelled_and_replaced.sub(/%/, id))
            else
              insert_unpub_note(b, @i18n.withdrawn)
            end
          end
      end

      def withdrawn_ref?(biblio)
        return false if pub_class(biblio) > 2

        (s = biblio.at("./status/stage")) && (s.text.to_i == 95) &&
          (t = biblio.at("./status/substage")) && (t.text.to_i == 99)
      end

      def replacement_standard(biblio)
        r = biblio.at("./relation[@type = 'updates']/bibitem") or return nil
        id = r.at("./formattedref | ./docidentifier[@primary = 'true'] | "\
                  "./docidentifier | ./formattedref") or return nil
        id.text
      end

      def insert_unpub_note(biblio, msg)
        biblio.at("./language | ./script | ./abstract | ./status")
          .previous = %(<note type="Unpublished-Status"><p>#{msg}</p></note>)
      end

      def termdef_boilerplate_insert(xmldoc, isodoc, once = false)
        once = true
        super
      end

      def term_defs_boilerplate_cont(src, term, isodoc)
        @vocab and src.empty? and return
        super
      end

      def section_names_terms_cleanup(xml)
        @vocab and return
        super
      end

      def bibdata_cleanup(xmldoc)
        super
        approval_groups_rename(xmldoc)
        editorial_groups_agency(xmldoc)
      end

      def approval_groups_rename(xmldoc)
        %w(technical-committee subcommittee workgroup).each do |v|
          xmldoc.xpath("//bibdata//approval-#{v}").each do |a|
            a.name = v
          end
        end
      end

      def editorial_groups_agency(xmldoc)
        pubs = xmldoc.xpath("//bibdata/contributor[role/@type = 'publisher']/"\
                            "organization").each_with_object([]) do |p, m|
          x = p.at("./abbreviation") || p.at("./name") or next
          m << x.text
        end
        xmldoc.xpath("//bibdata/ext/editorialgroup").each do |e|
          pubs.reverse.each do |p|
            e.children.first.previous = "<agency>#{p}</agency>"
          end
        end
      end
    end
  end
end
