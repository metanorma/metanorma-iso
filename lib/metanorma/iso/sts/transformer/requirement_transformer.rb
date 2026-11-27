# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      module Transformer
        # Converts MN requirement / recommendation / permission blocks to
        # STS formal tables (<table-wrap>), the way the HTML and PDF
        # pipelines render them (metanorma-document Standard
        # Renderer#render_requirement).
        #
        # PREFERRED: the requirement's own rendered table — the
        # <fmt-provision> <table> carried by the sibling presentation XML
        # — mapped 1:1 (label, caption, rows) per the IEC/ISO Coding
        # Guidelines formal-table coding.
        #
        # FALLBACK (no presentation XML, or a requirement — typically a
        # nested test — that carries no provision of its own): synthesize
        # the rows from the semantic components, one row per populated
        # component plus a Classification row, mirroring the renderer's
        # REQ_COMPONENTS inventory.
        #
        # Nested requirements (tests inside conformance classes) render
        # after the parent's table, as their own table-wraps.
        class RequirementTransformer < Metanorma::Document::Sts::Transformer::RequirementTransformer
          # Component attribute → row label, mirroring the HTML renderer.
          REQ_COMPONENTS = {
            description: "Description",
            specification: "Statement",
            measurement_target: "Measurement target",
            verification: "Verification",
            inherit: "Inheritance",
            import: "Imported",
          }.freeze

          # Requirement type → NISO STS table-wrap @content-type, the
          # mnconvert vocabulary (recommend / recommendtest /
          # recommendclass).
          TYPE_TO_CONTENT_TYPE = {
            "class" => "recommendclass",
            "conformanceclass" => "recommendclass",
            "abstractclass" => "recommendclass",
            "verification" => "recommendtest",
            "test" => "recommendtest",
          }.freeze

          # Requirement type → mn-requirements vocabulary key, for the
          # synthesized label ("Requirements class", "Conformance class",
          # "Requirement test", …).
          TYPE_TO_LABEL_KEY = {
            "class" => "requirementclass",
            "abstractclass" => "requirementclass",
            "verification" => "requirementtest",
            "test" => "requirementtest",
          }.freeze

          # @return [Array<::Sts::TbxIsoTml::TableWrap>] the requirement's
          #   table first, then one per nested requirement.
          def transform(source_req)
            parent = table_wrap_for(source_req)
            wraps = parent ? [parent] : []
            wraps + nested_transforms(source_req)
          end

          private

          def table_wrap_for(source_req)
            provision = context.provision_for(source_req)
            if provision
              provision_table_wrap(source_req, provision)
            else
              synthesized_table_wrap(source_req)
            end
          end

          def nested_transforms(source_req)
            %i[requirement recommendation permission].flat_map do |attr|
              next [] unless source_req.class.attributes.key?(attr)

              Array(source_req.public_send(attr)).flat_map { |child| transform(child) }
            end
          end

          # ---- Preferred path: the provision table 1:1 -------------------

          def provision_table_wrap(source_req, provision_table)
            table_transformer.transform(provision_table,
                                        id: requirement_sts_id(source_req),
                                        content_type: content_type_for(source_req),
                                        specific_use: specific_use_for(source_req),
                                        bold_header: true)
          end

          # ---- Fallback path: synthesize from the components -------------

          def synthesized_table_wrap(source_req)
            rows = component_rows(source_req)
            return nil if rows.empty? && title_text_of(source_req).nil?

            ::Sts::TbxIsoTml::TableWrap.new do |tw|
              tw.id = requirement_sts_id(source_req)
              tw.label = synthesized_label_text(source_req)
              tw.content_type = content_type_for(source_req)
              tw.specific_use = specific_use_for(source_req)
              caption = synthesized_caption(source_req)
              tw.caption = caption if caption
              tw.table = [table_from_rows(rows)]
            end
          end

          def table_from_rows(rows)
            trs = rows.map do |row_label, cell|
              ModelBuilder.tr(th: [bold_cell(row_label)], td: [cell])
            end
            ModelBuilder.table(tbody: ModelBuilder.tbody(tr: trs))
          end

          def bold_cell(text)
            ::Sts::TbxIsoTml::Th.new do |c|
              c.bold ::Sts::TbxIsoTml::Bold.new(value: [text]) if text && !text.empty?
            end
          end

          # One row per populated component (HTML's REQ_COMPONENTS
          # inventory), then the Classification row.
          def component_rows(source_req)
            rows = []
            REQ_COMPONENTS.each do |attr, row_label|
              next unless source_req.class.attributes.key?(attr)

              value = source_req.public_send(attr)
              cell = component_cell(attr, value)
              rows << [row_label, cell] if cell
            end

            cls_cell = classification_cell(source_req)
            rows << ["Classification", cls_cell] if cls_cell
            rows
          end

          def component_cell(attr, value)
            case attr
            when :inherit, :import
              inherit_cell(value)
            else
              description_cell(value)
            end
          end

          # Description-family components carry paragraphs / lists /
          # notes / examples.
          def description_cell(components)
            td = ::Sts::TbxIsoTml::Td.new
            populated = false
            Array(components).each do |component|
              next unless component.is_a?(Lutaml::Model::Serializable)

              Array(component.p).each do |p|
                paragraph = paragraph_transformer.transform(p)
                td.paragraph paragraph if paragraph
                populated = true
              end
              %i[ul ol].each do |kind|
                Array(component.public_send(kind)).each do |list|
                  td.list list_transformer.transform(list)
                  populated = true
                end
              end
              Array(component.note).each do |n|
                note = note_transformer.transform(n)
                td.non_normative_note note if note
                populated = true
              end
              Array(component.example).each do |ex|
                example = note_transformer.transform(ex)
                td.non_normative_example example if example
                populated = true
              end
            end
            populated ? td : nil
          end

          # Inheritance / import rows carry requirement paths — the ref
          # coding sets them in monospace.
          def inherit_cell(inherits)
            texts = Array(inherits).filter_map do |inh|
              value = RenderedTextExtractor.text_of(inh)
              value unless value.nil? || value.empty?
            end
            return nil if texts.empty?

            ::Sts::TbxIsoTml::Td.new do |c|
              texts.each { |t| c.monospace ::Sts::NisoSts::Monospace.new(content: [t]) }
            end
          end

          def classification_cell(source_req)
            

            cls = Array(source_req.classification).filter_map do |c|
              next unless c.respond_to?(:value)

              "#{c.tag if c.respond_to?(:tag)} #{RenderedTextExtractor.text_of(c.value)}".strip
            end.reject(&:empty?)
            return nil if cls.empty?

            ::Sts::TbxIsoTml::Td.new do |c|
              c.content cls.join("; ")
            end
          end

          # "Requirement 1" / "Conformance class A.1" — the renderer's
          # label vocabulary (mn-requirements' i18n strings, keyed by the
          # requirement type), suffixed by the requirement identifier.
          def synthesized_label_text(source_req)
            base = reqt_label(source_req)
            ident = requirement_identifier(source_req)
            ident && !ident.empty? ? "#{base} #{ident}" : base
          end

          def requirement_identifier(source_req)
            

            RenderedTextExtractor.text_of(source_req.identifier).to_s.strip
          end

          def synthesized_caption(source_req)
            text = title_text_of(source_req)
            return nil if text.nil? || text.empty?

            ::Sts::NisoSts::Caption.new(
              title: ::Sts::NisoSts::Title.new(content: [text])
            )
          end

          def title_text_of(source_req)
            

            title = source_req.title
            text = if title.is_a?(Lutaml::Model::Serializable) &&
                title.respond_to?(:value) && !title.respond_to?(:each_mixed_content)
                     Array(title.value).join
                   else
                     RenderedTextExtractor.text_of(title)
                   end
            text.nil? || text.to_s.empty? ? nil : text.to_s
          end

          def reqt_label(source_req)
            type = source_req.type.to_s
            vocabulary = reqt_labels
            key = TYPE_TO_LABEL_KEY[type] || type
            vocabulary[key] ||
              vocabulary[source_req.class.name.split("::").last.delete_suffix("Model").downcase] ||
              source_req.class.name.split("::").last.delete_suffix("Model").capitalize
          end

          # mn-requirements' vocabulary (the strings the native isodoc
          # pipeline renders), via IsoDoc::MnRequirementsI18n. Empty when
          # the gem is absent — the class-name fallback covers it.
          def reqt_labels
            @reqt_labels ||= begin
              require "isodoc-i18n"
              gem_path = Gem.loaded_specs["mn-requirements"]&.full_gem_path
              gem_path && require(File.join(gem_path, "lib/isodoc/i18n"))
              i18n = IsoDoc::MnRequirementsI18n.new(context.language, nil)
              req = Hash(i18n.get["requirements"])
              Hash(req["default"]).merge(Hash(req["modspec"]))
            rescue StandardError
              {}
            end
          end

          # ---- Shared helpers ---------------------------------------------

          # xs:ID for the requirement's table: its anchor (what xrefs
          # target — "rc-…", "cc-…", "r-…"), else the source id.
          def requirement_sts_id(source_req)
            

            anchor = source_req.anchor
            anchor.nil? || anchor.empty? ? source_req.id : anchor
          end

          def content_type_for(source_req)
            type = source_req.type.to_s
            TYPE_TO_CONTENT_TYPE[type] || "recommend"
          end

          # modspec-model requirements render under specific-use="modspec".
          def specific_use_for(source_req)
            model = source_req.model.to_s
            model.empty? ? nil : "modspec"
          end
        end
      end
    end
  end
end
