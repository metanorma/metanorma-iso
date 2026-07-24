# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      module Transformer
        # Factory methods for building sts-ruby NisoSts model instances.
        # Centralizing construction here keeps "how do I build an X?" in one
        # place (DRY, MECE) and makes future model-class renames a one-file
        # change (OCP — adding a new mapped class is a new factory method,
        # not a scatter of construction sites).
        #
        # All output is Sts::NisoSts / Sts::TbxIsoTml — the maintained
        # NISO STS v1.2 tagset per the IEC/ISO Coding Guidelines ed. 2.1.
        # The legacy Sts::IsoSts tagset is not used.
        module ModelBuilder
          NISO = ::Sts::NisoSts
          TBX = ::Sts::TbxIsoTml

          module_function

          # ---- Document shell --------------------------------------------------

          def standard(lang: "en", dtd_version: "1.2", front: nil, body: nil, back: nil)
            NISO::Standard.new(lang: lang, dtd_version: dtd_version).tap do |std|
              std.front = front if front
              std.body = body if body
              std.back = back if back
            end
          end

          def front(iso_meta: nil, sec: [])
            NISO::Front.new.tap do |f|
              f.iso_meta = iso_meta if iso_meta
              Array(sec).each { |s| f.sec s }
            end
          end

          def body(sec: [])
            NISO::Body.new.tap { |b| Array(sec).each { |s| b.sec s } }
          end

          def back(app_group: nil, ref_list: [])
            NISO::Back.new.tap do |b|
              b.app_group = app_group if app_group
              Array(ref_list).each { |r| b.ref_list r }
            end
          end

          def app_group(app: [])
            NISO::AppGroup.new.tap { |g| Array(app).each { |a| g.app a } }
          end

          # ---- Sections & blocks ----------------------------------------------

          def section(id: nil, sec_type: nil, label: nil, title: nil)
            NISO::Section.new.tap do |s|
              s.id = id if id
              s.type = sec_type if sec_type
              s.label = label_obj(label) if label
              s.title = title_obj(title) if title
              yield s if block_given?
            end
          end

          def term_section(id: nil, label: nil, title: nil)
            NISO::TermSection.new.tap do |s|
              s.id = id if id
              s.label = label_obj(label) if label
              s.title = title_obj(title) if title
              yield s if block_given?
            end
          end

          def app(id: nil, label: nil, title: nil)
            NISO::App.new.tap do |a|
              a.id = id if id
              a.label = label_obj(label) if label
              a.title = title_obj(title) if title
              yield a if block_given?
            end
          end

          def paragraph(id: nil, content: nil)
            NISO::Paragraph.new.tap do |p|
              p.id = id if id
              yield p if block_given?
              p.content = Array(content) if content
            end
          end

          def list(id: nil, list_type: "bullet")
            NISO::List.new(id: id, list_type: list_type).tap { |l| yield l if block_given? }
          end

          def list_item
            NISO::ListItem.new.tap { |i| yield i if block_given? }
          end

          def def_list(id: nil)
            NISO::DefList.new.tap do |dl|
              dl.id = id if id
              yield dl if block_given?
            end
          end

          def table_wrap(id: nil, label: nil, caption: nil)
            TBX::TableWrap.new.tap do |tw|
              tw.id = id if id
              tw.label = label_obj(label) if label
              tw.caption = caption if caption
              yield tw if block_given?
            end
          end

          def caption(title: nil)
            NISO::Caption.new.tap do |c|
              c.title = title_obj(title) if title
              yield c if block_given?
            end
          end

          def figure(id: nil, label: nil, caption: nil, graphic: nil)
            NISO::Figure.new.tap do |f|
              f.id = id if id
              f.label = label_obj(label) if label
              f.caption = caption if caption
              yield f if block_given?
            end
          end

          def graphic(href: nil)
            NISO::Graphic.new(href: href)
          end

          def display_formula(id: nil, label: nil)
            NISO::DisplayFormula.new.tap do |f|
              f.id = id if id
              f.label = label_obj(label) if label
              yield f if block_given?
            end
          end

          def inline_formula
            NISO::InlineFormula.new.tap { |f| yield f if block_given? }
          end

          def non_normative_note(id: nil, label: nil)
            NISO::NonNormativeNote.new.tap do |n|
              n.id = id if id
              n.label = label_obj(label) if label
              yield n if block_given?
            end
          end

          def non_normative_example(id: nil, label: nil)
            NISO::NonNormativeExample.new.tap do |e|
              e.id = id if id
              e.label = label_obj(label) if label
              yield e if block_given?
            end
          end

          def disp_quote
            NISO::DispQuote.new.tap { |q| yield q if block_given? }
          end

          def preformat(id: nil)
            NISO::Preformat.new.tap do |p|
              p.id = id if id
              yield p if block_given?
            end
          end

          # ---- Bibliography ----------------------------------------------------

          def ref_list(content_type: nil, title: nil)
            NISO::ReferenceList.new.tap do |rl|
              rl.content_type = content_type if content_type
              rl.title = title_obj(title) if title
              yield rl if block_given?
            end
          end

          def ref(label: nil, mixed_citation: nil, std: nil)
            NISO::Reference.new.tap do |r|
              r.label = label_obj(label) if label
              yield r if block_given?
              r.mixed_citation = mixed_citation if mixed_citation
              r.std = std if std
            end
          end

          def mixed_citation(content: nil)
            NISO::MixedCitation.new.tap do |c|
              yield c if block_given?
              c.content = Array(content) if content
            end
          end

          def element_citation(content: nil)
            NISO::ElementCitation.new.tap do |c|
              yield c if block_given?
              c.content = Array(content) if content
            end
          end

          def reference_standard
            NISO::ReferenceStandard.new.tap { |s| yield s if block_given? }
          end

          def standard_ref(type: "dated", value: nil)
            NISO::StandardRef.new.tap do |r|
              r.type = type
              r.value = value if value
              yield r if block_given?
            end
          end

          # ---- Inline phrase ---------------------------------------------------

          def bold
            TBX::Bold.new.tap { |b| yield b if block_given? }
          end

          def italic
            TBX::Italic.new.tap { |i| yield i if block_given? }
          end

          def sub
            NISO::Sub.new.tap { |s| yield s if block_given? }
          end

          def sup
            NISO::Sup.new.tap { |s| yield s if block_given? }
          end

          def monospace
            NISO::Monospace.new.tap { |m| yield m if block_given? }
          end

          def sc
            NISO::Sc.new.tap { |s| yield s if block_given? }
          end

          def ext_link(href: nil, ext_link_type: "uri")
            NISO::ExtLink.new(ext_link_type: ext_link_type, href: href).tap do |l|
              yield l if block_given?
            end
          end

          def xref(rid: nil, ref_type: "other")
            TBX::Xref.new(rid: rid, ref_type: ref_type).tap { |x| yield x if block_given? }
          end

          def fn(id: nil)
            TBX::Fn.new.tap do |f|
              f.id = id if id
              yield f if block_given?
            end
          end

          def break
            NISO::Break.new
          end

          def styled_content
            NISO::StyledContent.new.tap { |s| yield s if block_given? }
          end

          # ---- ISO metadata (iso-meta, NISO STS v1.2 shape) -------------------

          # NisoSts::MetadataIso is the <iso-meta> container per Coding
          # Guidelines ed. 2.1. Most children are STRINGS — only
          # title_wrap, doc_ident, std_ident, std_ref, permissions, ics
          # remain typed. The block yields the MetadataIso instance so
          # callers can attach the typed children + set string fields
          # directly.
          def metadata_iso
            NISO::MetadataIso.new.tap { |m| yield m if block_given? }
          end

          def title_wrap(lang: nil)
            NISO::TitleWrap.new.tap do |tw|
              tw.lang = lang if lang
              yield tw if block_given?
            end
          end

          def title_full(content: nil)
            NISO::TitleFull.new.tap do |t|
              yield t if block_given?
              t.content = Array(content) if content
            end
          end

          def title_compl(content: nil)
            NISO::TitleCompl.new.tap do |t|
              yield t if block_given?
              t.content = Array(content) if content
            end
          end

          def document_identification(sdo: nil, proj_id: nil, language: nil,
                                      release_version: nil, urn: nil)
            NISO::DocumentIdentification.new(
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
            NISO::StandardIdentification.new(
              originator: originator,
              doc_type: doc_type,
              doc_number: doc_number,
              edition: edition,
              version: version,
              part_number: part_number,
            )
          end

          def permissions(copyright_statement: nil, copyright_year: nil,
                          copyright_holder: nil)
            attrs = {}
            attrs[:copyright_statement] = copyright_statement if copyright_statement
            attrs[:copyright_year] = copyright_year if copyright_year
            attrs[:copyright_holder] = Array(copyright_holder) if copyright_holder
            NISO::Permissions.new(attrs)
          end

          def ics(code: nil)
            NISO::Ics.new.tap do |i|
              i.content = code if code
              yield i if block_given?
            end
          end

          def fn_group(id: nil)
            NISO::FnGroup.new.tap do |g|
              g.id = id if id
              yield g if block_given?
            end
          end

          def table_wrap_foot
            TBX::TableWrapFoot.new.tap { |f| yield f if block_given? }
          end

          # ---- Common leaves ---------------------------------------------------

          def title(content: nil)
            NISO::Title.new.tap do |t|
              yield t if block_given?
              t.content = Array(content) if content
            end
          end

          def label(content: nil)
            NISO::Label.new(content: (content ? Array(content) : nil))
          end

          # ---- Private helpers -------------------------------------------------

          # Wraps a String in a Title; passes through an existing Title model
          # unchanged; ignores nil.
          def title_obj(value)
            return nil unless value
            return value if value.is_a?(NISO::Title)

            NISO::Title.new(content: [value])
          end

          def label_obj(value)
            return nil unless value
            return value if value.is_a?(NISO::Label)

            NISO::Label.new(content: [value])
          end
        end
      end
    end
  end
end
