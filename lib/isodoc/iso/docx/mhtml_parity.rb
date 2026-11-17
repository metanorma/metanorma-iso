# frozen_string_literal: true

require "nokogiri"
require "zip"
require "uniword"

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
          if File.extname(path).downcase == ".docx"
            DocxReader.new.read(path)
          else
            HtmlReader.new.read(path)
          end
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
            lines.concat(difference_lines)
          end
          lines.join("\n")
        end

        private

        def difference_lines
          lines = []
          old_position = new_position = 0
          matches = Alignment.new(@expected, @actual).matches
          return delta_lines(matches) unless matches.compact.each_cons(2).all? { |a, b| a < b }

          matches[@expected.length] = @actual.length
          matches.each_with_index do |new_match, old_match|
            next if new_match.nil?

            while old_position < old_match || new_position < new_match
              if old_position < old_match
                lines << "- #{old_position + 1}: #{@expected[old_position]}"
                old_position += 1
              end
              if new_position < new_match
                lines << "+ #{new_position + 1}: #{@actual[new_position]}"
                new_position += 1
              end
            end
            old_position = old_match + 1
            new_position = new_match + 1
          end
          lines
        end

        # Multiset matches need not be ordered. Report only the unmatched
        # occurrences, retaining their original one-based positions.
        def delta_lines(matches)
          matched_actual = matches.compact.to_h { |position| [position, true] }
          removed = @expected.each_index.filter_map do |position|
            "- #{position + 1}: #{@expected[position]}" if matches[position].nil?
          end
          added = @actual.each_index.filter_map do |position|
            "+ #{position + 1}: #{@actual[position]}" unless matched_actual[position]
          end
          Array.new([removed.size, added.size].max) do |index|
            [removed[index], added[index]]
          end.flatten.compact
        end

        # Bitset LCS thresholds avoid enumerating every pair of equal tokens
        # (quadratic for repeated table cells). Keep the same earliest-endpoint
        # thresholds and predecessor links as diff-lcs, including its prefix and
        # suffix trimming, so ambiguous alignments retain their report positions.
        class Alignment
          # Keep ordinary artifacts' exact alignment and tie-breaking. Large
          # artifacts align a bounded leading window after prefix/suffix trim;
          # the rest is a multiset delta (ordering there is not compared).
          MAX_EXACT_TOKENS = 100_000
          WINDOW_TOKENS = 2_048

          def initialize(expected, actual)
            @expected = expected
            @actual = actual
            @matches = []
            @links = {}
          end

          def matches
            first, last_expected, last_actual = trim
            if [last_expected, last_actual].max - first + 1 > MAX_EXACT_TOKENS
              return bounded_matches(first, last_expected, last_actual)
            end

            masks = Hash.new(0)
            (first..last_actual).each do |position|
              masks[@actual[position]] |= 1 << (position - first)
            end
            row = 0
            (first..last_expected).each do |position|
              # Set bits mark the smallest actual endpoint for each LCS length.
              # Subtraction propagates each threshold to its next matching bit;
              # unchanged thresholds retain their original predecessor links.
              union = row | masks[@expected[position]]
              next_row = union & ~(union - ((row << 1) | 1))
              update_links(row, next_row, position, first)
              row = next_row
            end
            link = @links[row.bit_length - 1]
            while link
              @matches[link[1]] = link[2]
              link = link[0]
            end
            @matches
          end

          private

          def bounded_matches(first, last_expected, last_actual)
            expected_end = [first + WINDOW_TOKENS, last_expected + 1].min
            actual_end = [first + WINDOW_TOKENS, last_actual + 1].min
            window = self.class.new(@expected[first...expected_end],
                                    @actual[first...actual_end]).matches
            window.each_with_index do |match, position|
              @matches[first + position] = first + match if match
            end
            multiset_matches(expected_end, actual_end, last_expected, last_actual)
            @matches
          end

          def multiset_matches(first_expected, first_actual, last_expected, last_actual)
            positions = Hash.new { |hash, token| hash[token] = [] }
            last_actual.downto(first_actual) do |position|
              positions[@actual[position]] << position
            end
            (first_expected..last_expected).each do |position|
              @matches[position] = positions[@expected[position]].pop
            end
          end

          def trim
            first = 0
            last_expected = @expected.length - 1
            last_actual = @actual.length - 1
            while first <= last_expected && first <= last_actual &&
                @expected[first] == @actual[first]
              @matches[first] = first
              first += 1
            end
            while first <= last_expected && first <= last_actual &&
                @expected[last_expected] == @actual[last_actual]
              @matches[last_expected] = last_actual
              last_expected -= 1
              last_actual -= 1
            end
            [first, last_expected, last_actual]
          end

          def update_links(row, next_row, position, offset)
            # Descending order leaves each predecessor on the previous row.
            each_bit(next_row & ~row) do |index, bit|
              previous = (row & (bit - 1)).bit_length - 1
              @links[index] = [@links[previous], position, index + offset]
            end
            each_bit(row & ~next_row) { |index, _bit| @links.delete(index) }
          end

          def each_bit(bits)
            until bits.zero?
              index = bits.bit_length - 1
              bit = 1 << index
              yield index, bit
              bits ^= bit
            end
          end
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
            ["#{kind}#{"|#{style}" unless style.empty?}",
             *children(node), "/#{kind}"]
          end

          def children(node)
            node.element_children.flat_map { |child| visit(child) }
          end
        end

        class HtmlReader < Reader
          # Word HTML uses Mso-prefixed class aliases for built-in body styles,
          # often without declaring mso-style-name. Custom names keep the prefix.
          BUILTIN_CLASSES = %w[Normal BodyText BodyText2 BodyText3
                               BodyTextIndent BodyTextIndent2 BodyTextIndent3
                               BodyTextFirstIndent BodyTextFirstIndent2]
            .to_h { |name| ["mso#{name.downcase}", name] }.freeze

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

          # A valid CSS class identifier never starts with a digit; Word
          # still emits such selectors in its stylesheets (e.g. "span.1"),
          # and handing them to Node#matches? raises a CSS syntax error.
          VALID_SELECTOR_RE = /\A(?:[A-Za-z_][\w-]*(?:\.[A-Za-z_][\w-]*)?
                                  |\.[A-Za-z_][\w-]*)\z/x.freeze

          def html_style(node)
            # Word's named-style selectors are tags, classes or tag.class.
            # Ignore layout CSS and resolve these by specificity/source order.
            classes = node["class"]&.split
            rules = @styles.select do |selector, _name, _level|
              selector_matches?(node, classes, selector)
            end.sort_by do |selector,|
              [selector.include?(".") ? 1 : 0, selector.start_with?(".") ? 0 : 1]
            end
            named_rules = classes&.any? ? rules.select { |rule| rule[0].include?(".") } : rules
            name = named_rules.filter_map { |rule| rule[1] }.last
            level = rules.filter_map { |rule| rule[2] }.last
            name = property(node["style"], "mso-style-name") || name
            level = property(node["style"], "mso-outline-level") || level
            name ||= class_style(classes&.first)
            name ||= node.name.match?(/\Ah[1-6]\z/) ? "Heading#{node.name[1]}" : "Normal"
            [style_name(name), level]
          end

          def selector_matches?(node, classes, selector)
            return false unless selector.match?(VALID_SELECTOR_RE)

            # Node#matches? searches the entire document for every paragraph.
            # These simple selectors depend only on the current element.
            tag, klass = selector.split(".", 2)
            (tag.empty? || tag == node.name) &&
              (klass.nil? || classes&.include?(klass))
          end

          def class_style(name)
            BUILTIN_CLASSES.fetch(name.to_s.downcase, name)
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
