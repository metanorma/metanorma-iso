require "uuidtools"

module Asciidoctor
  module ISO
    module Word
      module ISO2WordHTML
        class << self
          def postprocess(result, filename)
            # see http://sebsauvage.net/wiki/doku.php?id=word_document_generation
            result = populate_template(msword_fix(result))
            doc_header_files($filename)
            File.open("#{$filename}.htm", "w") { |f| f.write(result) }
            mime_package result, $filename
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

          def msword_fix(result)
            # brain damage in MSWord parser
            result.gsub(%r{<span style="mso-special-character:footnote"/>},
                        %q{<span style="mso-special-character:footnote"></span>} ).
            gsub(%r{<link rel="File-List"}, "<link rel=File-List").
            gsub(%r{<meta http-equiv="Content-Type"}, "<meta http-equiv=Content-Type")
          end


        end
      end
    end
  end
end
