# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      # Renders the cover page from the document model's bibdata.
      #
      # The cover page appears as the first page of the DOCX and includes:
      #   - Document identifier (with stage/draft)
      #   - Reference number of working document (iso-tc identifier)
      #   - Date
      #   - Reference number of project (iso-undated identifier + draft)
      #   - Committee identification (approval group) or TC/SC/WG reference
      #   - Secretariat
      #   - Edition information
      #   - Main title and title part
      #   - Second-language subtitle
      #   - Stage label
      #
      # All data comes from the model's bibdata attribute — no hardcoded text.
      class CoverRenderer
        include ModelUtils

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
          render_cover_line(doc, working_document_number(bibdata))
          render_cover_line(doc, date_text(bibdata))
          render_cover_line(doc, project_number(bibdata))
          render_cover_line(doc, committee_identification(bibdata) ||
                                   committee_reference(bibdata))
          render_cover_line(doc, secretariat_line(bibdata))
          render_cover_line(doc, edition_text(bibdata))
          render_cover_line(doc, "")
          render_cover_title(doc, main_title(bibdata))
          render_cover_subtitle(doc, subtitle(bibdata))
          render_translated_subtitle(doc, bibdata)
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

        # Second-language subtitle: the classic chain renders the document
        # title in the other ISO language (FR for EN documents, EN for FR)
        # as an italic cover line under the main title (docsubtitle).
        def render_translated_subtitle(doc, bib)
          text = translated_title(bib)
          return if text.nil? || text.empty?

          para = Uniword::Builder::ParagraphBuilder.new
          para.style = @resolver.paragraph_style(:cover_meta)
          para << Uniword::Builder::RunBuilder.new.text(text).italic
          doc << para
        end

        # "Reference number of working document: 29166" — the ISO-tc
        # docidentifier carried on DIS/FDIS covers (zzCover).
        def working_document_number(bib)
          id = docidentifier_of_type(bib, "iso-tc")
          return nil unless id

          "Reference number of working document: #{id}"
        end

        # "Reference number of project: ISO/FDTR 29166 (draft 2011-12)" —
        # the undated project identifier plus the draft suffix. Falls back
        # to the bare document number for documents without the iso-undated
        # identifier (early-stage covers).
        def project_number(bib)
          id = docidentifier_of_type(bib, "iso-undated")
          return doc_number(bib) unless id

          "Reference number of project: #{id}#{draft_info(bib)}"
        end

        # "Committee identification: JTC 1/SC 34" — the full identifiers of
        # the approval group (authorizer committee subdivisions).
        def committee_identification(bib)
          ids = approval_group_identifiers(bib)
          return nil if ids.empty?

          "Committee identification: #{ids.join(' and ')}"
        end

        # "Secretariat: SAC" — the name of the secretariat subdivision on
        # the author/secretariat contributor.
        def secretariat_line(bib)
          name = secretariat_name(bib)
          return nil unless name

          "Secretariat: #{name}"
        end

        # Unwrap a typed model leaf to its display text. Model leaves in the
        # bibdata (FormattedString, LocalizedName, …) may carry their text as
        # a String or as a single-element collection on :value/:content/:text.
        def typed_text(node)
          case node
          when String then node
          when Array then node.filter_map { |n| typed_text(n) }.first
          when Lutaml::Model::Serializable
            leaf = if node.class.attributes.key?(:value)
                     typed_text(node.value)
                   end
            leaf ||= %i(content text).filter_map do |a|
              next unless node.class.attributes.key?(a)

              typed_text(node.public_send(a))
            end.first
            leaf
          end
        end

        def docidentifier_of_type(bib, type)
          return nil unless bib.class.attributes.key?(:doc_identifier)

          identifiers = Array(bib.doc_identifier).find do |d|
            d.is_a?(Lutaml::Model::Serializable) &&
              d.class.attributes.key?(:type) &&
              d.type == type &&
              !d.value.to_s.empty?
          end
          identifiers&.value
        end

        # Classic draftinfo: " (draft <draft>)". <version> carries either
        # a <draft> child or its text as the draft value (legacy form).
        def draft_info(bib)
          draft = extract_draft(bib)
          return nil unless draft

          " (draft #{draft})"
        end

        def extract_draft(bib)
          return nil unless bib.class.attributes.key?(:version)

          version = bib.version
          return nil unless version.is_a?(Lutaml::Model::Serializable)

          draft = version.draft if version.class.attributes.key?(:draft)
          if (draft.nil? || draft.to_s.empty?) &&
              version.class.attributes.key?(:content)
            draft = version.content
          end
          draft = typed_text(draft)
          draft && !draft.empty? ? draft : nil
        end

        def approval_group_identifiers(bib)
          contributors(bib).filter_map do |contributor|
            next unless committee_authorizer?(contributor)

            organization = attribute_value(contributor, :organization)
            next unless organization

            Array(attribute_value(organization, :subdivision)).filter_map do |sub|
              full_identifiers(sub)
            end
          end.flatten
        end

        def committee_authorizer?(contributor)
          roles(contributor).any? do |role|
            attribute_value(role, :type) == "authorizer" &&
              role_descriptions(role).include?("committee")
          end
        end

        def secretariat_name(bib)
          contributors(bib).each do |contributor|
            next unless secretariat_contributor?(contributor)

            organization = attribute_value(contributor, :organization)
            next unless organization

            Array(attribute_value(organization, :subdivision)).each do |sub|
              next unless attribute_value(sub, :type) == "Secretariat"

              Array(attribute_value(sub, :name)).each do |name|
                text = typed_text(name)
                return text unless text.nil? || text.empty?
              end
            end
          end
          nil
        end

        def secretariat_contributor?(contributor)
          roles(contributor).any? do |role|
            attribute_value(role, :type) == "author" &&
              role_descriptions(role).include?("secretariat")
          end
        end

        def contributors(bib)
          return [] unless bib.class.attributes.key?(:contributor)

          Array(bib.contributor)
        end

        def roles(contributor)
          return [] unless contributor.is_a?(Lutaml::Model::Serializable) &&
            contributor.class.attributes.key?(:role)

          Array(contributor.role)
        end

        def role_descriptions(role)
          return [] unless role.is_a?(Lutaml::Model::Serializable) &&
            role.class.attributes.key?(:description)

          Array(role.description).map { |d| typed_text(d) }
        end

        def full_identifiers(subdivision)
          return [] unless subdivision.is_a?(Lutaml::Model::Serializable) &&
            subdivision.class.attributes.key?(:identifier)

          Array(subdivision.identifier).filter_map do |identifier|
            next unless identifier.is_a?(Lutaml::Model::Serializable) &&
              identifier.class.attributes.key?(:type) &&
              identifier.type == "full"

            value = typed_text(identifier.value)
            value unless value.nil? || value.empty?
          end
        end

        # The document title in the other ISO language. FR documents take
        # the EN title; all others take the FR title (falling back to any
        # other language when that one is absent).
        def translated_title(bib)
          doc_lang = language_code(bib)
          other = doc_lang == "fr" ? "en" : "fr"
          localized = localized_title_in(bib, other) ||
            other_language_title(bib, doc_lang)
          return nil unless localized

          compose_localized_title(localized)
        end

        def localized_title_in(bib, lang)
          return nil unless bib.class.attributes.key?(:titles)

          titles = bib.titles
          return nil unless titles.is_a?(Metanorma::Iso::Document::Metadata::TitleCollection)

          localized = titles.for_language(lang)
          return nil if localized.nil? || localized.to_s.empty?

          localized
        end

        def other_language_title(bib, doc_lang)
          return nil unless bib.class.attributes.key?(:titles)

          titles = bib.titles
          return nil unless titles.is_a?(Metanorma::Iso::Document::Metadata::TitleCollection)

          Array(titles.per_language).find do |localized|
            localized.language != doc_lang
          end
        end

        # Compose a localized title as "intro — main — prefix: part",
        # mirroring the classic chain's compose_title.
        def compose_localized_title(localized)
          parts = []
          parts << typed_text(localized.title_intro.value) if localized.title_intro
          parts << typed_text(localized.title_main.value) if localized.title_main
          if localized.title_part && !localized.title_part.value.to_s.empty?
            prefix = typed_text(localized.title_part_prefix&.value).to_s.strip
            part = typed_text(localized.title_part.value).to_s
            parts << (prefix.empty? ? part : "#{prefix}: #{part}")
          end
          parts.compact.empty? ? nil : parts.compact.join(" — ")
        end

        def doc_number(bib)
          num = bib.docnumber if bib.class.attributes.key?(:docnumber)
          return num if num && !num.to_s.empty?

          # Fallback: extract from docidentifier
          identifiers = if bib.class.attributes.key?(:doc_identifier)
                          Array(bib.doc_identifier)
                        end
          primary = identifiers&.find { |d| d.primary.to_s == "true" } || identifiers&.first
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
          primary = identifiers&.find { |d| d.primary.to_s == "true" } || identifiers&.first
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
          primary = identifiers&.find { |d| d.primary.to_s == "true" } || identifiers&.first
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
          return nil unless titles.is_a?(Metanorma::Iso::Document::Metadata::TitleCollection)

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
