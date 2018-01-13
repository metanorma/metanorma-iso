require "nokogiri"
require "mime"
require "asciimath"
require "xml/xslt"
require "pp"

$anchors = {}
$footnotes = []

$xslt = XML::XSLT.new()
$xslt.xsl = File.read(File.join(File.dirname(__FILE__), "mathml2omml.xsl"))

def convert(filename)
  doc = File.read(filename)
  docxml = Nokogiri::XML(doc)
  docxml.root.default_namespace = ""
  result = noko do |xml|
    xml.html do |html|
      html_header(html, docxml, filename)
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
  result = populate_template(msword_fix(result))
  doc_header_files(filename)
  File.open("#{filename}.htm", "w") { |f| f.write(result) }
  mime_package result, filename
end

def mime_package(result,filename)
  mhtml = MIME::Multipart::Related.new
  # mhtml.add("#{filename}.htm")
  mhtml.add(MIME::Text.new(result, "html"))
  Dir.foreach("#{filename}.fld") do |item|
    next if item == '.' or item == '..'
    f = File.join "#{filename}.fld", item
    type = /\.(?<suffix>\S+)$/.match item
    case type
    when "jpeg", "jpg", "gif", "png"
      image = MIME::DiscreteMediaFactory.create(f)
      image.transfer_encoding = "binary"
      mhtml.inline(image)
    when "xml"
      mhtml.add(MIME::Text.new(File.read(f, :encoding => "UTF-8")), "xml")
    when "html", "htm"
      mhtml.add(MIME::Text.new(File.read(f, :encoding => "UTF-8")), "html")
    else
      mhtml.add(MIME::Text.new(File.read(f, :encoding => "UTF-8")))
    end
  end
  File.open("#{filename}.doc", "w") do |f|
    f.write mhtml
  end
end

def section_break(body) 
  body.br **{clear: "all", style: "page-break-before:always;mso-break-type:section-break"}
end

