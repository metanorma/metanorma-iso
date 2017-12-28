require "nokogiri"
require "pp"

def convert(doc)
  docxml = Nokogiri::XML(doc)
  docxml.root.default_namespace = ""
  result = noko do |xml|
    xml.article do |a|
      a.info do |i|
        title docxml, i
        subtitle docxml, i
      end
    end
  end.join("\n")
  puts result
end

# namespace
z = {"n": "http://riboseinc.com/isoxml"}

def nsp(xpath)
  xpath.gsub(%r{/([a-zA-z])}, "/xmlns:\\1")
end

def title(isoxml, out)
  pp isoxml.namespaces
  out.title do |t|
        intro = isoxml.at(nsp("//title/en/title_intro"))
        main = isoxml.at(nsp("//title/en/title_main"))
        part = isoxml.at(nsp("//title/en/title_part"))
        partnumber = isoxml.at(nsp("//id/documentnumber/@partnumber"))
        main = main.text
        main = "#{intro.text} -- #{main}" if intro
        main = "#{main} -- Part #{partnumber}: #{part.text}" if part
        t << main
  end
end

def subtitle(isoxml, out)
  out.subtitle do |t|
        intro = isoxml.at(nsp("//title/fr/title_intro"))
        main = isoxml.at(nsp("//title/fr/title_main"))
        part = isoxml.at(nsp("//title/fr/title_part"))
        partnumber = isoxml.at(nsp("//id/documentnumber/@partnumber"))
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

convert($stdin.read)
