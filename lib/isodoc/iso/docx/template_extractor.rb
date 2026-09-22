# frozen_string: true

require "nokogiri"
require "yaml"
require "fileutils"
require "digest"
require "tmpdir"
require "zip"

module IsoDoc
  module Iso
    module Docx
      # Extracts style/numbering/defaults YAML from a reference DOCX.
      #
      # Produces (in +output_dir+):
      #   styles.yml       — paragraph + character style definitions
      #   numbering.yml    — abstractNum and num definitions
      #   doc_defaults.yml — run + paragraph defaults
      #
      # All output includes provenance metadata (reference filename,
      # sha256, extraction timestamp, template era).
      #
      # This is a build-time tool. Runtime code reads the YAML files;
      # the extractor is not on the hot path.
      class TemplateExtractor
        REFERENCE_ERA = "late_typefi".freeze
        W_NS = "http://schemas.openxmlformats.org/wordprocessingml/2006/main".freeze

        attr_reader :reference_path, :output_dir, :provenance,
                    :style_definitions, :numbering_definitions, :doc_defaults

        def initialize(reference_docx_path, output_dir)
          @reference_path = File.expand_path(reference_docx_path)
          @output_dir = File.expand_path(output_dir)
          @provenance = Provenance.new(
            reference_doc: File.basename(@reference_path),
            reference_doc_sha256: sha256_of(@reference_path),
            template_era: REFERENCE_ERA,
            extracted_at: Time.now.utc
          )
          FileUtils.mkdir_p(@output_dir)
        end

        def extract
          unpack do |word_dir|
            styles_xml = read_xml("#{word_dir}/word/styles.xml")
            num_xml    = read_xml("#{word_dir}/word/numbering.xml")
            @style_definitions     = StylesParser.new(styles_xml).parse
            @numbering_definitions = NumberingParser.new(num_xml).parse
            @doc_defaults          = DocDefaultsParser.new(styles_xml).parse
          end
          write_styles
          write_numbering
          write_doc_defaults
          self
        end

        private

        def unpack
          Dir.mktmpdir("dis-extract") do |tmp|
            Zip::File.open(@reference_path) do |zip|
              zip.each do |entry|
                path = File.join(tmp, entry.name)
                FileUtils.mkdir_p(File.dirname(path))
                zip.extract(entry, path) { true }
              end
            end
            yield tmp
          end
        end

        def read_xml(path)
          Nokogiri::XML(File.read(path)) { |config| config.noblanks }
        end

        def sha256_of(path)
          Digest::SHA256.file(path).hexdigest
        end

        def write_styles
          grouped = @style_definitions.group_by(&:type)
          data = {
            "style_library" => {
              "name" => "ISO DIS Template (Era C — late Typefi)",
              "version" => provenance.template_era,
              "description" => "Styles extracted from #{provenance.reference_doc}",
              "template_era" => provenance.template_era,
              "reference_doc" => provenance.reference_doc,
              "reference_doc_sha256" => provenance.reference_doc_sha256,
              "extracted_at" => provenance.extracted_at.iso8601,
              "paragraph_styles" => styles_to_h(grouped["paragraph"] || []),
              "character_styles" => styles_to_h(grouped["character"] || []),
              "table_styles" => styles_to_h(grouped["table"] || [])
            }
          }
          write_yaml("styles.yml", data)
        end

        def styles_to_h(list)
          list.each_with_object({}) { |s, h| h[s.id] = s.to_h }
        end

        def write_numbering
          data = {
            "definitions" => @numbering_definitions.map(&:to_h),
            "template_era" => provenance.template_era,
            "reference_doc" => provenance.reference_doc,
            "reference_doc_sha256" => provenance.reference_doc_sha256,
            "extracted_at" => provenance.extracted_at.iso8601
          }
          write_yaml("numbering.yml", data)
        end

        def write_doc_defaults
          data = @doc_defaults.to_h.merge(
            "template_era" => provenance.template_era,
            "reference_doc" => provenance.reference_doc,
            "reference_doc_sha256" => provenance.reference_doc_sha256,
            "extracted_at" => provenance.extracted_at.iso8601
          )
          write_yaml("doc_defaults.yml", data)
        end

        def write_yaml(filename, data)
          File.write(File.join(@output_dir, filename), YAML.dump(data))
        end

        # Value object: provenance metadata.
        Provenance = Struct.new(
          :reference_doc, :reference_doc_sha256,
          :template_era, :extracted_at,
          keyword_init: true
        )

        # Value object: a single style definition.
        StyleDefinition = Struct.new(
          :id, :type, :name, :based_on, :next_style, :linked_style,
          :ui_priority, :quick_format, :hidden, :semi_hidden,
          :unhide_when_used, :paragraph_properties, :run_properties,
          keyword_init: true
        ) do
          def to_h
            h = { "id" => id, "type" => type, "name" => name }
            h["based_on"]       = based_on       if based_on
            h["next_style"]     = next_style     if next_style
            h["linked_style"]   = linked_style   if linked_style
            h["ui_priority"]    = ui_priority    if ui_priority
            h["quick_format"]   = quick_format   if quick_format
            h["hidden"]         = hidden         unless hidden.nil?
            h["semi_hidden"]    = semi_hidden    unless semi_hidden.nil?
            h["unhide_when_used"] = unhide_when_used unless unhide_when_used.nil?
            h["paragraph_properties"] = paragraph_properties if paragraph_properties
            h["run_properties"]      = run_properties      if run_properties
            h
          end
        end

        # Value object: a numbering definition (abstractNum or num).
        NumberingDefinition = Struct.new(
          :kind, :id, :abstract_num_id, :levels, :num_style_link,
          keyword_init: true
        ) do
          def to_h
            h = { "kind" => kind, "id" => id }
            h["abstract_num_id"] = abstract_num_id if abstract_num_id
            h["levels"] = levels if levels
            h["num_style_link"] = num_style_link if num_style_link
            h
          end
        end

        # Base class for OOXML → Ruby property hash conversion.
        class PropertyReader
          def initialize(node)
            @node = node
            @ns = TemplateExtractor::W_NS
          end

          def read
            {}.tap { |h| read_into(h) }
          end

          private

          def child_text(name)
            el = @node.at_xpath("w:#{name}", "w" => @ns)
            el&.[]("w:val")
          end

          def val_of(node, name)
            node.at_xpath("w:#{name}", "w" => @ns)&.[]("w:val")
          end

          def has_child?(name)
            !!@node.at_xpath("w:#{name}", "w" => @ns)
          end

          def read_into(_h)
            raise NotImplementedError
          end
        end

        # Parses <w:style> elements into StyleDefinition instances.
        class StylesParser
          def initialize(xml)
            @xml = xml
            @ns = TemplateExtractor::W_NS
          end

          def parse
            @xml.xpath("//w:style", "w" => @ns).map { |s| parse_one(s) }
          end

          private

          def parse_one(style_node)
            StyleDefinition.new(
              id: style_node["w:styleId"],
              type: style_node["w:type"],
              name: read_name(style_node),
              based_on: read_attr(style_node, "basedOn"),
              next_style: read_attr(style_node, "next"),
              linked_style: read_attr(style_node, "link"),
              ui_priority: read_val(style_node, "uiPriority"),
              quick_format: !style_node.at_xpath("w:qFormat", "w" => @ns).nil?,
              hidden: !style_node.at_xpath("w:hidden", "w" => @ns).nil?,
              semi_hidden: !style_node.at_xpath("w:semiHidden", "w" => @ns).nil?,
              unhide_when_used: !style_node.at_xpath("w:unhideWhenUsed",
                                                      "w" => @ns).nil?,
              paragraph_properties: read_pPr(style_node),
              run_properties: read_rPr(style_node)
            )
          end

          def read_name(node)
            node.at_xpath("w:name", "w" => @ns)&.[]("w:val")
          end

          def read_attr(node, name)
            node.at_xpath("w:#{name}", "w" => @ns)&.[]("w:val")
          end

          def read_val(node, name)
            node.at_xpath("w:#{name}", "w" => @ns)&.[]("w:val")
          end

          def read_pPr(node)
            pPr = node.at_xpath("w:pPr", "w" => @ns)
            return nil unless pPr
            ParagraphPropertiesReader.new(pPr).read
          end

          def read_rPr(node)
            rPr = node.at_xpath("w:rPr", "w" => @ns)
            return nil unless rPr
            RunPropertiesReader.new(rPr).read
          end
        end

        # Parses <w:pPr> into a properties hash.
        class ParagraphPropertiesReader < PropertyReader
          private

          def read_into(h)
            h["numbering"]      = read_numbering
            h["spacing"]        = read_spacing
            h["indent"]         = read_indent
            h["alignment"]      = read_alignment
            h["tabs"]           = read_tabs
            h["outline_level"]  = val_of(@node, "outlineLvl")
            h["keep_next"]      = has_child?("keepNext")
            h["keep_lines"]     = has_child?("keepLines")
            h["page_break_before"] = has_child?("pageBreakBefore")
            h.compact!
          end

          def read_numbering
            num_pr = @node.at_xpath("w:numPr", "w" => @ns)
            return nil unless num_pr
            h = {}
            h["num_id"] = num_pr.at_xpath("w:numId", "w" => @ns)&.[]("w:val")
            h["ilvl"]   = num_pr.at_xpath("w:ilvl", "w" => @ns)&.[]("w:val")
            h.compact
          end

          def read_spacing
            sp = @node.at_xpath("w:spacing", "w" => @ns)
            return nil unless sp
            %w[before after line line_rule before_lines after_lines
               before_autospacing after_autospacing].each_with_object({}) do |a, h|
              v = sp["w:#{a.tr('_', '')}"] || sp["w:#{a}"]
              h[a] = v if v
            end.yield_self { |h| h.empty? ? nil : h }
          end

          def read_indent
            ind = @node.at_xpath("w:ind", "w" => @ns)
            return nil unless ind
            {
              "left" => ind["w:left"] || ind["w:start"],
              "right" => ind["w:right"] || ind["w:end"],
              "hanging" => ind["w:hanging"],
              "firstLine" => ind["w:firstLine"]
            }.compact.yield_self { |h| h.empty? ? nil : h }
          end

          def read_alignment
            al = @node.at_xpath("w:jc", "w" => @ns)
            al&.[]("w:val")
          end

          def read_tabs
            tabs = @node.at_xpath("w:tabs", "w" => @ns)
            return nil unless tabs
            tabs.xpath("w:tab", "w" => @ns).map do |t|
              { "type" => t["w:val"], "position" => t["w:pos"],
                "leader" => t["w:leader"] }.compact
            end.yield_self { |t| t.empty? ? nil : t }
          end
        end

        # Parses <w:rPr> into a properties hash.
        class RunPropertiesReader < PropertyReader
          private

          def read_into(h)
            h["fonts"]         = read_fonts
            h["font_size"]     = val_of(@node, "sz")
            h["font_size_cs"]  = val_of(@node, "szCs")
            h["bold"]          = has_child?("b")
            h["italic"]        = has_child?("i")
            h["color"]         = val_of(@node, "color")
            h["underline"]     = val_of(@node, "u")
            h["small_caps"]    = has_child?("smallCaps")
            h["all_caps"]      = has_child?("caps")
            h["lang_val"]      = read_lang_attr("val")
            h["lang_eastasia"] = read_lang_attr("eastAsia")
            h["lang_bidi"]     = read_lang_attr("bidi")
            h.compact!
          end

          def read_fonts
            rFonts = @node.at_xpath("w:rFonts", "w" => @ns)
            return nil unless rFonts
            %w[ascii hAnsi cs eastAsia asciiTheme hAnsiTheme
               cstheme eastAsiaTheme].each_with_object({}) do |a, h|
              v = rFonts["w:#{a}"]
              h[a] = v if v
            end.yield_self { |h| h.empty? ? nil : h }
          end

          def read_lang_attr(attr)
            lang = @node.at_xpath("w:lang", "w" => @ns)
            lang&.[]("w:#{attr}")
          end
        end

        # Parses <w:numbering> into NumberingDefinition instances.
        class NumberingParser
          def initialize(xml)
            @xml = xml
            @ns = TemplateExtractor::W_NS
          end

          def parse
            abstracts = parse_abstract + parse_nums
            abstracts
          end

          private

          def parse_abstract
            @xml.xpath("//w:abstractNum", "w" => @ns).map do |a|
              NumberingDefinition.new(
                kind: "abstractNum",
                id: a["w:abstractNumId"],
                levels: parse_levels(a)
              )
            end
          end

          def parse_nums
            @xml.xpath("//w:num", "w" => @ns).map do |n|
              abstract_id = n.at_xpath("w:abstractNumId", "w" => @ns)&.[]("w:val")
              style_link  = n.at_xpath("w:styleLink", "w" => @ns)&.[]("w:val")
              NumberingDefinition.new(
                kind: "num",
                id: n["w:numId"],
                abstract_num_id: abstract_id,
                num_style_link: style_link
              )
            end
          end

          def parse_levels(abstract)
            abstract.xpath("w:lvl", "w" => @ns).map do |lvl|
              {
                "ilvl" => lvl["w:ilvl"],
                "start" => lvl.at_xpath("w:start", "w" => @ns)&.[]("w:val"),
                "format" => lvl.at_xpath("w:numFmt", "w" => @ns)&.[]("w:val"),
                "text" => lvl.at_xpath("w:lvlText", "w" => @ns)&.[]("w:val"),
                "alignment" => lvl.at_xpath("w:lvlJc", "w" => @ns)&.[]("w:val"),
                "paragraph_properties" => lvl_pPr(lvl)
              }.compact
            end
          end

          def lvl_pPr(lvl)
            pPr = lvl.at_xpath("w:pPr", "w" => @ns)
            return nil unless pPr
            ParagraphPropertiesReader.new(pPr).read
          end
        end

        # Parses <w:docDefaults> from styles.xml.
        class DocDefaultsParser
          def initialize(xml)
            @xml = xml
            @ns = TemplateExtractor::W_NS
          end

          def parse
            dd = @xml.at_xpath("//w:docDefaults", "w" => @ns)
            return Struct.new(:run_properties, :paragraph_properties,
                              keyword_init: true).new.to_h unless dd

            rPr = read_rPr(dd)
            pPr = read_pPr(dd)
            Struct.new(:run_properties, :paragraph_properties,
                       keyword_init: true).new(
                         run_properties: rPr,
                         paragraph_properties: pPr
                       ).to_h.compact
          end

          private

          def read_rPr(dd)
            node = dd.at_xpath("w:rPrDefault/w:rPr", "w" => @ns)
            return nil unless node
            RunPropertiesReader.new(node).read
          end

          def read_pPr(dd)
            node = dd.at_xpath("w:pPrDefault/w:pPr", "w" => @ns)
            return nil unless node
            ParagraphPropertiesReader.new(node).read
          end
        end
      end
    end
  end
end
