#!/usr/bin/env ruby
# frozen_string_literal: true

# Extract all style definitions from ISO DIS template to YAML using Uniword.
#
# Usage: cd metanorma-iso && bundle exec ruby data/iso-dis/extract_styles.rb
#
# Produces:
#   data/iso-dis/styles.yml       - All paragraph + character style definitions
#   data/iso-dis/numbering.yml    - Numbering definitions (abstractNum + num)
#   data/iso-dis/doc_defaults.yml - Document defaults (rPrDefault, pPrDefault)

require "uniword"
require "nokogiri"
require "yaml"

W_NS = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"

def w_attr(el, name)
  el["w:#{name}"]
end

# Convert OOXML half-points to pt
def half_points_to_pt(val)
  return nil unless val
  (val.to_i / 2.0).to_s
end

# Convert twips to pt
def twips_to_pt(val)
  return nil unless val
  (val.to_i / 20.0).to_s
end

# Convert twips to cm
def twips_to_cm(val)
  return nil unless val
  (val.to_i / 567.0).round(2).to_s
end

# ─── Parse run properties ─────────────────────────────────────────────
def parse_rpr(rpr_element)
  return nil unless rpr_element

  result = {}

  rpr_element.element_children.each do |el|
    local = el.name
    case local
    when "rFonts"
      fonts = {}
      %w[ascii hAnsi cs eastAsia].each do |f|
        v = w_attr(el, f)
        fonts[f] = v if v
      end
      %w[asciiTheme hAnsiTheme csTheme eastAsiaTheme].each do |f|
        v = w_attr(el, f)
        fonts[f] = v if v
      end
      result[:fonts] = fonts unless fonts.empty?
    when "sz"
      result[:font_size] = half_points_to_pt(w_attr(el, "val"))
    when "szCs"
      result[:font_size_cs] = half_points_to_pt(w_attr(el, "val"))
    when "color"
      v = w_attr(el, "val")
      result[:color] = v if v
      tc = w_attr(el, "themeColor")
      result[:theme_color] = tc if tc
      ts = w_attr(el, "themeTint")
      result[:theme_tint] = ts if ts
      tsh = w_attr(el, "themeShade")
      result[:theme_shade] = tsh if tsh
    when "b"
      result[:bold] = w_attr(el, "val") != "0"
    when "bCs"
      result[:bold_cs] = w_attr(el, "val") != "0"
    when "i"
      result[:italic] = w_attr(el, "val") != "0"
    when "iCs"
      result[:italic_cs] = w_attr(el, "val") != "0"
    when "u"
      result[:underline] = w_attr(el, "val") || "single"
    when "strike"
      result[:strikethrough] = w_attr(el, "val") != "false"
    when "dstrike"
      result[:double_strikethrough] = w_attr(el, "val") != "false"
    when "vanish"
      result[:hidden] = true
    when "smallCaps"
      result[:small_caps] = w_attr(el, "val") != "0"
    when "caps"
      result[:all_caps] = w_attr(el, "val") != "0"
    when "vertAlign"
      result[:vertical_alignment] = w_attr(el, "val")
    when "highlight"
      result[:highlight] = w_attr(el, "val")
    when "shd"
      result[:shading_fill] = w_attr(el, "fill")
      result[:shading_color] = w_attr(el, "color")
      result[:shading_type] = w_attr(el, "val")
    when "lang"
      %w[val eastAsia bidi].each do |a|
        v = w_attr(el, a)
        result[:"lang_#{a.downcase}"] = v if v
      end
    when "spacing"
      v = w_attr(el, "val")
      result[:character_spacing] = half_points_to_pt(v) if v
    when "kern"
      result[:kern] = w_attr(el, "val")
    when "position"
      result[:position] = half_points_to_pt(w_attr(el, "val"))
    end
  end

  result.empty? ? nil : result
end

