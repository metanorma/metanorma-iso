# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      class Transformer::IsoMetaTransformer < Transformer::Base
        include Transformer::ContentText

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

        def transform(bibdata)
          build_ordered(::Sts::IsoSts::IsoMeta) do |m|
            title_wraps_for(bibdata).each { |tw| m.title_wrap tw }
            m.doc_ident doc_ident_for(bibdata)
            m.std_ident std_ident_for(bibdata)
            std_refs_for(bibdata).each { |sr| m.std_ref sr }
            m.doc_ref doc_ref_for(bibdata)
            release_dates_for(bibdata).each { |rd| m.release_date rd }
            m.comm_ref comm_ref_for(bibdata)
            if (sec = secretariat_for(bibdata))
              m.secretariat sec
            end
            ics_codes_for(bibdata).each { |i| m.ics i }
            permissions_for(bibdata).each { |p| m.permissions p }
          end
        end

        private

        def title_wraps_for(bibdata)
          wraps = []

          languages_for(bibdata).each do |lang|
            title = title_for_language(bibdata, lang)
            next unless title

            tw = build_ordered(::Sts::IsoSts::TitleWrap)
            tw.xml_lang = lang

            intro_text = title_intro_text(title)
            tw.intro = ::Sts::IsoSts::TitleIntro.new(content: [intro_text]) if intro_text

            main_text = title_main_text(title)
            tw.main = ::Sts::IsoSts::TitleMain.new(content: [main_text]) if main_text

            compl_text = title_compl_text(title)
            tw.compl = ::Sts::IsoSts::TitleCompl.new(content: [compl_text]) if compl_text

            full_text = [intro_text, main_text, compl_text].compact.join(" — ")
            tw.full = ::Sts::IsoSts::TitleFull.new(content: [full_text]) if full_text

            wraps << tw
          end

          wraps
        end

        def title_for_language(bibdata, lang)
          titles = bibdata.titles
          titles = titles.items if titles.is_a?(Lutaml::Model::Collection)
          Array(titles).find do |t|
            t_lang = t.language || t.lang
            t_lang == lang
          end
        end

        def title_intro_text(title)
          ti = title.title_intro
          extract_text_value(ti) if ti
        end

        def title_main_text(title)
          tm = title.title_main
          if tm
            extract_text_value(tm)
          elsif title.content
            extract_text_value(title)
          end
        end

        def title_compl_text(title)
          tp = title.title_part
          extract_text_value(tp) if tp
        end

        def doc_ident_for(bibdata)
          di = ::Sts::IsoSts::DocumentIdentification.new
          di.sdo = ::Sts::NisoSts::Sdo.new(content: [publisher_for(bibdata)])

          ext = bibdata.ext
          if ext&.structuredidentifier
            si = ext.structuredidentifier
            proj_num = extract_text_value(si.project_number || si)
            di.proj_id = ::Sts::NisoSts::ProjId.new(content: [proj_num]) if proj_num && !proj_num.empty?
          end

          lang = primary_language(bibdata)
          di.language = ::Sts::IsoSts::Language.new(content: [lang]) if lang

          release_ver = release_version_for(bibdata)
          di.release_version = ::Sts::NisoSts::ReleaseVersion.new(content: [release_ver]) if release_ver

          di
        end

        def std_ident_for(bibdata)
          si = ::Sts::IsoSts::StandardIdentification.new
          si.originator = ::Sts::NisoSts::Originator.new(content: [publisher_for(bibdata)])

          doctype_abbrev = doctype_abbreviation(bibdata)
          si.doc_type = ::Sts::NisoSts::DocType.new(content: [doctype_abbrev]) if doctype_abbrev

          if bibdata.docnumber
            si.doc_number = ::Sts::NisoSts::DocNumber.new(content: [bibdata.docnumber])
          end

          ext = bibdata.ext
          if ext&.structuredidentifier
            si_struct = ext.structuredidentifier
            if si_struct.partnumber
              si.part_number = ::Sts::NisoSts::PartNumber.new(content: [si_struct.partnumber.to_s])
            end
          end

          if bibdata.edition && !bibdata.edition.empty?
            edition_val = bibdata.edition.is_a?(Array) ? bibdata.edition.first : bibdata.edition
            edition_text = extract_text_value(edition_val) || edition_val.to_s
            si.edition = ::Sts::IsoSts::Edition.new(content: [edition_text]) if edition_text && !edition_text.empty?
          end

          if bibdata.version
            ver = bibdata.version
            ver_text = ver.revision_date || "1"
            si.version = ::Sts::NisoSts::Version.new(content: [ver_text.to_s])
          end

          si
        end

        def std_refs_for(bibdata)
          refs = []

          identifiers = doc_identifiers(bibdata)
          primary_id = identifiers.first
          return refs unless primary_id

          ref_text = extract_text_value(primary_id) || primary_id.to_s
          if ref_text && !ref_text.empty?
            sr = ::Sts::IsoSts::StdRef.new
            sr.type = "dated"
            sr.content = [ref_text]
            refs << sr

            undated = undated_ref(ref_text)
            if undated != ref_text
              sr2 = ::Sts::IsoSts::StdRef.new
              sr2.type = "undated"
              sr2.content = [undated]
              refs << sr2
            end
          end

          refs
        end

        def doc_ref_for(bibdata)
          pub = publisher_for(bibdata)
          num = bibdata.docnumber
          return nil unless pub && num

          lang = primary_language(bibdata)
          ref_text = "#{pub} #{num}"
          ref_text += " (#{lang})" if lang && lang != "en"

          ::Sts::IsoSts::DocRef.new(content: [ref_text])
        end

        def release_dates_for(bibdata)
          dates = []
          return dates unless bibdata.date

          Array(bibdata.date).each do |d|
            next unless d.type == "released"

            date_val = d.on&.content || extract_text_value(d)
            if date_val
              rd = ::Sts::IsoSts::ReleaseDate.new
              rd.content = [date_val.to_s]
              dates << rd
            end
          end

          dates
        end

        def comm_ref_for(bibdata)
          eg = bibdata.ext&.editorial_group
          return nil unless eg

          parts = []
          tc = eg.technical_committee
          if tc
            if tc.is_a?(Hash)
              parts << "ISO/#{tc['type']} #{tc['number']}"
            elsif tc.number
              parts << extract_text_value(tc)
            end
          end

          return nil if parts.empty?

          ::Sts::IsoSts::CommRef.new(content: [parts.join("/")])
        end

        def secretariat_for(bibdata)
          eg = bibdata.ext&.editorial_group
          return nil unless eg

          sec = eg.secretariat
          return nil unless sec

          ::Sts::IsoSts::Secretariat.new(content: [sec.to_s])
        end

        def ics_codes_for(bibdata)
          ics_list = bibdata.ext&.ics
          return [] unless ics_list

          Array(ics_list).filter_map do |ics|
            code = ics.code
            next unless code

            i = ::Sts::NisoSts::Ics.new
            i.ics_code = ::Sts::NisoSts::IcsCode.new(content: [code.to_s])
            i
          end
        end

        def permissions_for(bibdata)
          perms = []
          return perms unless bibdata.copyright

          Array(bibdata.copyright).each do |cr|
            perm = build_ordered(::Sts::IsoSts::Permissions) do |p|
              p.copyright_statement = ::Sts::IsoSts::CopyrightStatement.new(
                content: ["All rights reserved"],
              )

              if cr.from
                p.copyright_year = ::Sts::IsoSts::CopyrightYear.new(
                  content: [cr.from.to_s],
                )
              end

              if cr.owner
                owners = cr.owner.is_a?(Array) ? cr.owner : [cr.owner]
                owners.each do |owner|
                  name = owner.organization || owner
                  name_text = if name.name
                                extract_text_value(name.name) || name.name.to_s
                              elsif name.abbreviation
                                extract_text_value(name.abbreviation) || name.abbreviation.to_s
                              else
                                name.to_s
                              end
                  next if name_text.empty?

                  p.copyright_holder = ::Sts::IsoSts::CopyrightHolder.new(
                    content: [name_text],
                  )
                end
              end
            end

            perms << perm
          end

          perms
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
          abbr_text = extract_text_value(abbr) || abbr.to_s
          abbr_text.empty? ? "ISO" : abbr_text
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

          stage_val = extract_text_value(stage) || stage.to_s

          stage_abbrev = status.stage_abbreviation
          abbrev = extract_text_value(stage_abbrev) if stage_abbrev

          case stage_val
          when "60" then "IS"
          when "50" then "FDIS"
          when "40" then "DIS"
          when "30" then "CD"
          when "20" then "WD"
          else abbrev || nil
          end
        end

        def languages_for(bibdata)
          langs = []
          if bibdata.language
            Array(bibdata.language).each do |l|
              langs << (l.is_a?(String) ? l : (l.value || l.to_s))
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
