# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      # Renders the preface: foreword, introduction, and preface clauses.
      #
      # Era C layout:
      #   - Foreword title with `foreword` paragraph style, wrapped in
      #     Context#with_foreword so child paragraphs pick up the zone
      #   - Introduction title with `introduction` style, wrapped in
      #     Context#with_introduction
      #   - Preface clauses routed through the dispatcher; clauses whose
      #     type is "toc" are skipped (TocBuilder owns them)
      #
      # Extracted from Adapter so Adapter stays a thin orchestrator.
      class PrefaceRenderer
        TOC_CLAUSE_TYPE = "toc"
        private_constant :TOC_CLAUSE_TYPE

        def initialize(resolver:, context:, inline_renderer:, walker:)
          @resolver = resolver
          @context = context
          @inline_renderer = inline_renderer
          @walker = walker
        end

        def render(preface, doc)
          render_foreword(preface, doc)
          render_introduction(preface, doc)
          render_preface_clauses(preface, doc)
        end

        private

        def render_foreword(preface, doc)
          return unless preface.class.attributes.key?(:foreword)
          foreword = preface.foreword
          return unless foreword

          @context.with_foreword do
            render_titled_section(foreword, doc, :foreword)
            doc.page_break if has_content_after_foreword?(preface)
          end
        end

        def render_introduction(preface, doc)
          return unless preface.class.attributes.key?(:introduction)
          intro = preface.introduction
          return unless intro

          @context.with_introduction do
            render_titled_section(intro, doc, :introduction)
          end
        end

        def render_preface_clauses(preface, doc)
          return unless preface.class.attributes.key?(:clause)

          Array(preface.clause).each do |clause|
            next if toc_clause?(clause)

            @walker.walk(clause, doc)
          end
        end

        def render_titled_section(section, doc, style_key)
          title = section.fmt_title || section.title
          if title
            para = Uniword::Builder::ParagraphBuilder.new
            para.style = @resolver.paragraph_style(style_key)
            @inline_renderer.render(title, para)
            doc << para
          end
          @walker.walk(section, doc)
        end

        def toc_clause?(clause)
          return false unless clause.class.attributes.key?(:type)

          clause.type == TOC_CLAUSE_TYPE
        end

        def has_content_after_foreword?(preface)
          return true if preface.class.attributes.key?(:introduction) && preface.introduction

          preface.class.attributes.key?(:clause) && Array(preface.clause).any?
        end
      end
    end
  end
end
