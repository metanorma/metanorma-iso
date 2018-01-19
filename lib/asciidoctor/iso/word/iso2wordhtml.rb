require "nokogiri"
require "mime"
require "asciimath"
require "xml/xslt"
require "uuidtools"
require "base64"
require "mime/types"
require "image_size"
require "asciidoctor/iso/isoxml/utils"
require "asciidoctor/iso/word/postprocessing"
require "asciidoctor/iso/word/utils"
require "asciidoctor/iso/word/metadata"
require "pp"

module Asciidoctor
  module ISO
    module Word
      module ISO2WordHTML
        class << self

          include ::Asciidoctor::ISO::Word::Postprocessing
          include ::Asciidoctor::ISO::Word::Utils
          include ::Asciidoctor::ISO::Word::Metadata

          $anchors = {}
          $footnotes = []
          $termdomain = ""
          $filename = ""
          $dir = ""
          $xslt = XML::XSLT.new()
          $xslt.xsl = File.read(File.join(File.dirname(__FILE__),
                                          "mathml2omml.xsl"))

          def convert(filename)
            $filename = filename.gsub(%r{\.[^/.]+$}, "")
            $dir = "#{$filename}_files"
            Dir.mkdir($dir) unless File.exists?($dir)
            system "rm -r #{$dir}/*"

            docxml = Nokogiri::XML(File.read(filename))
            docxml.root.default_namespace = ""
            result = noko do |xml|
              xml.html do |html|
                Postprocessing::html_header(html, docxml, $filename)
                body_attr = {lang: "EN-US", link: "blue", vlink: "#954F72"}
                xml.body **body_attr do |body|
                  body.div **{class: "WordSection1"} do |div1|
                    Postprocessing::titlepage docxml, div1
                  end
                  section_break(body)
                  body.div **{class: "WordSection2"} do |div2|
                    info docxml, div2
                  end
                  section_break(body)
                  body.div **{class: "WordSection3"} do |div3|
                    middle docxml, div3
                    footnotes div3
                  end
                end
              end
            end.join("\n")
            Postprocessing::postprocess(result, $filename)
          end

          def section_break(body)
            body.br **{clear: "all", class: "section"}
          end

          def footnotes(div)
            div.div **{style: "mso-element:footnote-list"} do |div1|
              $footnotes.each do |fn|
                div1.parent << fn
              end
            end
          end

          def info(isoxml, out)
            intropage = File.read(File.join(File.dirname(__FILE__),
                                            "iso_intro.html"),
                                            :encoding => "UTF-8")
            out.parent.add_child intropage
            title isoxml, out
            subtitle isoxml, out
            id isoxml, out
            author isoxml, out
            version isoxml, out
            foreword isoxml, out
            introduction isoxml, out
          end

          def middle(isoxml, out)
            title_attr = {class: "zzSTDTitle1"}
            out.p **attr_code(title_attr) do |p|
              p << $iso_doctitle
            end
            scope isoxml, out
            norm_ref isoxml, out
            terms_defs isoxml, out
            symbols_abbrevs isoxml, out
            clause isoxml, out
            annex isoxml, out
            bibliography isoxml, out
          end

          def footnote_parse(node, out)
            fn = $footnotes.length + 1
            attrs = {style: "mso-footnote-id:ftn#{fn}",
                     href: "#_ftn#{fn}",
                     name: "_ftnref#{fn}",
                     title: ""}
            out.a **attrs do |a|
              a.span **{class: "MsoFootnoteReference"} do |span|
                span.span **{style: "mso-special-character:footnote"}
              end
            end
            $footnotes << noko do |xml|
              xml.div **{style: "mso-element:footnote",
                         id: "ftn#{fn}"} do |div|
                div.p **{class: "MsoFootnoteText"} do |p|
                  attrs = {style: "mso-footnote-id:ftn#{fn}",
                           href: "#_ftn#{fn}",
                           name: "_ftnref#{fn}", 
                           title: ""}
                  p.a **attrs do |a|
                    a.span **{class: "MsoFootnoteReference"} do |span|
                      span.span **{style: "mso-special-character:footnote"}
                    end
                    node.children.each { |n| parse(n, p) }
                  end
                end
              end
            end.join("\n")
          end

          def parse(node, out)
            if node.text?
              out << node.text
            else
              case node.name
              when "em" then out.i { |e| e << node.text }
              when "strong" then out.b { |e| e << node.text }
              when "sup" then out.sup { |e| e << node.text }
              when "sub" then out.sub { |e| e << node.text }
              when "tt" then out.tt { |e| e << node.text }
              when "br" then out.br
              when "stem" then stem_parse(node, out)
              when "clause" then clause_parse(node, out)
              when "xref" then xref_parse(node, out)
              when "eref" then eref_parse(node, out)
              when "ul" then ul_parse(node, out)
              when "ol" then ol_parse(node, out)
              when "li" then li_parse(node, out)
              when "dl" then dl_parse(node, out)
              when "fn" then footnote_parse(node, out)
              when "p" then para_parse(node, out)
              when "tr" then tr_parse(node, out)
              when "note" then note_parse(node, out)
              when "warning" then warning_parse(node, out)
              when "formula" then formula_parse(node, out)
              when "table" then table_parse(node, out)
              when "figure" then figure_parse(node, out)
              when "termdef" then termdef_parse(node, out)
              when "term" then term_parse(node, out)
              when "admitted_term" then admitted_term_parse(node, out)
              when "termsymbol" then termsymbol_parse(node, out)
              when "deprecated_term" then deprecated_term_parse(node, out)
              when "termdomain" then $termdomain = node.text
              when "termdefinition"
                node.children.each { |n| parse(n, out) }
              when "termref" then termref_parse(node, out)
              when "isosection"
                out << "[ISOSECTION] #{node.text}"
              when "modification" then modification_parse(node, out)
              when "termnote" then termnote_parse(node, out)
              when "termexample" then termexample_parse(node, out)
              else
                error_parse(node, out)
              end
            end
          end

          def modification_parse(node, out)
            out << "[MODIFICATION]"
            node.children.each { |n| parse(n, out) }
          end

          def deprecated_term_parse(node, out)
            out.p **{class: "AltTerms"} do |p|
              p << "DEPRECATED: #{node.text}"
            end
          end

          def termsymbol_parse(node, out)
            out.p **{class: "AltTerms"} do |p|
              node.children.each { |n| parse(n, out) }
            end
          end

          def admitted_term_parse(node, out)
            out.p **{class: "AltTerms"} { |p| p << node.text }
          end

          def term_parse(node, out)
            out.p **{class: "Terms"} { |p| p << node.text }
          end

          def error_parse(node, out)
            if $block
              out.b **{role: "strong"} do |e|
                e << node.to_xml.gsub(/</,"&lt;").gsub(/>/,"&gt;")
              end
            else
              out.para do |p|
                p.b **{role: "strong"} do |e|
                  e << node.to_xml.gsub(/</,"&lt;").gsub(/>/,"&gt;")
                end
              end
            end
          end

          def eref_parse(node, out)
            linktext = node.text
            linktext = node["target"] if linktext.empty?
            out.a **{"href": node["target"]} { |l| l << linktext }
          end

          def li_parse(node, out)
            out.li **{class: "MsoNormal"} do |li|
              node.children.each { |n| parse(n, li) }
            end
          end

          def ul_parse(node, out)
            out.ul do |ul|
              node.children.each { |n| parse(n, ul) }
            end
          end

          def ol_parse(node, out)
            attrs = {numeration: node["type"] }
            out.ol **attr_code(attrs) do |ol|
              node.children.each { |n| parse(n, ol) }
            end
          end

          def note_parse(node, out)
            out.div **attr_code("id": node["anchor"],
                                class: "MsoNormalIndent" ) do |t|
              node.children.each { |n| parse(n, t) }
            end
          end

          def termexample_parse(node, out)
            out.p **{class: "Note"} do |p|
              p << "EXAMPLE:"
              p.span **attr_code(style: "mso-tab-count:1") do |span|
                span << "&#xA0; "
              end
              node.children.each { |n| parse(n, p) }
            end
          end

          def termnote_parse(node, out)
            out.p **{class: "Note"} do |p|
              $termnotenumber += 1
              p << "Note #{$termnotenumber} to entry: "
              node.children.each { |n| parse(n, p) }
            end
          end

          def termref_parse(node, out)
            out.p **{class: "MsoNormal"} do |p|
              p << "[TERMREF]"
              node.children.each { |n| parse(n, p) }
              p << "[/TERMREF]"
            end
          end

          def termdef_parse(node, out)
            out.p **{class: "TermNum", id: node["anchor"]} do |p|
              p << $anchors[node["anchor"]][:label]
            end
            $termdomain = ""
            $termnotenumber = 0
            node.children.each { |n| parse(n, out) }
          end

          def figure_parse(node, out)
            name = node.at(ns("./name"))
            out.div **attr_code(id: node["anchor"]) do |div|
              if node["src"]
                image_parse(node["src"], div, nil)
              end
              node.children.each do |n|
                parse(n, div) unless n.name == "name"
              end
              if name
                div.p **{class: "FigureTitle",
                         align: "center",
                } do |p|
                  p.b do |b|
                    b << "#{$anchors[node["anchor"]][:label]}&nbsp;&mdash; "
                    b << name.text
                  end
                end
              end
            end
          end

          def warning_parse(node, out)
            name = node.at(ns("./name"))
            out.div **{class: "MsoBlockText"} do |t|
              if name
                t.p do |tt|
                  tt.b { |b| b << name.text }
                end
              end
              node.children.each do |n|
                parse(n, t) unless n.name == "name"
              end
            end
          end

          def formula_parse(node, out)
            stem = node.at(ns("./stem"))
            dl = node.at(ns("./dl"))
            out.div **attr_code(id: node["anchor"], class: "formula") do |div|
              parse(stem, out)
              div.span **attr_code(style: "mso-tab-count:1") do |span|
                span << "&#xA0; "
              end
              div << "(#{$anchors[node["anchor"]][:label]})"
            end
            out.p { |p| p << "where" }
            parse(dl, out) if dl
          end

          def para_parse(node, out)
            out.p **{class: "MsoNormal"} do |p|
              unless $termdomain.empty?
                p << "&lt;#{$termdomain}&gt; "
                $termdomain = ""
              end
              $block = true
              node.children.each { |n| parse(n, p) }
              $block = false
            end
          end

          def dl_parse(node, out)
            out.dl do |v|
              node.elements.each_slice(2) do |dt, dd|
                v.dt do |term|
                  dt.children.each { |n| parse(n, term) }
                end
                v.dd do |listitem|
                  dd.children.each { |n| parse(n, listitem) }
                end
              end
            end
          end

          def xref_parse(node, out)
            linkend = node["target"]
            if $anchors.has_key? node["target"]
              linkend = $anchors[node["target"]][:xref]
            end
            linkend = node.text if !node.text.empty?
            if node["format"] == "footnote"
              out.sup do |s|
                s.a **{"href": node["target"]} { |l| l << linkend }
              end
            else
              out.a **{"href": node["target"]} { |l| l << linkend }
            end
          end

          def clause_parse(node, out)
            out.div **attr_code("id": node["anchor"]) do |s|
              node.children.each do |c1|
                if c1.name == "name"
                  s.send "h#{$anchors[node["anchor"]][:level]}" do |h|
                    h << "#{$anchors[node["anchor"]][:label]}. #{c1.text}"
                  end
                else
                  parse(c1, s)
                end
              end
            end
          end

          def stem_parse(node, out)
            $xslt.xml = AsciiMath.parse(node.text).to_mathml.
              gsub(/<math>/,
                   "<math xmlns='http://www.w3.org/1998/Math/MathML'>")
            ooml = $xslt.serve().gsub(/<\?[^>]+>\s*/, "").
              gsub(/ xmlns:[^=]+="[^"]+"/, "")
            out.span **{class: "stem"} do |span|
              span.parent.add_child ooml
            end
          end

          def image_parse(url, out, caption)
            orig_filename = url
            matched = /\.(?<suffix>\S+)$/.match orig_filename
            uuid = UUIDTools::UUID.random_create
            new_filename = "#{uuid.to_s[0..17]}.#{matched[:suffix]}"
            new_full_filename = File.join($dir, new_filename)
            system "cp #{orig_filename} #{new_full_filename}"
            image_size = ImageSize.path(orig_filename).size
            # max width is 400
            if image_size[0] > 400
              image_size[1] = (image_size[1] * 400 / image_size[0]).ceil
              image_size[0] = 400
            end
            # TODO ditto max height
            out.img **attr_code(src: new_full_filename,
                                height: image_size[1],
                                width: image_size[0])
            unless caption.nil?
              out.p **{class: "FigureTitle", align: "center"} do |p|
                p.b do |b|
                  b << "#{caption}"
                end
              end
            end
          end

          def table_parse(node, out)
            table_attr = {id: node["anchor"],
                          class: "MsoISOTable",
                          border: 1,
                          cellspacing: 0,
                          cellpadding: 0,
            }
            name = node.at(ns("./name"))
            if name
              out.p **{class: "TableTitle",
                       align: "center",
              } do |p|
                p.b do |b|
                  b << "#{$anchors[node["anchor"]][:label]}&nbsp;&mdash; "
                  b << name.text
                end
              end
            end
            out.table **attr_code(table_attr) do |t|
              thead = node.at(ns("./thead"))
              tbody = node.at(ns("./tbody"))
              tfoot = node.at(ns("./tfoot"))
              dl = node.at(ns("./dl"))
              note = node.xpath(ns("./note"))
              if thead
                t.thead do |h|
                  thead.children.each { |n| parse(n, h) }
                end
              end
              t.tbody do |h|
                tbody.children.each { |n| parse(n, h) }
              end
              if tfoot
                t.tfoot do |h|
                  tfoot.children.each { |n| parse(n, h) }
                end
              end
              parse(dl, out) if dl
              note.each { |n| parse(n, out) }
            end
          end

          def tr_parse(node, out)
            out.tr do |r|
              node.elements.each do |td|
                attrs = {
                  rowspan: td["rowspan"],
                  colspan: td["colspan"],
                  align: td["align"],
                }
