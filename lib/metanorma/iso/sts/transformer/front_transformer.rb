# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      class Transformer::FrontTransformer < Transformer::Base
        def transform(source)
          build_ordered(::Sts::IsoSts::Front) do |f|
            f.iso_meta = Transformer::IsoMetaTransformer.new(@context).transform(source.bibdata)

            preface = source.preface
            if preface
              transform_preface_sections(preface).each do |sec|
                f.sec sec
              end
            end
          end
        end

        private

        def transform_preface_sections(preface)
          sections = []

          if preface.foreword
            sections << section_transformer.transform_foreword(preface.foreword)
          end

          if preface.abstract
            sections << section_transformer.transform_abstract(preface.abstract)
          end

          if preface.introduction
            sections << section_transformer.transform_introduction(preface.introduction)
          end

          if preface.clause
            Array(preface.clause).each do |cl|
              sections << section_transformer.transform(cl)
            end
          end

          if preface.acknowledgements
            sections << section_transformer.transform(preface.acknowledgements)
          end

          if preface.executivesummary
            sections << section_transformer.transform(preface.executivesummary)
          end

          sections
        end
      end
    end
  end
end
