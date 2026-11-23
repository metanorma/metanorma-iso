# frozen_string_literal: true

# Semantic-only fixture built through the real ISO/Document SDK. No fmt-* input.
module NativeIsoFixture
  def inline
    Metanorma::Document::Components::Inline
  end

  def ordered(node, *names)
    node.element_order = names.map do |name|
      name.is_a?(Array) ? Lutaml::Xml::Element.new("Text", "text", text_content: name.first) :
        Lutaml::Xml::Element.new("Element", name)
    end
    node
  end

  def native_iso_fixture
    sections = Metanorma::Iso::Document::Sections
    paragraph_class = Metanorma::Document::Components::Paragraphs::ParagraphBlock
    title = ordered(inline::TitleWithAnnotationElement.new(text: ["A ", " title"],
                      em: [inline::EmRawElement.new(text: ["rich"]) ]), ["A "], "em", [" title"])
    xref = inline::XrefElement.new(target: "method")
    authored = inline::XrefElement.new(target: "method", text: ["the procedure"])
    paragraph = ordered(paragraph_class.new(text: ["See ", " or ", "."],
                          xref: [xref, authored]), ["See "], "xref", [" or "], "xref", ["."])
    lead = sections::IsoClauseSection.new(id: "scope", title: title, paragraphs: [paragraph])
    ordered(lead, "title", "p")
    body = sections::IsoClauseSection.new(id: "method", title: inline::TitleWithAnnotationElement.new(text: ["Method"]),
               paragraphs: [paragraph_class.new(text: ["Retained body."])])
    ordered(body, "title", "p")
    container = ordered(sections::IsoSections.new(clause: [lead, body]), "clause", "clause")
    metadata = Metanorma::Iso::Document::Metadata
    bib = metadata::IsoBibliographicItem.new(language: [metadata::LanguageElement.new(value: ["en"])])
    Metanorma::Iso::Document::Root.new(type: "semantic", flavor: "iso", bibdata: bib, sections: container)
  end

  def native_labeler(profile: Metanorma::Ladl::Profile.iso_iec)
    lambda do |root, flavor:, options:|
      raise ArgumentError, flavor unless flavor == :iso

      engine = Metanorma::Ladl::Engine.new(profile: profile)
      engine.call(root, adapter: Metanorma::Ladl::DocumentAdapter.new(mode: :presentation))
    end
  end
end
