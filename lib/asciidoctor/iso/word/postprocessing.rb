require "uuidtools"
require "asciidoctor/iso/word/xref_gen"

module Asciidoctor
  module ISO
    module Word
      module Postprocessing
        include ::Asciidoctor::ISO::Word::XrefGen

        def postprocess(result, filename, dir)
          # http://sebsauvage.net/wiki/doku.php?id=word_document_generation
          result = cleanup(Nokogiri::XML(result), dir).to_xml
          result = populate_template(msword_fix(result))
          doc_header_files(filename, dir)
          File.open("#{filename}.htm", "w") { |f| f.write(result) }
          mime_package result, filename, dir
        end

        def cleanup(docxml, dir)
          comment_cleanup(docxml)
          footnote_cleanup(docxml)
          image_cleanup(docxml, dir)
          docxml
        end

        def image_resize(orig_filename)
          image_size = ImageSize.path(orig_filename).size
          # max width for Word document is 400, max height is 680
          if image_size[0] > 400
            image_size[1] = (image_size[1] * 400 / image_size[0]).ceil
            image_size[0] = 400
          end
          if image_size[1] > 680
            image_size[0] = (image_size[0] * 680 / image_size[1]).ceil
            image_size[1] = 680
          end
          image_size
        end

        def image_cleanup(docxml, dir)
          docxml.xpath(ns("//img")).each do |i|
            matched = /\.(?<suffix>\S+)$/.match i["src"]
            uuid = UUIDTools::UUID.random_create.to_s
            new_full_filename = File.join(dir, "#{uuid}.#{matched[:suffix]}")
            # presupposes that the image source is local
            system "cp #{i["src"]} #{new_full_filename}"
            image_size = image_resize(i["src"])
            i["src"] = new_full_filename
            i["height"] = image_size[1]
            i["width"] = image_size[0]
          end
        end

        def comment_cleanup(docxml)
          docxml.xpath('//xmlns:div/xmlns:span[@style="MsoCommentReference"]').
            each do |x|
            prev = x.previous_element
            if !prev.nil?
              x.parent = prev
            end
          end
          docxml
        end

        def footnote_cleanup(docxml)
          docxml.xpath('//xmlns:div[@style="mso-element:footnote"]/xmlns:a').
            each do |x|
            n = x.next_element
            if !n.nil?
              n.children.first.add_previous_sibling(x.remove)
            end
          end
          docxml
        end

        def mime_preamble(boundary, filename, result)
          <<~"PREAMBLE"
          MIME-Version: 1.0
          Content-Type: multipart/related; boundary="#{boundary}"

          --#{boundary}
          Content-Location: file:///C:/Doc/#{filename}.htm
          Content-Type: text/html; charset="utf-8"

          #{result}

          PREAMBLE
        end

        def mime_attachment(boundary, filename, item, dir)
          encoded_file = Base64.strict_encode64(
            File.read("#{dir}/#{item}"),
          ).gsub(/(.{76})/, "\\1\n")
          <<~"FILE"
          --#{boundary}
          Content-Location: file:///C:/Doc/#{filename}_files/#{item}
          Content-Transfer-Encoding: base64
          Content-Type: #{mime_type(item)}

          #{encoded_file}

          FILE
        end

        def mime_type(item)
          types = MIME::Types.type_for(item)
          type = types ? types.first.to_s : 'text/plain; charset="utf-8"'
          type = type + ' charset="utf-8"' if /^text/.match?(type) && types
          type
        end

        def mime_boundary
          salt = UUIDTools::UUID.random_create.to_s.gsub(/-/, ".")[0..17]
          "----=_NextPart_#{salt}"
        end

        def mime_package(result, filename, dir)
          boundary = mime_boundary
          mhtml = mime_preamble(boundary, filename, result)
          Dir.foreach(dir) do |item|
            next if item == "." || item == ".." || /^\./.match(item)
            mhtml += mime_attachment(boundary, filename, item, dir)
          end
          mhtml += "--#{boundary}--"
          File.open("#{filename}.doc", "w") { |f| f.write mhtml }
        end

        def populate_template(docxml)
          meta = get_metadata
          docxml.
            gsub(/DOCYEAR/, meta[:docyear]).
            gsub(/DOCNUMBER/, meta[:docnumber]).
            gsub(/TCNUM/, meta[:tc]).
            gsub(/SCNUM/, meta[:sc]).
            gsub(/WGNUM/, meta[:wg]).
            gsub(/DOCTITLE/, meta[:doctitle]).
            gsub(/DOCSUBTITLE/, meta[:docsubtitle]).
            gsub(/SECRETARIAT/, meta[:secretariat]).
            gsub(/\[TERMREF\]\s*/, "[SOURCE: ").
            gsub(/\s*\[\/TERMREF\]\s*/, "]").
            gsub(/\s*\[ISOSECTION\]/, ", ").
            gsub(/\s*\[MODIFICATION\]/, ", modified &mdash; ").
            gsub(%r{WD/CD/DIS/FDIS}, meta[:stageabbr])
        end

        def generate_header(filename, dir)
          hdr_file = File.join(File.dirname(__FILE__), "header.html")
          header = File.read(hdr_file, encoding: "UTF-8").
            gsub(/FILENAME/, filename).
            gsub(/DOCYEAR/, get_metadata()[:docyear]).
            gsub(/DOCNUMBER/, get_metadata()[:docnumber])
          File.open(File.join(dir, "header.html"), "w") do |f|
            f.write(header)
          end
        end

        def generate_filelist(filename, dir)
          File.open(File.join(dir, "filelist.xml"), "w") do |f|
            f.write(<<~"XML")
                <xml xmlns:o="urn:schemas-microsoft-com:office:office">
                 <o:MainFile HRef="../#{filename}.htm"/>
            XML
            Dir.foreach(dir) do |item|
              next if item == "." || item == ".." || /^\./.match(item)
              f.write %{  <o:File HRef="#{item}"/>\n}
            end
            f.write("</xml>\n")
          end
        end

        def doc_header_files(filename, dir)
          generate_header(filename, dir)
          generate_filelist(filename, dir)
        end

        def msword_fix(r)
          # brain damage in MSWord parser
          r.gsub(%r{<span style="mso-special-character:footnote"/>},
                 '<span style="mso-special-character:footnote"></span>').
                 gsub(%r{(<a style="mso-comment-reference:[^>/]+)/>},
                      "\\1></a>").
                      gsub(%r{<link rel="File-List"}, "<link rel=File-List").
                      gsub(%r{<meta http-equiv="Content-Type"},
                           "<meta http-equiv=Content-Type").
                           gsub(%r{&tab;|&amp;tab;}, 
                                '<span style="mso-tab-count:1">&#xA0; </span>')
        end

        # these are in fact preprocess,
        # but they are extraneous to main HTML file
        def html_header(html, docxml, filename, dir)
          p = html.parent
          {
            o: "urn:schemas-microsoft-com:office:office",
            w: "urn:schemas-microsoft-com:office:word",
            m: "http://schemas.microsoft.com/office/2004/12/omml",
          }.each { |k, v| p.add_namespace_definition(k.to_s, v) }
          p.add_namespace(nil, "http://www.w3.org/TR/REC-html40")
          anchor_names docxml
          define_head html, filename, dir
        end

        def define_head(html, filename, dir)
          html.head do |head|
            head.title { |t| t << filename }
            head.parent.add_child <<~XML

              <!--[if gte mso 9]>
              <xml>
              <w:WordDocument>
              <w:View>Print</w:View>
              <w:Zoom>100</w:Zoom>
              <w:DoNotOptimizeForBrowser/>
              </w:WordDocument>
              </xml>
              <![endif]-->
            XML
            head.meta **{ "http-equiv": "Content-Type",
                          content: "text/html; charset=utf-8" }
            head.link **{ rel: "File-List", href: "#{dir}/filelist.xml" }
            head.style do |style|
              fn = File.join(File.dirname(__FILE__), "wordstyle.css")
              style.comment File.read(fn).gsub("FILENAME", filename)
            end
          end

          def titlepage(_docxml, div)
            fn = File.join(File.dirname(__FILE__), "iso_titlepage.html")
            titlepage = File.read(fn, encoding: "UTF-8")
            div.parent.add_child titlepage
          end
        end
      end
    end
  end
end
