# frozen_string_literal: true

require "nokogiri"
require "zip"
require "uniword"
require "diff/lcs"

module IsoDoc
  module Iso
    module Docx
      # Body structure and paragraph/table style parity, not visual or text parity.
      # Read the two serializations directly: a Uniword model round trip could
      # hide a serialization defect in the output being checked.
      class MhtmlParity
        W = { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main" }.freeze
        CONTAINERS = { "table" => "table", "tr" => "row", "td" => "cell",
                       "th" => "cell", "tbl" => "table", "tc" => "cell" }.freeze

        def self.normalize(path)
          File.extname(path).downcase == ".docx" ? DocxReader.new.read(path) :
            HtmlReader.new.read(path)
        end

        def initialize(submitted, output)
          @submitted = submitted
          @output = output
          @expected = self.class.normalize(submitted)
          @actual = self.class.normalize(output)
        end

        def match?
          @expected == @actual
        end

        # LCS alignment avoids turning one missing paragraph into a report of
        # changes to every following paragraph. Positions are one-based tokens.
        def report
          lines = ["--- #{@submitted}", "+++ #{@output}"]
          if match?
            lines << "MATCH (#{@expected.length} structure/style tokens)"
          else
            Diff::LCS.sdiff(@expected, @actual).each do |change|
              next if change.unchanged?

              if change.old_element
                lines << "- #{change.old_position + 1}: #{change.old_element}"
              end
              if change.new_element
                lines << "+ #{change.new_position + 1}: #{change.new_element}"
              end
            end
          end
          lines.join("\n")
        end

        # Word uses both "Heading 1" and "Heading1", and MsoNormal/Normal.
        # Preserve punctuation so distinct ISO named styles remain distinct.
        class Reader
          private

          def style_name(value)
            value.to_s.gsub(/[[:space:]]+/, "").downcase
              .sub(/\Amsonormal\z/, "normal")
          end

          def paragraph(style, level = nil)
            kind = if level then "heading#{level}"
                   elsif style.start_with?("note") then "note"
                   elsif style.start_with?("example") then "example"
                   else "paragraph"
                   end
            ["#{kind}|#{style}"]
          end

          def container(node, style = "")
            kind = CONTAINERS.fetch(node.name)
            ["#{kind}#{style.empty? ? '' : "|#{style}"}",
             *children(node), "/#{kind}"]
          end

          def children(node)
            node.element_children.flat_map { |child| visit(child) }
          end
        end

        class HtmlReader < Reader
          def read(path)
            package = Uniword::Mhtml::MhtmlPackage.from_file(path)
            part = root_part(package, path)
            raise ArgumentError, "No HTML body in #{path}" unless part

            charset = part.content_type[/charset=["']?([^\s;"']+)/i, 1]
            @html = Nokogiri::HTML(part.decoded_content, nil, charset)
            body = @html.at_css("body")
            raise ArgumentError, "No HTML body in #{path}" unless body

            @styles = css_styles
            children(body)
          end

          private

          def root_part(package, path)
            headers = File.open(path, "rb") do |file|
              file.each_line.take_while { |line| !line.strip.empty? }.join
            end
            start = headers[/\bstart\s*=\s*["']?<([^>]+)>/i, 1]
            return package.html_part unless start

            package.parts.find do |part|
              part.content_id == start && part.is_a?(Uniword::Mhtml::HtmlPart)
            end
          end

          def css_styles
            rules = []
            @html.css("style").each do |sheet|
              sheet.text.gsub(%r{/\*.*?\*/}m, "")
                .scan(/([^{}]+)\{([^{}]*)\}/m) do |selectors, declarations|
                name = property(declarations, "mso-style-name")
                level = property(declarations, "mso-outline-level")
                next unless name || level

                selectors.split(",").each do |selector|
                  rules << [selector.strip, name, level]
                end
              end
            end
            rules
          end

          def property(css, name)
            css.to_s[/\b#{name}\s*:\s*([^;]+)/i, 1]&.strip
              &.gsub(/\A["']|["']\z/, "")
          end

          def html_style(node)
            # Word's named-style selectors are tags, classes or tag.class.
            # Ignore layout CSS and resolve these by specificity/source order.
            rules = @styles.select do |selector, _name, _level|
              selector.match?(/\A(?:[\w-]+(?:\.[\w-]+)?|\.[\w-]+)\z/) &&
                node.matches?(selector)
            end.sort_by do |selector,|
              [selector.include?(".") ? 1 : 0, selector.start_with?(".") ? 0 : 1]
            end
            classes = node["class"]&.split
            named_rules = classes&.any? ? rules.select { |rule| rule[0].include?(".") } : rules
            name = named_rules.filter_map { |rule| rule[1] }.last
            level = rules.filter_map { |rule| rule[2] }.last
            name = property(node["style"], "mso-style-name") || name
            level = property(node["style"], "mso-outline-level") || level
            name ||= classes&.first
            name ||= node.name.match?(/\Ah[1-6]\z/) ? "Heading#{node.name[1]}" : "Normal"
            [style_name(name), level]
          end

          def visit(node)
            case node.name
            when "p", /\Ah[1-6]\z/
              style, level = html_style(node)
              level ||= style[/\Aheading([1-9])\z/, 1]
              level ||= node.name[/\Ah([1-6])\z/, 1]
              paragraph(style, level) + node.css("img, imagedata").map { "figure" }
            when "table"
              style, = html_style(node)
              container(node, style == "normal" ? "" : style)
            when "td", "th"
              cell(node)
            when "tr"
              container(node)
            when "img", "imagedata" then ["figure"]
            when "style", "script" then []
            else children(node)
            end
          end

          def cell(node)
            # Word emits paragraphs in cells; HTML also allows bare inline
            # content. Preserve that implicit paragraph, including empty cells.
            if node.css("p, h1, h2, h3, h4, h5, h6, table, div").empty?
              ["cell", *paragraph("normal"), *children(node), "/cell"]
            else
              container(node)
            end
          end
        end

        class DocxReader < Reader
          def read(path)
            Zip::File.open(path) do |zip|
              document = xml_part(zip, "word/document.xml")
              styles = xml_part(zip, "word/styles.xml")
              @styles = styles.xpath("//w:style", W).to_h do |style|
                [style["w:styleId"], style]
              end
              @default = styles.at_xpath("//w:style[@w:type='paragraph'][@w:default='1' or @w:default='true']/@w:styleId", W)&.value
              body = document.at_xpath("/w:document/w:body", W)
              raise ArgumentError, "No Word body in #{path}" unless body

              children(body)
            end
          end

          private

          def xml_part(zip, name)
            entry = zip.find_entry(name)
            raise ArgumentError, "Missing #{name}" unless entry

            Nokogiri::XML(entry.get_input_stream.read) { |config| config.strict.nonet }
          end

          def word_style(id)
            name = @styles[id]&.at_xpath("w:name/@w:val", W)&.value
            style_name(name || id || "Normal")
          end

          def outline_level(id, seen = [])
            return if seen.include?(id) || !@styles[id]

            style = @styles[id]
            level = style.at_xpath("w:pPr/w:outlineLvl/@w:val", W)&.value
            return level if level

            parent = style.at_xpath("w:basedOn/@w:val", W)&.value
            outline_level(parent, seen + [id])
          end

          def visit(node)
            case node.name
            when "p"
              id = node.at_xpath("w:pPr/w:pStyle/@w:val", W)&.value || @default
              style = word_style(id)
              level = node.at_xpath("w:pPr/w:outlineLvl/@w:val", W)&.value || outline_level(id)
              level = if level.nil?
                        style[/\Aheading([1-9])\z/, 1]
                      elsif level.to_i < 9
                        (level.to_i + 1).to_s
                      end
              paragraph(style, level) + node.xpath(".//w:drawing | .//w:pict", W).map { "figure" }
            when "tbl"
              id = node.at_xpath("w:tblPr/w:tblStyle/@w:val", W)&.value
              container(node, id ? word_style(id) : "")
            when "tr", "tc" then container(node)
            when "pPr", "tblPr", "trPr", "tcPr", "sectPr" then []
            else children(node)
            end
          end
        end
      end
    end
  end
end
