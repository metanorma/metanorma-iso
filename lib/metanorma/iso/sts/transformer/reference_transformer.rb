# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      class Transformer::ReferenceTransformer < Transformer::Base
        def transform_list(ref_section)
          normative = ref_section.normative == "true"

          build_ordered(::Sts::IsoSts::RefList) do |rl|
            rl.id = id_for(ref_section)
            rl.content_type = normative ? "norm-refs" : "bibl"

            if ref_section.title
              rl.title transform_title(ref_section.title)
            end

            if ref_section.p && !ref_section.p.empty?
              ref_section.p.each do |para|
                rl.p paragraph_transformer.transform(para)
              end
            end

            if ref_section.references && !ref_section.references.empty?
              ref_section.references.each_with_index do |bibitem, idx|
                rl.ref transform_bibitem(bibitem, idx + 1)
              end
            end
          end
        end

        def transform_bibitem(bibitem, index)
          build_ordered(::Sts::IsoSts::Ref) do |ref|
            ref.id = "biblref_#{index}"

            lbl = ::Sts::IsoSts::Label.new(content: ["[#{index}]"])
            ref.label lbl

            mc = build_mixed_citation(bibitem)
            ref.mixed_citation mc if mc

            std = build_std_for(bibitem)
            ref.std std if std
          end
        end

        private

        def build_mixed_citation(bibitem)
          mc = ::Sts::IsoSts::MixedCitation.new

          doc_id = primary_docidentifier(bibitem)
          title_text = reference_title(bibitem)

          if doc_id
            mc.content doc_id
            if title_text
              mc.content ", "
              italic = ::Sts::IsoSts::Italic.new
              italic.content title_text
              mc.italic italic
            end
          elsif title_text
            mc.content title_text
          else
            return nil
          end

          mc
        end

        def build_std_for(bibitem)
          doc_id = primary_docidentifier(bibitem)
          return nil unless doc_id

          std = ::Sts::IsoSts::Std.new
          std.type = "dated"

          dated_ref = ::Sts::IsoSts::StdRef.new
          dated_ref.type = "dated"
          dated_ref.content = [doc_id]
          std.std_ref dated_ref

          undated = undated_identifier(doc_id)
          if undated && undated != doc_id
            undated_ref = ::Sts::IsoSts::StdRef.new
            undated_ref.type = "undated"
            undated_ref.content = [undated]
            std.std_ref undated_ref
          end

          std
        end

        def primary_docidentifier(bibitem)
          return nil unless bibitem.docidentifier

          ids = Array(bibitem.docidentifier)

          primary = ids.find { |d| d.primary == true }
          return primary.id.to_s if primary&.id

          iso_id = ids.find { |d| d.type == "ISO" }
          return iso_id.id.to_s if iso_id&.id

          ids.first&.id&.to_s
        end

        def reference_title(bibitem)
          return nil unless bibitem.title

          titles = Array(bibitem.title)

          main_title = titles.find { |t| t.type == "title-main" }
          return extract_title_text(main_title) if main_title

          extract_title_text(titles.first) if titles.first
        end

        def extract_title_text(title)
          return nil unless title

          if title.content && !title.content.empty?
            Array(title.content).join
          elsif title.element_order && !title.element_order.empty?
            inline_transformer.extract_text(title)
          end
        end

        def undated_identifier(doc_id)
          doc_id.sub(/:\d{4}$/, "")
        end
      end
    end
  end
end