def titlepage(docxml, div)
  titlepage = File.read(File.join(File.dirname(__FILE__), "iso_titlepage.html"), 
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
    gsub(/SECRETARIAT/, $iso_secretariat)
end

def doc_header_files(filename)
  Dir.mkdir("#{filename}.fld") unless File.exists?("#{filename}.fld")
  File.open(File.join("#{filename}.fld", "filelist.xml"), "w") do |f|
    # TODO images will go here
    f.write(<<~"XML")
<xml xmlns:o="urn:schemas-microsoft-com:office:office">
 <o:MainFile HRef="../#{filename}.htm"/>
 <o:File HRef="header.html"/>
 <o:File HRef="filelist.xml"/>
</xml>
    XML
  end
  header = File.read(File.join(File.dirname(__FILE__), "header.html"), 
                     :encoding => "UTF-8").
                     gsub(/FILENAME/, filename).
                     gsub(/DOCYEAR/, $iso_docyear).
                     gsub(/DOCNUMBER/, $iso_docnumber)
  File.open(File.join("#{filename}.fld", "header.html"), "w") { |f| f.write(header) }
end

def html_header(html, docxml, filename)
  html.parent.add_namespace_definition("o", "urn:schemas-microsoft-com:office:office")
  html.parent.add_namespace_definition("w", "urn:schemas-microsoft-com:office:word")
  html.parent.add_namespace_definition("m", "http://schemas.microsoft.com/office/2004/12/omml")
  html.parent.add_namespace_definition(nil, "http://www.w3.org/TR/REC-html40")
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
    head.meta **{"http-equiv": "Content-Type", content: "text/html; charset=utf-8"}
    head.link **{rel: "File-List", href: "#{filename}.fld/filelist.xml"}
    head.style do |style|
      style.comment File.read(File.join(File.dirname(__FILE__), "wordstyle.css")).
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
  clause.xpath(ns(".//figure")).each_with_index do |t, i|
    $anchors[t["anchor"]] = { label: "Figure #{i + 1}", xref: "Figure #{i + 1}" }
  end
  clause.xpath(ns(".//formula")).each_with_index do |t, i|
    $anchors[t["anchor"]] = { label: "Formula #{i + 1}", xref: "Formula #{i + 1}" }
  end
end

def hierarchical_asset_names(clause, num)
  clause.xpath(ns(".//table")).each_with_index do |t, i|
    $anchors[t["anchor"]] = { label: "#{num}.#{i + 1}", xref: "Table #{num}.#{i + 1}" }
  end
  clause.xpath(ns(".//figure")).each_with_index do |t, i|
    $anchors[t["anchor"]] = { label: "#{num}.#{i + 1}", xref: "Figure #{num}.#{i + 1}" }
  end
  clause.xpath(ns(".//formula")).each_with_index do |t, i|
    $anchors[t["anchor"]] = { label: "#{num}.#{i + 1}", xref: "Formula #{num}.#{i + 1}" }
  end
end

def introduction_names(clause)
  clause.xpath(ns("./clause")).each_with_index do |c, i|
    section_names(c, "0.#{i + 1}")
  end
end

def section_names(clause, num, level)
  $anchors[clause["anchor"]] = { label: num, xref: "Clause #{num}", level: level }
  clause.xpath(ns("./clause")).each_with_index do |c, i|
    section_names1(c, "#{num}.#{i + 1}", level + 1)
  end
end

def section_names1(clause, num, level)
  $anchors[clause["anchor"]] = { label: num, xref: "Clause #{num}", level: level }
  clause.xpath(ns("./clause")).each_with_index do |c, i|
    section_names1(c, "#{num}.#{i + 1}", level + 1)
  end
end

def annex_names(clause, num)
  obligation = clause["subtype"] == "normative" ? "(Normative)" : "(Informative)"
  $anchors[clause["anchor"]] = { label: "Annex #{num} #{obligation}", xref: "Annex #{num}" , level: 1 }
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
  out.a **{style: "mso-footnote-id:ftn#{fn}", href: "#_ftn#{fn}", name: "_ftnref#{fn}", title: ""} do |a|
    a.span **{class: "MsoFootnoteReference"} do |span|
      span.span **{style: "mso-special-character:footnote"}
    end
  end
  $footnotes << noko do |xml|
    xml.div **{style: "mso-element:footnote", id: "ftn#{fn}"} do |div|
      div.p **{class: "MsoFootnoteText"} do |p|
        p.a **{style: "mso-footnote-id:ftn#{fn}", href: "#_ftn#{fn}", name: "_ftnref#{fn}", title: ""} do |a|
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
    when "name" then out.title { |e| e << node.text }
    when "stem"
#$xslt = XML::XSLT.new()
#$xslt.xsl = File.read(File.join(File.dirname(__FILE__), "mathml2omml.xsl"))
$xslt.xml = AsciiMath.parse(node.text).to_mathml.gsub(/<math>/, "<math xmlns='http://www.w3.org/1998/Math/MathML'>")
ooml = $xslt.serve().gsub(/<\?[^>]+>\s*/, "").
  gsub(/ xmlns:[^=]+="[^"]+"/, "")
puts ooml
      out.parent.add_child ooml
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
        $block = true
        node.children.each { |n| parse(n, p) }
        $block = false
      end
    when "tr"
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
    when "note"
      out.div **attr_code("id": node["anchor"], class: "MsoNormalIndent" ) do |t|
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
    when "table"
      table_attr = {id: node["anchor"],
                    class: "MsoISOTable",
                    border: 1,
                    cellspacing: 0,
                    cellpadding: 0,
      }
      out.table **attr_code(table_attr) do |t|
        name = node.at(ns("./name"))
        thead = node.at(ns("./thead"))
        tbody = node.at(ns("./tbody"))
        tfoot = node.at(ns("./tfoot"))
        dl = node.at(ns("./dl"))
        note = node.xpath(ns("./note"))
        t.caption { |tt| tt << "#{$anchors[node["anchor"]][:label]}. #{name.text}" }  if name
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
        note.each do |n|
          parse(n, out) 
        end
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
    s.h1 "Foreword"
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
  ret = "ISO #{docnumber.text}"
  ret += "-#{partnumber.text}" if partnumber
  $iso_docnumber = docnumber.text
  $iso_docnumber += "-#{partnumber.text}" if partnumber
  # out.p ret
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
  head = <<HERE
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

convert(ARGV[0])
