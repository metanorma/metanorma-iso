# frozen_string_literal: true

require "set"

module Metanorma
  module Iso
    module Sts
      module ParityValidator
        # Result of a parity check. Reports which MN HTML elements are
        # missing from the STS HTML.
        class Report
          attr_reader :missing_headings, :missing_paragraphs,
                      :missing_table_cells, :missing_list_items,
                      :missing_images, :missing_notes,
                      :word_coverage_percent, :paragraph_coverage_percent

          def initialize(mn_html:, sts_html:)
            @mn_html = Normaliser.strip_chrome(mn_html)
            # The STS side gets a lighter strip: its own heading anchors
            # (.h-anchor) and non-content elements. The TOC/nav/footer
            # stay — the MN side keeps its equivalents too, and removing
            # them on one side only would manufacture mismatches.
            @sts_html = Normaliser.strip_chrome(sts_html, selectors: STS_CHROME_SELECTORS)
            compute_missing_sets
            compute_coverage
          end

          STS_CHROME_SELECTORS = %w[script style head .h-anchor .li-label].freeze

          def pass?
            [
              @missing_headings, @missing_paragraphs,
              @missing_table_cells, @missing_list_items,
              @missing_images, @missing_notes
            ].all?(&:empty?)
          end

          def to_h
            {
              pass: pass?,
              missing_headings: @missing_headings.to_a,
              missing_paragraphs: @missing_paragraphs.to_a,
              missing_table_cells: @missing_table_cells.to_a,
              missing_list_items: @missing_list_items.to_a,
              missing_images: @missing_images.to_a,
              missing_notes: @missing_notes.to_a,
              word_coverage_percent: @word_coverage_percent,
              paragraph_coverage_percent: @paragraph_coverage_percent
            }
          end

          private

          def compute_missing_sets
            mn = extract_elements(@mn_html)
            sts = extract_elements(@sts_html)

            @missing_headings = mn[:headings] - sts[:headings]
            @missing_paragraphs = mn[:paragraphs] - sts[:paragraphs]
            @missing_table_cells = mn[:table_cells] - sts[:table_cells]
            @missing_list_items = mn[:list_items] - sts[:list_items]
            @missing_images = mn[:images] - sts[:images]
            @missing_notes = mn[:notes] - sts[:notes]
          end

          def extract_elements(html)
            doc = Nokogiri::HTML(html)
            {
              headings: extract_set(doc, "//h1 | //h2 | //h3 | //h4 | //h5 | //h6",
                                    method(:heading_normalised)),
              paragraphs: extract_set(doc, "//p", method(:paragraph_normalised)),
              # Cells that only carry a table note (class table-notes)
              # compare in the notes set, not here.
              table_cells: extract_set(doc, "//td[not(contains(@class,'table-notes'))] | //th",
                                       method(:Normaliser_paragraph)),
              list_items: extract_set(doc, "//li", method(:list_item_normalised)),
              images: doc.xpath("//img/@src").map(&:value).to_set,
              # Note bodies wherever they live (section flow or tfoot
              # table-notes cells); the kind label is included by both
              # renderers ("NOTE …").
              notes: extract_set(doc, "//div[contains(@class,'note')] | //td[contains(@class,'table-notes')]",
                                 method(:Normaliser_paragraph))
            }
          end

          def extract_set(doc, xpath, normaliser_method)
            doc.xpath(xpath).map do |node|
              normaliser_method.call(node.text)
            end.reject(&:empty?).to_set
          end

          def heading_normalised(text)
            Normaliser.heading_text(text)
          end

          def paragraph_normalised(text)
            Normaliser.paragraph_text(text)
          end

          def list_item_normalised(text)
            Normaliser.list_item_text(text)
          end

          def Normaliser_paragraph(text)
            Normaliser.normalise(text)
          end

          def compute_coverage
            mn_text = Normaliser.normalise(Nokogiri::HTML(@mn_html).text)
            sts_text = Normaliser.normalise(Nokogiri::HTML(@sts_html).text)
            mn_words = mn_text.split.to_set
            sts_words = sts_text.split.to_set
            covered = mn_words.count { |w| sts_words.include?(w) }
            @word_coverage_percent = if mn_words.empty?
                                       100.0
                                     else
                                       (covered.to_f * 100.0 / mn_words.size).round(2)
                                     end

            mn_paras = Nokogiri::HTML(@mn_html).css("p").map do |p|
              Normaliser.normalise(p.text)
            end.reject(&:empty?).reject { |t| t.length < 30 }.to_set
            sts_paras = Nokogiri::HTML(@sts_html).css("p").map do |p|
              Normaliser.normalise(p.text)
            end.reject(&:empty?).to_set
            pcovered = mn_paras.count { |p| sts_paras.include?(p) }
            @paragraph_coverage_percent = if mn_paras.empty?
                                            100.0
                                          else
                                            (pcovered.to_f * 100.0 / mn_paras.size).round(2)
                                          end
          end
        end
      end
    end
  end
end