# ─── Parse paragraph properties ────────────────────────────────────────
def parse_ppr(ppr_element)
  return nil unless ppr_element

  result = {}

  ppr_element.element_children.each do |el|
    local = el.name
    case local
    when "keepNext"
      result[:keep_next] = true
    when "keepLines"
      result[:keep_lines] = true
    when "pageBreakBefore"
      result[:page_break_before] = true
    when "widowControl"
      result[:widow_control] = w_attr(el, "val") != "false"
    when "jc"
      result[:alignment] = w_attr(el, "val")
    when "outlineLvl"
      result[:outline_level] = w_attr(el, "val")
    when "spacing"
      spacing = {}
      %w[before after line].each do |a|
        v = w_attr(el, a)
        spacing[a.to_sym] = twips_to_pt(v) if v
      end
      lr = w_attr(el, "lineRule")
      spacing[:line_rule] = lr if lr
      result[:spacing] = spacing unless spacing.empty?
    when "ind"
      indent = {}
      %w[left right firstLine hanging].each do |a|
        v = w_attr(el, a)
        indent[a.to_sym] = twips_to_cm(v) if v
      end
      result[:indent] = indent unless indent.empty?
    when "tabs"
      tabs = []
      el.element_children.each do |tab|
        tabs << {
          type: w_attr(tab, "val"),
          position: twips_to_cm(w_attr(tab, "pos")),
        }.compact
      end
      result[:tabs] = tabs unless tabs.empty?
    when "shd"
      result[:shading] = {
        fill: w_attr(el, "fill"),
        color: w_attr(el, "color"),
        type: w_attr(el, "val"),
      }.compact
    when "numPr"
      num = {}
      el.element_children.each do |n|
        if n.name == "numId"
          num[:num_id] = w_attr(n, "val")
        elsif n.name == "ilvl"
          num[:ilvl] = w_attr(n, "val")
        end
      end
      result[:numbering] = num unless num.empty?
    when "pBdr"
      borders = []
      el.element_children.each do |b|
        borders << {
          type: b.name,
          val: w_attr(b, "val"),
          sz: w_attr(b, "sz"),
          space: w_attr(b, "space"),
          color: w_attr(b, "color"),
        }.compact
      end
      result[:borders] = borders unless borders.empty?
    end
  end

  result.empty? ? nil : result
end

# ─── Parse a single style from XML ─────────────────────────────────────
def parse_style_from_xml(xml_string)
  doc = Nokogiri::XML(xml_string)
  style_el = doc.root

  result = {
    id: w_attr(style_el, "styleId"),
    type: w_attr(style_el, "type"),
  }

  style_el.element_children.each do |el|
    local = el.name
    case local
    when "name"
      result[:name] = w_attr(el, "val")
    when "basedOn"
      result[:based_on] = w_attr(el, "val")
    when "next"
      result[:next_style] = w_attr(el, "val")
    when "link"
      result[:linked_style] = w_attr(el, "val")
    when "uiPriority"
      result[:ui_priority] = w_attr(el, "val")
    when "qFormat"
      result[:quick_format] = true
    when "semiHidden"
      result[:semi_hidden] = true
    when "unhideWhenUsed"
      result[:unhide_when_used] = true
    when "pPr"
      ppr = parse_ppr(el)
      result[:paragraph_properties] = ppr if ppr
    when "rPr"
      rpr = parse_rpr(el)
      result[:run_properties] = rpr if rpr
    end
  end

  result
end

# ─── Parse numbering definition from XML ───────────────────────────────
def parse_numbering_from_xml(xml_string)
  doc = Nokogiri::XML(xml_string)
  root = doc.root

  levels = []
  root.element_children.select { |e| e.name == "lvl" }.each do |lvl_el|
    level = { ilvl: w_attr(lvl_el, "ilvl") }

    lvl_el.element_children.each do |el|
      case el.name
      when "start"
        level[:start] = w_attr(el, "val")
      when "numFmt"
        level[:format] = w_attr(el, "val")
      when "lvlText"
        level[:text] = w_attr(el, "val")
      when "lvlJc"
        level[:alignment] = w_attr(el, "val")
      when "pPr"
        ppr = parse_ppr(el)
        level[:paragraph_properties] = ppr if ppr
      when "rPr"
        rpr = parse_rpr(el)
        level[:run_properties] = rpr if rpr
      end
    end

    levels << level
  end

  mlt = root.element_children.find { |e| e.name == "multiLevelType" }
  {
    abstract_num_id: w_attr(root, "abstractNumId"),
    type: mlt ? w_attr(mlt, "val") : "singleLevel",
    levels: levels,
  }
end

# ─── Main extraction ──────────────────────────────────────────────────
puts "Loading DIS template..."
document = Uniword::DocumentFactory.from_file("data/iso-dis/template.docx")
sc = document.styles_configuration

