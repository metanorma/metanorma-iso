require "uuidtools"
require "asciidoctor/iso/word/xref_gen"

module Asciidoctor
  module ISO
    module Word
      module Postprocessing
        class << self
          def postprocess(result, _filename)
            # http://sebsauvage.net/wiki/doku.php?id=word_document_generation
            result = populate_template(msword_fix(result))
            doc_header_files($filename)
            File.open("#{$filename}.htm", "w") { |f| f.write(result) }
            mime_package result, $filename
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

          def mime_attachment(boundary, filename, item)
            encoded_file = Base64.strict_encode64(
              File.read("#{$dir}/#{item}"),
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

          def mime_package(result, filename)
            boundary = mime_boundary
            mhtml = mime_preamble(boundary, filename, result)
            Dir.foreach($dir) do |item|
              next if item == "." || item == ".." || /^\./.match(item)
              mhtml += mime_attachment(boundary, filename, item)
            end
            mhtml += "--#{boundary}--"
            File.open("#{filename}.doc", "w") { |f| f.write mhtml }
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
              gsub(/\s*\[MODIFICATION\]/, ", modified ?~@~T ").
              gsub(%r{WD/CD/DIS/FDIS}, $iso_stageabbr)
          end

          def generate_header(filename)
            hdr_file = File.join(File.dirname(__FILE__), "header.html")
            header = File.read(hdr_file, encoding: "UTF-8").
              gsub(/FILENAME/, filename).
              gsub(/DOCYEAR/, $iso_docyear).
              gsub(/DOCNUMBER/, $iso_docnumber)
            File.open(File.join($dir, "header.html"), "w") do |f|
              f.write(header)
            end
          end

          def generate_filelist(filename)
            File.open(File.join($dir, "filelist.xml"), "w") do |f|
              f.write(<<~"XML")
                <xml xmlns:o="urn:schemas-microsoft-com:office:office">
                 <o:MainFile HRef="../#{filename}.htm"/>
              XML
              Dir.foreach($dir) do |item|
                next if item == "." || item == ".." || /^\./.match(item)
                f.write %{  <o:File HRef="#{item}"/>\n}
              end
              f.write("</xml>\n")
            end
          end

          def doc_header_files(filename)
            generate_header(filename)
            generate_filelist(filename)
          end

          def msword_fix(r)
            # brain damage in MSWord parser
            r.gsub(
              %r{<span style="mso-special-character:footnote"/>},
              '<span style="mso-special-character:footnote"></span>',
            ).gsub(
              %r{<link rel="File-List"},
              "<link rel=File-List",
              ).gsub(%r{<meta http-equiv="Content-Type"},
                     "<meta http-equiv=Content-Type")
          end

          # these are in fact preprocess,
          # but they are extraneous to main HTML file
          def html_header(html, docxml, filename)
            p = html.parent
            {
              o: "urn:schemas-microsoft-com:office:office",
              w: "urn:schemas-microsoft-com:office:word",
              m: "http://schemas.microsoft.com/office/2004/12/omml",
              nil: "http://www.w3.org/TR/REC-html40",
            }.each { |k, v| p.add_namespace_definition(k.to_s, v) }
            XrefGen::anchor_names docxml
            define_head html, filename
          end

          def define_head(html, filename)
            html.head do |head|
              head.title { |t| t << filename }
              head.parent.add_child <<~XML
                <xml> <w:WordDocument> <w:View>Print</w:View>
                <w:Zoom>100</w:Zoom> <w:DoNotOptimizeForBrowser/>
                </w:WordDocument> </xml>
              XML
              head.meta **{ "http-equiv": "Content-Type",
                            content: "text/html; charset=utf-8" }
              head.link **{ rel: "File-List", href: "#{$dir}/filelist.xml" }
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
end
