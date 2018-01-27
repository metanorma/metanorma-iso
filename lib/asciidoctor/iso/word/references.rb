module Asciidoctor
  module ISO
    module Word
      module References
        def iso_ref_code(b)
          isocode = b.at(ns("./isocode"))
          isodate = b.at(ns("./isodate"))
          reference = "ISO #{isocode.text}"
          reference += ": #{isodate.text}" if isodate
          reference
        end

        def iso_ref_entry(list, b, ordinal, biblio)
          attrs = { id: b["id"],
                    class: biblio ? "Biblio" : "MsoNormal" }
          list.p **attr_code(attrs) do |ref|
            date_footnote = b.at(ns("./date_footnote"))
            if biblio
              ref << "[#{ordinal}]"
              insert_tab(ref, 1)
            end
            ref << iso_ref_code(b)
            footnote_parse(date_footnote, ref) if date_footnote
            ref << ", " if biblio
            ref.i { |i| i << " #{b.at(ns('./isotitle')).text}" }
          end
        end

        def ref_entry_code(r, ordinal, t)
          if /^\d+$/.match?(t)
            r << "[#{t}]"
            insert_tab(r, 1)
          else
            r << "[#{ordinal}]"
            insert_tab(r, 1)
            r << t
          end
        end

        def ref_entry(list, b, ordinal, bibliography)
          ref = b.at(ns("./ref"))
          para = b.at(ns("./p"))
          list.p **attr_code("id": ref["id"], class: "Biblio") do |r|
            ref_entry_code(r, ordinal, ref.text.gsub(/[\[\]]/, ""))
            para.children.each { |n| parse(n, r) }
          end
        end

        def biblio_list(f, div, bibliography)
          isobiblio = f.xpath(ns("./iso_ref_title"))
          refbiblio = f.xpath(ns("./reference"))
          isobiblio.each_with_index do |b, i|
            iso_ref_entry(div, b, i + 1, bibliography)
          end
          refbiblio.each_with_index do |b, i|
            ref_entry(div, b, i + 1 + isobiblio.size, bibliography)
          end
        end

        @@norm_with_refs_pref = <<~BOILERPLATE
          The following documents are referred to in the text in such a way
          that some or all of their content constitutes requirements of this
          document. For dated references, only the edition cited applies.
          For undated references, the latest edition of the referenced
          document (including any amendments) applies.
        BOILERPLATE

        @@norm_empty_pref =
          "There are no normative references in this document."

        def norm_ref_preface(f, div)
          refs = f.elements.select do |e|
            ["iso_ref_title", "reference"].include? e.name
          end
          pref = refs.empty? ? @@norm_empty_pref : @@norm_with_refs_pref
          div.p pref, **{ class: "MsoNormal" }
        end

        def norm_ref(isoxml, out)
          q = "//sections/references[title = 'Normative References']"
          f = isoxml.at(ns(q)) or return
          out.div do |div|
            clause_name("2.", "Normative References", div)
            norm_ref_preface(f, div)
            biblio_list(f, div, false)
          end
        end

        def bibliography(isoxml, out)
          q = "//sections/references[title = 'Bibliography']"
          f = isoxml.at(ns(q)) or return
          page_break(out)
          out.div do |div|
            div.h1 "Bibliography", **{ class: "Section3" }
            f.elements.reject do |e|
              ["iso_ref_title", "reference", "title"].include? e.name
            end.each { |e| parse(e, div) }
            biblio_list(f, div, true)
          end
        end
      end
    end
  end
end
