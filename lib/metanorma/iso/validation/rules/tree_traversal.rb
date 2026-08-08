# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Shared helpers for walking the IsoDocument tree. Mixed into Base
        # so every rule has access without inheriting implementation detail.
        #
        # Helpers are added incrementally as rule TODOs need them. Each
        # helper is a single responsibility (MECE): one kind of walk, one
        # kind of text extraction, etc.
        module TreeTraversal
          # Yield every subdivision of every contributor whose role description
          # matches +role_text+, along with the subdivision's @type.
          # Skips contributors without an organization or subdivisions.
          def each_contributor_subdivision(bibdata, role_text)
            return enum_for(__method__, bibdata, role_text) unless block_given?

            Array(bibdata&.contributor).each do |contributor|
              next unless contributor_has_role?(contributor, role_text)
              next unless contributor.organization

              Array(contributor.organization.subdivision).each do |subdivision|
                yield(subdivision, subdivision.type) if subdivision.type
              end
            end
          end

          # Recursively yield every term in the document. A terms section
          # contains a +term+ collection (IsoTerm); each IsoTerm can also
          # contain nested +term+ (related terms).
          def each_term(root)
            return enum_for(__method__, root) unless block_given?

            sections = root&.sections or return
            visit_terms_section(sections.terms) { |term| yield(term) }
            visit_clause_subtree_for_terms(sections.clause) { |t| yield(t) }
          end

          # Yield every clause (recursive) under root.sections.
          def each_clause(root)
            return enum_for(__method__, root) unless block_given?

            sections = root&.sections or return
            walk_clauses(sections) { |clause| yield(clause) }
          end

          # Concatenate the text content of a model node, with optional
          # child element types stripped. Used by style rules to reproduce
          # the existing extract_text() behavior without Nokogiri.
          def extract_text(node, strip: [])
            return "" if node.nil?
            return node.to_s unless node.is_a?(Lutaml::Model::Serializable)

            stripped_types = strip.to_set
            parts = []
            walk_text(node, stripped_types, parts)
            parts.join
          end

          private

          def contributor_has_role?(contributor, role_text)
            roles = Array(contributor.role)
            roles.any? { |role| role_matches?(role, role_text) }
          end

          def role_matches?(role, expected)
            descriptions = Array(role.description) + Array(role.text)
            descriptions.any? { |d| text_of(d) == expected }
          end

          # Extracts a single string from a role description value.
          # FormattedString stores its text in a +value+ collection (one entry
          # per mixed-content run); we join and strip to compare cleanly.
          # Strings pass through unchanged.
          def text_of(value)
            return value.to_s unless value.is_a?(Lutaml::Model::Serializable)

            values = array_value_of(value)
            return values.join.strip unless values.nil?

            extract_text(value).strip
          end

          # Read a Serializable's +value+ attribute if it has one (without
          # using respond_to?). Returns nil if the attribute is absent.
          def array_value_of(node)
            return nil unless node.class.method_defined?(:value)

            Array(node.value).map(&:to_s)
          end

          def visit_terms_section(terms_section)
            return unless terms_section

            Array(terms_section.term).each { |t| yield_subterms(t) { |term| yield(term) } }
          end

          def yield_subterms(term)
            yield(term)
            Array(term.term).each { |sub| yield_subterms(sub) { |t| yield(t) } }
          end

          def visit_clause_subtree_for_terms(clause_node)
            Array(clause_node).each do |clause|
              visit_terms_section(clause) { |t| yield(t) } if clause.is_a?(Metanorma::IsoDocument::Sections::IsoTermsSection)
              visit_clause_subtree_for_terms(clause.clause) { |t| yield(t) } if clause.class.method_defined?(:clause)
            end
          end

          def walk_clauses(node, &block)
            return unless node

            Array(node.clause).each do |clause|
              yield(clause)
              walk_clauses(clause, &block)
            end
          end

          def walk_text(node, stripped_types, parts)
            return if node.nil?

            if node.is_a?(String)
              parts << node
              return
            end

            if node.is_a?(Lutaml::Model::Serializable)
              node.class.attributes.each_value do |attr_def|
                next if stripped_types.include?(attr_def.name.to_sym)

                value = node.public_send(attr_def.name)
                walk_text_value(value, stripped_types, parts)
              end
            else
              parts << node.to_s
            end
          end

          def walk_text_value(value, stripped_types, parts)
            case value
            when Array then value.each { |v| walk_text_value(v, stripped_types, parts) }
            when String then parts << value
            when Lutaml::Model::Serializable then walk_text(value, stripped_types, parts)
            else
              parts << value.to_s unless value.nil?
            end
          end
        end
      end
    end
  end
end
