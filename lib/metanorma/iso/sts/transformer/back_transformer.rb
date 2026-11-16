# frozen_string_literal: true
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

          def build_app_group(source)
            return nil if source.annexes.empty?

            apps = source.annexes.map do |annex|
              sec = section_transformer.transform(annex)
              attrs = {}
              APP_CONTENT_ATTRS.each do |attr|
                next unless sec.class.method_defined?(attr)

                value = sec.public_send(attr)
                next if value.nil? || (value.is_a?(Array) && value.empty?)

                # Section stores body paragraphs as `paragraphs` (plural);
                # App stores them as `paragraph` (singular). Map across
                # the boundary so the annex intro paragraphs survive.
                key = (attr == :paragraphs) ? :paragraph : attr
                attrs[key] = value
              end
              ::Sts::NisoSts::App.new(attrs)
            end
            ModelBuilder.app_group(app: apps)
          end

          # Everything SectionTransformer can produce: dropping any of
          # these at the app boundary silently loses annex-level content
          # (e.g. the Element map annex's table — or the annex letter
          # label, "Annex A").
          APP_CONTENT_ATTRS = %i[
            id label title paragraphs list fig table_wrap def_list disp_formula
            non_normative_note non_normative_example ref_list sec preformat
          ].freeze

          def build_bibliography(source)
            return [] if source.bibliography.empty?
            source.bibliography.map { |rs| reference_transformer.transform_section(rs) }
          end
        end
      end
    end
  end
end
