# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      class Transformer::TermTransformer < Transformer::Base
        def transform_section(terms)
          build_ordered(::Sts::IsoSts::TermSec) do |ts|
            ts.id = id_for(terms)

            if terms.number && !terms.number.empty?
              ts.label = ::Sts::IsoSts::Label.new(content: [terms.number])
            end

            if terms.title
              ts.title transform_title(terms.title)
            end

            terms.each_mixed_content do |node|
              next if node.is_a?(String)
              next if node == terms.title

              case node
              when Metanorma::Document::Components::Paragraphs::ParagraphBlock,
                   Metanorma::IsoDocument::RawParagraph
                ts.p paragraph_transformer.transform(node)
              when Metanorma::Document::Components::Lists::UnorderedList,
                   Metanorma::Document::Components::Lists::OrderedList
                ts.list list_transformer.transform(node)
              when Metanorma::IsoDocument::Terms::IsoTerm
                ts.tbz_term_entry transform_entry(node)
              end
            end
          end
        end

        def transform_entry(term)
          entry = ::Sts::TbxIsoTml::TermEntry.new
          entry.id = "term_#{term.id.gsub(/^term_/, '')}" if term.id

          lang = @context.language || "en"
          entry.lang_set build_lang_set(term, lang)

          entry
        end

        private

        def build_lang_set(term, lang)
          ls = ::Sts::TbxIsoTml::LangSet.new
          ls.lang = lang

          if term.domain&.text
            sf = ::Sts::TbxIsoTml::SubjectField.new
            sf.value = term.domain.text
            ls.subject_field sf
          end

          Array(term.definition).each do |defn|
            ls.definition build_definition(defn)
          end
          Array(term.termnote).each { |tn| ls.note build_note(tn) }
          Array(term.termexample).each { |te| ls.example build_example(te) }
          Array(term.termsource).each { |ts| ls.source build_source_ref(ts) }
          Array(term.source).each { |s| ls.source build_source_ref(s) }

          build_tigs_for(term).each { |tig| ls.tig tig }

          ls
        end

        def build_definition(defn)
          d = ::Sts::TbxIsoTml::Definition.new

          if defn.verbal_definition
            vd = defn.verbal_definition
            if vd.p && !vd.p.empty?
              vd.p.each { |para| inline_transformer.apply_tbx_content(para, d) }
            end
          end

          if defn.p && !defn.p.empty?
            defn.p.each { |para| inline_transformer.apply_tbx_content(para, d) }
          end

          if defn.ul && !defn.ul.empty?
            defn.ul.each { |ul| d.list list_transformer.transform(ul) }
          end
          if defn.ol && !defn.ol.empty?
            defn.ol.each { |ol| d.list list_transformer.transform(ol) }
          end

          d
        end

        def build_note(tn)
          note = ::Sts::TbxIsoTml::Note.new
          note.instance_variable_set(:@__order_tracking__, true)

          if tn.p && !tn.p.empty?
            tn.p.each do |para|
              inline_transformer.apply_tbx_content(para, note)
            end
          end

          note
        end

        def build_example(te)
          ex = ::Sts::TbxIsoTml::Example.new

          if te.p && !te.p.empty?
            te.p.each do |para|
              inline_transformer.apply_tbx_content(para, ex, text_attr: :value)
            end
          end

          ex
        end

        def build_source_ref(ts)
          src = ::Sts::TbxIsoTml::Source.new
          origin = ts.origin
          if origin
            citeas = origin.citeas
            src.value = citeas if citeas
          end
          src
        end

        def build_tigs_for(term)
          has_multiple = Array(term.admitted).any? || Array(term.deprecates).any?

          tigs = Array(term.preferred).map do |pref|
            build_tig(pref, "preferredTerm", has_multiple)
          end
          Array(term.admitted).each do |adm|
            tigs << build_tig(adm, "admittedTerm", true)
          end
          Array(term.deprecates).each do |dep|
            tigs << build_tig(dep, "deprecatedTerm", true)
          end

          tigs
        end

        def build_tig(designation, norm_status, has_multiple)
          tig = ::Sts::TbxIsoTml::TermInformationGroup.new

          term_text = extract_designation_text(designation)
          t = ::Sts::TbxIsoTml::Term.new
          t.value = [term_text] if term_text
          tig.term = t

          if designation.expression
            expr = designation.expression
            if expr.name && !expr.name.empty?
              name = expr.name.first
              if name
                term_content = Array(name.text).join
                if term_content && !term_content.empty?
                  t.value = [term_content]
                end

                grammar = detect_grammar(name)
                if grammar
                  pos = ::Sts::TbxIsoTml::PartOfSpeech.new
                  pos.value = grammar
                  tig.pos = pos
                end
              end
            end

            abbrev_type = expr.abbreviation_type
            if abbrev_type && !abbrev_type.empty?
              tt = ::Sts::TbxIsoTml::TermType.new
              tt.value = abbrev_type_map(abbrev_type)
              tig.term_type = tt
            end
          end

          if has_multiple
            na = ::Sts::TbxIsoTml::NormativeAuthorization.new
            na.value = norm_status
            tig.normative_authorization = na
          end

          tig
        end

        def extract_designation_text(designation)
          texts = Array(designation.text)
          return texts.join if texts.any?

          if designation.expression
            expr = designation.expression
            Array(expr.name).each do |n|
              t = Array(n.text).join
              return t unless t.empty?
            end
          end

          nil
        end

        def detect_grammar(name_element)
          return nil unless name_element

          if name_element.text
            text = Array(name_element.text).join
            return nil if text.empty?
          end

          nil
        end

        def abbrev_type_map(type)
          case type
          when "acronym" then "acronym"
          when "abbreviation" then "abbreviation"
          else "variant"
          end
        end
      end
    end
  end
end
