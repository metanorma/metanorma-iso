require "date"
require "nokogiri"
require "htmlentities"
require "json"
require "pathname"
require "open-uri"

module Asciidoctor
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
        xmldoc.xpath(PRE_NORMREF_FOOTNOTES).each do |fn|
          i, seen = other_footnote_renumber1(fn, i, seen)
        end
        xmldoc.xpath(NORMREF_FOOTNOTES).each do |fn|
          i, seen = other_footnote_renumber1(fn, i, seen)
        end
        xmldoc.xpath(POST_NORMREF_FOOTNOTES).each do |fn|
          i, seen = other_footnote_renumber1(fn, i, seen)
        end
      end

      def id_prefix(prefix, id)
        return id.text if @amd # we're just inheriting the prefixes from parent doc
        prefix.join("/") + ( id.text.match(%{^/}) ? "" :  " " ) + id.text
      end

      def get_id_prefix(xmldoc)
        prefix = []
        xmldoc.xpath("//bibdata/contributor[role/@type = 'publisher']"\
                     "/organization").each do |x|
          x1 = x.at("abbreviation")&.text || x.at("name")&.text
          x1 == "ISO" and prefix.unshift("ISO") or prefix << x1
        end
        prefix
      end

      # ISO as a prefix goes first
      def docidentifier_cleanup(xmldoc)
        prefix = get_id_prefix(xmldoc)
        id = xmldoc.at("//bibdata/docidentifier[@type = 'ISO']") or return
        id.content = id_prefix(prefix, id)
        id = xmldoc.at("//bibdata/ext/structuredidentifier/project-number") and
          id.content = id_prefix(prefix, id)
        id = xmldoc.at("//bibdata/docidentifier[@type = 'iso-with-lang']") and
          id.content = id_prefix(prefix, id)
        id = xmldoc.at("//bibdata/docidentifier[@type = 'iso-reference']") and
          id.content = id_prefix(prefix, id)
      end

      def format_ref(ref, type, isopub)
        ref = ref.sub(/ \(All Parts\)/i, "")
        super
      end

      TERM_CLAUSE = "//sections//terms".freeze
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
        abbrid = metaid unless /^\[\d+\]$/.match(metaid)
        /\d-(?<partid>\d+)/ =~ id&.text
        type = id['type'] if id
        title = bib&.at("./title[@type = 'main']")&.text ||
          bib&.at("./title")&.text || bib&.at("./formattedref")&.text
        "#{pubclass} :: #{type} :: "\
          "#{num.nil? ? abbrid : sprintf("%09d", num.to_i)} :: "\
          "#{partid} :: #{id&.text} :: #{title}"
      end

      def sections_cleanup(x)
        super
        return unless @amd
        x.xpath("//*[@inline-header]").each do |h|
          h.delete('inline-header')
        end
      end

      def boilerplate_file(xmldoc)
        file = @lang == "fr" ? "boilerplate-fr.xml" : "boilerplate.xml"
        File.join(@libdir, file)
      end

      def footnote_cleanup(xmldoc)
        unpub_footnotes(xmldoc)
        super
      end

      def unpub_footnotes(xmldoc)
        xmldoc.xpath("//bibitem/note[@type = 'Unpublished-Status']").each do |n|
          id = n.parent["id"]
          e = xmldoc.at("//eref[@bibitemid = '#{id}']") or next
          e.next = n.dup
          e.next.name = "fn"
          e.next.delete("format")
          e.next.delete("type")
        end
      end

      def bibitem_cleanup(xmldoc)
        super
        unpublished_note(xmldoc)
      end

      def unpublished_note(xmldoc)
        xmldoc.xpath("//bibitem[not(note[@type = 'Unpublished-Status'])]").each do |b|
          next if pub_class(b) > 2
          next unless s = b.at("./status/stage") and s.text.to_i < 60
          id = b.at("docidentifier").text
          b.at("./language | ./script | ./abstract | ./status").previous = <<~NOTE
          <note type="Unpublished-Status">
            <p>#{@i18n.under_preparation.sub(/%/, id)}</p></note>
          NOTE
        end
      end

      def biblio_cleanup(xmldoc)
        super
        express_hidden_refs(xmldoc, "express-schema")
      end

      def gather_express_refs(xmldoc, prefix)
        xmldoc.xpath("//eref[@type = '#{prefix}']").each_with_object({}) do |e, m|
          e.delete("type")
          m[e["bibitemid"]] = true
        end.keys
      end

      def insert_express_biblio(xmldoc, refs, prefix)
        ins = xmldoc.at("bibliography") or
          xmldoc.root << "<bibliography/>" and ins = xmldoc.at("bibliography")
        ins = ins.add_child("<references hidden='true' normative='false'/>").first
        refs.each do |x|
          ins << <<~END
            <bibitem id="#{x}" type="internal">
            <docidentifier type="repository">#{x.sub(/^#{prefix}_/, "#{prefix}/")}</docidentifier>
            </bibitem>
          END
        end
      end

      def express_eref_to_xref(e, id)
        loc = e&.at("./location[@type = 'anchor']")&.remove&.text
        target = loc ? "#{id}.#{loc}" : id
        e.name = "xref"
        e.delete("bibitemid")
        if e.document.at("//*[@id = '#{target}']")
          e["target"] = target
        else
          e["target"] = id
          e.children = %(** Missing target #{loc})
        end
      end

      def resolve_local_express_refs(xmldoc, refs, prefix)
        refs.each_with_object([]) do |r, m|
          id = r.sub(/^#{prefix}_/, "")
          if xmldoc.at("//*[@id = '#{id}'][@type = '#{prefix}']")
            xmldoc.xpath("//eref[@bibitemid = '#{r}']").each do |e|
              express_eref_to_xref(e, id)
            end
          else
            m << r
          end
        end
      end

      def express_hidden_refs(xmldoc, prefix)
        refs = gather_express_refs(xmldoc, prefix)
        refs = resolve_local_express_refs(xmldoc, refs, prefix)
        refs.empty? and return
        insert_express_biblio(xmldoc, refs, prefix)
      end
    end
  end
end