=begin
                if td.name == "td"
                  r.td **attr_code(attrs) do |entry|
                    td.children.each { |n| parse(n, entry) }
                  end
                else
                  r.th **attr_code(attrs) do |entry|
                    td.children.each { |n| parse(n, entry) }
                  end
                end
=end
                r.send td.name, **attr_code(attrs) do |entry|
                    td.children.each { |n| parse(n, entry) }
                  end
              end
            end
          end

          def clause(isoxml, out)
            clauses = isoxml.xpath(ns("//middle/clause"))
            return unless clauses
            clauses.each do |c|
              out.div **attr_code("id": c["anchor"]) do |s|
                c.elements.each do |c1|
                  if c1.name == "name"
                    s.h1 do |t|
                      t << "#{$anchors[c["anchor"]][:label]}. #{c1.text}"
                    end
                  else
                    parse(c1, s)
                  end
                end
              end
            end
          end

          def annex(isoxml, out)
            clauses = isoxml.xpath(ns("//annex"))
            return unless clauses
            clauses.each do |c|
              out.div **attr_code("id": c["anchor"]) do |s|
                c.elements.each do |c1|
                  if c1.name == "name"
                    s.h1 do |t|
                      t << "#{$anchors[c["anchor"]][:label]}. #{c1.text}"
                    end
                  else
                    parse(c1, s)
                  end
                end
              end
            end
          end

          def scope(isoxml, out)
            f = isoxml.at(ns("//scope"))
            return unless f
            out.div do |div|
              div.h1 "1. Scope"
              f.elements.each do |e|
                parse(e, div)
              end
            end
          end

          def iso_ref_entry(list, b)
            list.p **attr_code("id": b["anchor"], class: "MsoNormal") do |ref|
              isocode = b.at(ns("./isocode"))
              isodate = b.at(ns("./isodate"))
              isotitle = b.at(ns("./isotitle"))
              date_footnote = b.at(ns("./date_footnote"))
              reference = "ISO #{isocode.text}"
              reference += ": #{isodate.text}" if isodate
              ref << reference
              if date_footnote
                footnote_parse(date_footnote, ref)
              end
              ref.i { |i| i <<  " #{isotitle.text}" }
            end
          end

          def ref_entry(list, b)
            ref = b.at(ns("./ref"))
            p = b.at(ns("./p"))
            list.p **attr_code("id": ref["anchor"], class: "MsoNormal") do |r|
              r << ref.text
              p.children.each { |n| parse(n, r) }
            end
          end

          def biblio_list(f, s)
            isobiblio = f.xpath(ns("./iso_ref_title"))
            refbiblio = f.xpath(ns("./reference"))
            isobiblio.each do |b|
              iso_ref_entry(s, b)
            end
            refbiblio.each do |b|
              ref_entry(s, b)
            end
          end

          def norm_ref(isoxml, out)
            f = isoxml.at(ns("//norm_ref"))
            return unless f
            out.div do |div|
              div.h1 "2. Normative References"
              f.elements.each do |e|
                unless ["iso_ref_title" , "reference"].include? e.name
                  parse(e, div)
                end
              end
              biblio_list(f, div)
            end
          end

          def bibliography(isoxml, out)
            f = isoxml.at(ns("//bibliography"))
            return unless f
            out.div do |div|
              div.h1 "Bibliography"
              f.elements.each do |e|
                unless ["iso_ref_title" , "reference"].include? e.name
                  parse(e, div)
              end
              end
              biblio_list(f, div)
            end
          end

          def terms_defs(isoxml, out)
            f = isoxml.at(ns("//terms_defs"))
            return unless f
            out.div do |div|
              div.h1 "3. Terms and Definitions"
              f.elements.each do |e|
                parse(e, div)
              end
            end
          end

          def symbols_abbrevs(isoxml, out)
            f = isoxml.at(ns("//symbols_abbrevs"))
            return unless f
            out.div do |div|
              div.h1 "4. Symbols and Abbreviations"
              f.elements.each do |e|
                parse(e, div)
              end
            end
          end

          def introduction(isoxml, out)
            f = isoxml.at(ns("//introduction"))
            return unless f
            title_attr = {class: "IntroTitle",
                          style: "page-break-before:always"}
            out.div do |div|
              div.h1 **attr_code(title_attr) do |p|
                p << "Introduction"
              end
              f.elements.each do |e|
                if e.name == "patent_notice"
                  e.elements.each do |e1|
                    parse(e1, div)
                  end
                else
                  parse(e, div)
                end
              end
            end
          end

          def foreword(isoxml, out)
            f = isoxml.at(ns("//foreword"))
            return unless f
            out.div  do |s|
              s.h1 **{class: "ForewordTitle"} { |h1| h1 << "Foreword" }
=begin
    s.p **{class: "ForewordTitle"} do |p|
      p.a **{name: "_Toc353342667"}
      p.a **{name: "_Toc485815077"} do |a|
        a.span **{style: "mso-bookmark:_Toc353342667"} do |span|
          span.span << "Foreword"
        end
      end
    end
=end
              f.elements.each do |e|
                parse(e, s)
              end
            end
          end
        end
      end
    end
  end
end
