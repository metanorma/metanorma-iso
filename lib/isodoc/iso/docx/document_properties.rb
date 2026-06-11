# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      # Generates ISO-specific custom properties (docProps/custom.xml) from
      # the document model's bibdata. These 20 properties are required by
      # ISO's Typefi publishing pipeline for document identification.
      class DocumentProperties
        # rubocop:disable Metrics/ClassLength
        PROPERTY_DEFS = [
          ["intro",              :lpwstr, :title_intro],
          ["main",               :lpwstr, :title_main],
          ["compl",              :lpwstr, :title_complement],
          ["full",               :lpwstr, :title_full],
          ["proj-id",            :i4,     :project_id],
          ["release-version",    :lpwstr, :release_version],
          ["ident-originator",   :lpwstr, :ident_originator],
          ["ident-doc-type",     :lpwstr, :ident_doc_type],
          ["ident-doc-number",   :i4,     :ident_doc_number],
          ["ident-part-number",  :i4,     :ident_part_number],
          ["ident-edition",      :i4,     :ident_edition],
          ["ident-version",      :i4,     :ident_version],
          ["content-language",   :lpwstr, :content_language],
          ["doc-ref",            :lpwstr, :doc_ref],
          ["comm-ref",           :lpwstr, :comm_ref],
          ["secretariat",        :lpwstr, :secretariat],
          ["copyright-statement", :lpwstr, :copyright_statement],
          ["copyright-year",     :lpwstr, :copyright_year],
          ["copyright-holder",   :lpwstr, :copyright_holder],
          ["self-uri",           :lpwstr, :self_uri],
        ].freeze

        FMTID = "{D5CDD505-2E9C-101B-9397-08002B2CF9AE}"

        STAGE_ABBREVIATIONS = {
          0 => "PWI", 10 => "NP", 20 => "WD", 30 => "CD",
          40 => "DIS", 50 => "FDIS", 60 => "IS",
          90 => "AMD", 95 => "COR",
        }.freeze

        def initialize(doc_model)
          @model = doc_model
          @bib = doc_model.bibdata
        end

        def build
          properties = PROPERTY_DEFS.each_with_index.filter_map do |(name, type, extractor), i|
            value = extract_property(extractor)
            next unless value

            build_property(name, type, value, i + 2)
          end

          Uniword::Ooxml::CustomProperties.new(properties: properties)
        end

        private

        def extract_property(key)
          case key
          when :title_intro then title_intro
          when :title_main then title_main
          when :title_complement then title_complement
          when :title_full then title_full
          when :project_id then project_id
          when :release_version then release_version
          when :ident_originator then ident_originator
          when :ident_doc_type then ident_doc_type
          when :ident_doc_number then ident_doc_number
          when :ident_part_number then ident_part_number
          when :ident_edition then ident_edition
          when :ident_version then ident_version
          when :content_language then content_language
          when :doc_ref then doc_ref
          when :comm_ref then comm_ref
          when :secretariat then secretariat
          when :copyright_statement then copyright_statement
          when :copyright_year then copyright_year
          when :copyright_holder then copyright_holder
          when :self_uri then self_uri
          end
        end

        def build_property(name, type, value, pid)
          case type
          when :lpwstr
            Uniword::Ooxml::CustomProperty.new(
              fmtid: FMTID, pid: pid, name: name,
              lpwstr: Uniword::Ooxml::Types::VariantTypes::VtLpwstr.new(value: value.to_s),
            )
          when :i4
            Uniword::Ooxml::CustomProperty.new(
              fmtid: FMTID, pid: pid, name: name,
              i4: Uniword::Ooxml::Types::VariantTypes::VtI4.new(value: value.to_i),
            )
          end
        end

        def title_intro
          en_title("title-intro")
        end

        def title_main
          en_title("title-main")
        end

        def title_complement
          en_title("title-part")
        end

        def title_full
          intro = en_title("title-intro")
          main = en_title("title-main")
          part = en_title("title-part")
          prefix = en_title("title-part-prefix")
          parts = [intro, main].compact
          result = parts.join(" — ")
          if part
            result += " — "
            result += "#{prefix}: " if prefix
            result += part
          end
          result.empty? ? nil : result
        end

        def project_id
          ext = @bib&.ext if @bib&.class&.attributes&.key?(:ext)
          return nil unless ext

          if ext.class.attributes.key?(:proj_id)
            pid = ext.proj_id
            return pid.to_i if pid
          end

          project_id_attr = extract_ext_attribute(:projid) || extract_ext_attribute(:proj_id)
          project_id_attr&.to_i
        end

        def release_version
          stage = extract_stage
          return nil unless stage

          STAGE_ABBREVIATIONS[stage / 10 * 10] || "IS"
        end

        def ident_originator
          contributors = Array(@bib&.copyright).flat_map do |c|
            c.owner if c.class.attributes.key?(:owner)
          end
          org = contributors&.first
          org_name = org&.name if org&.class&.attributes&.key?(:name)
          Array(org_name).first&.content || "ISO"
        end

        def ident_doc_type
          doctype = extract_doctype
          case doctype
          when "international-standard" then "IS"
          when "technical-specification" then "TS"
          when "technical-report" then "TR"
          when "publicly-available-specification" then "PAS"
          when "international-workshop-agreement" then "IWA"
          when "guide" then "Guide"
          when "amendment" then "AMD"
          when "technical-corrigendum" then "COR"
          else doctype&.upcase
          end
        end

        def ident_doc_number
          @bib&.docnumber&.to_i if @bib&.class&.attributes&.key?(:docnumber)
        end

        def ident_part_number
          identifiers = Array(@bib&.doc_identifier)
          primary = identifiers.find { |d| d.primary.to_s == "true" } || identifiers.first
          return nil unless primary

          value = primary.value
          return nil unless value

          match = value.match(/(\d+):(\d+)/) || value.match(/-(\d+)\s/)
          match ? match[1].to_i : nil
        end

        def ident_edition
          edition = @bib&.edition if @bib&.class&.attributes&.key?(:edition)
          return nil unless edition
          edition_val = edition.is_a?(Array) ? edition.first : edition
          return nil unless edition_val
          extract_value(edition_val).to_s.to_i
        end

        def ident_version
          version = @bib&.version if @bib&.class&.attributes&.key?(:version)
          return 1 unless version
          version = version.first if version.is_a?(Array)
          return 1 unless version
          v = extract_value(version)
          v = Array(v).first.to_s if v.is_a?(Array)
          v.to_i > 0 ? v.to_i : 1
        end

        def content_language
          langs = Array(@bib&.language) if @bib&.class&.attributes&.key?(:language)
          lang = langs&.first
          lang ? extract_value(lang) : "en"
        end

        def doc_ref
          identifiers = Array(@bib&.doc_identifier)
          primary = identifiers.find { |d| d.primary.to_s == "true" } || identifiers.first
          return nil unless primary

          value = primary.value
          return nil unless value

          lang = content_language
          value.include?("(#{lang})") ? value : "#{value}(#{lang})"
        end

        def comm_ref
          eg = extract_editorial_group
          return nil unless eg

          parts = []
          [:committee, :subcommittee, :workgroup].each do |key|
            next unless eg.class.attributes.key?(key)
            sub = eg.public_send(key)
            next unless sub

            sub_ids = Array(sub.identifier) if sub.class.attributes.key?(:identifier)
            if sub_ids && !sub_ids.empty?
              full = sub_ids.find { |i| i.type == "full" }
              parts << (full&.value || sub_ids.first&.value)
            end
          end
          parts.empty? ? nil : parts.join("/")
        end

        def secretariat
          eg = extract_editorial_group
          return nil unless eg

          eg.secretariat if eg.class.attributes.key?(:secretariat)
        end

        def copyright_statement
          "All rights reserved"
        end

        def copyright_year
          copyrights = Array(@bib&.copyright) if @bib&.class&.attributes&.key?(:copyright)
          return nil unless copyrights&.first

          from = copyrights.first.from if copyrights.first.class.attributes.key?(:from)
          return nil unless from
          extract_value(from)
        end

        def copyright_holder
          copyrights = Array(@bib&.copyright) if @bib&.class&.attributes&.key?(:copyright)
          return nil unless copyrights&.first

          owner = copyrights.first.owner if copyrights.first.class.attributes.key?(:owner)
          org = Array(owner).first
          return nil unless org

          names = org.name if org.class.attributes.key?(:name)
          Array(names).first&.content || "ISO"
        end

        def self_uri
          uris = Array(@bib&.uri) if @bib&.class&.attributes&.key?(:uri)
          uri = uris&.first
          uri ? extract_value(uri) : nil
        end

        # ── Helpers ──

        # Extract a plain string value from a model node that may use
        # :content, :value, or :text as its text attribute.
        def extract_value(node)
          return nil unless node
          return node if node.is_a?(String)

          [:content, :value, :text].each do |attr|
            next unless node.is_a?(Lutaml::Model::Serializable)
            next unless node.class.attributes.key?(attr)

            val = node.public_send(attr)
            return val.to_s if val.is_a?(String)
            return Array(val).first.to_s if val.is_a?(Array) && !val.empty?
          end

          node.to_s
        end

        def en_title(type)
          return nil unless @bib&.class&.attributes&.key?(:title)

          titles = Array(@bib.title)
          t = titles.find { |title| title_type(title) == type && title_language(title) == "en" }
          t ||= titles.find { |title| title_type(title) == type }
          return nil unless t

          extract_title_value(t)
        end

        def title_type(title)
          if title.class.attributes.key?(:_type)
            title._type
          elsif title.class.attributes.key?(:type)
            title.type
          end
        end

        def title_language(title)
          if title.class.attributes.key?(:language)
            title.language
          elsif title.class.attributes.key?(:lang)
            title.lang
          end
        end

        def extract_title_value(title)
          if title.class.attributes.key?(:content)
            title.content
          elsif title.class.attributes.key?(:value)
            title.value
          else
            collect_text(title)
          end
        end

        def extract_stage
          return nil unless @bib

          status = @bib.status if @bib.class.attributes.key?(:status)
          return nil unless status

          stage = status.stage if status.class.attributes.key?(:stage)
          return nil unless stage

          stage = stage.first if stage.is_a?(Array)
          return nil unless stage

          if stage.is_a?(String)
            stage.to_i
          else
            extract_value(stage).to_s.to_i
          end
        end

        def extract_doctype
          return nil unless @bib

          if @bib.class.attributes.key?(:doctype)
            dt = @bib.doctype
            dt = dt.first if dt.is_a?(Array)
            dt ? extract_value(dt) : nil
          elsif @bib.class.attributes.key?(:ext)
            ext = @bib.ext
            extract_ext_attribute(:doctype) if ext
          end
        end

        def extract_editorial_group
          return nil unless @bib

          if @bib.class.attributes.key?(:editorialgroup)
            @bib.editorialgroup
          elsif @bib.class.attributes.key?(:ext)
            ext = @bib.ext
            ext.editorialgroup if ext&.class&.attributes&.key?(:editorialgroup)
          end
        end

        def extract_ext_attribute(attr_name)
          return nil unless @bib&.class&.attributes&.key?(:ext)
          ext = @bib.ext
          return nil unless ext

          return nil unless ext.class.attributes.key?(attr_name)
          val = ext.public_send(attr_name)
          return nil unless val
          return val if val.is_a?(String)
          val = val.first if val.is_a?(Array)
          return nil unless val
          extract_value(val)
        end

        def collect_text(node)
          return node.to_s if node.is_a?(String)
          return "" unless node
          return node.content if node.class.attributes.key?(:content) && node.content.is_a?(String)

          texts = []
          [:text, :content, :content_text].each do |attr|
            next unless node.class.attributes.key?(attr)
            val = node.public_send(attr)
            case val
            when Array then texts.concat(val.grep(String))
            when String then texts << val
            end
          end
          texts.compact.join
        end
      end
    end
  end
end
