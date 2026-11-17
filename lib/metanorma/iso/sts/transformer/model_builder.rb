# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      module Transformer
        # Factory methods for building sts-ruby model instances.
        # Zero Nokogiri — all models are constructed via lutaml-model.
        module ModelBuilder
          module_function

          # The NISO STS XSD pins <standard dtd-version> to the fixed
          # value "1.0"; anything else fails schema validation.
          def standard(lang:, dtd_version: "1.0", front: nil, body: nil, back: nil)
            ::Sts::NisoSts::Standard.new(
              lang: lang,
              dtd_version: dtd_version
            ).tap do |std|
              std.front = front if front
              std.body = body if body
              std.back = back if back
            end
          end

          def front(std_meta: nil, iso_meta: nil, sec: [])
            ::Sts::NisoSts::Front.new.tap do |f|
              f.std_meta = std_meta if std_meta
              f.iso_meta = iso_meta if iso_meta
              Array(sec).each { |s| f.sec s }
            end
          end

          def body(sec: [])
            ::Sts::NisoSts::Body.new(sec: Array(sec))
          end

          def back(app_group: nil, ref_list: [])
            attrs = {}
            attrs[:ref_list] = Array(ref_list) if ref_list&.any?
            ::Sts::NisoSts::Back.new(attrs).tap do |b|
              b.app_group = app_group if app_group
            end
          end

          def app_group(app: [])
            ::Sts::NisoSts::AppGroup.new(app: Array(app))
          end

          def sec(id: nil, label: nil, title: nil, sec_type: nil, content: [],
                  paragraph: [], sec: [], list: [], table_wrap: [], fig: [],
                  non_normative_note: [], non_normative_example: [])
            all_content = Array(content) + Array(paragraph)
            distributed = distribute_sec_content(all_content)

            attrs = {}
            attrs[:id] = id if id
            attrs[:type] = sec_type if sec_type
            attrs[:title] = ::Sts::NisoSts::Title.new(content: [title]) if title
            attrs[:paragraphs] = distributed[:paragraph] if distributed[:paragraph].any?
            attrs[:sec] = Array(sec) if sec&.any?
            attrs[:list] = (Array(list) + distributed[:list]) if (list&.any? || distributed[:list].any?)
            attrs[:table_wrap] = (Array(table_wrap) + distributed[:table_wrap]) if (table_wrap&.any? || distributed[:table_wrap].any?)
            attrs[:fig] = (Array(fig) + distributed[:fig]) if (fig&.any? || distributed[:fig].any?)
            attrs[:non_normative_note] = (Array(non_normative_note) + distributed[:note]) if (non_normative_note&.any? || distributed[:note].any?)
            attrs[:non_normative_example] = (Array(non_normative_example) + distributed[:example]) if (non_normative_example&.any? || distributed[:example].any?)
            ::Sts::NisoSts::Section.new(attrs)
          end

          def distribute_sec_content(content)
            result = Hash.new { |h, k| h[k] = [] }
            content.each do |item|
              case item
              when ::Sts::NisoSts::Paragraph then result[:paragraph] << item
              when ::Sts::NisoSts::List then result[:list] << item
              when ::Sts::NisoSts::Figure then result[:fig] << item
              when ::Sts::TbxIsoTml::TableWrap then result[:table_wrap] << item
              when ::Sts::NisoSts::NonNormativeNote then result[:note] << item
              when ::Sts::NisoSts::NonNormativeExample then result[:example] << item
              when ::Sts::NisoSts::DisplayFormula then result[:formula] << item
              when ::Sts::NisoSts::DefList then result[:def_list] << item
              end
            end
            result
          end

          def term_section(id: nil)
            ::Sts::NisoSts::TermSection.new do |ts|
              ts.id = id if id
              yield ts if block_given?
            end
          end

          def paragraph(id: nil)
            ::Sts::NisoSts::Paragraph.new.tap do |p|
              p.id = id if id
              yield p if block_given?
            end
          end

          def list(list_type: "bullet", list_item: [])
            ::Sts::NisoSts::List.new(list_type: list_type, list_item: Array(list_item))
          end

          def def_list(id: nil, def_items: [])
            items = Array(def_items)
            ::Sts::NisoSts::DefList.new.tap do |dl|
              dl.id = id if id
              dl.def_item = items if items.any?
            end
          end

          def def_item(id: nil, term: nil, defn: nil)
            ::Sts::NisoSts::DefItem.new.tap do |di|
              di.id = id if id
              di.term = term if term
              di.definition = defn if defn
            end
          end
          def term(content: [])
            ::Sts::NisoSts::Term.new(text: Array(content))
          end

          def def(paragraph: [])
            ::Sts::NisoSts::Def.new(paragraph: Array(paragraph))
          end

          def list_item(paragraph: [])
            ::Sts::NisoSts::ListItem.new(p: Array(paragraph))
          end

          def table_wrap(id: nil, caption: nil, table: nil)
            ::Sts::TbxIsoTml::TableWrap.new.tap do |tw|
              tw.id = id if id
              tw.caption = caption if caption
              tw.table = [table] if table
            end
          end

          def table(thead: nil, tbody: nil)
            ::Sts::TbxIsoTml::Table.new.tap do |t|
              t.thead = thead if thead
              t.tbody = tbody if tbody
            end
          end

          def thead(tr: [])
            ::Sts::TbxIsoTml::Thead.new(tr: Array(tr))
          end

          def tbody(tr: [])
            ::Sts::TbxIsoTml::Tbody.new(tr: Array(tr))
          end

          def tr(th: [], td: [])
            attrs = {}
            attrs[:th] = Array(th) if th&.any?
            attrs[:td] = Array(td) if td&.any?
            ::Sts::TbxIsoTml::Tr.new(attrs)
          end

          def th(content: nil)
            ::Sts::TbxIsoTml::Th.new.tap { |c| c.content = Array(content) if content }
          end

          def td(content: nil)
            ::Sts::TbxIsoTml::Td.new.tap { |c| c.content = Array(content) if content }
          end

          def fig(id: nil, label: nil, caption: nil, graphic: nil)
            ::Sts::NisoSts::Figure.new.tap do |f|
              f.id = id if id
              f.label = ::Sts::NisoSts::Label.new(content: [label]) if label
              f.caption = caption if caption
              f.graphic = [graphic] if graphic
            end
          end

          def graphic(href: nil)
            ::Sts::NisoSts::Graphic.new(href: href)
          end

          def caption(title: nil)
            ::Sts::NisoSts::Caption.new.tap do |c|
              c.title = ::Sts::NisoSts::Title.new(content: [title]) if title
            end
          end

          def disp_formula(id: nil, label: nil, math: nil)
            ::Sts::NisoSts::DisplayFormula.new.tap do |f|
              f.id = id if id
              f.label = ::Sts::NisoSts::Label.new(content: [label]) if label
              f.math = math if math
            end
          end

          def inline_formula(math: nil)
            ::Sts::NisoSts::InlineFormula.new(math: math)
          end

          def non_normative_note(paragraph: [], list: [], label: nil)
            # Block form: lutaml-model records setter-call order, so the
            # label lands before the content (the XSD's label? position).
            ::Sts::NisoSts::NonNormativeNote.new do |n|
              n.label = ::Sts::NisoSts::Label.new(content: [label]) if label
              n.p = Array(paragraph) if paragraph&.any?
              n.list = Array(list) if list&.any?
            end
          end

          def non_normative_example(paragraph: [], list: [], preformat: [], label: nil)
            ::Sts::NisoSts::NonNormativeExample.new do |e|
              e.label = ::Sts::NisoSts::Label.new(content: [label]) if label
              e.p = Array(paragraph) if paragraph&.any?
              e.list = Array(list) if list&.any?
              e.preformat = Array(preformat) if preformat&.any?
            end
          end

          def ref_list(content_type: nil, title: nil, ref: [])
            ::Sts::NisoSts::ReferenceList.new.tap do |rl|
              rl.content_type = content_type if content_type
              rl.title = ::Sts::NisoSts::Title.new(content: [title]) if title
              rl.ref = Array(ref) if ref&.any?
            end
          end

          def standard_ref(type: nil, value: nil)
            ::Sts::NisoSts::StandardRef.new do |sr|
              sr.type = type if type
              sr.value = value if value
            end
          end

          def ref(id: nil, label: nil, mixed_citation: nil, std: nil)
            ::Sts::NisoSts::Reference.new do |r|
              r.id = id if id
              r.label = ::Sts::NisoSts::Label.new(content: [label]) if label
              r.mixed_citation = ::Sts::NisoSts::MixedCitation.new(content: [mixed_citation]) if mixed_citation
              r.std = std if std
            end
          end

          # Builds the OIML front-matter metadata block. OIML is not
          # ISO — the NISO-STS-correct container for an OIML publication
          # is <std-meta> (the generic catch-all for non-ISO / non-
          # national / non-regional SDOs). MetadataStd ships the same
          # attribute set as MetadataIso (title_wrap, std_ident,
          # permissions, pub_date, custom_meta_group), but several
          # are collections where MetadataIso's were singular.
          def std_meta(doc_identifier: nil, title: nil, pub_date: nil,
                       permissions: nil, custom_meta_group: nil)
            ::Sts::NisoSts::MetadataStd.new.tap do |m|
              m.title_wrap = [::Sts::NisoSts::TitleWrap.new(main: title)] if title
              m.std_ident = std_ident_for(doc_identifier) if doc_identifier
              m.permissions = [permissions] if permissions
              m.pub_date = pub_date.to_s if pub_date
              m.custom_meta_group = [custom_meta_group] if custom_meta_group
            end
          end

          # <std-ident> per NISO STS (Z39.102-2022): the OIML identifier
          # decomposed into originator + doc-type + doc-number
          # (+ part-number). "OIML B 6-2:2024" → OIML / b / 6 / 2. The
          # publication year is NOT repeated here — pub-date carries it.
          # Identifiers that don't match the OIML pattern fall back to a
          # plain originator string rather than being dropped.
          OIML_ID_PATTERN = /\A(OIML)\s+([A-Z]+)\s+(\d+)(?:-(\d+))?(?::\d{4})?\z/.freeze

          def std_ident_for(doc_identifier)
            match = OIML_ID_PATTERN.match(doc_identifier.to_s.strip)
            return plain_std_ident(doc_identifier) unless match

            attrs = {
              originator: match[1],
              doc_type: match[2].downcase,
              doc_number: match[3],
            }
            attrs[:part_number] = match[4] if match[4]
            ::Sts::NisoSts::StandardIdentification.new(attrs)
          end

          def plain_std_ident(doc_identifier)
            ::Sts::NisoSts::StandardIdentification.new(originator: doc_identifier)
          end

          def permissions(holder: nil, year: nil, copyright_statement: nil)
            holders = Array(holder).compact
            attrs = {}
            attrs[:copyright_statement] = copyright_statement ||
              (year && holders.any? ? "© #{year} #{holders.first}" : nil)
            attrs[:copyright_year] = year.to_s if year
            attrs[:copyright_holder] = holders if holders.any?
            ::Sts::NisoSts::Permissions.new(attrs)
          end

          def custom_meta_group(name: nil, value: nil)
            ::Sts::NisoSts::CustomMetaGroup.new(
              custom_meta: [::Sts::NisoSts::CustomMeta.new(
                meta_name: name, meta_value: value
              )]
            )
          end

          # ---- ISO front matter (<std-meta>) ----------------------------------

          # Builds a <std-meta> block (NisoSts::MetadataStd) per the
          # IEC/ISO Coding Guidelines ed. 2.1 §4.3.2 ISO profile. The
          # block yields the instance so the ISO meta transformer can
          # attach the typed children in the XSD sequence order (the
          # model's mapping is ordered — setter call order is the
          # serialization order).
          def metadata_std
            ::Sts::NisoSts::MetadataStd.new { |m| yield m if block_given? }
          end

          def std_org(std_org_type: nil, abbrev: nil)
            ::Sts::NisoSts::StdOrg.new do |so|
              so.std_org_type = std_org_type if std_org_type
              so.std_org_abbrev = [::Sts::NisoSts::StdOrgAbbrev.new(content: [abbrev])] if abbrev
            end
          end

          def release_date(content: nil, date_type: nil)
            ::Sts::NisoSts::ReleaseDate.new do |rd|
              rd.content = Array(content) if content
              rd.date_type = date_type if date_type
            end
          end

          def proj_id(content: nil)
            ::Sts::NisoSts::ProjId.new(content: Array(content))
          end

          def release_version(content: nil)
            ::Sts::NisoSts::ReleaseVersion.new(content: Array(content))
          end

          def metadata_iso
            ::Sts::NisoSts::MetadataIso.new { |m| yield m if block_given? }
          end

          def title_wrap(lang: nil)
            ::Sts::NisoSts::TitleWrap.new do |tw|
              tw.lang = lang if lang
              yield tw if block_given?
            end
          end

          def title_full(content: nil)
            ::Sts::NisoSts::TitleFull.new do |t|
              yield t if block_given?
              t.content = Array(content) if content
            end
          end

          def title_compl(content: nil)
            ::Sts::NisoSts::TitleCompl.new do |t|
              yield t if block_given?
              t.content = Array(content) if content
            end
          end

          def document_identification(sdo: nil, proj_id: nil, language: nil,
                                      release_version: nil, urn: nil)
            ::Sts::NisoSts::DocumentIdentification.new(
              sdo: sdo,
              proj_id: proj_id,
              language: language,
              release_version: release_version,
              urn: urn,
            )
          end

          def standard_identification(originator: nil, doc_type: nil,
                                      doc_number: nil, edition: nil,
                                      version: nil, part_number: nil)
            ::Sts::NisoSts::StandardIdentification.new(
              originator: originator,
              doc_type: doc_type,
              doc_number: doc_number,
              edition: edition,
              version: version,
              part_number: part_number,
            )
          end

          def bold(content: [])
            ::Sts::TbxIsoTml::Bold.new(value: Array(content))
          end

          def italic(content: [])
            ::Sts::TbxIsoTml::Italic.new(value: Array(content))
          end

          def monospace(content: [])
            ::Sts::NisoSts::Monospace.new(content: Array(content))
          end

          def sub(content: [])
            ::Sts::NisoSts::Sub.new(content: Array(content))
          end

          def sup(content: [])
            ::Sts::NisoSts::Sup.new(content: Array(content))
          end

          def ext_link(xlink_href: nil, content: [])
            ::Sts::NisoSts::ExtLink.new(
              ext_link_type: "uri",
              xlink_href: xlink_href,
              content: Array(content)
            )
          end

          def xref(rid: nil, ref_type: "other", value: nil)
            ::Sts::TbxIsoTml::Xref.new(rid: rid, ref_type: ref_type, value: value)
          end

          def fn(id: nil, value: nil)
            ::Sts::TbxIsoTml::Fn.new(id: id, value: value)
          end

          def title(content: [])
            ::Sts::NisoSts::Title.new(content: Array(content))
          end

          def label(content: [])
            ::Sts::NisoSts::Label.new(content: Array(content))
          end
        end
      end
    end
  end
end