template_name = ENV["TEMPLATE"] || "dis"
template_file = template_name == "simple" ? "data/iso-simple/template.dotx" : "data/iso-dis/template.docx"
output_dir = template_name == "simple" ? "data/iso-simple" : "data/iso-dis"
template_label = template_name == "simple" ? "ISO Simple Template" : "ISO DIS Template"
template_desc = template_name == "simple" ? "ISO Simple template styles" : "ISO DIS/FDIS template styles extracted from ISO 6709 ed.3"

puts "Loading #{template_label} from #{template_file}..."
document = Uniword::DocumentFactory.from_file(template_file)
sc = document.styles_configuration

# Extract all styles
puts "Extracting #{sc.count} styles..."
all_styles = []
sc.styles.each do |style|
  xml = Uniword::Wordprocessingml::Style.to_xml(style)
  parsed = parse_style_from_xml(xml)
  all_styles << parsed
end

# Separate by type
para_styles = all_styles.select { |s| s[:type] == "paragraph" }
char_styles = all_styles.select { |s| s[:type] == "character" }
table_styles = all_styles.select { |s| s[:type] == "table" }
num_styles = all_styles.select { |s| s[:type] == "numbering" }

puts "  Paragraph: #{para_styles.size}"
puts "  Character: #{char_styles.size}"
puts "  Table: #{table_styles.size}"
puts "  Numbering: #{num_styles.size}"

# Convert symbol keys to string keys for clean YAML
def stringify_keys(obj)
  case obj
  when Hash
    obj.transform_keys(&:to_s).transform_values { |v| stringify_keys(v) }
  when Array
    obj.map { |v| stringify_keys(v) }
  else
    obj
  end
end

# Write styles.yml
styles_data = {
  "style_library" => {
    "name" => template_label,
    "version" => "1.0",
    "description" => template_desc,
    "paragraph_styles" => para_styles.map { |s| [s[:id], stringify_keys(s)] }.to_h,
    "character_styles" => char_styles.map { |s| [s[:id], stringify_keys(s)] }.to_h,
  },
}

File.write("#{output_dir}/styles.yml", YAML.dump(styles_data, line_width: 120))
puts "Wrote #{output_dir}/styles.yml"

# Extract numbering
puts "\nExtracting numbering definitions..."
nc = document.numbering_configuration

definitions = []
nc.definitions.each do |defn|
  xml = Uniword::Wordprocessingml::NumberingDefinition.to_xml(defn)
  parsed = parse_numbering_from_xml(xml)
  definitions << parsed
end

instances = []
nc.instances.each do |inst|
  xml = Uniword::Wordprocessingml::NumberingInstance.to_xml(inst)
  doc = Nokogiri::XML(xml)
  root = doc.root
  inst_data = {
    num_id: w_attr(root, "numId"),
  }
  abstract_ref = root.element_children.find { |e| e.name == "abstractNumId" }
  inst_data[:abstract_num_id] = w_attr(abstract_ref, "val") if abstract_ref
  instances << inst_data
end

numbering_data = {
  "definitions" => stringify_keys(definitions),
  "instances" => stringify_keys(instances),
}

File.write("#{output_dir}/numbering.yml", YAML.dump(numbering_data, line_width: 120))
puts "Wrote #{output_dir}/numbering.yml"

# Extract doc defaults
puts "\nExtracting document defaults..."
dd = sc.doc_defaults
doc_defaults = {}
if dd
  rpd = dd.rPrDefault
  if rpd && rpd.rPr
    rpr_xml = Uniword::Wordprocessingml::RunProperties.to_xml(rpd.rPr)
    rpr_doc = Nokogiri::XML(rpr_xml)
    rpr = parse_rpr(rpr_doc.root)
    doc_defaults["run_properties"] = rpr if rpr
  end

  ppd = dd.pPrDefault
  if ppd && ppd.pPr
    ppr_xml = Uniword::Wordprocessingml::ParagraphProperties.to_xml(ppd.pPr)
    ppr_doc = Nokogiri::XML(ppr_xml)
    ppr = parse_ppr(ppr_doc.root)
    doc_defaults["paragraph_properties"] = ppr if ppr
  end
end

File.write("#{output_dir}/doc_defaults.yml", YAML.dump(stringify_keys(doc_defaults), line_width: 120))
puts "Wrote #{output_dir}/doc_defaults.yml"

puts "\nDone!"
