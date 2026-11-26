# frozen_string_literal: true
module Metanorma
  module Iso
    module Sts
      module Transformer
        class ReferenceTransformer < Metanorma::Document::Sts::Transformer::ReferenceTransformer
          # The sts gem's ReferenceStandard maps the URN only inside
          # <std-id-group>; Guidelines 4.4.2 (iso-gdg-4.4.2-5) want a direct
          # <std-id @std-id-link-type="urn" @std-id-type="dated|undated">
          # child of <std>. The XSD content model is an unordered choice, so
          # the added element needs no particular position.
          class ReferenceStandardWithId < ::Sts::NisoSts::ReferenceStandard
            attribute :std_id_element, ::Sts::NisoSts::StdId, collection: true

            xml do
              element "std"
              mixed_content

              map_attribute "id", to: :id
              map_attribute "type", to: :type
              map_attribute "std-id", to: :std_id

              map_element "std-id", to: :std_id_element
              map_element "std-ref", to: :std_ref
              map_element "fn", to: :fn
              map_element "title", to: :title
              map_element "std-id-group", to: :std_id_group
              map_element "xref", to: :xref
              map_element "bold", to: :bold

              map_content to: :content
            end
          end

          # A references section is normative (in-body norm-refs) when it
          # carries intro paragraphs or a section number; otherwise it is
          # the back-matter bibliography. Shared with DocumentTransformer's
          # id pre-registration so both agree on each entry's kind.
          def normative_section?(ref_section)
            Array(ref_section.p).any? ||
              !section_transformer.extract_autonum(ref_section).nil?
          end

          # The identity an in-text citation needs to reproduce a normative
          # reference as <std>: designation, URN and dated/undated type.
          def reference_identity(bibitem)
            identifier = extract_docidentifier(bibitem)
            urn = extract_urn(bibitem)
            return nil unless identifier && urn

            { identifier: identifier, urn: urn,
              type: std_type_for(identifier) }
          end

          def transform_section(ref_section)
            bibitems = extract_bibitems(ref_section)
            title_text = extract_title(ref_section)

            paragraphs = intro_paragraphs(ref_section)
            label = section_transformer.extract_autonum(ref_section)
            normative = normative_section?(ref_section)
            # Bibliography entries are numbered ([1], [2], …); normative
            # reference entries are not (ISO/Metanorma convention).
            refs = bibitems.map.with_index do |b, i|
              transform_bibitem(b, normative ? nil : i + 1, normative: normative)
            end.compact

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

          def transform_bibitem(bibitem, ordinal = nil, normative: false)
            identifier = extract_docidentifier(bibitem)
            formattedref = extract_formattedref(bibitem)
            label_text = ordinal ? "[#{ordinal}]" : nil

            content_parts = []
            content_parts << identifier if identifier
            content_parts << formattedref if formattedref

            rid = bibitem.id
            if rid
              id_generator.register(rid, rid, normative ? "norm-ref" : "ref")
              id_generator.register_normative_ref(rid, reference_identity(bibitem)) if normative
            end
            ModelBuilder.ref(
              id: rid,
              label: label_text,
              mixed_citation: content_parts.join(", "),
              std: build_std(identifier, formattedref, extract_urn(bibitem))
            )
          end

          private

          # Every bibliographic <std> carries a <title> (OIML X 999
          # 5.4); the publication year rides inside the <std-ref>
          # designation, which is type="dated" when the identifier
          # embeds a year ("…:2012", "…-2022") and "undated" otherwise
          # (NISO STS idiom — <std> has no <pub-date> in the base tag
          # suite).
          def build_std(identifier, formattedref, urn = nil)
            return nil unless identifier || formattedref

            type = std_type_for(identifier)
            attrs = { type: type }
            attrs[:std_ref] = ::Sts::NisoSts::StandardRef.new(type: type, value: identifier) if identifier
            attrs[:title] = formattedref.to_s if formattedref
            if urn
              sid = ::Sts::NisoSts::StdId.new(std_id_link_type: "urn", std_id_type: type, content: urn)
              attrs[:std_id_element] = [sid]
            end
            ReferenceStandardWithId.new(attrs)
          end

          # "dated" when the designation embeds a year, else "undated".
          def std_type_for(identifier)
            identifier.to_s.match?(/(:\d{4}|-\d{4}\b)/) ? "dated" : "undated"
          end

          # The URN carried by the bibitem's own <docidentifier type="URN">
          # (the value may be prefixed with the literal "URN ").
          def extract_urn(bibitem)
            urn = Array(bibitem.docidentifier).find { |i| i.type.to_s.casecmp?("URN") }
            return nil unless urn

            # The prefix may be separated by a no-break space (U+00A0),
            # which \s does not match; [[:space:]] does.
            value = (urn.id || urn.to_s).to_s.strip.sub(/\AURN[[:space:]]+/i, "")
            value.empty? ? nil : value
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
