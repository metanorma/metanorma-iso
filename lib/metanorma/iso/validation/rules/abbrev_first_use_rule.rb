# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # ISO_53 (House Style 2026-08, Abbreviated terms): abbreviated terms
        # must be expanded at first use — full term followed by the
        # abbreviated term in brackets ("Climate Change (CC)").
        #
        # Detection model: an abbreviation is DECLARED either by an entry in
        # an abbreviated-terms list (a <definitions> section typed
        # abbreviated_terms, or titled "Abbreviated terms", whose <dl>
        # carries the abbreviation in <dt> and the full form in <dd>), or by
        # a term-entry designation whose <expression> carries an
        # <abbreviation-type> element. Only declared abbreviations are
        # tracked: undeclared abbreviated forms are not this rule's domain.
        #
        # The House Style requirements implemented:
        # - Title: an abbreviation used in the Title is expanded within the
        #   Title itself.
        # - Scope: an abbreviation used in the Scope is expanded within the
        #   Scope itself. These two hold regardless of an abbreviated-terms
        #   list; abbreviated alone is acceptable on later instances.
        # - Running text: expand at first use in document order, unless the
        #   document carries an abbreviated-terms list — with a list
        #   present, first-use expansion is optional, so the body and
        #   Clause 3 checks are skipped entirely (conservative boundary: a
        #   list never produces a flag).
        # - Clause 3 terms and definitions: expand at first use in each
        #   entry. Entry text excludes the designation forms themselves, so
        #   the abbreviation's own designation is not read as a use.
        #
        # mn_category is :style rather than :structure: the requirement is a
        # presentation convention (when to spell a term in full); the model
        # traversal is only the detection mechanism.
        class AbbrevFirstUseRule < Base
          code "ISO_53"

          policy category: "Abbreviated terms",
                 rule: "expand an abbreviated term at first use — full term followed by the abbreviated term in brackets; expand in both Title and Scope; a list of abbreviated terms makes first-use expansion elsewhere optional",
                 source: :house_style, mn_category: :style

          include DocumentOrderWalk

          # Tracked abbreviation shape: an uppercase-led token of two to ten
          # letters/digits. Truncated lowercase forms and single-letter
          # symbols are out of scope: matching them against running text
          # reliably needs word-list support (issue #1705 tranche D).
          ABBREVIATION_SHAPE = /\A\p{Lu}[\p{L}\p{N}]{1,9}\z/.freeze

          ABBREVIATED_TERMS_TYPE = "abbreviated_terms".freeze
          ABBREVIATED_TERMS_TITLE = /abbreviated\s+terms/i.freeze

          # Expansion form: the full term immediately followed by the
          # abbreviation in round brackets, on one line. The lead-in stops
          # at sentence punctuation, so an earlier bare use in the same
          # sentence block is not swallowed into a later expansion. NBSP
          # between words and parens matches as well.
          EXPANSION_TEMPLATE = "[\\p{L}][^()\\n.;:!?]{0,80}\\(\\s*%s\\s*\\)".freeze

          ISO_TERMS_SECTION =
            Metanorma::Iso::Document::Sections::IsoTermsSection
          ISO_TERM_CLASS = Metanorma::Iso::Document::Terms::IsoTerm
          DEFINITION_LIST_CLASS =
            Metanorma::Document::Components::Lists::DefinitionList
          DT_CLASS = Metanorma::Document::Components::Lists::DtElement
          ISO_CLAUSE_CLASS = Metanorma::Iso::Document::Sections::IsoClauseSection
          DEFINITIONS_SECTION_CLASS =
            Metanorma::Standoc::Document::Sections::DefinitionSection

          def applicable?(context)
            !context.root.nil?
          end

          def check(context)
            root = context.root
            abbrevs = declared_abbreviations(root)
            return [] if abbrevs.empty?

            issues = []
            issues.concat(check_titles(root, abbrevs))
            issues.concat(check_scopes(root, abbrevs))
            return issues if abbreviated_terms_list?(root)

            issues.concat(check_running_text(root, abbrevs))
            issues.concat(check_term_entries(root, abbrevs))
            issues
          end

          private

          # Declared abbreviations, keyed by abbreviated form.
          def declared_abbreviations(root)
            abbrevs = {}
            each_document_node(root) do |node, ancestors|
              case node
              when DEFINITION_LIST_CLASS
                next unless inside_abbreviated_terms_list?(ancestors)

                Array(node.dt).each do |dt|
                  record_abbreviation(abbrevs, extract_text(dt))
                end
              when ISO_TERM_CLASS
                designation_abbreviations(node).each do |abbr|
                  record_abbreviation(abbrevs, abbr)
                end
              end
            end
            abbrevs
          end

          def record_abbreviation(abbrevs, text)
            abbr = text.to_s.strip
            return if abbr.empty?
            return unless abbr.match?(ABBREVIATION_SHAPE)

            abbrevs[abbr] = true
          end

          def inside_abbreviated_terms_list?(ancestors)
            ancestors.any? { |a| abbreviated_terms_definitions?(a) }
          end

          # A <definitions> section typed abbreviated_terms or titled
          # "Abbreviated terms".
          def abbreviated_terms_definitions?(node)
            node.is_a?(DEFINITIONS_SECTION_CLASS) &&
              (node.type.to_s == ABBREVIATED_TERMS_TYPE ||
               extract_text(node.title).match?(ABBREVIATED_TERMS_TITLE))
          end

          def abbreviated_terms_list?(root)
            each_document_node(root).any? do |node, _|
              abbreviated_terms_definitions?(node)
            end
          end

          # Abbreviated designations of a term entry: preferred/admitted/
          # deprecates designations whose expression carries an
          # <abbreviation-type>; the designation name is the abbreviated
          # form.
          def designation_abbreviations(term)
            designations = Array(term.preferred) +
              Array(term.admitted) + Array(term.deprecates)
            designations.filter_map do |designation|
              expression = designation.expression
              next if expression.nil?
              next if expression.abbreviation_type.nil? ||
                expression.abbreviation_type.to_s.empty?

              Array(expression.name).map { |n| extract_text(n) }.join.strip
            end
          end

          # Title: the abbreviated term is expanded within the Title itself.
          def check_titles(root, abbrevs)
            issues = []
            flagged = {}
            title_strings(root).each do |title|
              abbrevs.each_key do |abbr|
                next if flagged[abbr]
                next unless use_before_expansion?(title, abbr)

                flagged[abbr] = true
                issues << build_issue(location: "IsoBibliographicItem",
                                      params: [abbr, "Title"])
              end
            end
            issues
          end

          def title_strings(root)
            titles = root.bibdata&.titles
            return [] unless titles

            items = titles.respond_to?(:items) ? Array(titles.items) : Array(titles)
            items
              .select { |t| t.class.method_defined?(:value) }
              .map { |t| t.value.to_s }
              .uniq
          end

          # Scope: expanded within the Scope itself; abbreviated alone is
          # acceptable on later instances inside it.
          def check_scopes(root, abbrevs)
            issues = []
            seen = {}
            each_document_node(root) do |node, _|
              next unless scope_clause?(node)

              scope_text = subtree_text(node)
              abbrevs.each_key do |abbr|
                next if seen[[node.object_id, abbr]]
                next unless use_before_expansion?(scope_text, abbr)

                seen[[node.object_id, abbr]] = true
                issues << build_issue(location: model_location(node),
                                      params: [abbr, "Scope"])
              end
            end
            issues
          end

          def scope_clause?(node)
            node.is_a?(ISO_CLAUSE_CLASS) && node.type.to_s == "scope"
          end

          def in_scope_clause?(ancestors)
            ancestors.any? { |a| scope_clause?(a) }
          end

          # Running text: expand at first use in document order. Paragraphs
          # inside terms sections are the per-entry check's domain; inside
          # the Scope the dedicated scope check applies; inside a list's
          # <dt> the text is the declaration itself.
          def check_running_text(root, abbrevs)
            issues = []
            expanded = Hash.new(false)
            flagged = {}
            each_document_paragraph(root) do |paragraph, ancestors|
              next if under_ancestor?(ancestors, ISO_TERMS_SECTION)
              next if under_ancestor?(ancestors, DT_CLASS)
              next if in_scope_clause?(ancestors)

              text = ordered_text(paragraph)
              abbrevs.each_key do |abbr|
                next if flagged[abbr]

                use_events(text, abbr).each do |offset, kind|
                  if kind == :expansion
                    expanded[abbr] = true
                  elsif !expanded[abbr]
                    flagged[abbr] = true
                    issues << build_issue(
                      location: model_location(paragraph),
                      params: [abbr, "the body of the document"]
                    )
                    break
                  end
                end
              end
            end
            issues
          end

          # Clause 3: expand at first use in each entry.
          def check_term_entries(root, abbrevs)
            issues = []
            seen = {}
            each_document_node(root) do |node, _|
              next unless node.is_a?(ISO_TERM_CLASS)

              entry_text = term_entry_text(node)
              abbrevs.each_key do |abbr|
                next if seen[[node.object_id, abbr]]
                next unless use_before_expansion?(entry_text, abbr)

                seen[[node.object_id, abbr]] = true
                issues << build_issue(
                  location: model_location(node),
                  params: [abbr, "the terms and definitions entry"]
                )
              end
            end
            issues
          end

          # The running text of a term entry: definitions, notes, examples
          # and paragraphs — not the preferred/admitted/deprecates forms.
          def term_entry_text(term)
            parts = Array(term.p)
            Array(term.definition).each do |definition|
              parts.concat(Array(definition.verbal_definition))
            end
            parts.concat(Array(term.termnote))
            parts.concat(Array(term.termexample))
            parts.concat(Array(term.admonition))
            parts.map { |n| extract_text(n) }.join(" ")
          end

          # True when the first occurrence of +abbr+ in +text+ is a bare
          # use, i.e. no expansion of it appears at or before that position.
          def use_before_expansion?(text, abbr)
            events = use_events(text, abbr)
            !events.empty? && events.first[1] == :bare
          end

          # Word-boundary occurrences of +abbr+ that sit outside an
          # expansion parenthetical.
          def bare_occurrences(text, abbr)
            spans = expansion_spans(text, abbr)
            offsets = []
            text.to_s.scan(/\b#{Regexp.escape(abbr)}\b/) do
              offsets << Regexp.last_match.begin(0)
            end
            offsets.reject { |offset| spans.any? { |range| range.cover?(offset) } }
          end

          # Expansion matches as (begin, kind) event pairs plus bare
          # occurrences, sorted by position.
          def use_events(text, abbr)
            events = bare_occurrences(text, abbr).map { |o| [o, :bare] }
            expansion_spans(text, abbr).each do |range|
              events << [range.begin, :expansion]
            end
            events.sort_by(&:first)
          end

          # Expansion matches as position ranges, from the full-term lead-in
          # to the closing bracket.
          def expansion_spans(text, abbr)
            pattern = Regexp.new(format(EXPANSION_TEMPLATE, Regexp.escape(abbr)))
            spans = []
            text.to_s.scan(pattern) do
              spans << (Regexp.last_match.begin(0)...Regexp.last_match.end(0))
            end
            spans
          end
        end
      end
    end
  end
end
