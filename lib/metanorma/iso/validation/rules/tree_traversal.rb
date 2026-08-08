# frozen_string_literal: true

require "set"

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

          # Yield every definitions section in the document along with its
          # parent container symbol (:sections or :annex). Used by ISO_25
          # (count), ISO_26 (content), ISO_27 (vocab-annex) rules.
          def each_definitions_section(root)
            return enum_for(__method__, root) unless block_given?

            sections = root&.sections
            visit_definitions_in(sections, :sections) { |d, p| yield(d, p) } if sections
            Array(root.annex).each do |annex|
              visit_definitions_in(annex, :annex) { |d, p| yield(d, p) }
            end
          end

          # Yield every terms section in the document (top-level sections/terms
          # plus any clause containing a terms sub-section). Used by ISO_44/45
          # (vocab terms titles).
          def each_terms_section(root)
            return enum_for(__method__, root) unless block_given?

            sections = root&.sections or return
            yield(sections.terms) if sections.terms
            visit_clauses_for_terms(sections.clause) { |t| yield(t) }
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

          # Find the first docidentifier with the given +type+ on the
          # document's bibdata. Returns nil when absent.
          def find_docidentifier(bibdata, type)
            return nil unless bibdata
            return nil unless bibdata.class.method_defined?(:doc_identifier)

            Array(bibdata.doc_identifier).find { |id| id.type == type }
          end

          # Yield every organization that has a "publisher" role on the
          # bibliographic item. Used by publisher-identity checks
          # (ISO_42, ISO_16).
          def each_publisher_organization(bibitem)
            return enum_for(__method__, bibitem) unless block_given?
            return unless bibitem
            return unless bibitem.class.method_defined?(:contributor)

            Array(bibitem.contributor).each do |contributor|
              next unless publisher_role?(contributor)
              next unless contributor.organization

              yield(contributor.organization)
            end
          end

          ISO_ABBR = "ISO".freeze
          IEC_ABBR = "IEC".freeze
          ISO_NAME = "International Organization for Standardization".freeze
          IEC_NAME = "International Electrotechnical Commission".freeze

          def iso_iec_publisher?(bibitem)
            each_publisher_organization(bibitem).any? do |org|
              org.abbreviation.to_s == ISO_ABBR ||
                org.abbreviation.to_s == IEC_ABBR ||
                organization_name_text(org) == ISO_NAME ||
                organization_name_text(org) == IEC_NAME
            end
          end

          def iec_publisher?(bibitem)
            each_publisher_organization(bibitem).any? do |org|
              org.abbreviation.to_s == IEC_ABBR ||
                organization_name_text(org) == IEC_NAME
            end
          end

          def organization_name_text(org)
            names = Array(org.name) if org.class.method_defined?(:name)
            return "" if Array(names).empty?

            name = Array(names).first
            return name.to_s unless name.is_a?(Lutaml::Model::Serializable)

            values = array_value_of(name)
            values.nil? ? name.to_s : values.join.strip
          end

          # Walk every model node that has an :id or :anchor attribute,
          # yielding (node, id, anchor). Used by UniqueIdRule to detect
          # duplicates and populate SharedState for xref rules. Walker is
          # breadth-first over the typed attribute graph; a visited-set
          # prevents infinite loops on cyclic references.
          def each_node_with_id_or_anchor(root)
            return enum_for(__method__, root) unless block_given?

            visited = Set.new
            queue = [root].compact
            until queue.empty?
              node = queue.shift
              next unless node.is_a?(Lutaml::Model::Serializable)
              next if visited.include?(node.object_id)

              visited << node.object_id

              if has_id_or_anchor?(node)
                yield(node, read_id_attr(node), read_anchor_attr(node))
              end

              enqueue_children(node, queue)
            end
          end

          def has_id_or_anchor?(node)
            (node.class.method_defined?(:id) && !read_id_attr(node).nil?) ||
              (node.class.method_defined?(:anchor) && !read_anchor_attr(node).nil?)
          end

          def read_id_attr(node)
            return nil unless node.class.method_defined?(:id)

            value = node.id
            return nil if value.nil? || value.to_s.empty?

            value.to_s
          end

          def read_anchor_attr(node)
            return nil unless node.class.method_defined?(:anchor)

            value = node.anchor
            return nil if value.nil? || value.to_s.empty?

            value.to_s
          end

          def enqueue_children(node, queue)
            return unless node.is_a?(Lutaml::Model::Serializable)

            node.class.attributes.each_value do |attr_def|
              value = node.public_send(attr_def.name)
              enqueue_value(value, queue)
            end
          end

          def enqueue_value(value, queue)
            case value
            when Array
              value.each { |v| queue << v if v.is_a?(Lutaml::Model::Serializable) }
            when Lutaml::Model::Serializable
              queue << value
            end
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

          def visit_definitions_in(holder, parent_symbol)
            return unless holder
            return unless holder.class.method_defined?(:definitions)

            Array(holder.definitions).each do |d|
              yield(d, parent_symbol)
              Array(d.definitions).each { |sub| yield(sub, parent_symbol) }
            end
          end

          def visit_clauses_for_terms(clauses)
            Array(clauses).each do |clause|
              yield(clause.terms) if clause.class.method_defined?(:terms) && clause.terms
              visit_clauses_for_terms(clause.clause) { |t| yield(t) } if clause.class.method_defined?(:clause)
            end
          end

          def publisher_role?(contributor)
            return false unless contributor.class.method_defined?(:role)

            Array(contributor.role).any? { |role| role.type == "publisher" }
          end
        end
      end
    end
  end
end
