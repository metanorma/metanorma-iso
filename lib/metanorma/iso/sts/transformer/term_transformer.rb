# frozen_string: true

module Metanorma
  module Iso
    module Sts
      module Transformer
        # A term becomes one nested <term-sec> holding the TBX
        # <tbx:termEntry> — the shape mnconvert emits for ISO-STS
        # terminology sections. term-sec and termEntry derive from the
        # same source id but must not share the derived value: xs:ID
        # forbids duplicates, so the section takes the sec_ prefix and
        # the entry the term_ prefix (the split mnconvert emits:
        # sec_3.1.2 / term_3.1.2).
        class TermTransformer < Metanorma::Document::Sts::Transformer::TermTransformer
          def transform(source_term)
            sec_id, entry_id = id_generator.term_ids(source_term)

            Transformer::ModelBuilder.term_section(id: sec_id) do |ts|
              number = extract_term_number(source_term)
              ts.label = ::Sts::NisoSts::Label.new(content: [number]) if number

              entry = ::Sts::TbxIsoTml::TermEntry.new
              entry.id = entry_id if entry_id
              entry.lang_set = build_lang_set(source_term)
              ts.term_entry = entry
            end
          end

          private

          # The term number ("3.1") from the term's fmt-name caption label.
          def extract_term_number(source_term)
            section_transformer.extract_autonum(source_term)
          end

          # Built through the block form so lutaml-model's order tracking
          # records setter-call order: the released LangSet mapping
          # declares subject_field last, but the tbx:langSet content model
          # places tig last, so mapping-declaration order emits
          # subjectField after the tigs and fails XSD validation. Gem-level
          # defect — the workaround pins the schema's order here.
          def build_lang_set(term)
            lang = context.language || "en"

            ::Sts::TbxIsoTml::LangSet.new do |set|
              set.lang = lang

              if domain_text(term)
                sf = ::Sts::TbxIsoTml::SubjectField.new
                sf.value = [domain_text(term)]
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

          def domain_text(term)
            

            domain = Array(term.domain).first
            return nil unless domain

            text = RenderedTextExtractor.text_of(domain).strip
            text.empty? ? nil : text
          end

          def build_definition(defn)
            d = ::Sts::TbxIsoTml::Definition.new

            if defn.verbal_definition
              vd = defn.verbal_definition
              Array(vd.p).each { |para| inline_transformer.apply_inline_content(para, d) }
            end

            Array(defn.p).each { |para| inline_transformer.apply_inline_content(para, d) }

            Array(defn.ul).each { |ul| d.list list_transformer.transform(ul) }
            Array(defn.ol).each { |ol| d.list list_transformer.transform(ol) }

            d
          end

          def build_note(tn)
            note = ::Sts::TbxIsoTml::Note.new
            Array(tn.p).each { |para| inline_transformer.apply_inline_content(para, note) }
            note
          end

          def build_example(te)
            ex = ::Sts::TbxIsoTml::Example.new
            Array(te.p).each { |para| inline_transformer.apply_inline_content(para, ex) }
            ex
          end

          def build_source_ref(ts)
            src = ::Sts::TbxIsoTml::Source.new
            origin = ts.origin
            return src unless origin

            citeas = origin.citeas
            src.value = [citeas] if citeas
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
              name = Array(expr.name).first
              if name
                term_content = Array(name.text).join
                t.value = [term_content] if term_content && !term_content.empty?

                pos_value = detect_grammar(name, designation)
                if pos_value
                  pos = ::Sts::TbxIsoTml::PartOfSpeech.new
                  pos.value = pos_value
                  tig.pos = pos
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

                rendered = RenderedTextExtractor.text_of(n)
                return rendered unless rendered.nil? || rendered.empty?
              end
            end

            nil
          end

          # The semantic name carries no part-of-speech; the presentation
          # grammar annotation (fmt-name semx grammar attr) does.
          def detect_grammar(name_element, designation = nil)
            grammar = designation.class.attributes.key?(:grammar) ? designation.grammar : nil
            grammar = Array(grammar).first if grammar.is_a?(Array)
            return grammar_value(grammar) if grammar

            nil
          end

          def grammar_value(grammar)
            %i[value is_abbreviation?].each do |attr|
              next unless grammar.class.attributes.key?(attr)
              next if attr == :is_abbreviation?

              val = grammar.public_send(attr)
              return val.to_s unless val.nil? || val.to_s.empty?
            end
            nil
          rescue StandardError
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
end
