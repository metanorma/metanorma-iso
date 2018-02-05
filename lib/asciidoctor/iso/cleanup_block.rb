require "date"
require "nokogiri"
require "htmlentities"
require "json"
require "pathname"
require "open-uri"
require "pp"

module Asciidoctor
  module ISO
    module Cleanup
      def para_cleanup(xmldoc)
        xmldoc.xpath("//p[not(@id)]").each do |x|
          x["id"] = Utils::anchor_or_uuid
        end
        xmldoc.xpath("//note[not(@id)][not(ancestor::bibitem)]"\
                     "[not(ancestor::table)]").each do |x|
          x["id"] = Utils::anchor_or_uuid
        end
        xmldoc.xpath("//note[@id][ancestor::table]").each do |x|
          x.delete("id")
        end
      end


    end
  end
end
