# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      module Transformer
        class SectionTransformer < Base
          def transform(source_clause)
            title_text = extract_title(source_clause)
            id_val = id_for_section(source_clause)
            content = content_of(source_clause)
            autonum = extract_autonum(source_clause)

            # Built through the block form so lutaml-model's order
            # tracking records setter-call order — the document order of
            # the annex/clause body (the App hash-init form would emit in
            # mapping-declaration order instead).
            ::Sts::NisoSts::Section.new do |sec|
              sec.id = id_val if id_val
              sec.label = ::Sts::NisoSts::Label.new(content: [autonum]) if autonum
              sec.title = ::Sts::NisoSts::Title.new(content: [title_text]) if title_text && !title_text.empty?
              sec_type = section_type(source_clause)
              sec.type = sec_type if sec_type
              append_section_content(sec, content)
            end
          end

          # Appends the section's ordered content onto the target model
          # (a Section here, the App for annex bodies via BackTransformer).
          def append_section_content(target, content)
            content.each do |item|
              case item
              when ::Sts::NisoSts::Paragraph then target.paragraphs item
              when ::Sts::NisoSts::List then target.list item
              when ::Sts::NisoSts::Figure then target.fig item
              when ::Sts::TbxIsoTml::TableWrap then target.table_wrap item
              when ::Sts::NisoSts::NonNormativeNote then target.non_normative_note item
              when ::Sts::NisoSts::NonNormativeExample then target.non_normative_example item
              when ::Sts::NisoSts::DisplayFormula then target.disp_formula item
              when ::Sts::NisoSts::DefList then target.def_list item
              when ::Sts::NisoSts::Preformat then target.preformat item
              when ::Sts::NisoSts::TermSection then target.term_sec item
              when ::Sts::NisoSts::Section then target.sec item
              end
            end
          end

          # Ordered block content of a section: dispatched blocks, nested
          # clauses, and term entries. Shared with BackTransformer so the
          # annex body lands in the <app> in the same order.
          def content_of(source_clause)
            content = []
            attrs = BlockDispatcher::TYPED_ATTR_DISPATCH.keys + NESTED_ATTRS

            SourceOrder.entries(source_clause, attrs).each do |attr, item|
              case attr
              when :clause then append(content, transform(item))
              when :term then append(content, term_transformer.transform(item))
              when :terms then append(content, transform_terms_section(item))
              else dispatcher.dispatch_block(attr, item, content)
              end
            end

            content
          end

          # Nested clauses (IsoClauseSection and IsoAnnexSection — annex
          # subsections), a top-level <terms>' own term entries, and a
          # clause's nested terms sections. Each nested terms-section
          # (e.g. "3.1 General definitions") is preserved as its own Sec
          # so its heading renders for parity.
          NESTED_ATTRS = %i[clause term terms].freeze

          def append(content, item)
            content << item if item
          end
          private :append

          # Build a Sec for a nested terms-section (e.g. "3.1 General
          # definitions") that wraps its term entries. The wrapper's
          # title and autonum are emitted so the renderer produces the
          # "3.1 General definitions" heading that appears in MN HTML.
          # Terms sections carry sec-type="terms" (the NISO STS marker
          # mnconvert emits) and a claimed fallback id per section.
          def transform_terms_section(terms_section)
            title_text = extract_title(terms_section)
            autonum = extract_autonum(terms_section)
            terms_id = id_generator.id_for_terms(terms_section, autonum)

            nested = Array(terms_section.term).map { |term| term_transformer.transform(term) }.compact
            return nil unless title_text || autonum || nested.any?

            ::Sts::NisoSts::Section.new do |sec|
              sec.id = terms_id if terms_id
              sec.type = "terms"
              sec.label = ::Sts::NisoSts::Label.new(content: [autonum]) if autonum
              sec.title = ::Sts::NisoSts::Title.new(content: [title_text]) if title_text && !title_text.empty?
              nested.each { |ts| sec.term_sec ts }
            end
          end

          # Annexes renumber to sec_A/sec_B (…), terms sections to their
          # number or the claimed sec_terms fallback; plain clauses keep
          # their source id (identity-claimed so generated ids cannot
          # collide with it).
          def id_for_section(section)
            case section.class.name&.split("::")&.last
            when "IsoAnnexSection", "AnnexSection"
              id_generator.id_for_annex(section, extract_autonum(section))
            when "IsoTermsSection", "TermsSection"
              id_generator.id_for_terms(section, extract_autonum(section))
            else
              id_generator.id_for_clause(section)
            end
          end

          # Clause-type marker per Guidelines 4.2/4.4.2: scope, norm-refs,
          # intro and terms flag @sec-type; Foreword/introduction are front
          # secs (FrontTransformer).
          def section_type(clause)
            return "terms" if terms_section?(clause)

            t = clause.type
            marked = case t
                     when "scope" then "scope"
                     when "norm-ref", "norm-refs" then "norm-refs"
                     when "intro" then "intro"
                     end
            return marked if marked

            # Title fallback: the known clause titles flag @sec-type even
            # when the presentation clause carries no type attribute
            # (Guidelines 4.2).
            title = extract_title(clause).to_s
            case title
            when /\Ascope\z/i then "scope"
            when /\Anormative references\z/i then "norm-refs"
            when /\Aintroduction\z/i then "intro"
            when /\Aterms and definitions\z/i, /\Aterms, definitions/i then "terms"
            end
          end

          def terms_section?(section)
            %w[IsoTermsSection TermsSection].include?(section.class.name&.split("::")&.last)
          end

          # Section number from the presentation XML — delegates to the
          # shared extractor (single source of truth shared with the id
          # derivation).
          def extract_autonum(source_clause)
            RenderedTextExtractor.autonum_of(source_clause)
          end

          private

          def extract_title(source_clause)
            return nil unless source_clause.title
            title = source_clause.title
            return extract_with_stems(title) if title_is_mixed_with_stems?(title)
            RenderedTextExtractor.text_of(title)
          end

          # Title text where stem elements contribute their visible
          # AsciiMath tokens (e.g. "D_(\"min\")" → " D min ") so the
          # parity check sees content where it would otherwise see "()".
          # Source text from asciimath matches what Nokogiri's text
          # extraction produces from MN HTML after the document-level
          # normaliser lowercases both; case sensitivity is therefore
          # not an issue here, and we never parse MathML XML.
          def extract_with_stems(title)
            parts = collect_title_parts(title, [])
            parts.join.strip
          end

          def title_is_mixed_with_stems?(title)
            title.respond_to?(:each_mixed_content)
          end

          def collect_title_parts(node, parts)
            return parts unless node.is_a?(Lutaml::Model::Serializable)
            return parts unless node.respond_to?(:each_mixed_content)

            node.each_mixed_content do |child|
              if child.is_a?(String)
                parts << child
              elsif stem_node?(child)
                parts << stem_visible_text(child)
              elsif xref_node?(child)
                parts << xref_visible_text(child)
              elsif child.is_a?(Lutaml::Model::Serializable)
                collect_title_parts(child, parts)
              end
            end
            parts
          end

          STEM_NODE_CLASSES = [
            "Metanorma::Document::Components::Inline::StemInlineElement",
            "Metanorma::Document::Components::Inline::FmtStemElement",
            "Metanorma::Document::Components::TextElements::StemElement",
            "Metanorma::Document::Components::Inline::AsciimathElement",
            "Metanorma::Document::Components::Inline::MathElement",
          ].freeze

          def stem_node?(node)
            STEM_NODE_CLASSES.include?(node.class.name)
          end

          def xref_node?(node)
            node.is_a?(Metanorma::Document::Components::Inline::XrefElement)
          end

          def stem_visible_text(stem)
            # The typed stem has an `asciimath` attribute mapping to
            # Asciiml (a typed model with a `:value` string). For
            # Semx wrappers the asciimath sits on the inner stem; for
            # inline stems on the stem itself.
            asciimath_value(asciimath_of(stem)).then do |raw|
              text = raw.to_s.tr("_", " ").gsub(/[()"\\]/, "").strip
              text.empty? ? "" : " #{text} "
            end
          end

          def asciimath_of(stem)
            stem.is_a?(Metanorma::Document::Components::TextElements::StemElement) ||
              stem.is_a?(Metanorma::Document::Components::Inline::StemInlineElement) ||
              stem.is_a?(Metanorma::Document::Components::Inline::FmtStemElement) ? stem.asciimath : nil
          end

          def asciimath_value(asciiml)
            return nil unless asciiml
            asciiml.is_a?(Metanorma::Document::Components::TextElements::Asciiml) ? asciiml.value : asciiml.to_s
          end

          def xref_visible_text(xref)
            txt = Array(xref.text).join
            txt = xref.target.to_s if txt.empty? && xref.target
            case txt
            when /\Asec-(.+)\z/, /\Afig-(.+)\z/, /\Atable-(.+)\z/, /\Afn-(.+)\z/
              "#{Regexp.last_match(1)} "
            else
              txt
            end
          end
        end
      end
    end
  end
end
