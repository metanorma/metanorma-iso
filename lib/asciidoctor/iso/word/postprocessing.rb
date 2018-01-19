require "uuidtools"
require "asciidoctor/iso/word/xref_gen"

module Asciidoctor
  module ISO::Word
    module Postprocessing
      class << self
        def postprocess(result, filename)
          # see http://sebsauvage.net/wiki/doku.php?id=word_document_generation
          result = populate_template(msword_fix(result))
          doc_header_files($filename)
          File.open("#{$filename}.htm", "w") { |f| f.write(result) }
          mime_package result, $filename
        end

        def mime_package(result, filename)
          salt = UUIDTools::UUID.random_create.to_s.gsub(/-/, '.')[0..17]
          boundary = "----=_NextPart_#{salt}"
          mhtml = <<~"EOF"
          MIME-Version: 1.0
          Content-Type: multipart/related; boundary="#{boundary}"

          --#{boundary}
          Content-Location: file:///C:/Doc/#{filename}.htm
          Content-Type: text/html; charset="utf-8"

          #{result}

          EOF
          Dir.foreach($dir) do |item|
            next if item == '.' or item == '..' or /^\./.match item
            types = MIME::Types.type_for(item)
            type = types ? types.first.to_s : %Q{text/plain; charset="utf-8"}
            type = type + ' charset="utf-8"' if /^text/.match type and types
            encoded_file = Base64.strict_encode64(
              File.read("#{$dir}/#{item}")).
            gsub(/(.{76})/, "\\1\n")

            mhtml += <<~"EOF"
            --#{boundary}
            Content-Location: file:///C:/Doc/#{filename}_files/#{item}
            Content-Transfer-Encoding: base64
            Content-Type: #{type}

            #{encoded_file}

            EOF
          end
          mhtml += "--#{boundary}--"

          File.open("#{filename}.doc", "w") do |f|
            f.write mhtml
          end
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

        def doc_header_files(filename)
          header = File.read(File.join(File.dirname(__FILE__), "header.html"),
                             :encoding => "UTF-8").
                             gsub(/FILENAME/, filename).
                             gsub(/DOCYEAR/, $iso_docyear).
                             gsub(/DOCNUMBER/, $iso_docnumber)
          File.open(File.join($dir, "header.html"), "w") do |f|
            f.write(header)
          end

          File.open(File.join($dir, "filelist.xml"), "w") do |f|
            f.write(<<~"XML")
              <xml xmlns:o="urn:schemas-microsoft-com:office:office">
               <o:MainFile HRef="../#{filename}.htm"/>
            XML
            Dir.foreach($dir) do |item|
              next if item == '.' or item == '..'
              f.write %Q{  <o:File HRef="#{item}"/>\n}
            end
            f.write("</xml>\n")
          end
        end

        def msword_fix(r)
          # brain damage in MSWord parser
          r.gsub(%r{<span style="mso-special-character:footnote"/>},
                 %q{<span style="mso-special-character:footnote"></span>} ).
          gsub(%r{<link rel="File-List"}, "<link rel=File-List").
          gsub(%r{<meta http-equiv="Content-Type"}, 
               "<meta http-equiv=Content-Type")
        end

        # these are in fact preprocess, 
        # but they are extraneous to main HTML file
        def html_header(html, docxml, filename)
          p = html.parent
          {o: "urn:schemas-microsoft-com:office:office",
           w: "urn:schemas-microsoft-com:office:word",
           m: "http://schemas.microsoft.com/office/2004/12/omml",
           nil: "http://www.w3.org/TR/REC-html40"}.each do |k, v|
             p.add_namespace_definition(k.to_s, v)
           end
           XrefGen::anchor_names docxml
           define_head html, filename
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
            head.link **{rel: "File-List", href: "#{$dir}/filelist.xml"}
            head.style do |style|
              style.comment File.read(File.join(File.dirname(__FILE__),
                                                "wordstyle.css")).
                                               gsub("FILENAME", filename)
            end
          end

          def titlepage(docxml, div)
            titlepage = File.read(File.join(File.dirname(__FILE__),
                                            "iso_titlepage.html"),
                                            :encoding => "UTF-8")
            div.parent.add_child titlepage
          end
        end
      end
    end
  end
end
