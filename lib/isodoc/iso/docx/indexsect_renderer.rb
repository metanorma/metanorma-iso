# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      # Renders the index section (indexsect) — title via IndexHead style
      # plus mixed-content children routed through the walker.
      class IndexsectRenderer
        def initialize(resolver:, inline_renderer:, walker:)
          @resolver = resolver
          @inline_renderer = inline_renderer
          @walker = walker
        end

        def render(section, doc)
          render_title(section, doc)
          @walker.walk(section, doc)
        end

        private

        def render_title(section, doc)
          return unless section.class.attributes.key?(:title)

          titles = Array(section.title)
          return if titles.empty?

          para = Uniword::Builder::ParagraphBuilder.new
          para.style = @resolver.paragraph_style(:index)
          @inline_renderer.render_heading(titles.first, para)
          doc << para
        end
      end
    end
  end
end
