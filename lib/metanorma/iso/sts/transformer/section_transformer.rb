# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      module Transformer
        class SectionTransformer < Base
          def transform(source_clause)
            title_text = extract_title(source_clause)
            id_val = source_clause.id if source_clause.is_a?(Lutaml::Model::Serializable) && source_clause.class.method_defined?(:id) && source_clause.id

            content = dispatcher.dispatch_section_blocks(source_clause)

            # Dispatch nested clauses for any section type carrying a
            # clause collection (IsoClauseSection AND IsoAnnexSection —
            # annex subsections like the Examples annex's entries).
            nested_clauses = []
            if source_clause.is_a?(Lutaml::Model::Serializable) && source_clause.class.method_defined?(:clause)
              nested_clauses = Array(source_clause.clause).map { |sub| transform(sub) }.compact
            end

            # Dispatch terms sections (a top-level <terms> carries its
            # entries directly in .term; a clause's nested terms section
            # appears in .terms). Each nested terms-section (e.g.
            # "3.1 General definitions") is preserved as its own Sec so
            # its heading renders for parity; only the top-level section
            # whose .term collection we're flattening skips the wrapper.
            if source_clause.class.method_defined?(:term) && Array(source_clause.term).any?
              Array(source_clause.term).each do |term|
                term_sec = term_transformer.transform(term)
                nested_clauses << term_sec if term_sec
              end
            end
            if source_clause.class.method_defined?(:terms)
              Array(source_clause.terms).each do |terms_section|
                terms_sec = transform_terms_section(terms_section)
                nested_clauses << terms_sec if terms_sec
              end
            end

            attrs = {}
            attrs[:id] = id_val if id_val
            attrs[:title] = ::Sts::NisoSts::Title.new(content: [title_text]) if title_text && !title_text.empty?
            autonum = extract_autonum(source_clause)
            attrs[:label] = ::Sts::NisoSts::Label.new(content: [autonum]) if autonum

            paragraphs, lists, figs, tables, notes, examples, formulas, def_lists, preformats, sub_secs = [], [], [], [], [], [], [], [], [], []
            content.each do |item|
              case item
              when ::Sts::NisoSts::Paragraph then paragraphs << item
              when ::Sts::NisoSts::List then lists << item
              when ::Sts::NisoSts::Figure then figs << item
              when ::Sts::TbxIsoTml::TableWrap then tables << item
              when ::Sts::NisoSts::NonNormativeNote then notes << item
              when ::Sts::NisoSts::NonNormativeExample then examples << item
              when ::Sts::NisoSts::DisplayFormula then formulas << item
              when ::Sts::NisoSts::DefList then def_lists << item
              when ::Sts::NisoSts::Preformat then preformats << item
              when ::Sts::NisoSts::Section then sub_secs << item
              end
            end
            nested_clauses.concat(sub_secs)

            attrs[:paragraphs] = paragraphs if paragraphs.any?
            attrs[:list] = lists if lists.any?
            attrs[:fig] = figs if figs.any?
            attrs[:table_wrap] = tables if tables.any?
            attrs[:non_normative_note] = notes if notes.any?
            attrs[:non_normative_example] = examples if examples.any?
            attrs[:disp_formula] = formulas if formulas.any?
            attrs[:def_list] = def_lists if def_lists.any?
            attrs[:preformat] = preformats if preformats.any?
            attrs[:sec] = nested_clauses if nested_clauses.any?

            ::Sts::NisoSts::Section.new(attrs)
          end

          # Build a Sec for a nested terms-section (e.g. "3.1 General
          # definitions") that wraps its term entries. The wrapper's
          # title and autonum are emitted so the renderer produces the
          # "3.1 General definitions" heading that appears in MN HTML.
          def transform_terms_section(terms_section)
            title_text = extract_title(terms_section)
            autonum = extract_autonum(terms_section)

            nested = Array(terms_section.term).map { |term| term_transformer.transform(term) }.compact

            attrs = {}
            attrs[:id] = terms_section.id if terms_section.class.method_defined?(:id) && terms_section.id
            attrs[:title] = ::Sts::NisoSts::Title.new(content: [title_text]) if title_text && !title_text.empty?
            attrs[:label] = ::Sts::NisoSts::Label.new(content: [autonum]) if autonum
            attrs[:sec] = nested if nested.any?
            return nil unless title_text || autonum || nested.any?

            ::Sts::NisoSts::Section.new(attrs)
          end

          # Section number from the presentation XML: the autonum
          # attribute (annexes, term notes) or the fmt-title/fmt-name
          # caption-label's autonum semx ("1", "8.1", "3.1"). The delim
          # between number and title is a <tab/>, which text extraction
          # drops, so the caption-label span must be isolated —
          # splitting the whole fmt-title text would glue number and
          # title together ("1Scope").
          def extract_autonum(source_clause)
            if source_clause.class.method_defined?(:autonum) && source_clause.autonum
              return source_clause.autonum.to_s
            end

            title_wrapper = %i[fmt_title fmt_name].filter_map do |method|
              source_clause.public_send(method) if source_clause.class.method_defined?(method)
            end.first
            title_wrapper = Array(title_wrapper).first
            return nil unless title_wrapper

            caption_label_text(title_wrapper)
          end

          private

          def extract_title(source_clause)
            return nil unless source_clause.class.method_defined?(:title) && source_clause.title
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
            title.class.method_defined?(:each_mixed_content)
          end

          def collect_title_parts(node, parts)
            return parts unless node.is_a?(Lutaml::Model::Serializable)
            return parts unless node.class.method_defined?(:each_mixed_content)

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

          # Text of the <span class="fmt-caption-label"> inside a
          # fmt-title — the bare section number.
          def caption_label_text(fmt_title)
            return nil unless fmt_title.class.method_defined?(:each_mixed_content)

            label_span = nil
            fmt_title.each_mixed_content do |child|
              if child.is_a?(Metanorma::Document::Components::Inline::SpanElement) &&
                  child.class_attr == "fmt-caption-label"
                label_span = child
                break
              end
            end
            return nil unless label_span

            text = RenderedTextExtractor.text_of(label_span).strip
            text.empty? ? nil : text
          end
        end
      end
    end
  end
end
