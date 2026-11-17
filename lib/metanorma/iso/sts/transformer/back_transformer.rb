# frozen_string: true
module Metanorma
  module Iso
    module Sts
      module Transformer
        class BackTransformer < Base
          def transform(source)
            app_group = build_app_group(source)
            ref_lists = build_bibliography(source)
            ModelBuilder.back(app_group: app_group, ref_list: ref_lists)
          end

          private

          # Annexes serialize as <app> elements in <back><app-group>.
          # Built through the block form so lutaml-model's order tracking
          # records setter-call order: the schema's app content model
          # wants label/annex-type/title, then para-level content, then
          # child secs — the App mapping's declaration order puts sec
          # BEFORE paragraph, which hash-init emission would follow and
          # fail XSD validation.
          def build_app_group(source)
            return nil if source.annexes.empty?

            apps = source.annexes.map { |annex| transform_annex(annex) }
            ModelBuilder.app_group(app: apps)
          end

          def transform_annex(annex)
            sts_id = id_generator.id_for_annex(annex, section_transformer.extract_autonum(annex))

            ::Sts::NisoSts::App.new do |app|
              app.id = sts_id if sts_id
              app.content_type = annex_content_type(annex)

              label_text = annex_label_text(annex, sts_id)
              app.label = ::Sts::NisoSts::Label.new(content: [label_text]) if label_text
              title_text = annex_title_text(annex)
              app.title = ::Sts::NisoSts::Title.new(content: [title_text]) if title_text && !title_text.empty?

              # Dispatch the annex body straight into the App — a wrapper
              # <sec> would need its own label/title to be schema-valid,
              # which the annex structure never provides.
              dispatch_annex_content(annex, app)
            end
          end

          # "Annex A" — from the source number when present, else from
          # the generated annex letter (sec_B → B), keeping label and id
          # consistent. The NBSP mirrors MN's annex header typography.
          def annex_label_text(annex, sts_id)
            number = annex_autonum(annex)
            return "Annex #{number}" if number

            letter = sts_id.to_s.delete_prefix("sec_")
            letter.empty? ? nil : "Annex #{letter}"
          end

          def annex_autonum(annex)
            section_transformer.extract_autonum(annex)
          end

          def annex_title_text(annex)
            RenderedTextExtractor.text_of(annex.title) if annex.title
          end

          def annex_content_type(annex)
            

            case annex.obligation
            when "normative" then "normative"
            when "informative" then "informative"
            end
          end

          # SectionTransformer#content_of yields the annex body in
          # document order; each item appends onto the app via its own
          # setter, preserving the order. The App model carries no
          # def-list or disp-formula mapping — an annex carrying one
          # raises here instead of silently losing the block.
          def dispatch_annex_content(annex, app)
            section_transformer.content_of(annex).each do |item|
              case item
              when ::Sts::NisoSts::Paragraph then app.paragraph item
              when ::Sts::NisoSts::List then app.list item
              when ::Sts::NisoSts::Figure then app.fig item
              when ::Sts::TbxIsoTml::TableWrap then app.table_wrap item
              when ::Sts::NisoSts::NonNormativeNote then app.non_normative_note item
              when ::Sts::NisoSts::NonNormativeExample then app.non_normative_example item
              when ::Sts::NisoSts::Preformat then app.preformat item
              when ::Sts::NisoSts::Section then app.sec item
              when ::Sts::NisoSts::TermSection then app.sec item
              when ::Sts::NisoSts::ReferenceList then app.ref_list item
              when ::Sts::NisoSts::DefList
                raise_unsupported("def-list", item)
              when ::Sts::NisoSts::DisplayFormula
                raise_unsupported("disp-formula", item)
              end
            end
          end

          def raise_unsupported(element, _item)
            raise ArgumentError,
                  "Sts::NisoSts::App has no #{element} mapping: cannot " \
                  "place annex content in the <app> element"
          end

          def build_bibliography(source)
            return [] if source.bibliography.empty?
            source.bibliography.map { |rs| reference_transformer.transform_section(rs) }
          end
        end
      end
    end
  end
end
