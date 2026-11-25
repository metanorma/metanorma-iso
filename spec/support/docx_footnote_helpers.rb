# frozen_string_literal: true

module DocxFootnoteHelpers
  def fn(target:, text:)
    Metanorma::Document::Components::Inline::FnElement.new(
      target: target,
      p: [
        Metanorma::Document::Components::Paragraphs::ParagraphBlock.new(
          text: text,
        ),
      ],
    )
  end

  def fn_with_stem(target:)
    Metanorma::Document::Components::Inline::FnElement.from_xml(<<~XML)
      <fn reference="1" target="#{target}"><p id="p1">The time <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><msub><mi>t</mi><mn>90</mn></msub></math><asciimath>t_90</asciimath></stem> was estimated to be 18,2 min.</p></fn>
    XML
  end

  def labelled_xml(label_delim)
    minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1"><title>Scope</title>
          <p id="p1">Body text<fn id="f1" reference="1"><p id="fp">Footnote body.</p><fmt-fn-label><span class="fmt-caption-label"><sup><semx element="autonum">1</semx>#{label_delim}</sup></span></fmt-fn-label></fn> more.</p>
        </clause>
      </sections>
    INNER
  end

  def convert_parts(xml)
    Dir.mktmpdir do |dir|
      path = File.join(dir, "output.docx")
      adapter.convert(xml, path)
      yield docx_entry_xml(path, "word/document.xml"), docx_entry_xml(path, "word/footnotes.xml")
    end
  end

  def docx_entry_xml(path, entry_name)
    Zip::File.open(path) do |zip|
      Nokogiri::XML(zip.find_entry(entry_name).get_input_stream.read)
    end
  end

  def body_footnote(footnotes)
    footnotes.xpath("//w:footnote[not(@w:type)]", ns).first
  end
end
