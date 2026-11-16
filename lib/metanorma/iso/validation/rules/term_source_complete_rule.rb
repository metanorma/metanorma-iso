# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # ISO_55 (House Style 2026-08, Referencing > References in Clause 3):
        # term entries reproduced from external documents carry a [SOURCE]
        # citation, and the cited source document is informative and listed
        # in the Bibliography.
        #
        # Detection stays deliberately conservative (issue #1705): whether an
        # entry is in fact reproduced from another document is not decidable
        # from the model, so entries with no source element at all are NOT
        # flagged. The rule flags the clear violations only:
        # - a <source>/<termsource> element whose <origin> is missing or
        #   targetless (no bibitemid);
        # - a source origin whose bibitemid matches no bibliography entry.
        # Cross-document identity of the cited source is not validated.
        class TermSourceCompleteRule < Base
          code "ISO_55"

          policy category: "Referencing > References in Clause 3",
                 rule: "reproduced term entries carry their source citation in the SOURCE line and the cited source document appears in the Bibliography",
                 source: :house_style, mn_category: :references

          include DocumentOrderWalk

          ISO_TERM_CLASS = Metanorma::Iso::Document::Terms::IsoTerm

          NO_ORIGIN = "SOURCE line carries no origin citation".freeze
          NO_BIBITEMID = "SOURCE origin cites no bibliography entry".freeze
          UNLISTED = "SOURCE cites %s, which is not listed in the Bibliography".freeze

          def applicable?(context)
            !context.root.nil?
          end

          def check(context)
            root = context.root
            bibitem_ids = bibliography_ids(root)
            issues = []
            seen = {}

            each_document_node(root) do |node, _|
              next unless node.is_a?(ISO_TERM_CLASS)

              term_sources(node).each do |source|
                detail = source_detail(source, bibitem_ids)
                next if detail.nil?

                key = [node.object_id, detail]
                next if seen[key]

                seen[key] = true
                issues << build_issue(location: model_location(node),
                                      params: [term_label(node), detail])
              end
            end
            issues
          end

          private

          # Source elements of a term entry: term-level <source> and
          # <termsource>, plus designation-level sources.
          def term_sources(term)
            sources = Array(term.source) + Array(term.termsource)
            designations = Array(term.preferred) +
              Array(term.admitted) + Array(term.deprecates)
            designations.each do |designation|
              sources.concat(Array(designation.source))
            end
            sources
          end

          # Nil when the source element is complete against +bibitem_ids+.
          def source_detail(source, bibitem_ids)
            origin = source.origin
            return NO_ORIGIN if origin.nil?

            bibitemid = origin.bibitemid.to_s.strip
            return NO_BIBITEMID if bibitemid.empty?
            return UNLISTED % bibitemid unless bibitem_ids.include?(bibitemid)

            nil
          end

          # Every bibliography entry id/anchor the document declares.
          def bibliography_ids(root)
            ids = Set.new
            bibliography = root.bibliography
            Array(bibliography&.references).each do |section|
              Array(section.references).each do |bibitem|
                ids << read_id_attr(bibitem)
                ids << read_anchor_attr(bibitem)
              end
            end
            ids.compact
          end

          def term_label(term)
            Array(term.preferred).each do |designation|
              expression = designation.expression
              next if expression.nil?

              text = Array(expression.name).map { |n| extract_text(n) }
                .join.strip
              return text unless text.empty?
            end
            read_id_attr(term) || "term"
          end
        end
      end
    end
  end
end
