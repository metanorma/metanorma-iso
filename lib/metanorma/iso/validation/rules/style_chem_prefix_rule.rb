# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warning: in chemical names, the locant prefixes -- cis-,
        # trans-, tert-, n-, N-, N,N-, o-, p-, m- -- are italic
        # (ISO House Style, Symbols > Chemical formulae). A prefix token
        # carried upright in stem content is a violation.
        #
        # The stem content is parsed with plurimath and flattened into a
        # styled character sequence: plurimath's AST carries both the
        # math source (AsciiMath and MathML parse to the same node
        # vocabulary) and the styling MathML declares through
        # +mathvariant+ (Function::FontStyle wrappers), so italicity is
        # inspectable without re-reading raw markup.
        #
        # Conservative, by construction:
        #
        # - only the closed prefix list is scanned, and only when
        #   followed by a hyphen and a chemical-looking token (letter or
        #   digit): "n-butane", "cis-2-butene";
        # - the prefix must not be preceded by a letter (no matches
        #   inside words: the "cis" of "decision" does not match);
        # - a prefix is flagged when an occurrence renders non-italic.
        #   MathML defaults make this the upright case: multi-character
        #   <mi> content and <mtext> render upright, a single-character
        #   <mi> renders italic. AsciiMath quoted text ("n") is upright,
        #   an unquoted prefix letter is an italic identifier. A prefix
        #   italic through mathvariant="italic" is the legal form and is
        #   never flagged; a mathvariant="normal" (or bold, monospace,
        #   ...) wrapper forces its content upright and is checked;
        # - prose is never scanned (stems only), units markup passes.
        class StyleChemPrefixRule < StyleRule
          code "ISO_145"

          policy category: "Symbols > Chemical formulae",
                 rule: "chemical locant prefixes (cis-, trans-, tert-, n-, " \
                       "N-, N,N-, o-, p-, m-) are italic in chemical names",
                 source: :house_style, mn_category: :style

          include StemMath

          LABEL = "style: chemical prefix '%s' is not italic; locant " \
                  "prefixes are italic in chemical names".freeze

          # The closed prefix list, longest first: "N,N" matches before
          # a lone "N" would.
          PREFIXES = %w[N,N trans tert cis n N o p m].freeze

          # A prefix occurrence: not preceded by a letter (no matches
          # inside words), then the prefix, a hyphen, and a
          # chemical-looking token (letter or digit).
          PREFIX_REGEX = /
            (?<![A-Za-z])(#{PREFIXES.sort_by { |p| -p.length }.join("|")})
            -(?=[A-Za-z0-9])
          /x.freeze

          # Flattened character styles: :italic, :upright, or nil for the
          # rendering defaults (single-letter symbols italic, text and
          # multi-character content upright).
          ITALIC = :italic
          UPRIGHT = :upright
          DEFAULT_STYLE = nil

          # Value-less operator symbols carry punctuation the prefix
          # shape needs: they are subclasses of Symbols::Symbol whose
          # +value+ is nil. Closed map; unmapped operators emit nothing.
          OPERATOR_TEXT = {
            "Minus" => "-",
            "Comma" => ",",
          }.freeze

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

            chars = [] # [[character, :italic, :upright, or DEFAULT_STYLE]]
            flatten(formula, DEFAULT_STYLE, chars)
            text = chars.map(&:first).join

            upright_prefixes = []
            text.to_enum(:scan, PREFIX_REGEX).each do
              match = Regexp.last_match
              prefix = match[1]
              span = chars[match.begin(1), prefix.length] || []
              next if span.all? { |(_, style)| style == ITALIC }

              upright_prefixes << prefix
            end

            upright_prefixes.uniq.map do |prefix|
              build_warning(stem, format(LABEL, prefix))
            end
          end

          # -- styled flattening ----------------------------------------

          # Pre-order flatten of the AST into styled characters. Leaf
          # styles follow the rendering defaults; a FontStyle wrapper
          # overrides its content's style outright (+mathvariant+ is a
          # setting, not a suggestion).
          def flatten(node, style, chars)
            if node.is_a?(Plurimath::Math::Function::FontStyle)
              child_style = node.is_a?(
                Plurimath::Math::Function::FontStyle::Italic
              ) ? ITALIC : UPRIGHT
              walk_children(node, child_style, chars)
            elsif node.is_a?(Plurimath::Math::Function::Text)
              append_text(node.parameter_one.to_s, style, chars)
            elsif (operator = operator_text(node))
              chars << [operator, style || UPRIGHT]
            elsif node.is_a?(Plurimath::Math::Number)
              append_text(node.value.to_s, style, chars)
            elsif node.is_a?(Plurimath::Math::Symbols::Symbol)
              default = node.value.to_s.length == 1 ? ITALIC : UPRIGHT
              effective = style || default
              node.value.to_s.each_char do |char|
                chars << [char, effective]
              end
            else
              walk_children(node, style, chars)
            end
          end

          # The punctuation of a value-less operator symbol, or nil when
          # the node is not one (its class name is the only identifier
          # plurimath gives them).
          def operator_text(node)
            OPERATOR_TEXT[node.class.name.split("::").last]
          end

          def append_text(text, style, chars)
            effective = style || UPRIGHT
            text.each_char { |char| chars << [char, effective] }
          end

          def walk_children(node, style, chars)
            %i(value parameter_one parameter_two parameter_three).each do |slot|
              next unless node.class.method_defined?(slot)

              Array(node.public_send(slot)).each do |child|
                next unless child.is_a?(Plurimath::Math::Core)

                flatten(child, style, chars)
              end
            end
          end
        end
      end
    end
  end
end
