# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      module ParityValidator
        # Text normalisation shared by all comparison logic.
        class Normaliser
          CHROME_SELECTORS = %w[
            script style head nav
            .title-section .prefatory-section
            .toc #toc
            .coverpage_docnumber .coverpage_techcommittee
            .coverpage_docstage .coverpage_warning
            .doctitle-fr .doc-title
            .btn .collapse-button .collapse-group
            .anchor .h-anchor
          ].freeze

          # MN wraps heading text in `<a class="header">…</a>`. Removing
          # the node would discard the title text; unwrap it instead so
          # the content survives but the link chrome is gone.
          UNWRAP_SELECTORS = %w[.header].freeze

          BLOCK_BOUNDARY_ELEMENTS =
            %w[p div td th li h1 h2 h3 h4 h5 h6 section table tr
               ul ol dl dt dd].freeze

          def self.strip_chrome(html, selectors: CHROME_SELECTORS)
            doc = Nokogiri::HTML(html)
            UNWRAP_SELECTORS.each do |sel|
              doc.css(sel).each { |node| node.replace(node.children) }
            end
            selectors.each { |sel| doc.css(sel).remove }
            doc.css("body").first&.to_html || doc.to_html
          end

          def self.normalise(text)
            new_text = text.to_s
            new_text = unify_block_boundaries(new_text)
            # Collapse non-breaking spaces (U+00A0) and regular whitespace.
            new_text = new_text.gsub(/[⁡⁢⁣⁤]/, "")
            new_text = new_text.gsub(/[ \s]+/, " ")
            new_text = unify_dashes(new_text)
            new_text = new_text.gsub(/\s+/, " ").strip.downcase
            new_text
          end

          def self.unify_block_boundaries(text)
            regex = /(<\/(?:#{BLOCK_BOUNDARY_ELEMENTS.join("|")})>)/i
            text.gsub(regex, " \\1")
          end

          def self.unify_dashes(text)
            text.gsub(/[–—−]/, "-")
          end

          def self.strip_section_number(text)
            text.to_s.gsub(/\A\s*\d+(\.\d+)*[\s ]+/, "")
          end

          # Annex headings carry an obligation marker on one side only:
          # "Annex A (Informative) Examples" vs "Annex A Examples".
          # Whitespace handling is intentionally separate from the
          # marker match — the previous combined regex was flagged by
          # CodeQL for polynomial backtracking on adversarial whitespace.
          def self.strip_annex_obligation(text)
            stripped = text.to_s.gsub(/\((?:in|nor)formative\)/i, " ")
            stripped.squeeze(" ")
          end

          def self.strip_anchor_brackets(text)
            text.to_s.gsub(/\[([A-Z0-9][A-Z0-9_]*)\]/, '\1')
          end

          def self.heading_text(text)
            # Normalise FIRST: the number/title delimiter is often a
            # non-breaking space, which only the normaliser collapses.
            normalise(strip_annex_obligation(strip_section_number(normalise(text))))
          end

          def self.paragraph_text(text)
            normalise(strip_anchor_brackets(text))
          end

          # List-item markers ("—", "•", "1.") are rendered as literal
          # text on one side and CSS on the other; compare the content.
          def self.list_item_text(text)
            normalise(text.to_s.sub(/\A\s*[-–—•‒]\s*/, ""))
          end
        end
      end
    end
  end
end
