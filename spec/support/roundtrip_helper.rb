# frozen_string_literal: true

require "nokogiri"

module RoundtripHelper
  FIXTURES_DIR = File.expand_path("../fixtures", __dir__)

  # Discover all non-collection XML fixtures for a flavor directory.
  # Returns Array<Hash> with :name, :path, :flavor_dir, :xml_type keys.
  def self.discover_fixtures(flavor_dir: nil)
    base = File.join(FIXTURES_DIR, flavor_dir)
    Dir[File.join(base, "**", "*.xml")].filter_map do |path|
      next if path.include?("/collection/")
      next if collection_xml?(path)

      name = build_name(path)
      xml_type = path.end_with?(".presentation.xml") ? "presentation" : "semantic"

      { name: name, path: path, flavor_dir: flavor_dir, xml_type: xml_type }
    end
  end

  # Discover collection XML fixtures.
  # Returns Array<Hash> with :name, :path, :xml_type keys.
  def self.discover_collections(flavor_dir: nil)
    base = File.join(FIXTURES_DIR, flavor_dir)
    Dir[File.join(base, "collection", "collection*.xml")].map do |path|
      name = File.basename(path, ".xml")
      xml_type = path.end_with?(".presentation.xml") ? "presentation" : "semantic"

      { name: name, path: path, xml_type: xml_type }
    end
  end

  # Parse XML with Nokogiri, strip namespaces for consistent CSS selectors.
  def self.parse_xml(xml_string)
    doc = Nokogiri::XML(xml_string, &:noblanks)
    doc.remove_namespaces!
    doc
  end

  # Check for ERROR-level parse errors.
  def self.xml_has_errors?(xml_string)
    doc = Nokogiri::XML(xml_string)
    doc.errors.any? { |e| e.type == Nokogiri::XML::SyntaxError::ERROR }
  end

  # Extract root element attributes as a hash.
  def self.root_attrs(doc)
    root = doc.root
    return {} unless root

    { name: root.name, type: root["type"], flavor: root["flavor"],
      version: root["version"] }
  end

  # Extract bibdata type attribute.
  def self.bibdata_type(doc)
    bibdata = doc.at_css("bibdata")
    bibdata ? bibdata["type"] : nil
  end

  # Extract title elements as [language, type, text] triples.
  def self.bibdata_titles(doc)
    doc.css("bibdata > title").map do |t|
      [t["language"], t["type"], t.text.strip]
    end
  end

  # Extract status stage text.
  def self.status_stage(doc)
    doc.at_css("bibdata > status stage")&.text&.strip
  end

  # Extract top-level section clause IDs (sorted).
  def self.section_clause_ids(doc)
    doc.css("sections > clause").filter_map { |c| c["id"] }.sort
  end

  # Check if preface element exists.
  def self.has_preface?(doc)
    !doc.at_css("preface").nil?
  end

  # Extract annex IDs (sorted).
  def self.annex_ids(doc)
    doc.css("annex").filter_map { |a| a["id"] }.sort
  end

  # Count bibliography references sections.
  def self.bibliography_references_count(doc)
    doc.css("bibliography > references").length
  end

  # Extract bibliography normative attributes in order.
  def self.bibliography_normative_attrs(doc)
    doc.css("bibliography > references").map { |r| r["normative"] }
  end

  # Extract term IDs (sorted).
  def self.term_ids(doc)
    doc.css("term").filter_map { |t| t["id"] }.sort
  end

  # Extract table IDs (sorted).
  def self.table_ids(doc)
    doc.css("table").filter_map { |t| t["id"] }.sort
  end

  # Extract figure IDs (sorted).
  def self.figure_ids(doc)
    doc.css("figure").filter_map { |f| f["id"] }.sort
  end

  # Extract formula IDs (sorted).
  def self.formula_ids(doc)
    doc.css("formula").filter_map { |f| f["id"] }.sort
  end

  # Extract nested clause IDs — 2 levels deep (sorted).
  def self.nested_clause_ids(doc)
    doc.css("sections clause clause").filter_map { |c| c["id"] }.sort
  end

  # Count inline-header attributes.
  def self.inline_header_count(doc)
    doc.css("[inline-header]").length
  end

  # Collection-specific: count directive elements.
  def self.collection_directive_count(doc)
    doc.css("directive").length
  end

  # Collection-specific: count entry elements.
  def self.collection_entry_count(doc)
    doc.css("entry").length
  end

  # Collection-specific: count doc-container elements.
  def self.doc_container_count(doc)
    doc.css("doc-container").length
  end

  # Collection-specific: extract doc-container IDs.
  def self.doc_container_ids(doc)
    doc.css("doc-container").filter_map { |d| d["id"] }.sort
  end

  # Collection-specific: extract primary docidentifiers from embedded docs.
  def self.doc_container_docidentifiers(doc)
    doc.css("doc-container bibdata > docidentifier[primary]").map do |d|
      d.text.strip
    end.sort
  end

  class << self
    private

    def build_name(path)
      rel = path.sub("#{FIXTURES_DIR}/", "")
      rel.sub(/\.xml$/, "")
    end

    def collection_xml?(path)
      content = File.read(path, 200)
      content.include?("<metanorma-collection")
    end
  end
end
