require_relative "cleanup_biblio"

module Metanorma
  module Iso
    class Converter < Standoc::Converter
      PRE_NORMREF_FOOTNOTES = "//preface//fn | " \
                              "//clause[@type = 'scope']//fn".freeze

      NORMREF_FOOTNOTES =
        "//references[@normative = 'true']//fn | " \
        "//clause[.//references[@normative = 'true']]//fn".freeze

      POST_NORMREF_FOOTNOTES =
        "//sections//clause[not(@type = 'scope')]//fn | " \
        "//annex//fn | //references[@normative = 'false']//fn | " \
        "//clause[.//references[@normative = 'false']]//fn".freeze

      NORM_REF =
        "//bibliography/references[@normative = 'true'][not(@hidden)] | " \
        "//bibliography/clause[.//references[@normative = 'true']] | "\
        "//sections//references[@normative = 'true'][not(@hidden)]"
          .freeze

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

      def ol_cleanup(doc)
        doc.xpath("//ol[@type]").each do |x|
          x.delete("type")
        end
        doc.xpath("//ol[@explicit-type]").each do |x|
          x["type"] = x["explicit-type"]
          x.delete("explicit-type")
          @log.add("Style", x,
                   "Style override set for ordered list")
        end
      end

      TERM_CLAUSE =
        "//sections/terms | " \
        "//sections//terms[not(preceding-sibling::clause)] | " \
        "//sections//clause[@type = 'terms'][not(descendant::definitions)] | " \
        "//sections/clause[not(@type = 'terms')][not(descendant::definitions)]//terms".freeze

      def sections_cleanup(xml)
        super
        @amd or return
        xml.xpath("//*[@inline-header]").each { |h| h.delete("inline-header") }
      end

      def boilerplate_file(_xmldoc)
        file = case @lang
               when "fr" then "boilerplate-fr.adoc"
               when "ru" then "boilerplate-ru.adoc"
               else "boilerplate.adoc"
               end
        File.join(@libdir, file)
      end

      def footnote_cleanup(xmldoc)
        unpub_footnotes(xmldoc)
        super
      end

      def unpub_footnotes(xmldoc)
        xmldoc.xpath("//bibitem/note[@type = 'Unpublished-Status']").each do |n|
          e = xmldoc.at("//eref[@bibitemid = '#{n.parent['anchor']}']") or next
          fn = n.children.to_xml
          n.elements&.first&.name == "p" or fn = "<p>#{fn}</p>"
          e.next = "<fn>#{fn}</fn>"
          add_id(e.next)
        end
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

      def terms_terms_cleanup(xmldoc)
        @vocab and return
        super
      end

      def bibdata_cleanup(xmldoc)
        super
        approval_groups_rename(xmldoc)
        editorial_groups_agency(xmldoc)
        editorial_group_types(xmldoc)
      end

      def approval_groups_rename(xmldoc)
        %w(technical-committee subcommittee workgroup).each do |v|
          xmldoc.xpath("//bibdata//approval-#{v}").each { |a| a.name = v }
        end
      end

      def editorial_groups_agency(xmldoc)
        pubs = extract_publishers(xmldoc)
        xmldoc.xpath("//bibdata/ext/editorialgroup").each do |e|
          pubs.reverse_each do |p|
            if e.children.empty? then e << "<agency>#{p}</agency>"
            else e.children.first.previous = "<agency>#{p}</agency>"
            end
          end
        end
      end

      def extract_publishers(xmldoc)
        xmldoc.xpath("//bibdata/contributor[role/@type = 'publisher']/" \
                     "organization").each_with_object([]) do |p, m|
          x = p.at("./abbreviation") || p.at("./name") or next
          m << x.children.to_xml
        end
      end

      DEFAULT_EDGROUP_TYPE = { "technical-committee": "TC",
                               subcommittee: "SC", workgroup: "WG" }.freeze

      def editorial_group_types(xmldoc)
        %w(technical-committee subcommittee workgroup).each do |v|
          xmldoc.xpath("//bibdata//#{v} | //bibdata//approval-#{v}").each do |g|
            g["type"] ||= DEFAULT_EDGROUP_TYPE[v.to_sym]
          end
          v1 = v.sub("-", " ").capitalize
          xmldoc.xpath("//bibdata//subdivision[@type = '#{v1}']").each do |g|
            g["subtype"] ||= DEFAULT_EDGROUP_TYPE[v.to_sym]
          end
        end
      end

      def termdef_boilerplate_insert_locationx(xmldoc)
        f = xmldoc.at(self.class::TERM_CLAUSE)
        root = xmldoc.at("//sections/terms | //sections/clause[.//terms]")
        !f || !root and return f || root
        f.at("./preceding-sibling::clause") and return root
        f
      end
    end
  end
end
