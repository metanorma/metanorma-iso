# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      # Renders the cover page from the document model's bibdata.
      #
      # The cover page appears as the first page of the DOCX and includes:
      #   - Document number
      #   - Document identifier (with stage/draft)
      #   - TC/SC/WG committee reference
      #   - Edition information
      #   - Date
      #   - Main title
      #   - Stage label
      #
      # All data comes from the model's bibdata attribute — no hardcoded text.
      class CoverRenderer
        STAGE_LABELS = {
          0 => "PWI stage", 10 => "NP stage", 20 => "WD stage",
          30 => "CD stage", 40 => "DIS stage", 50 => "FDIS stage",
          60 => "IS stage",
        }.freeze

        ORDINAL_SUFFIXES = { 1 => "st", 2 => "nd", 3 => "rd" }.freeze

        def initialize(resolver, context)
          @resolver = resolver
          @context = context
        end

        def render(bibdata, doc)
          return unless bibdata

          render_cover_large(doc, identifier_with_language(bibdata))
          render_cover_line(doc, doc_number(bibdata))
          render_cover_line(doc, committee_reference(bibdata))
          render_cover_line(doc, edition_text(bibdata))
          render_cover_line(doc, "")
          render_cover_line(doc, date_text(bibdata))
          render_cover_title(doc, main_title(bibdata))
          render_cover_subtitle(doc, subtitle(bibdata))
          render_cover_line(doc, "")
          render_cover_line(doc, stage_label(bibdata))
        end

        private

        def render_cover_line(doc, text)
          para = Uniword::Builder::ParagraphBuilder.new
          para.style = @resolver.paragraph_style(:cover_meta)
          para << text.to_s
          doc << para
        end

        def render_cover_large(doc, text)
          return if text.nil? || text.empty?

          para = Uniword::Builder::ParagraphBuilder.new
          para.style = @resolver.paragraph_style(:cover_large)
          para << text
          doc << para
        end

        def render_cover_title(doc, title_text)
          return if title_text.nil? || title_text.empty?

          para = Uniword::Builder::ParagraphBuilder.new
          para.style = @resolver.paragraph_style(:cover_title)
          para << title_text
          doc << para
        end

        def render_cover_subtitle(doc, subtitle_text)
          return if subtitle_text.nil? || subtitle_text.empty?

          para = Uniword::Builder::ParagraphBuilder.new
          para.style = @resolver.paragraph_style(:cover_subtitle)
          para << subtitle_text
          doc << para
        end

        def doc_number(bib)
          num = bib.docnumber if bib.class.attributes.key?(:docnumber)
          return num if num && !num.to_s.empty?

          # Fallback: extract from docidentifier
          identifiers = if bib.class.attributes.key?(:doc_identifier)
                          Array(bib.doc_identifier)
                        end
          primary = identifiers&.find { |d| d.primary == "true" } || identifiers&.first
          return nil unless primary

          id = primary.value
          return nil unless id

          # Extract numeric part from identifier like "ISO/CD 17301-1:2016"
          match = id.match(/(\d+)/)
          match ? match[1] : nil
        end

        def doc_identifier(bib)
          identifiers = if bib.class.attributes.key?(:doc_identifier)
                          Array(bib.doc_identifier)
                        end
          primary = identifiers&.find { |d| d.primary == "true" } || identifiers&.first
          return nil unless primary

          id_text = primary.value
          return nil if id_text.nil? || id_text.empty?

          draft_date = extract_draft_date(bib)
          id_text + (draft_date ? " (draft #{draft_date})" : "")
        end

        # Cover-large line: primary identifier with language tag, e.g.
        # "ISO/DIS 15926-100(en)". Matches the DIS 15926 reference DOCX
        # zzCoverlarge paragraph.
        def identifier_with_language(bib)
          identifiers = if bib.class.attributes.key?(:doc_identifier)
                          Array(bib.doc_identifier)
                        end
          primary = identifiers&.find { |d| d.primary == "true" } || identifiers&.first
          return nil unless primary

          id_text = primary.value
          return nil if id_text.nil? || id_text.empty?

          lang = language_code(bib)
          lang ? "#{id_text}(#{lang})" : id_text
        end

        def language_code(bib)
          langs = if bib.class.attributes.key?(:language)
                    Array(bib.language)
                  end
          lang = langs&.first
          return lang if lang.is_a?(String)

          extract_value(lang) if lang.is_a?(Lutaml::Model::Serializable)
        end

        def committee_reference(bib)
          parts = []

          # Primary: bib.editorialgroup (EditorialGroupType) has technicalcommittee
          eg = extract_editorial_group(bib)
          if eg
            tc = if eg.class.attributes.key?(:technicalcommittee)
                   Array(eg.technicalcommittee).first
                 elsif eg.class.attributes.key?(:technical_committee)
                   Array(eg.technical_committee).first
                 end
            parts << extract_subgroup_text(tc) if tc

            # Also check for subcommittee/workgroup on IsoProjectGroup
            [:subcommittee, :workgroup].each do |key|
              next unless eg.class.attributes.key?(key)
              sub = Array(eg.public_send(key)).first
              parts << extract_subgroup_text(sub) if sub
            end
          end

          # Fallback: ext.editorial_group (IsoProjectGroup) has all three
          if parts.empty?
            eg_ext = extract_ext_editorial_group(bib)
            if eg_ext
              [:technical_committee, :subcommittee, :workgroup].each do |key|
                next unless eg_ext.class.attributes.key?(key)
                sub = Array(eg_ext.public_send(key)).first
                parts << extract_subgroup_text(sub) if sub
              end
            end
          end

          parts.empty? ? nil : parts.join("/")
        end

        def extract_subgroup_text(sub)
          return nil unless sub

          # Try identifier attribute first (IsoSubGroup has this)
          if sub.class.attributes.key?(:identifier)
            identifiers = Array(sub.identifier)
            full = identifiers.find { |i| i.type == "full" if i.is_a?(Lutaml::Model::Serializable) && i.class.attributes.key?(:type) }
            text = full&.value || identifiers.first
            return text.to_s if text && !text.to_s.empty?
          end

          # Try text content (IsoSubGroup maps content to :text)
          if sub.class.attributes.key?(:text)
            text = sub.text
            return text if text.is_a?(String) && !text.empty?
          end

          # Fallback
          extract_value(sub)
        end

        def edition_text(bib)
          edition = bib.edition if bib.class.attributes.key?(:edition)
          return nil unless edition

          edition_val = edition.is_a?(Array) ? edition.first : edition
          num = extract_value(edition_val).to_s.to_i
          return nil if num.zero?

          suffix = ORDINAL_SUFFIXES[num % 100] || ORDINAL_SUFFIXES[num % 10] || "th"
          suffix = "th" if (11..13).cover?(num % 100)
          "#{num}#{suffix} edition"
        end

        def date_text(bib)
          date = extract_draft_date(bib)
          date ? "Date: #{date}" : nil
        end

        def main_title(bib)
          localized = find_en_title(bib)
          return nil unless localized

          parts = []
          parts << localized.title_intro.value if localized.title_intro
          parts << localized.title_main.value if localized.title_main
          parts << localized.title_full.value if localized.title_full && !localized.title_main
          parts.empty? ? nil : parts.join(" — ")
        end

        def subtitle(bib)
          localized = find_en_title(bib)
          return nil unless localized&.title_part

          prefix = localized.title_part_prefix&.value.to_s.strip
          part_val = localized.title_part.value
          return nil if part_val.nil? || part_val.to_s.empty?

          if !prefix.empty?
            sep = prefix.end_with?(":") ? " " : ": "
            "#{prefix}#{sep}#{part_val}"
          else
            part_val.to_s
          end
        end

        def stage_label(bib)
          stage_num = extract_stage_number(bib)
          return nil unless stage_num

          STAGE_LABELS[stage_num / 10 * 10]
        end

        # ── Extraction helpers ──

        def find_en_title(bib)
          return nil unless bib.class.attributes.key?(:titles)

          titles = bib.titles
          return nil unless titles.is_a?(Metanorma::IsoDocument::Metadata::TitleCollection)

          localized = titles.for_language("en")
          return localized unless localized.nil? || localized.to_s.empty?

          # Fallback: try any language
          bib.titles.per_language&.first
        end

        def extract_stage_number(bib)
          return nil unless bib
          return nil unless bib.class.attributes.key?(:status)

          status = bib.status
          return nil unless status
          return nil unless status.class.attributes.key?(:stage)

          stages = status.stage
          return nil unless stages

          stage = stages.is_a?(Array) ? stages.first : stages
          return nil unless stage

          # StageElement has :value attribute which may be an array or string
          if stage.class.attributes.key?(:value)
            val = stage.value
            val = val.first if val.is_a?(Array)
            return val.to_s.to_i if val
          end

          extract_value(stage).to_s.to_i
        end

        def extract_draft_date(bib)
          return nil unless bib
          return nil unless bib.class.attributes.key?(:date)

          dates = Array(bib.date)
          return nil if dates.empty?

          updated = dates.find { |d| d.type == "updated" if d.class.attributes.key?(:type) }
          updated ||= dates.find { |d| d.type == "published" if d.class.attributes.key?(:type) }
          updated ||= dates.first

          return nil unless updated

          on = updated.on if updated.class.attributes.key?(:on)
          return extract_value(on) if on

          nil
        end

        def extract_value(node)
          return nil unless node
          return node if node.is_a?(String)

          if node.is_a?(Lutaml::Model::Serializable)
            # Check :value first (most common for typed attributes)
            if node.class.attributes.key?(:value)
              val = node.value
              return val.to_s if val.is_a?(String) && !val.empty?
            end
            [:content, :text].each do |a|
              next unless node.class.attributes.key?(a)
              val = node.public_send(a)
              return val.to_s if val.is_a?(String) && !val.empty?
            end
          end

          node.to_s
        end

        def extract_editorial_group(bib)
          return nil unless bib

          if bib.class.attributes.key?(:editorialgroup)
            bib.editorialgroup
          end
        end

        def extract_ext_editorial_group(bib)
          return nil unless bib
          return nil unless bib.class.attributes.key?(:ext)

          ext = bib.ext
          return nil unless ext

          if ext.class.attributes.key?(:editorial_group)
            ext.editorial_group
          elsif ext.class.attributes.key?(:editorialgroup)
            ext.editorialgroup
          end
        end
      end
    end
  end
end
