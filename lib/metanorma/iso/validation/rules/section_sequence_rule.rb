# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # ISO_28 / ISO_32 / ISO_33 / ISO_34 / ISO_36 / ISO_37 / ISO_38 /
        # ISO_40 / ISO_41: section sequence validation.
        #
        # Walks the document's top-level sections in document order (using
        # lutaml-model's element_order) and enforces ISO ordering:
        #   Foreword → (Introduction)? → Scope → Terms → Clauses →
        #   Annexes → Normative References → (Bibliography)?
        #
        # Different ISO_N keys fire for each kind of violation. Faithful
        # port of the legacy sections_sequence_validate state machine.
        class SectionSequenceRule < Base
          code "ISO_28"

          SectionItem = Struct.new(:kind, :node, keyword_init: true)

          def applicable?(context)
            !context.root.nil?
          end

          def check(context)
            items = build_ordered_items(context.root)
            issues = []
            run_state_machine(items, context.state, issues)
            issues
          end

          private

          def build_ordered_items(root)
            items = []
            append_preface_items(root, items)
            append_sections_items(root, items)
            append_annex_items(root, items)
            append_bibliography_items(root, items)
            items
          end

          def append_preface_items(root, items)
            preface = root.preface
            return unless preface

            order = document_order_of(preface)
            order.each do |name|
              case name
              when "foreword"     then items << SectionItem.new(kind: :foreword, node: preface.foreword) if preface.foreword
              when "introduction" then items << SectionItem.new(kind: :introduction, node: preface.introduction) if preface.introduction
              end
            end
          end

          def append_sections_items(root, items)
            sections = root.sections
            return unless sections

            order = document_order_of(sections)
            clause_idx = 0
            terms_idx = 0
            order.each do |name|
              case name
              when "clause"
                clause = Array(sections.clause)[clause_idx]
                items << SectionItem.new(kind: clause_kind(clause), node: clause) if clause
                clause_idx += 1
              when "terms"
                terms = sections.terms
                items << SectionItem.new(kind: :terms, node: terms) if terms
                terms_idx += 1
              when "definitions"
                if has_definitions?(sections) && sections.definitions
                  items << SectionItem.new(kind: :definitions, node: sections.definitions)
                end
              end
            end
          end

          def append_annex_items(root, items)
            Array(root.annex).each { |a| items << SectionItem.new(kind: :annex, node: a) }
          end

          def append_bibliography_items(root, items)
            bibliography = root.bibliography
            return unless bibliography

            order = document_order_of(bibliography)
            refs_idx = 0
            order.each do |name|
              next unless name == "references"

              refs = Array(bibliography.references)[refs_idx]
              next unless refs

              kind = normative?(refs) ? :normative_references : :bibliography
              items << SectionItem.new(kind: kind, node: refs)
              refs_idx += 1
            end
          end

          def document_order_of(node)
            return [] unless node.class.method_defined?(:element_order)

            node.element_order.filter_map { |e| name_of(e) }
          end

          def name_of(entry)
            return entry.name if entry.is_a?(Lutaml::Xml::Element)
            return entry if entry.is_a?(String)

            entry.respond_to?(:name) ? entry.name : nil
          rescue StandardError
            nil
          end

          def has_definitions?(sections)
            sections.class.method_defined?(:definitions)
          end

          def clause_kind(clause)
            clause.type == "scope" ? :scope : :clause
          end

          def normative?(refs)
            refs.normative == true || refs.normative.to_s == "true"
          end

          def run_state_machine(items, state, issues)
            remaining = items.dup
            current = step_start(remaining, issues)
            current = state.vocab ? step_body_vocab(remaining, current, issues)
                                   : step_body(remaining, current, issues)
            step_end(remaining, current, issues)
          end

          # Faithful port of seqcheck: shift the first item off +remaining+,
          # emit ISO_28 with +msg+ if the shifted item's kind is not in
          # +accepted_kinds+. Returns the shifted item (or nil).
          def shift_check(remaining, msg, accepted_kinds, issues, code)
            item = remaining.shift
            return nil if item.nil?

            unless accepted_kinds.include?(item.kind)
              emit(issues, code, item, msg)
            end
            item
          end

          def step_start(remaining, issues)
            shift_check(remaining, "Initial section must be (content) Foreword",
                        [:foreword], issues, "ISO_28")
            n = remaining.first
            shift_check(remaining,
                        "Prefatory material must be followed by (clause) Scope",
                        [:introduction, :scope], issues, "ISO_28")
            if n && n.kind == :introduction
              shift_check(remaining,
                          "Prefatory material must be followed by (clause) Scope",
                          [:scope], issues, "ISO_28")
            end
            shift_check(remaining,
                        "Normative References must be followed by Terms and Definitions",
                        [:terms], issues, "ISO_28")

            current = remaining.shift
            current = remaining.shift if current && current.kind == :definitions
            current
          end

          def step_body(remaining, current, issues)
            if current.nil? || (current.kind != :clause && current.kind != :scope)
              emit(issues, "ISO_32", current)
            end
            if current && current.kind != :clause && current.kind != :scope
              emit(issues, "ISO_33", current)
            end
            if current && current.kind == :scope
              emit(issues, "ISO_34", current)
            end

            current = remaining.shift
            while current && (current.kind == :clause || current.kind == :scope)
              emit(issues, "ISO_34", current) if current.kind == :scope
              current = remaining.shift
            end

            unless current && %i[annex normative_references bibliography].include?(current.kind)
              emit(issues, "ISO_36", current)
            end

            current
          end

          def step_body_vocab(remaining, current, issues)
            while current && %i[clause scope terms].include?(current.kind)
              current = remaining.shift
            end

            unless current && %i[annex normative_references bibliography].include?(current.kind)
              emit(issues, "ISO_37", current)
            end

            current
          end

          def step_end(remaining, current, issues)
            while current && current.kind == :annex
              current = remaining.shift
              if current.nil? && !remaining.empty?
                emit(issues, "ISO_38", current)
                return
              end
            end

            return if current.nil?

            unless current.kind == :normative_references
              emit(issues, "ISO_38", current)
            end

            current = remaining.shift
            return if current.nil?

            unless current.kind == :bibliography
              emit(issues, "ISO_40", current)
            end

            emit(issues, "ISO_41", current) unless remaining.empty?
          end

          def shift_check_unused(_remaining, _msg, _accepted_kinds, _issues, _code)
            raise "should not be called"
          end

          def emit(issues, code, item, msg = nil)
            params = msg ? [msg] : []
            location = item && item.node ? model_location(item.node) : nil
            issues << Metanorma::Iso::Validation::Issue.from_finding(
              code: code, location: location, params: params
            )
          end
        end
      end
    end
  end
end
