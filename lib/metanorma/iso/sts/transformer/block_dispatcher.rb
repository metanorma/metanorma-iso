# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      module Transformer
        class BlockDispatcher < Base
          HANDLERS = {
            "IsoClauseSection"             => :dispatch_via_section,
            "ClauseSection"                => :dispatch_via_section,
            "IsoForewordSection"           => :dispatch_via_section,
            "IsoIntroductionSection"       => :dispatch_via_section,
            "IsoTermsSection"              => :dispatch_via_section,
            "DefinitionSection"            => :dispatch_via_section,
            "IsoAnnexSection"              => :dispatch_via_section,
            "ParagraphBlock"               => :dispatch_via_paragraph,
            "ParagraphWithFootnote"        => :dispatch_via_paragraph,
            "UnorderedList"                => :dispatch_via_list,
            "OrderedList"                  => :dispatch_via_list,
            "DefinitionList"               => :dispatch_via_dl,
            "TableBlock"                   => :dispatch_via_table,
            "FigureBlock"                  => :dispatch_via_figure,
            "FormulaBlock"                 => :dispatch_via_formula,
            "NoteBlock"                    => :dispatch_via_note,
            "ExampleBlock"                 => :dispatch_via_note,
            "AdmonitionBlock"              => :dispatch_via_note,
            "QuoteBlock"                   => :dispatch_via_note,
            "SourcecodeBlock"              => :dispatch_via_sourcecode,
            "RequirementModel"             => :dispatch_via_requirement,
            "RecommendationModel"          => :dispatch_via_requirement,
            "PermissionModel"              => :dispatch_via_requirement,
            "StandardReferencesSection"    => :dispatch_via_references,
            "BibliographySection"          => :dispatch_via_references
          }.freeze

          PRESENTATION_CLASSES = %w[
            FmtTitleElement FmtXrefLabelElement FmtNameElement FmtStemElement
            FmtFnLabelElement FmtConceptElement SemxElement LocalizedString
            LocalizedStrings FmtVal AsciiMath BrElement TabElement Bookmark
            SpanElement
          ].freeze

          def dispatch(source_obj)
            return nil if source_obj.nil? || source_obj.is_a?(String)
            class_name = source_obj.class.name&.split("::")&.last
            return nil if PRESENTATION_CLASSES.include?(class_name)

            handler = HANDLERS[class_name]
            return nil unless handler

            send(handler, source_obj)
          end

          SECTION_CLASS_NAMES = %w[
            IsoClauseSection ClauseSection IsoForewordSection
            IsoIntroductionSection IsoTermsSection DefinitionSection
            IsoAnnexSection AnnexSection
          ].freeze

          # Typed attribute → handler method mapping for ContentSection.
          # These are NOT yielded by each_mixed_content; we iterate them
          # explicitly to dispatch tables, lists, notes, etc.
          TYPED_ATTR_DISPATCH = {
            paragraphs: :dispatch_via_paragraph,
            unordered_lists: :dispatch_via_list,
            ordered_lists: :dispatch_via_list,
            tables: :dispatch_via_table,
            requirement: :dispatch_via_requirement,
            recommendation: :dispatch_via_requirement,
            permission: :dispatch_via_requirement,
            figures: :dispatch_via_figure,
            formulas: :dispatch_via_formula,
            notes: :dispatch_via_note,
            examples: :dispatch_via_note,
            admonitions: :dispatch_via_note,
            sourcecode_blocks: :dispatch_via_sourcecode,
            quote_blocks: :dispatch_via_note,
            definition_lists: :dispatch_via_dl,
            definitions: :dispatch_via_section,
          }.freeze

          def dispatch_section_blocks(section)
            results = []

            # Walk typed collection attributes for all content types.
            # each_mixed_content is NOT used because it overlaps with
            # typed attributes (causing duplication) and misses some
            # content types (tables, lists, notes).
            TYPED_ATTR_DISPATCH.each do |attr, handler|
              next unless section.class.attributes.key?(attr)
              collection = section.public_send(attr)
              Array(collection).each do |item|
                result = send(handler, item)
                Array(result).each { |r| results << r } if result
                dispatch_paragraph_siblings(item, results)
              end
            end

            results
          end

          # MN's typed model attaches "block siblings" as attributes on
          # the preceding block (ParagraphBlock.note holds notes that
          # semantically follow the paragraph; TableBlock.note and
          # List#note hold the same kind of trailing notes for their
          # carriers). Walk those sibling collections and dispatch each,
          # preserving document order. Restricted to the block carriers
          # whose note/example sub-collections have that semantics —
          # lists that carry their own note sub-collections with
          # different semantics are excluded case by case.
          def dispatch_paragraph_siblings(item, results)
            return unless sibling_block?(item)

            SIBLING_ATTRS.each do |attr, handler|
              next unless item.class.attributes.key?(attr)
              Array(item.public_send(attr)).each do |sibling|
                result = send(handler, sibling)
                Array(result).each { |r| results << r } if result
              end
            end
          end

          def sibling_block?(item)
            paragraph_block?(item) || table_block?(item) || list_block?(item)
          end

          def paragraph_block?(item)
            item.is_a?(Metanorma::Document::Components::Paragraphs::ParagraphBlock)
          end

          def table_block?(item)
            item.is_a?(Metanorma::Document::Components::Tables::TableBlock)
          end

          def list_block?(item)
            item.is_a?(Metanorma::Document::Components::Lists::List)
          end

          SIBLING_ATTRS = {
            note: :dispatch_via_note,
            example: :dispatch_via_note,
          }.freeze

          private

          def dispatch_via_section(obj);   section_transformer.transform(obj);   end
          def dispatch_via_paragraph(obj); paragraph_transformer.transform(obj); end
          def dispatch_via_list(obj);     list_transformer.transform(obj);     end
          def dispatch_via_dl(obj);       dl_transformer.transform(obj);       end
          def dispatch_via_table(obj);    table_transformer.transform(obj);    end
          def dispatch_via_figure(obj);   figure_transformer.transform(obj);   end
          def dispatch_via_formula(obj);  formula_transformer.transform(obj);  end
          # MN binds a note following a list's last item as List.note; the
          # STS note/example models have no nested-note slot, so those
          # notes surface as siblings after their carrier.
          def dispatch_via_note(obj)
            model = note_transformer.transform(obj)
            [model, *list_trailing_notes(obj)].compact
          end
          def dispatch_via_requirement(obj); requirement_transformer.transform(obj); end
          def dispatch_via_sourcecode(obj); note_transformer.transform_preformat(obj); end
          def dispatch_via_references(obj); reference_transformer.transform_section(obj); end

          def list_trailing_notes(obj)
            %i[ul ol].flat_map do |attr|
              next [] unless obj.class.attributes.key?(attr)
              Array(obj.public_send(attr)).flat_map do |list|
                next [] unless list.class.attributes.key?(:note)
                Array(list.note).filter_map { |n| note_transformer.transform(n) }
              end
            end
          end
        end
      end
    end
  end
end
