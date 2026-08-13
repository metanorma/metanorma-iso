# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      class Transformer::IsoMetaTransformer < Transformer::Base
        include Transformer::ContentText

        # Maps IsoDocument doctype values to the abbreviated forms used
        # inside <std-ident><doc-type> per the IEC/ISO Coding Guidelines.
        DOC_TYPE_MAP = {
          "international-standard" => "IS",
          "technical-specification" => "TS",
          "technical-report" => "TR",
          "publicly-available-specification" => "PAS",
          "international-workshop-agreement" => "IWA",
          "guide" => "GUIDE",
          "amendment" => "Amd",
          "technical-corrigendum" => "TCor",
          "committee-document" => "CD",
          "recommendation" => "R",
        }.freeze

        # Emits a <iso-meta> block (NisoSts::MetadataIso) per Coding
        # Guidelines ed. 2.1. Most children are bare strings on the model;
        # only title_wrap, doc_ident, std_ident, std_ref, permissions, ics
        # remain typed.
        def transform(bibdata)
          return Transformer::ModelBuilder.metadata_iso unless bibdata

          Transformer::ModelBuilder.metadata_iso do |m|
            title_wraps_for(bibdata).each { |tw| m.title_wrap tw }
            m.doc_ident = doc_ident_for(bibdata) if doc_ident_for(bibdata)
            m.std_ident = std_ident_for(bibdata) if std_ident_for(bibdata)
            std_refs_for(bibdata).each { |sr| m.std_ref sr }
            m.doc_ref = doc_ref_for(bibdata) if doc_ref_for(bibdata)
            release_dates_for(bibdata).each { |rd| m.release_date rd }
            m.comm_ref = comm_ref_for(bibdata) if comm_ref_for(bibdata)
            m.secretariat = secretariat_for(bibdata) if secretariat_for(bibdata)
            ics_codes_for(bibdata).each { |i| m.ics i }
            permissions_for(bibdata).each { |p| m.permissions p }
          end
        end

        private

        def title_wraps_for(bibdata)
          wraps = []

          languages_for(bibdata).each do |lang|
            intro_text = title_text_for(bibdata, lang, "title-intro")
            main_text = title_text_for(bibdata, lang, "title-main")
            compl_text = title_text_for(bibdata, lang, "title-part")

            if intro_text.nil? && main_text.nil? && compl_text.nil?
              main_text = title_text_for(bibdata, lang, nil)
            end
            next if intro_text.nil? && main_text.nil? && compl_text.nil?

            tw = Transformer::ModelBuilder.title_wrap(lang: lang) do |t|
              t.intro = intro_text if intro_text
              t.main = main_text if main_text
              t.compl = Transformer::ModelBuilder.title_compl(content: [compl_text]) if compl_text

              full_text = [intro_text, main_text, compl_text].compact.join(" — ")
              if full_text && !full_text.empty?
                t.full = Transformer::ModelBuilder.title_full(content: [full_text])
              end
            end

            wraps << tw
          end

          wraps
        end

        def title_text_for(bibdata, lang, type)
          titles = Array(bibdata.titles)
          titles = titles.items if titles.is_a?(Lutaml::Model::Collection)
          title = titles.find do |t|
            t_lang = t.language || t.lang
            (lang.nil? || t_lang == lang) && (type.nil? || t._type == type)
          end
          return nil unless title

          text = title.value.to_s.strip
          text.empty? ? nil : text
        end

        # <doc-ident> in NISO STS v1.2: all children are bare strings.
        def doc_ident_for(bibdata)
          sdo = publisher_for(bibdata)
          proj_id = project_number_for(bibdata)
          language = primary_language(bibdata)
          release_version = release_version_for(bibdata)

          return nil if sdo.nil? && proj_id.nil? && language.nil? && release_version.nil?

          Transformer::ModelBuilder.document_identification(
            sdo: sdo,
            proj_id: proj_id,
            language: language,
            release_version: release_version,
          )
        end

        # <std-ident> in NISO STS v1.2: all children are bare strings.
        def std_ident_for(bibdata)
          originator = publisher_for(bibdata)
          doc_type = doctype_abbreviation(bibdata)
          doc_number = bibdata.docnumber
          part_number = part_number_from(bibdata)
          edition = edition_text_for(bibdata)
          version = version_text_for(bibdata)

          return nil if originator.nil? && doc_type.nil? && doc_number.nil? &&
                        part_number.nil? && edition.nil? && version.nil?

          Transformer::ModelBuilder.standard_identification(
            originator: originator,
            doc_type: doc_type,
            doc_number: doc_number,
            edition: edition,
            version: version,
            part_number: part_number,
          )
        end

        def std_refs_for(bibdata)
          refs = []

          identifiers = doc_identifiers(bibdata)
          primary_id = identifiers.first
          return refs unless primary_id

          ref_text = extract_text_value(primary_id)
          return refs unless ref_text && !ref_text.empty?

          refs << Transformer::ModelBuilder.standard_ref(type: "dated", value: ref_text)

          undated = undated_ref(ref_text)
          if undated != ref_text
            refs << Transformer::ModelBuilder.standard_ref(type: "undated", value: undated)
          end

          refs
        end

        # <doc-ref> is a bare STRING on MetadataIso in NISO STS v1.2.
        def doc_ref_for(bibdata)
          pub = publisher_for(bibdata)
          num = bibdata.docnumber
          return nil unless pub && num

          lang = primary_language(bibdata)
          ref_text = "#{pub} #{num}"
          ref_text += " (#{lang})" if lang && lang != "en"
          ref_text
        end

        # <release-date> is a bare STRING on MetadataIso. One per
        # released date.
        def release_dates_for(bibdata)
          dates = []
          return dates unless bibdata.date

          Array(bibdata.date).each do |d|
            next unless d.type == "released"

            date_val = d.on&.content || extract_text_value(d)
            dates << date_val.to_s if date_val
          end

          dates
        end

        # <comm-ref> is a bare STRING on MetadataIso.
        def comm_ref_for(bibdata)
          eg = bibdata.ext&.editorial_group
          return nil unless eg

          tc = eg.technical_committee
          return nil unless tc

          if tc.is_a?(Hash)
            "ISO/#{tc['type']} #{tc['number']}"
          elsif tc.number
            extract_text_value(tc)
          end
        end

        # <secretariat> is a bare STRING on MetadataIso.
        def secretariat_for(bibdata)
          eg = bibdata.ext&.editorial_group
          return nil unless eg

          sec = eg.secretariat
          return nil unless sec

          sec.to_s
        end

        def ics_codes_for(bibdata)
          ics_list = bibdata.ext&.ics
          return [] unless ics_list

          Array(ics_list).filter_map do |ics|
            code = ics.code
            next unless code

            Transformer::ModelBuilder.ics(code: code.to_s)
          end
        end

        def permissions_for(bibdata)
          perms = []
          return perms unless bibdata.copyright

          Array(bibdata.copyright).each do |cr|
            from = cr.from
            year = from.is_a?(Metanorma::Document::Relaton::DateTime) ? from.content.to_s : from.to_s
            holder = copyright_holder_for(cr)
            holder_text = holder.is_a?(Array) ? holder.first : holder
            statement = year && holder_text ? "© #{year} #{holder_text}" : nil

            perms << Transformer::ModelBuilder.permissions(
              copyright_statement: statement,
              copyright_year: year,
              copyright_holder: holder,
            )
          end

          perms
        end

        def copyright_holder_for(copyright)
          return nil unless copyright.owner

          owners = copyright.owner.is_a?(Array) ? copyright.owner : [copyright.owner]
          names = owners.filter_map do |owner|
            org = owner.organization || owner
            text = extract_text_value(org.name) ||
                   extract_text_value(org.abbreviation) ||
                   extract_text_value(org)
            text&.strip
          end
          names.empty? ? nil : names
        end

        def publisher_for(bibdata)
          return "ISO" unless bibdata.contributor

          publisher = Array(bibdata.contributor).find do |c|
            roles = c.role
            roles = [roles] unless roles.is_a?(Array)
            roles&.any? do |r|
              rtype = r.type || r
              rtype.to_s.include?("publisher")
            end
          end
          return "ISO" unless publisher

          org = publisher.organization || publisher
          abbr = org.abbreviation
          abbr_text = extract_text_value(abbr)
          abbr_text&.empty? ? "ISO" : abbr_text || "ISO"
        end

        def doctype_abbreviation(bibdata)
          dt = bibdata.ext&.doctype
          return nil unless dt

          dt = Array(dt).first if dt.is_a?(Array)
          value = dt.is_a?(String) ? dt : (dt.value || dt.abbreviation || dt.to_s)
          DOC_TYPE_MAP[value] || value
        end

        def release_version_for(bibdata)
          status = bibdata.status
          return nil unless status

          stage = status.stage
          return nil unless stage

          stage_val = extract_text_value(stage)
          stage_abbrev = status.stage_abbreviation
          abbrev = extract_text_value(stage_abbrev) if stage_abbrev

          case stage_val
          when "60" then "IS"
          when "50" then "FDIS"
          when "40" then "DIS"
          when "30" then "CD"
          when "20" then "WD"
          else abbrev
          end
        end

        def project_number_for(bibdata)
          ext = bibdata.ext
          return nil unless ext&.structuredidentifier

          pn = ext.structuredidentifier.project_number
          extract_text_value(pn)
        end

        def part_number_from(bibdata)
          ext = bibdata.ext
          return nil unless ext&.structuredidentifier

          si_struct = ext.structuredidentifier
          return nil unless si_struct.is_a?(Metanorma::Iso::Document::Metadata::StructuredIdentifier)

          pn = si_struct.project_number
          return nil unless pn && pn.class.method_defined?(:part)

          pn.part
        end

        def edition_text_for(bibdata)
          return nil unless bibdata.edition && !bibdata.edition.empty?

          edition_val = bibdata.edition.is_a?(Array) ? bibdata.edition.first : bibdata.edition
          extract_text_value(edition_val)
        end

        def version_text_for(bibdata)
          return nil unless bibdata.version

          ver = bibdata.version
          ver.revision_date || "1"
        end

        def languages_for(bibdata)
          langs = []
          if bibdata.language
            Array(bibdata.language).each do |l|
              langs << (l.is_a?(String) ? l : l.value)
            end
          end
          langs.empty? ? ["en"] : langs
        end

        def primary_language(bibdata)
          languages_for(bibdata).first
        end

        def doc_identifiers(bibdata)
          return [] unless bibdata.doc_identifier

          Array(bibdata.doc_identifier).select do |di|
            type = di.type
            !type || type == "ISO" || type == "std" || type == "URN"
          end
        end

        def undated_ref(ref)
          ref.sub(/:\d{4}$/, "")
        end
      end
    end
  end
end
