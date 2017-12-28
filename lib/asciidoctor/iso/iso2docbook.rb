require "nokogiri"
require "htmlentities"
require "pp"

def convert(doc)
  docxml = Nokogiri::XML(doc)
  docxml.root.default_namespace = ""
  result = noko do |xml|
    xml.article do |a|
      # a.parent.add_namespace_definition("xlink", "http://www.w3.org/1999/xlink")
      a.parent.add_namespace_definition("xml", "http://www.w3.org/XML/1998/namespace")
      info docxml, a
    end
  end.join("\n")
  puts result
end

def ns(xpath)
  xpath.gsub(%r{/([a-zA-z])}, "/xmlns:\\1")
end

def info(isoxml, out)
  out.info do |i|
    title isoxml, i
    subtitle isoxml, i
    id isoxml, i
    version isoxml, i
    author isoxml, i
  end
  foreword isoxml, out
  introduction isoxml, out
  scope isoxml, out
  clause isoxml, out
  annex isoxml, out
end

def parse(node, out)
  if node.text?
    out << node.text
  else
    case node.name
    when "em" then out.emphasis { |e| e << node.text }
    when "strong" then out.emphasis **{role: "strong"} { |e| e << node.text }
    when "sup" then out.superscript { |e| e << node.text }
    when "sub" then out.subscript { |e| e << node.text }
    when "tt" then out.literal { |e| e << node.text }
    when "br" 
      # out.parent << Nokogiri::XML::ProcessingInstruction.new(out.doc, "asciidoc-br", "")
      out.parent << "&#xa;"
    when "name" then out.title { |e| e << node.text }
    when "clause" 
      out.section **attr_code("id": node["anchor"]) do |s|
        node.children.each { |n| parse(n, s) }
      end
    when "xref" 
      if node["format"] == "footnote"
        out.superscript do |s|
          if !node.text.empty?
          s.link **{"endterm": node["target"]} { |l| l << node.text }
          else
          s.link **{"endterm": node["target"], linkend: node["target"]} 
          end
        end
      else
        if !node.text.empty?
        out.link **{"endterm": node["target"]} { |l| l << node.text }
        else
        out.link **{endterm: node["target"], linkend: node["target"]} 
        end
      end
    when "eref" 
      # out.link **{"xlink:href": node["target"]} { |l| l << node.text }
      # Word XSLT is Docbook 4!
      # out.ulink **{"url": node["target"]} { |l| l << node.text }
      # And that doesn't work either!
      out << "[#{node["target"]}] #{node.text}"
    when "ul" then out.itemizedlist do |ul| 
      node.children.each { |n| parse(n, ul) }
    end
    when "li" then out.listitem do |li| 
      node.children.each { |n| parse(n, li) }
    end
    when "p" 
      out.para do |p| 
        $block = true
        node.children.each { |n| parse(n, p) }
        $block = false
      end
    else
      if $block
        out.emphasis **{role: "strong"} { |e| e << node.to_xml.gsub(/</,"&lt;").gsub(/>/,"&gt;") }
      else
        out.para do |p|
          p.emphasis **{role: "strong"} { |e| e << node.to_xml.gsub(/</,"&lt;").gsub(/>/,"&gt;") }
        end
      end
    end
  end
end

def clause(isoxml, out)
  clauses = isoxml.xpath(ns("//middle/clause"))
  return unless clauses
  clauses.each do |c|
    out.sect1 **attr_code("id": c["anchor"]) do |s| 
      c.elements.each { |c1| parse(c1, s) }
    end
  end
end

def annex(isoxml, out)
  clauses = isoxml.xpath(ns("//annex"))
  return unless clauses
  clauses.each do |c|
    out.appendix **attr_code("id": c["anchor"]) do |s| 
      c.elements.each { |c1| parse(c1, s) }
    end
  end
end

def scope(isoxml, out)
  f = isoxml.at(ns("//scope"))
  return unless f
  out.sect1 **{label: "1"} do |s|
    s.title "Scope"
    f.elements.each do |e|
      parse(e, s)
    end
  end
end

def introduction(isoxml, out)
  f = isoxml.at(ns("//introduction"))
  return unless f
  out.section  do |s|
    s.title "Introduction"
    f.elements.each do |e|
      if e.name == "patent_notice"
        e.elements.each do |e1|
          parse(e1, s)
        end
      else
        parse(e, s)
      end
    end
  end
end

def foreword(isoxml, out)
  f = isoxml.at(ns("//foreword"))
  return unless f
  out.section  do |s|
    s.title "Foreword"
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
  ret = tc.text
  ret = "ISO TC #{tc_num.text}: #{ret}" if tc_num
  ret += " SC #{sc_num.text}:" if sc_num
  ret += " #{sc.text}" if sc
  ret += " WG #{wg_num.text}:" if wg_num
  ret += " #{wg.text}" if wg
  out.org { |o| o.orgname ret }
end

def id(isoxml, out)
  docnumber = isoxml.at(ns("//documentnumber"))
  partnumber = isoxml.at(ns("//documentnumber/@partnumber"))
  ret = docnumber.text
  ret += "-#{partnumber.text}" if partnumber
  out.volumenum ret
end

def version(isoxml, out)
  e =  isoxml.at(ns("//edition"))
  out.edition e.text if e
  e =  isoxml.at(ns("//revdate"))
  out.date e.text if e
  yr =  isoxml.at(ns("//copyright_year"))
  out.copyright { |c| c.year yr.text } if yr
end

def title(isoxml, out)
  out.title do |t|
    intro = isoxml.at(ns("//title/en/title_intro"))
    main = isoxml.at(ns("//title/en/title_main"))
    part = isoxml.at(ns("//title/en/title_part"))
    partnumber = isoxml.at(ns("//id/documentnumber/@partnumber"))
    main = main.text
    main = "#{intro.text} -- #{main}" if intro
    main = "#{main} -- Part #{partnumber}: #{part.text}" if part
    t << main
  end
end

def subtitle(isoxml, out)
  out.subtitle do |t|
    intro = isoxml.at(ns("//title/fr/title_intro"))
    main = isoxml.at(ns("//title/fr/title_main"))
    part = isoxml.at(ns("//title/fr/title_part"))
    partnumber = isoxml.at(ns("//id/documentnumber/@partnumber"))
    main = main.text
    main = "#{intro.text} -- #{main}" if intro
    main = "#{main} -- Part #{partnumber}: #{part.text}" if part
    t << main
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
    [k, (v.is_a? String) ? HTMLEntities.new.decode(v) : v]
  end.to_h
end

convert($stdin.read)
