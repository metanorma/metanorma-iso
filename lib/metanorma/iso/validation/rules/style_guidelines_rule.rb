# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warning: the word "guidelines" is avoided in titles
        # (ISO House Style prefers "guidance"). Scoped to clause,
        # subclause, table and figure titles only — body prose is not
        # flagged by this rule.
        #
        # Walks the clause/annex hierarchy for section titles, and the
        # whole tree for table/figure captions (<name> elements).
        class StyleGuidelinesRule < StyleRule
          code "ISO_92"

          policy category: "Spelling and wording > Guidance or guidelines",
                 rule: "'guidance' is preferred over 'guidelines' in titles and captions",
                 source: :house_style, mn_category: :style

          GUIDELINES_REGEX = /\bguidelines\b/i.freeze

          TITLE_LABEL = "title style: 'guidelines' (House Style " \
                        "prefers 'guidance')".freeze
          CAPTION_LABEL = "caption style: 'guidelines' (House Style " \
                          "prefers 'guidance')".freeze

          def check(context)
            issues = []
            each_titled_section(context.root) do |section|
              issues.concat(title_issues(section))
            end
            [
              Metanorma::Document::Components::Tables::TableBlock,
              Metanorma::Document::Components::AncillaryBlocks::FigureBlock,
            ].each do |klass|
              each_instance_of(context.root, klass) do |block|
                issues.concat(caption_issues(block))
              end
            end
            issues
          end

          private

          # Yield every clause/annex section (recursive), including
          # subclauses, that carries a title.
          def each_titled_section(root, &block)
            sections = root.sections
            walk_titled_sections(sections, &block) if sections
            Array(root.annex).each do |annex|
              walk_titled_sections(annex, &block)
            end
          end

          def walk_titled_sections(node, &block)
            return unless node

            yield(node) if titled?(node)
            Array(node.clause).each { |c| walk_titled_sections(c, &block) } if
              node.class.method_defined?(:clause)
          end

          def titled?(node)
            node.class.method_defined?(:title) && !node.title.nil?
          end

          def title_issues(section)
            check_text(section, extract_text(section.title).strip, TITLE_LABEL)
          end

          def caption_issues(block)
            return [] unless block.class.method_defined?(:name)

            name = block.name
            return [] if name.nil?

            check_text(block, extract_text(name).strip, CAPTION_LABEL)
          end

          def check_text(node, text, label)
            return [] if text.empty?
            return [] unless text.match?(GUIDELINES_REGEX)

            [build_warning(node, label)]
          end
        end
      end
    end
  end
end
