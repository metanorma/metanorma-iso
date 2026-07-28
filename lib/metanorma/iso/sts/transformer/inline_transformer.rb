# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      class Transformer::InlineTransformer < Transformer::Base
        include Transformer::ContentText

        def transform_inline(node)
          case node
          when String
            [:content, node]
          when Metanorma::Document::Components::Inline::EmRawElement
            [:italic, transform_italic(node)]
          when Metanorma::Document::Components::Inline::StrongRawElement
            [:bold, transform_bold(node)]
          when Metanorma::Document::Components::Inline::SubElement
            [:sub, transform_sub(node)]
          when Metanorma::Document::Components::Inline::SupElement
            [:sup, transform_sup(node)]
          when Metanorma::Document::Components::Inline::TtElement
            [:monospace, transform_monospace(node)]
          when Metanorma::Document::Components::Inline::SmallCapElement
            [:sc, transform_smallcap(node)]
          when Metanorma::Document::Components::Inline::XrefElement
            [:xref, transform_xref(node)]
          when Metanorma::Document::Components::Inline::ErefElement
            [:std, transform_eref(node)]
          when Metanorma::Document::Components::Inline::FnElement
            [:xref, transform_fn(node)]
          when Metanorma::Document::Components::Inline::LinkElement
            [:ext_link, transform_link(node)]
          when Metanorma::Document::Components::Inline::BrElement
            [:break, transform_br(node)]
          when Metanorma::Document::Components::Inline::StemInlineElement
            [:inline_formula, transform_stem(node)]
          when Metanorma::Document::Components::Inline::ConceptElement
            nil
          when Metanorma::Document::Components::Inline::SpanElement
            [:styled_content, transform_span(node)]
          when Metanorma::Document::Components::Inline::Bcp14Element
            [:bold, transform_bcp14(node)]
          end
        end

        # SINGLE SOURCE OF TRUTH for sts-ruby text-attribute names.
        #
        # NISO STS v1.2 models don't agree on a single text attr name:
        # NisoSts models use :text, every TbxIsoTml model uses :value.
        # This hash is the one place in this repo that knows which name
        # each class uses. If sts-ruby renames one (e.g. the recent Fn
        # :p → :paragraph in PR #47), update this hash and only this hash.
        #
        # Do NOT extract into a separate Appender module yet — there is
        # only one caller today (this class). Extract when a second
        # caller materialises; until then the lookup belongs here.
        TEXT_ATTR_FOR = {
          ::Sts::NisoSts::Paragraph => :text,
          ::Sts::NisoSts::MixedCitation => :text,
          ::Sts::NisoSts::ElementCitation => :text,
          ::Sts::NisoSts::Fn => :text,
          ::Sts::TbxIsoTml::Bold => :value,
          ::Sts::TbxIsoTml::Italic => :value,
          ::Sts::TbxIsoTml::Xref => :value,
          ::Sts::TbxIsoTml::Definition => :value,
          ::Sts::TbxIsoTml::Note => :value,
          ::Sts::TbxIsoTml::Example => :value,
          ::Sts::TbxIsoTml::Source => :value,
          ::Sts::TbxIsoTml::Term => :value,
        }.freeze

        def apply_inline_content(source, target)
          source.each_mixed_content do |node|
            result = transform_inline(node)
            next unless result

            type, value = result
            if type == :content
              text_attr = TEXT_ATTR_FOR[target.class] || :content
              target.public_send(text_attr, value)
            else
              target.public_send(type, value)
            end
          end
          target
        end

        def apply_term_inline_content(source, target)
          text = extract_text(source)
          text_attr = TEXT_ATTR_FOR[target.class] || :content
          target.public_send(text_attr, text) if text && !text.empty?
          target
        end

        private

        def transform_bold(node)
          ::Sts::TbxIsoTml::Bold.new do |b|
            apply_inline_content(node, b)
          end
        end

        def transform_italic(node)
          ::Sts::TbxIsoTml::Italic.new do |i|
            apply_inline_content(node, i)
          end
        end

        def transform_sub(node)
          ::Sts::NisoSts::Sub.new do |s|
            s.content node.content if node.content
          end
        end

        def transform_sup(node)
          ::Sts::NisoSts::Sup.new do |s|
            apply_inline_content(node, s)
          end
        end

        def transform_monospace(node)
          content = node.content || extract_text(node)
          ::Sts::NisoSts::Monospace.new do |m|
            m.content content if content
          end
        end

        def transform_smallcap(node)
          content = node.content || extract_text(node)
          ::Sts::NisoSts::Sc.new do |s|
            s.content content if content
          end
        end

        def transform_xref(node)
          rid = remap_id(node.target)
          xref = ::Sts::TbxIsoTml::Xref.new
          xref.rid = rid
          xref.ref_type = ref_type_for(node.target)
          text = extract_text(node)
          xref.value = text if text && !text.empty?
          xref
        end

        def transform_eref(node)
          node.bibitemid
          citeas = node.citeas

          std = ::Sts::NisoSts::ReferenceStandard.new
          std.std_id = citeas
          std.type = "dated"

          std_ref = ::Sts::NisoSts::StandardRef.new
          ref_text = citeas.to_s
          if node.locality_stack && !node.locality_stack.empty?
            localities = node.locality_stack.map do |ls|
              Array(ls.bib_locality).map do |loc|
                if loc.reference_from
                  "#{loc.type} #{loc.reference_from}"
                else
                  loc.type.to_s
                end
              end
            end.flatten.join(", ")
            ref_text = "#{ref_text}, #{localities}" unless localities.empty?
          end
          std_ref.value = ref_text
          std.std_ref std_ref
          std
        end

        def transform_fn(node)
          text = extract_fn_text(node)
          fn_paragraphs = build_fn_paragraphs(node)
          entry = @context.footnote_collector.register(text,
                                                       paragraphs: fn_paragraphs)

          xref = ::Sts::TbxIsoTml::Xref.new
          xref.rid = entry[:id]
          xref.ref_type = "fn"
          xref.value = "<sup>#{entry[:number]})</sup>"
          xref
        end

        def build_fn_paragraphs(node)
          paras = []
          return paras unless node.p && !node.p.empty?

          node.p.each do |para|
            fn_para = ::Sts::NisoSts::Paragraph.new
            apply_inline_content(para, fn_para)
            paras << fn_para
          end
          paras
        end

        def extract_fn_text(node)
          parts = []
          if node.p && !node.p.empty?
            node.p.each do |para|
              text = extract_text(para)
              parts << text if text && !text.empty?
            end
          end
          parts.join(" ")
        end

        def transform_link(node)
          link = ::Sts::NisoSts::ExtLink.new
          link.href = node.target if node.target
          text = extract_text(node)
          link.content = [text] if text && !text.empty?
          link
        end

        def transform_br(_node)
          ::Sts::NisoSts::Break.new
        end

        def transform_stem(node)
          formula = ::Sts::NisoSts::InlineFormula.new
          if node.class.method_defined?(:math) && node.math
            formula.math = node.math
          end
          formula
        end

        def transform_span(node)
          styled = ::Sts::NisoSts::StyledContent.new
          styled.style_type = node.style if node.style
          apply_inline_content(node, styled)
          styled
        end

        def transform_bcp14(node)
          content = extract_text(node)
          ::Sts::TbxIsoTml::Bold.new do |b|
            b.content content if content
          end
        end

        def ref_type_for(target)
          return "sec" unless target

          case target
          when /^term_/
            "term-sec"
          when /^tab_/
            "table"
          when /^fig_/
            "fig"
          when /^formula_/
            "disp-formula"
          when /^fn_/
            "fn"
          when /^biblref_/, /^sec_bibl/
            "bibr"
          when /^app_/, /^sec_[A-Z]/
            "app"
          else
            "sec"
          end
        end
      end
    end
  end
end
