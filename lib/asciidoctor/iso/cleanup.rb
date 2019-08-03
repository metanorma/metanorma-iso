require "date"
require "nokogiri"
require "htmlentities"
require "json"
require "pathname"
require "open-uri"
require "pp"

module Asciidoctor
  module ISO
    class Converter < Standoc::Converter
      PRE_NORMREF_FOOTNOTES = "//foreword//fn | //introduction//fn |"\
        "//clause[title = 'Scope']//fn" .freeze

      NORMREF_FOOTNOTES =
        "//references[title = 'Normative References']//fn".freeze

      POST_NORMREF_FOOTNOTES =
        "//clause[not(title = 'Scope')]//fn | "\
        "//references[title = 'Bibliography']//fn".freeze

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
        id = xmldoc.at("//bibdata/docidentifier[@type = 'iso']") or return
        id.content = id_prefix(prefix, id)
        id = xmldoc.at("//bibdata/ext/structuredidentifier/project-number") or return
        id.content = id_prefix(prefix, id)
      end
    end
  end
end
