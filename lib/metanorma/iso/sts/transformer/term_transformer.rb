# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      class Transformer::TermTransformer < Transformer::Base
        # A terms section renders as a <sec sec-type="terms"> carrying its
        # intro paragraphs/lists, with one nested <term-sec> per term holding
        # the TBX termEntry — the shape mnconvert emits for ISO-STS.
        # (sts-ruby's NisoSts::TermSection cannot hold section intro content:
        # it supports only label/term-display/termEntry, so the wrapper
        # Section carries the boilerplate.)
        def transform_section(terms)
          Transformer::ModelBuilder.section(
            id: id_for(terms),
            sec_type: "terms",
            label: terms_label(terms),
            title: terms.title ? transform_title(terms.title) : nil,
          ) do |sec|
            terms.each_mixed_content do |node|
              next if node.is_a?(String)
              next if node == terms.title

              if node.is_a?(Metanorma::Iso::Document::Terms::IsoTerm)
                sec.term_sec build_term_section(node)
              else
                block_dispatcher.dispatch(node, sec)
              end
            end
          end
        end

        def transform_entry(term)
          suffix = term_id_suffix(term)
          entry = ::Sts::TbxIsoTml::TermEntry.new
          entry.id = "term_#{suffix}" unless suffix.empty?

          lang = @context.language || "en"
          entry.lang_set build_lang_set(term, lang)

          entry
        end

        private

        def terms_label(terms)
          terms.number if terms.number && !terms.number.empty?
        end

        # One nested <term-sec> per term, holding the TBX termEntry.
        # term-sec and termEntry derive from the same source id but must
        # not share the derived value: xs:ID forbids duplicates, so the
        # section takes the sec_ prefix and the entry the term_ prefix
        # (the split mnconvert emits: sec_3.1.2 / term_3.1.2).
        def build_term_section(term)
          suffix = term_id_suffix(term)
          Transformer::ModelBuilder.term_section(
            id: suffix.empty? ? nil : "sec_#{suffix}",
          ) do |ts|
            ts.term_entry transform_entry(term)
          end
        end

        # The semantic <term> id is a uuid, usually "_8b70fb0a-…"; strip
        # the leading underscore and any legacy term_ prefix so both
        # derived ids stay valid NCNames.
        def term_id_suffix(term)
          term.id.to_s.sub(/\A_?term_?/, "").delete_prefix("_")
        end

        def build_lang_set(term, lang)
          # Built through the block form so lutaml-model's order tracking
          # records setter-call order: the released LangSet mapping
          # declares subjectField last, but the tbx:langSet content model
          # places tig last, so mapping-declaration order emits
          # subjectField after the tigs and fails XSD validation.
          ::Sts::TbxIsoTml::LangSet.new do |set|
            set.lang = lang

            if term.domain&.text
              sf = ::Sts::TbxIsoTml::SubjectField.new
              sf.value = term.domain.text
              set.subject_field sf
            end

            Array(term.definition).each do |defn|
              set.definition build_definition(defn)
            end
            Array(term.termnote).each { |tn| set.note build_note(tn) }
            Array(term.termexample).each { |te| set.example build_example(te) }
            Array(term.termsource).each { |ts| set.source build_source_ref(ts) }
            Array(term.source).each { |s| set.source build_source_ref(s) }

            build_tigs_for(term).each { |tig| set.tig tig }
          end
        end

        def build_definition(defn)
          d = ::Sts::TbxIsoTml::Definition.new

          if defn.verbal_definition
            vd = defn.verbal_definition
            if vd.p && !vd.p.empty?
              vd.p.each { |para| inline_transformer.apply_inline_content(para, d) }
            end
          end

          if defn.p && !defn.p.empty?
            defn.p.each { |para| inline_transformer.apply_inline_content(para, d) }
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

          if tn.p && !tn.p.empty?
            tn.p.each do |para|
              inline_transformer.apply_inline_content(para, note)
            end
          end

          note
        end

        def build_example(te)
          ex = ::Sts::TbxIsoTml::Example.new

          if te.p && !te.p.empty?
            te.p.each do |para|
              inline_transformer.apply_inline_content(para, ex)
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
