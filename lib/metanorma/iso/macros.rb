module Metanorma
  module ISO
    class EditorAdmonitionBlock < Asciidoctor::Extensions::BlockProcessor
      use_dsl
      named :EDITOR
      on_contexts :example, :paragraph

      def process(parent, reader, attrs)
        attrs["name"] = "editorial"
        attrs["caption"] = "EDITOR"
        create_block(parent, :admonition, reader.lines, attrs,
                     content_model: :compound)
      end
    end

    class EditorInlineAdmonitionBlock < Asciidoctor::Extensions::Treeprocessor
      def process(document)
        (document.find_by context: :paragraph).each do |para|
          next unless /^EDITOR: /.match? para.lines[0]

          parent = para.parent
          para.set_attr("name", "editorial")
          para.set_attr("caption", "EDITOR")
          para.lines[0].sub!(/^EDITOR: /, "")
          todo = Asciidoctor::Block
            .new(parent, :admonition, attributes: para.attributes,
                                      source: para.lines,
                                      content_model: :compound)
          parent.blocks[parent.blocks.index(para)] = todo
        end
      end
    end
  end
end
