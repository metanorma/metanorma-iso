# frozen_string_literal: true
module Metanorma
  module Iso
    module Sts
      module Transformer
        class ReferenceTransformer < Base
          def transform_section(ref_section)
            bibitems = extract_bibitems(ref_section)
            title_text = extract_title(ref_section)

            paragraphs = intro_paragraphs(ref_section)
            label = section_transformer.extract_autonum(ref_section)
            normative = paragraphs.any? || !label.nil?
            # Bibliography entries are numbered ([1], [2], …); normative
            # reference entries are not (ISO/Metanorma convention).
            refs = bibitems.map.with_index { |b, i| transform_bibitem(b, normative ? nil : i + 1) }.compact

            unless normative
              # Back-matter bibliography: a bare ref-list.
              return ModelBuilder.ref_list(content_type: "bibl", title: title_text, ref: refs)
            end

            # In-body normative references: a numbered <sec> whose intro
            # paragraphs precede the (untitled) ref-list.
            ref_list = ModelBuilder.ref_list(content_type: "norm-refs", title: nil, ref: refs)
            attrs = {}
            attrs[:id] = ref_section.id if ref_section.id
            attrs[:type] = "norm-refs"
            attrs[:label] = ::Sts::NisoSts::Label.new(content: [label]) if label
            attrs[:title] = ::Sts::NisoSts::Title.new(content: [title_text]) if title_text && !title_text.empty?
            attrs[:paragraphs] = paragraphs if paragraphs.any?
            attrs[:ref_list] = [ref_list] if ref_list
            ::Sts::NisoSts::Section.new(attrs)
          end

          def transform_bibitem(bibitem, ordinal = nil)
            identifier = extract_docidentifier(bibitem)
            formattedref = extract_formattedref(bibitem)
            label_text = ordinal ? "[#{ordinal}]" : nil

            content_parts = []
            content_parts << identifier if identifier
            content_parts << formattedref if formattedref

            rid = bibitem.id
            id_generator.register(rid, rid, "ref") if rid
            ModelBuilder.ref(
              id: rid,
              label: label_text,
              mixed_citation: content_parts.join(", "),
              std: build_std(identifier, formattedref)
            )
          end

          private

          # Every bibliographic <std> carries a <title> (OIML X 999
          # 5.4); the publication year rides inside the <std-ref>
          # designation, which is type="dated" when the identifier
          # embeds a year ("…:2012", "…-2022") and "undated" otherwise
          # (NISO STS idiom — <std> has no <pub-date> in the base tag
          # suite).
          def build_std(identifier, formattedref)
            return nil unless identifier || formattedref

            type = identifier.to_s.match?(/(:\d{4}|-\d{4}\b)/) ? "dated" : "undated"
            attrs = { type: type }
            attrs[:std_ref] = ::Sts::NisoSts::StandardRef.new(type: type, value: identifier) if identifier
            attrs[:title] = formattedref.to_s if formattedref
            ::Sts::NisoSts::ReferenceStandard.new(attrs)
          end

          def extract_bibitems(ref_section)
            refs = ref_section.references
            return Array(refs) if refs
            []
          end

          # Boilerplate paragraphs of an in-body references section
          # ("The following documents are referred to ...").
          def intro_paragraphs(ref_section)
            

            Array(ref_section.p).map { |p| paragraph_transformer.transform(p) }
          end

          def extract_title(ref_section)
            return nil unless ref_section.title
            RenderedTextExtractor.text_of(ref_section.title)
          end

          def extract_docidentifier(bibitem)
            
            ids = Array(bibitem.docidentifier)
            primary = ids.find { |i| !i.type } || ids.first
            return nil unless primary
            val = primary.id || primary.to_s
            val.to_s.strip
          end

          def extract_formattedref(bibitem)
            fr = bibitem.formatted_ref
            return nil unless fr
            text = RenderedTextExtractor.text_of(fr)
            text.empty? ? nil : text
          end
        end
      end
    end
  end
end
