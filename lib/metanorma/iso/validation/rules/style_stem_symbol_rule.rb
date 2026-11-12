# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warning: quantity symbols are single letters (Latin or
        # Greek, lower or upper case) carrying their distinguishing
        # subscripts; a multi-letter alphabetic symbol in a stem is a
        # violation (ISO House Style, Symbols > Quantities and units).
        #
        # The stem content is parsed with plurimath and inspected at the
        # AST level. Detection is conservative, by construction:
        #
        # - only runs of adjacent single-letter identifier symbols are
        #   flagged (plurimath parses a bare multi-letter word as a run
        #   of one-letter symbols), plus multi-character <mi> content in
        #   MathML stems, which is the same multi-letter identifier;
        # - quoted text (Function::Text), numbers, operators and named
        #   single symbols (Greek letters, recognised functions) pass;
        # - subscript and superscript content is exempt: descriptive
        #   subscripts are multi-letter by design (E_"tot", x_(ij));
        # - a run immediately followed by fenced content passes: it is
        #   the function-application shape (f(x), unit(mm));
        # - ISO 80000-11 characteristic numbers are exempt: their two-
        #   letter symbols are standard by definition (Re, Fo, Fr, Gr,
        #   Ma, Nu, Pe, Pr, Ra, Sc, Sh, St, We, Bi, Al, ...);
        # - differential notation is exempt (dN, dx, dQ);
        # - a run continuing a chemical name -- a chemical prefix
        #   followed by a hyphen, the legal italic form policed by
        #   StyleChemPrefixRule -- is exempt (n-butane, cis-2-butene).
        class StyleStemSymbolRule < StyleRule
          code "ISO_144"

          policy category: "Symbols > Quantities and units",
                 rule: "quantity symbols are single letters (Latin or Greek) " \
                       "with subscripts; multi-letter alphabetic symbols are " \
                       "violations",
                 source: :house_style, mn_category: :style

          include StemMath

          LABEL = "style: quantity symbol '%s' is multi-letter; use a " \
                  "single letter with subscripts".freeze

          # ISO 80000-11 characteristic numbers: dimensionless quantities
          # whose symbols are two letters by convention. Closed list.
          CHARACTERISTIC_NUMBERS = %w[
            Al Ar Bd Bi Co De Ec Eu Fo Fr Gr Gz Kn Le Lu Ma Nu Pe Pr
            Ra Re Ri Ro Sc Sh Sr St We
          ].freeze

          # Spelled-out Greek letter names: a MathML <mi>alpha</mi> is
          # the letter alpha, not a quantity symbol.
          GREEK_NAMES = %w[
            alpha beta gamma delta epsilon zeta eta theta iota kappa
            lambda mu nu xi omicron pi rho sigma tau upsilon phi chi
            psi omega
          ].freeze

          # Chemical prefixes that may open a chemical name in a stem.
          CHEM_PREFIXES = %w[cis trans tert n N o p m].freeze

          # Differential shape: the operator d followed by one quantity
          # letter (dN, dx, dQ).
          DIFFERENTIAL_REGEX = /\Ad[A-Za-z]\z/.freeze

          SINGLE_LETTER_REGEX = /\A[A-Za-z]\z/.freeze
          MULTI_LETTER_REGEX = /\A[A-Za-z]{2,}\z/.freeze

          def check(context)
            issues = []
            each_stem(context.root) do |stem|
              issues.concat(stem_issues(stem))
            end
            issues
          end

          private

          def stem_issues(stem)
            source = math_source(stem)
            return [] unless source

            formula = parse_stem(*source)
            return [] unless formula

            texts = []
            collect_runs(formula) { |text| texts << text }
            texts.uniq
              .select { |text| contiguous_in_source?(source, text) }
              .map { |text| build_warning(stem, format(LABEL, text)) }
          end

          # An AsciiMath run whose letters are not glued in the source
          # is a product of spaced quantity symbols ("rho v L"), not a
          # multi-letter symbol ("vol"): ISO 80000-1 writes quantity
          # products with a half-space, so only contiguous source
          # spellings flag. MathML carries no spacing: adjacent <mi>
          # content is already glued, so every candidate stands.
          def contiguous_in_source?(source, text)
            return true unless source[0] == :asciimath

            source[1].to_s.include?(text)
          end

          # -- identifier-run detection --------------------------------

          # Sub/superscript content: parameter_two of the sub (Base) and
          # superscript (Power, PowerBase) functions. Exempt from flagging.
          SUB_SUP_FUNCTIONS = [
            Plurimath::Math::Function::Base,
            Plurimath::Math::Function::Power,
            Plurimath::Math::Function::PowerBase,
          ].freeze

          # Sibling sequences live in two container shapes: Formula
          # carries its children in +value+, Fenced carries its content
          # in +parameter_two+. Every other node is walked through its
          # operand slots instead.
          def sequence_children(node)
            if node.is_a?(Plurimath::Math::Formula)
              Array(node.value).select { |c| c.is_a?(Plurimath::Math::Core) }
            elsif node.is_a?(Plurimath::Math::Function::Fenced)
              Array(node.parameter_two)
                .select { |c| c.is_a?(Plurimath::Math::Core) }
            end
          end

          private

          def collect_runs(node, &block)
            children = sequence_children(node)
            if children
              walk_sequence(children, &block)
            else
              walk_slots(node, &block)
            end
          end

          def walk_sequence(children, &block)
            run = []
            # History of completed sibling entries, as
            # [:run|"text"] / [:symbol|"value"] / [:minus] / [:other]:
            # the chemical-name exemption reads the two entries
            # preceding a candidate run.
            history = []
            children.each do |child|
              if run_member?(child)
                run << child
                next
              end
              close_run(run, history, next_sibling: child, &block)
              run = []
              walk_non_member(child, history, &block)
            end
            close_run(run, history, next_sibling: nil, &block)
          end

          # Decide one closed run: flag it, record it in the history
          # either way.
          def close_run(run, history, next_sibling:, &block)
            return if run.empty?

            text = run.map(&:value).join
            if run.size >= 2 &&
                !exempt_run?(text, history, next_sibling: next_sibling)
              yield(text)
            end
            history << [:run, text]
          end

          def walk_non_member(child, history, &block)
            if multi_letter_symbol?(child)
              text = child.value
              unless exempt_run?(text, history, next_sibling: nil)
                yield(text)
              end
              history << [:symbol, text]
            else
              collect_runs(child, &block)
              history << [history_entry_kind(child), nil]
            end
          end

          def history_entry_kind(node)
            return :minus if minus_node?(node)

            :other
          end

          # Run membership: a symbol node whose value is exactly one
          # alphabetic character. Named symbols (Greek letters, arrows,
          # operators) carry no single-letter value and break runs.
          def run_member?(node)
            node.is_a?(Plurimath::Math::Symbols::Symbol) &&
              node.value.to_s.match?(SINGLE_LETTER_REGEX)
          end

          # A MathML <mi> with multi-character content parses to one
          # symbol node carrying the whole string: the upright multi-
          # letter identifier shape.
          def multi_letter_symbol?(node)
            node.is_a?(Plurimath::Math::Symbols::Symbol) &&
              node.value.to_s.match?(MULTI_LETTER_REGEX)
          end

          def minus_node?(node)
            node.class.name.split("::").last == "Minus"
          end

          # -- exemptions -----------------------------------------------

          def exempt_run?(text, history, next_sibling:)
            return true if CHARACTERISTIC_NUMBERS.include?(text)
            return true if GREEK_NAMES.include?(text)
            return true if text.match?(DIFFERENTIAL_REGEX)
            return true if next_sibling.is_a?(Plurimath::Math::Function::Fenced)
            return true if chemical_prefix_token?(text, next_sibling)
            return true if chemical_continuation?(history)

            false
          end

          # The run is the chemical prefix itself ("cis", "trans",
          # "tert"): legal per House Style when it opens a chemical
          # name, i.e. when a hyphen follows.
          def chemical_prefix_token?(text, next_sibling)
            CHEM_PREFIXES.include?(text) && minus_node?(next_sibling)
          end

          # The run continues a chemical name: an italic chemical prefix
          # followed by a hyphen, with optional digit locants in between
          # ("n-butane", "cis-2-butene", "trans-1,2-dimethyl...").
          def chemical_continuation?(history)
            return false unless history.size >= 2
            return false unless history[-1].first == :minus

            prefix = preceding_prefix(history, 2)
            return true if prefix

            # Digit locants: [.., prefix, minus, digit, minus, run]
            return false unless history.size >= 4
            return false unless history[-3].first == :minus

            !preceding_prefix(history, 4).nil?
          end

          # The history entry +offset+ entries before the end carries a
          # chemical prefix text: a completed run or a multi-character
          # symbol ("n", "cis", "N,N").
          def preceding_prefix(history, offset)
            entry = history[-offset]
            return unless entry

            text = entry.last
            text if CHEM_PREFIXES.include?(text)
          end

          # Operand slots of non-sequence nodes. Sub/superscript content
          # (+parameter_two+ of Base/Power/PowerBase) is skipped: it is
          # exempt from flagging.
          def walk_slots(node, &block)
            %i(parameter_one parameter_two parameter_three).each do |slot|
              next unless node.class.method_defined?(slot)
              next if slot == :parameter_two && sub_sup?(node)

              Array(node.public_send(slot)).each do |child|
                next unless child.is_a?(Plurimath::Math::Core)

                collect_runs(child, &block)
              end
            end
          end

          def sub_sup?(node)
            SUB_SUP_FUNCTIONS.any? { |klass| node.is_a?(klass) }
          end
        end
      end
    end
  end
end
