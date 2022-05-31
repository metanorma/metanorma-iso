require_relative "base_convert"
require_relative "init"
require "isodoc"

module IsoDoc
  module Iso
    class HtmlConvert < IsoDoc::HtmlConvert
      def initialize(options)
        @libdir = File.dirname(__FILE__)
        super
      end

      def googlefonts
        <<~HEAD.freeze
          <link href="https://fonts.googleapis.com/css?family=Space+Mono:400,400i,700,700i&display=swap" rel="stylesheet">
          <link href="https://fonts.googleapis.com/css?family=Lato:400,400i,700,900" rel="stylesheet">
        HEAD
      end

      def default_fonts(options)
        {
          bodyfont: (if options[:script] == "Hans"
                       '"Source Han Sans",serif'
                     else
                       options[:alt] ? '"Lato",sans-serif' : '"Cambria",serif'
                     end),
          headerfont: (if options[:script] == "Hans"
                         '"Source Han Sans",sans-serif'
                       else
                         options[:alt] ? '"Lato",sans-serif' : '"Cambria",serif'
                       end),
          monospacefont: (if options[:alt]
                            '"Space Mono",monospace'
                          else
                            '"Courier New",monospace'
                          end),
          normalfontsize: "1.0em",
          smallerfontsize: "0.9em",
          footnotefontsize: "0.9em",
          monospacefontsize: "0.8em",
        }
      end

      def default_file_locations(options)
        {
          htmlstylesheet: (if options[:alt]
                             html_doc_path("style-human.scss")
                           else
                             html_doc_path("style-iso.scss")
                           end),
          htmlcoverpage: html_doc_path("html_iso_titlepage.html"),
          htmlintropage: html_doc_path("html_iso_intro.html"),
        }
      end

      def footnote_reference_format(link)
        link.content += ")"
      end

      def html_toc_entry(level, header)
        content = header.at("./following-sibling::p"\
                            "[@class = 'variant-title-toc']") || header
        if level == "h1" &&
            header.parent.at(".//h2#{toc_exclude_class}")
          <<~HDR
            <li class="#{level}"><div class="collapse-group"><a href="##{header['id']}">#{header_strip(content)}</a>
            <div class="collapse-button"></div></div></li>
          HDR
        else
          %(<li class="#{level}"><a href="##{header['id']}">\
      #{header_strip(content)}</a></li>)
        end
      end

      def html_toc(docxml)
        super
        docxml.xpath("//div[@id = 'toc']/ul[li[@class = 'h2']]").each do |u|
          html_toc1(u)
        end
        docxml
      end

      def html_toc1(ulist)
        u2 = nil
        ulist.xpath("./li").each do |l|
          if l["class"] != "h2"
            u2 = nil
          elsif u2 then u2.add_child(l.remove)
          else
            u2 = l.replace("<ul class='content collapse'>#{l}</ul>").first
            p = u2.previous_element and p << u2
          end
        end
      end

      def inject_script(doc)
        scr = <<~HEAD.freeze
          <script>
          $(".collapse-button").click(function () {
          $(this).toggleClass('expand'); // expand: the class to change the collapse button shape
          // collapse: the class to collapse/expand the li elements with the h2 class
          $(this).closest('li').children(".content").toggleClass('collapse');})
          </script>
        HEAD
        a = super.split(%r{</body>})
        "#{a[0]}#{scr}</body>#{a[1]}"
      end

      def table_th_center(docxml)
        docxml.xpath("//thead//th | //thead//td").each do |th|
          th["style"] += ";text-align:center;vertical-align:middle;"
        end
      end

      def ol_attrs(node)
        ret = super
        ret.merge(class: OL_STYLE.invert[ret[:type]])
      end

      include BaseConvert
      include Init
    end
  end
end
