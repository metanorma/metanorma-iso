require "nokogiri"
require "mime"
require "asciimath"
require "xml/xslt"
require "uuidtools"
require "base64"
require "mime/types"
require "image_size"
require "asciidoctor/iso/isoxml/utils"
require "pp"

module Asciidoctor
  module ISO
    module ISO2WordHTML
      class << self
        $anchors = {}
        $footnotes = []
        $termdomain = ""
        $filename = ""
        $xslt = XML::XSLT.new()
        $xslt.xsl = File.read(File.join(File.dirname(__FILE__), "mathml2omml.xsl"))

        def convert(filename)
          $filename = filename.gsub(%r{\.[^/.]+$}, "")
          Dir.mkdir("#{$filename}_files") unless File.exists?("#{$filename}_files")
          system "rm -r #{$filename}_files/*"
          doc = File.read(filename)
          docxml = Nokogiri::XML(doc)
          docxml.root.default_namespace = ""
          result = noko do |xml|
            xml.html do |html|
              html_header(html, docxml, $filename)
              body_attr = {lang: "EN-US",
                           link: "blue",
                           vlink: "#954F72",
                           style: "tab-interval:36.0pt",
              }
              xml.body **attr_code(body_attr) do |body|
                body.div **{class: "WordSection1"} do |div1|
                  titlepage docxml, div1
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
          # see http://sebsauvage.net/wiki/doku.php?id=word_document_generation
          result = populate_template(msword_fix(result))
          doc_header_files($filename)
          File.open("#{$filename}.htm", "w") { |f| f.write(result) }
          mime_package result, $filename
        end

        def mime_package1(result,filename)
          # first, parse all images, and change their references in document to inline
          images = []
          Dir.foreach("#{filename}_files") do |item|
            next if item == '.' or item == '..' or item =~ /^\./
            f = File.join "#{filename}_files", item
            matched = /\.(?<suffix>\S+)$/.match item
            case matched[:suffix]
            when "jpeg", "jpg", "gif", "png", "tiff", "tif"
              image = MIME::DiscreteMediaFactory.create(f)
              image.transfer_encoding = "binary"
              #image.transfer_encoding = "base64"
              result.gsub!(Regexp.new(Regexp.escape f), "cid:#{image.id}")
              images << image
            end
          end

          # now build MIME: first HTML proper, then images, then all other files
          mhtml = MIME::Multipart::Related.new
          mhtml.add(MIME::Text.new(result, "html", charset: "utf8-8"))
          #images.each { |image| mhtml.inline(image) }

          Dir.foreach("#{filename}_files") do |item|
            next if item == '.' or item == '..' or item =~ /^\./
            f = File.join "#{filename}_files", item
            matched = /\.(?<suffix>\S+)$/.match item
            case matched[:suffix]
            when "jpeg", "jpg", "gif", "png", "tiff", "tif"
              # nop
            when "xml"
              mhtml.add(MIME::Text.new(File.read(f, :encoding => "UTF-8"), "xml", charset: "UTF-8"))
            when "html", "htm"
              mhtml.add(MIME::Text.new(File.read(f, :encoding => "UTF-8"), "html", charset: "UTF-8"))
            else
              mhtml.add(MIME::Text.new(File.read(f, :encoding => "UTF-8"), "", charset: "UTF-8"))
            end
          end
          File.open("#{filename}.doc", "w") do |f|
            f.write mhtml
          end
        end

        def mime_package(result,filename)
          boundary = "----=_NextPart_#{UUIDTools::UUID.random_create.to_s.gsub(/-/, '.')[0..17]}"
          mhtml = <<~"EOF"
  MIME-Version: 1.0
  Content-Type: multipart/related; boundary="#{boundary}"

  --#{boundary}
  Content-Location: file:///C:/Doc/#{filename}.htm
  Content-Type: text/html; charset="utf-8"

          #{result}

          EOF

          Dir.foreach("#{filename}_files") do |item|
            next if item == '.' or item == '..' or /^\./.match item
            f = File.join "#{filename}_files", item
            # matched = /\.(?<suffix>\S+)$/.match item
            types = MIME::Types.type_for(item)
            type = types ? types.first : %Q{text/plain; charset="utf-8"}
            type = %Q{#{type}; charset="utf-8"} if /^text/.match type and types

            mhtml += <<~"EOF"
    --#{boundary}
    Content-Location: file:///C:/Doc/#{filename}_files/#{item}
    Content-Transfer-Encoding: base64
    Content-Type: #{type}

            #{Base64.strict_encode64(File.read("#{filename}_files/#{item}")).gsub(/(.{76})/, "\\1\n")}

            EOF
          end
          mhtml += "--#{boundary}--"

          File.open("#{filename}.doc", "w") do |f|
            f.write mhtml
          end

        end

        def section_break(body) 
          body.br **{clear: "all", 
                     style: "page-break-before:always;mso-break-type:section-break"}
        end

        def titlepage(docxml, div)
          titlepage = File.read(File.join(File.dirname(__FILE__), 
                                          "iso_titlepage.html"), 
                                          :encoding => "UTF-8")
          div.parent.add_child titlepage
        end

        def populate_template(docxml)
          docxml.
            gsub(/DOCYEAR/, $iso_docyear).
            gsub(/DOCNUMBER/, $iso_docnumber).
            gsub(/TCNUM/, $iso_tc).
            gsub(/SCNUM/, $iso_sc).
            gsub(/WGNUM/, $iso_wg).
            gsub(/DOCTITLE/, $iso_doctitle).
            gsub(/DOCSUBTITLE/, $iso_docsubtitle).
            gsub(/SECRETARIAT/, $iso_secretariat).
            gsub(/\[TERMREF\]\s*/, "[SOURCE: ").
            gsub(/\s*\[\/TERMREF\]\s*/, "]").
            gsub(/\s*\[ISOSECTION\]/, ", ").
            gsub(/\s*\[MODIFICATION\]/, ", modified — ").
            gsub(%r{WD/CD/DIS/FDIS}, $iso_stageabbr)
        end

        def doc_header_files(filename)
          header = File.read(File.join(File.dirname(__FILE__), "header.html"), 
                             :encoding => "UTF-8").
                             gsub(/FILENAME/, filename).
                             gsub(/DOCYEAR/, $iso_docyear).
                             gsub(/DOCNUMBER/, $iso_docnumber)
          File.open(File.join("#{filename}_files", "header.html"), "w") do |f| 
            f.write(header) 
          end

          File.open(File.join("#{filename}_files", "filelist.xml"), "w") do |f|
            # TODO images will go here
            f.write(<<~"XML")
<xml xmlns:o="urn:schemas-microsoft-com:office:office">
 <o:MainFile HRef="../#{filename}.htm"/>
            XML
            Dir.foreach("#{filename}_files") do |item|
              next if item == '.' or item == '..'
              f.write %Q{  <o:File HRef="#{item}"/>\n}
            end
            f.write("</xml>\n")
          end
        end

        def html_header(html, docxml, filename)
          parent = html.parent
          parent.add_namespace_definition("o", 
                                          "urn:schemas-microsoft-com:office:office")
          parent.add_namespace_definition("w", "urn:schemas-microsoft-com:office:word")
          parent.add_namespace_definition("m", 
                                          "http://schemas.microsoft.com/office/2004/12/omml")
          parent.add_namespace_definition(nil, "http://www.w3.org/TR/REC-html40")
          anchor_names docxml
          define_head html, filename
        end

        def msword_fix(result)
          # brain damage in MSWord parser
          result.gsub(%r{<span style="mso-special-character:footnote"/>}, 
                      %q{<span style="mso-special-character:footnote"></span>} ).
          gsub(%r{<link rel="File-List"}, "<link rel=File-List").
          gsub(%r{<meta http-equiv="Content-Type"}, "<meta http-equiv=Content-Type")
        end

        def footnotes(div)
          div.div **{style: "mso-element:footnote-list"} do |div1|
            $footnotes.each do |fn|
              div1.parent << fn
            end
          end
        end

        def define_head(html, filename)
          html.head do |head|
            head.title { |t| t << filename }
            head.parent.add_child <<~XML
<xml>
<w:WordDocument>
<w:View>Print</w:View>
<w:Zoom>100</w:Zoom>
<w:DoNotOptimizeForBrowser/>
</w:WordDocument>
</xml>
            XML
            head.meta **{"http-equiv": "Content-Type", 
                         content: "text/html; charset=utf-8"}
            head.link **{rel: "File-List", href: "#{filename}_files/filelist.xml"}
            head.style do |style|
              style.comment File.read(File.join(File.dirname(__FILE__), 
                                                "wordstyle.css")).
                                               gsub("FILENAME", filename)
            end
          end
        end

        def ns(xpath)
          xpath.gsub(%r{/([a-zA-z])}, "/xmlns:\\1")
        end

        def sequential_asset_names(clause)
          clause.xpath(ns(".//table")).each_with_index do |t, i|
            $anchors[t["anchor"]] = { label: "Table #{i + 1}", xref: "Table #{i + 1}" }
          end
          i = 0
          j = 0
          clause.xpath(ns(".//figure")).each do |t|
            if t.parent.name == "figure"
              j += 1
              $anchors[t["anchor"]] = { label: "Figure #{i}-#{j}", 
                                        xref: "Figure #{i}-#{j}" }
            else
              j = 0
              i += 1
              $anchors[t["anchor"]] = { label: "Figure #{i}", 
                                        xref: "Figure #{i}" }
            end
          end
          clause.xpath(ns(".//formula")).each_with_index do |t, i|
            $anchors[t["anchor"]] = { label: "#{i + 1}", xref: "Formula #{i + 1}" }
          end
        end

        def hierarchical_asset_names(clause, num)
          clause.xpath(ns(".//table")).each_with_index do |t, i|
            $anchors[t["anchor"]] = { label: "Table #{num}.#{i + 1}", 
                                      xref: "Table #{num}.#{i + 1}" }
          end
          i = 0
          j = 0
          clause.xpath(ns(".//figure")).each do |t|
            if t.parent.name == "figure"
              j += 1
              $anchors[t["anchor"]] = { label: "Figure #{num}.#{i}-#{j}",
                                        xref: "Figure #{num}.#{i}-#{j}" }
            else
              j = 0
              i += 1
              $anchors[t["anchor"]] = { label: "Figure #{num}.#{i}",
                                        xref: "Figure #{num}.#{i}" }
            end
          end
          clause.xpath(ns(".//formula")).each_with_index do |t, i|
            $anchors[t["anchor"]] = { label: "#{num}.#{i + 1}", 
                                      xref: "Formula #{num}.#{i + 1}" }
          end
        end

        def introduction_names(clause)
          clause.xpath(ns("./clause")).each_with_index do |c, i|
            section_names(c, "0.#{i + 1}")
          end
        end

        def section_names(clause, num, level)
          $anchors[clause["anchor"]] = { label: num, xref: "Clause #{num}", 
                                         level: level }
          clause.xpath(ns("./clause | ./termdef")).each_with_index do |c, i|
            section_names1(c, "#{num}.#{i + 1}", level + 1)
          end
        end

        def section_names1(clause, num, level)
          $anchors[clause["anchor"]] = { label: num, xref: "Clause #{num}", 
                                         level: level }
          clause.xpath(ns("./clause | ./termdef")).each_with_index do |c, i|
            section_names1(c, "#{num}.#{i + 1}", level + 1)
          end
        end

        def annex_names(clause, num)
          obligation = clause["subtype"] == "normative" ? 
            "(Normative)" : "(Informative)"
          $anchors[clause["anchor"]] = { label: "Annex #{num} #{obligation}", 
                                         xref: "Annex #{num}" , level: 1 }
          clause.xpath(ns("./clause")).each_with_index do |c, i|
            annex_names1(c, "#{num}.#{i + 1}", 2 )
          end
          hierarchical_asset_names(clause, num)
        end

        def annex_names1(clause, num, level )
          $anchors[clause["anchor"]] = { label: num, xref: num, level: level }
          clause.xpath(ns(".//clause")).each_with_index do |c, i|
            annex_names1(c, "#{num}.#{i + 1}", level + 1 )
          end
        end

        def iso_ref_names(ref)
          isocode = ref.at(ns("./isocode"))
          isodate = ref.at(ns("./isodate"))
          reference = "ISO #{isocode.text}"
          reference += ": #{isodate.text}" if isodate
          $anchors[ref["anchor"]] = { xref: reference }
        end

        def ref_names(ref)
          $anchors[ref["anchor"]] = { xref: ref.text }
        end

        # extract names for all anchors, xref and label
        def anchor_names(docxml)
          # section numbering
          introduction_names(docxml.at(ns("//introduction")))
          section_names(docxml.at(ns("//scope")), "1", 1)
          section_names(docxml.at(ns("//norm_ref")), "2", 1)
          section_names(docxml.at(ns("//terms_defs")), "3", 1)
          symbols_abbrevs = docxml.at(ns("//symbols_abbrevs"))
          sect_num = 4
          if symbols_abbrevs
            section_names(symbols_abbrevs, "#{sect_num}", 1)
            sect_num += 1
          end
          docxml.xpath(ns("//middle/clause")).each_with_index do |c, i|
            section_names(c, "#{i + sect_num}", 1)
          end
          sequential_asset_names(docxml.xpath(ns("//middle")))
          docxml.xpath(ns("//annex")).each_with_index do |c, i|
            annex_names(c, "#{(65 + i).chr}")
          end
          docxml.xpath(ns("//iso_ref_title")).each do |ref|
            iso_ref_names(ref)
          end
          docxml.xpath(ns("//ref")).each do |ref|
            ref_names(ref)
          end
        end

        def info(isoxml, out)
          intropage = File.read(File.join(File.dirname(__FILE__), "iso_intro.html"), 
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
          title_attr = {class: "zzSTDTitle",
                        style: "margin-top:0cm;margin-right:0cm;margin-bottom:18.0pt;margin-left:0cm"}
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
          out.a **{style: "mso-footnote-id:ftn#{fn}", 
                   href: "#_ftn#{fn}", name: "_ftnref#{fn}", title: ""} do |a|
            a.span **{class: "MsoFootnoteReference"} do |span|
              span.span **{style: "mso-special-character:footnote"}
            end
          end
          $footnotes << noko do |xml|
            xml.div **{style: "mso-element:footnote", id: "ftn#{fn}"} do |div|
              div.p **{class: "MsoFootnoteText"} do |p|
                p.a **{style: "mso-footnote-id:ftn#{fn}", 
                       href: "#_ftn#{fn}", name: "_ftnref#{fn}", title: ""} do |a|
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
              # when "name" then out.title { |e| e << node.text }
            when "stem"
              $xslt.xml = AsciiMath.parse(node.text).to_mathml.
                gsub(/<math>/, "<math xmlns='http://www.w3.org/1998/Math/MathML'>")
              ooml = $xslt.serve().gsub(/<\?[^>]+>\s*/, "").
                gsub(/ xmlns:[^=]+="[^"]+"/, "")
              out.span **{class: "stem"} do |span|
                span.parent.add_child ooml
              end
            when "clause" 
              out.div **attr_code("id": node["anchor"]) do |s|
                node.children.each do |c1| 
                  if c1.name == "name"
                    s.send "h#{$anchors[node["anchor"]][:level]}" do |header|
                      header << "#{$anchors[node["anchor"]][:label]}. #{c1.text}"
                    end
                  else
                    parse(c1, s)
                  end
                end
              end
            when "xref" 
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
            when "eref" 
              linktext = node.text
              linktext = node["target"] if linktext.empty?
              out.a **{"href": node["target"]} { |l| l << linktext }
            when "ul" then out.ul do |ul| 
              node.children.each { |n| parse(n, ul) }
            end
            when "ol" 
              attrs = {numeration: node["type"] }
              out.ol **attr_code(attrs) do |ol| 
                node.children.each { |n| parse(n, ol) }
              end
            when "li" then out.li **{class: "MsoNormal"} do |li| 
              node.children.each { |n| parse(n, li) }
            end
            when "dl"
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
            when "fn" 
              footnote_parse(node, out)
            when "p" 
              out.p **{class: "MsoNormal"} do |p| 
                unless $termdomain.empty?
                  p << "&lt;#{$termdomain}&gt; "
                  $termdomain = ""
                end
                $block = true
                node.children.each { |n| parse(n, p) }
                $block = false
              end
            when "tr" then tr_parse(node, out)
            when "note"
              out.div **attr_code("id": node["anchor"], 
                                  class: "MsoNormalIndent" ) do |t|
                node.children.each { |n| parse(n, t) }
              end
            when "warning"
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
            when "formula"
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
            when "table" then table_parse(node, out)
            when "figure" 
              name = node.at(ns("./name"))
              out.div **attr_code(id: node["anchor"]) do |div|
                if node["src"]
                  image_parse(node["src"], div, nil)
                end
                node.children.each do |n| 
                  parse(n, div) unless n.name == "name"
                end
                if name
                  div.p **{class: "MsoNormal",
                           align: "center",
                           style: "margin-bottom:6.0pt;text-align:center;page-break-before:avoid",
                  } do |p|
                    p.b do |b|
                      b << "#{$anchors[node["anchor"]][:label]}&nbsp;&mdash; "
                      b << name.text
                    end
                  end
                end
              end
            when "termdef"
              out.p **{class: "TermNum", id: node["anchor"]} do |p|
                p << $anchors[node["anchor"]][:label]
              end
              $termdomain = ""
              $termnotenumber = 0
              node.children.each { |n| parse(n, out) }
            when "term"
              out.p **{class: "Terms"} { |p| p << node.text }
            when "admitted_term"
              out.p **{class: "AltTerms"} { |p| p << node.text }
            when "termsymbol"
              out.p **{class: "AltTerms"} do |p| 
                node.children.each { |n| parse(n, out) }
              end
            when "deprecated_term"
              out.p **{class: "AltTerms"} do |p| 
                p << "DEPRECATED: "
                p << node.text 
              end
            when "termdomain"
              $termdomain = node.text
            when "termdefinition"
              node.children.each { |n| parse(n, out) }
            when "termref"
              out.p **{class: "MsoNormal"} do |p|
                p << "[TERMREF]"
                node.children.each { |n| parse(n, p) }
                p << "[/TERMREF]"
              end
            when "isosection"
              out << "[ISOSECTION]"
              out << node.text
            when "modification"
              out << "[MODIFICATION]"
              node.children.each { |n| parse(n, out) }
            when "termnote"
              out.p **{class: "Note"} do |p|
                $termnotenumber += 1
                p << "Note #{$termnotenumber} to entry: "
                node.children.each { |n| parse(n, p) }
              end
            when "termexample"
              out.p **{class: "Note"} do |p|
                p << "EXAMPLE:"
                p.span **attr_code(style: "mso-tab-count:1") do |span|
                  span << "&#xA0; "
                end
                node.children.each { |n| parse(n, p) }
              end
            else
              if $block
                out.b **{role: "strong"} { |e| e << node.to_xml.gsub(/</,"&lt;").gsub(/>/,"&gt;") }
              else
                out.para do |p|
                  p.b **{role: "strong"} { |e| e << node.to_xml.gsub(/</,"&lt;").gsub(/>/,"&gt;") }
                end
              end
            end
          end
        end

        def image_parse(url, out, caption)
          orig_filename = url #.gsub(%r{/}, File::ALT_SEPARATOR || File::PATH_SEPARATOR)
          matched = /\.(?<suffix>\S+)$/.match orig_filename
          new_filename = "#{UUIDTools::UUID.random_create.to_s[0..17]}.#{matched[:suffix]}"
          new_full_filename = File.join("#{$filename}_files", new_filename)
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
            out.p **{class: "MsoNormal",
                     align: "center",
                     style: "margin-bottom:6.0pt;text-align:center;page-break-before:avoid",
            } do |p|
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
            out.p **{class: "MsoNormal",
                     align: "center", 
                     style: "margin-bottom:6.0pt;text-align:center;page-break-before:always;page-break-after:avoid",
            } do |p| 
              p.b do |b|
                b << "#{$anchors[node["anchor"]][:label]}&nbsp;&mdash; #{name.text}" 
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
              if td.name == "td"
                r.td **attr_code(attrs) do |entry|
                  td.children.each { |n| parse(n, entry) }
                end
              else
                r.th **attr_code(attrs) do |entry|
                  td.children.each { |n| parse(n, entry) }
                end
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
                  s.h1 { |t| t << "#{$anchors[c["anchor"]][:label]}. #{c1.text}" }
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
                  s.h1 { |t| t << "#{$anchors[c["anchor"]][:label]}. #{c1.text}" }
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
              parse(e, div) unless ["iso_ref_title" , "reference"].include? e.name
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
              parse(e, div) unless ["iso_ref_title" , "reference"].include? e.name
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

        def author(isoxml, out)
          tc = isoxml.at(ns("//technical_committee"))
          tc_num = isoxml.at(ns("//technical_committee/@number"))
          sc = isoxml.at(ns("//subcommittee"))
          sc_num = isoxml.at(ns("//subcommittee/@number"))
          wg = isoxml.at(ns("//workgroup"))
          wg_num = isoxml.at(ns("//workgroup/@number"))
          secretariat = isoxml.at(ns("//secretariat"))
          ret = tc.text
          ret = "ISO TC #{tc_num.text}: #{ret}" if tc_num
          ret += " SC #{sc_num.text}:" if sc_num
          ret += " #{sc.text}" if sc
          ret += " WG #{wg_num.text}:" if wg_num
          ret += " #{wg.text}" if wg
          $iso_tc = "XXXX"
          $iso_sc = "XXXX"
          $iso_wg = "XXXX"
          $iso_secretariat = "XXXX"
          $iso_tc = tc_num.text if tc_num
          $iso_sc = sc_num.text if sc_num
          $iso_wg = wg_num.text if wg_num
          $iso_secretariat = secretariat.text if secretariat
          # out.p ret
        end

        def id(isoxml, out)
          docnumber = isoxml.at(ns("//documentnumber"))
          partnumber = isoxml.at(ns("//documentnumber/@partnumber"))
          documentstatus = isoxml.at(ns("//documentstatus/stage"))
          ret = "ISO #{docnumber.text}"
          ret += "-#{partnumber.text}" if partnumber
          $iso_docnumber = docnumber.text
          $iso_docnumber += "-#{partnumber.text}" if partnumber
          $iso_stage = documentstatus.text if documentstatus
          $iso_stageabbr = 
            Asciidoctor::ISO::ISOXML::Utils::stage_abbreviation($iso_stage)
          if $iso_stage.to_i < 60
            $iso_docnumber = $iso_stageabbr + " " + $iso_docnumber
          end
        end

        def version(isoxml, out)
          e =  isoxml.at(ns("//edition"))
          # out.p "Edition: #{e.text}" if e
          e =  isoxml.at(ns("//revdate"))
          # out.p "Revised: #{e.text}" if e
          yr =  isoxml.at(ns("//copyright_year"))
          $iso_docyear = yr.text
          # out.p "© ISO #{yr.text}" if yr
        end

        def title(isoxml, out)
          out.p **{class: "MsoTitle"} do |t|
            intro = isoxml.at(ns("//title/en/title_intro"))
            main = isoxml.at(ns("//title/en/title_main"))
            part = isoxml.at(ns("//title/en/title_part"))
            partnumber = isoxml.at(ns("//id/documentnumber/@partnumber"))
            main = main.text
            main = "#{intro.text} — #{main}" if intro
            main = "#{main} — Part #{partnumber}: #{part.text}" if part
            $iso_doctitle = main
          end
        end

        def subtitle(isoxml, out)
          out.p **{class: "MsoSubtitle"} do |t|
            intro = isoxml.at(ns("//title/fr/title_intro"))
            main = isoxml.at(ns("//title/fr/title_main"))
            part = isoxml.at(ns("//title/fr/title_part"))
            partnumber = isoxml.at(ns("//id/documentnumber/@partnumber"))
            main = main.text
            main = "#{intro.text} — #{main}" if intro
            main = "#{main} — Part #{partnumber}: #{part.text}" if part
            $iso_docsubtitle = main
          end
        end


        # block for processing XML document fragments as XHTML,
        # to allow for HTMLentities
        def noko(&block)
          # fragment = ::Nokogiri::XML::DocumentFragment.parse("")
          # fragment.doc.create_internal_subset("xml", nil, "xhtml.dtd")
          head = <<~HERE
        <!DOCTYPE html SYSTEM
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
        <html xmlns="http://www.w3.org/1999/xhtml">
        <head> <title></title> <meta charset="UTF-8" /> </head>
        <body> </body> </html>
          HERE
          doc = ::Nokogiri::XML.parse(head)
          fragment = doc.fragment("")
          ::Nokogiri::XML::Builder.with fragment, &block
          fragment.to_xml(encoding: "US-ASCII").lines.map do |l|
            l.gsub(/\s*\n/, "")
          end
        end

        def attr_code(attributes)
          attributes = attributes.reject { |_, val| val.nil? }.map
          attributes.map do |k, v|
            # [k, (v.is_a? String) ? HTMLEntities.new.decode(v) : v]
            [k, v]
          end.to_h
        end

      end
    end
  end
end
