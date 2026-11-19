# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      # Conversion context — tracks state during XML→DOCX rendering.
      #
      # Maintains counters, flags, and state that change as the document
      # tree is walked. Passed through the visitor chain to avoid global
      # mutable state on the adapter.
      class Context
        attr_reader :footnote_counter, :bookmark_counter, :comment_counter,
                    :formula_footnote_bodies, :formula_key_footnote_handler
        attr_accessor :in_note, :in_example, :in_table, :in_annex,
                      :in_normative, :in_foreword, :in_introduction,
                      :in_bibliography, :in_definition_dd, :in_formula,
                      :in_figure, :in_definitions, :list_depth,
                      :section_depth,
                      :term_counter, :section_counter, :body_width,
                      :amend_zone
        def initialize
          @footnote_counter = Counter.new
          @bookmark_counter = Counter.new
          @comment_counter = Counter.new
          @in_note = false
          @in_example = false
          @in_table = false
          @in_annex = false
          @in_normative = false
          @in_foreword = false
          @in_introduction = false
          @in_bibliography = false
          @in_definition_dd = false
          @in_formula = false
          @in_figure = false
          @in_definitions = false
          @list_depth = 0
          @section_depth = 0
          @section_counter = Counter.new(0)
          @term_counter = Counter.new(0)
          @zone_paragraph_counts = Hash.new(0)
          @amend_zone = nil
        end

        def next_footnote_id
          @footnote_counter.next
        end

        def next_bookmark_id
          @bookmark_counter.next
        end

        def next_comment_id
          @comment_counter.next
        end

        def next_section_number
          @section_counter.next
        end

        def current_section_number
          @section_counter.current
        end

        def next_term_number
          @term_counter.next
          "#{@section_counter.current}.#{@term_counter.current}"
        end

        def with_terms_section(section_number)
          old_counter = @term_counter
          @term_counter = Counter.new(0)
          yield
        ensure
          @term_counter = old_counter
        end

        def with_annex
          old = @in_annex
          @in_annex = true
          yield
        ensure
          @in_annex = old
        end

        def with_table
          old = @in_table
          @in_table = true
          yield
        ensure
          @in_table = old
        end

        def with_note
          old = @in_note
          old_count = @zone_paragraph_counts[:note]
          @in_note = true
          @zone_paragraph_counts[:note] = 0
          yield
        ensure
          @in_note = old
          @zone_paragraph_counts[:note] = old_count
        end

        def with_example
          old = @in_example
          old_count = @zone_paragraph_counts[:example]
          @in_example = true
          @zone_paragraph_counts[:example] = 0
          yield
        ensure
          @in_example = old
          @zone_paragraph_counts[:example] = old_count
        end

        def with_definition_dd
          old = @in_definition_dd
          @in_definition_dd = true
          yield
        ensure
          @in_definition_dd = old
        end

        def with_normative(value = true)
          old = @in_normative
          @in_normative = value
          yield
        ensure
          @in_normative = old
        end

        def with_foreword
          old = @in_foreword
          @in_foreword = true
          yield
        ensure
          @in_foreword = old
        end

        def with_introduction
          old = @in_introduction
          @in_introduction = true
          yield
        ensure
          @in_introduction = old
        end

        def with_bibliography
          old = @in_bibliography
          @in_bibliography = true
          yield
        ensure
          @in_bibliography = old
        end

        def with_formula(footnote_bodies = nil)
          old = @in_formula
          old_bodies = @formula_footnote_bodies
          @in_formula = true
          @formula_footnote_bodies = footnote_bodies
          yield
        ensure
          @in_formula = old
          @formula_footnote_bodies = old_bodies
        end

        def with_formula_key_footnotes(handler)
          old = @formula_key_footnote_handler
          @formula_key_footnote_handler = handler
          yield
        ensure
          @formula_key_footnote_handler = old
        end

        def with_list
          @list_depth += 1
          yield
        ensure
          @list_depth -= 1
        end

        def with_figure
          old = @in_figure
          @in_figure = true
          yield
        ensure
          @in_figure = old
        end

        # Enter a definitions section (ISO "Symbols and abbreviated
        # terms"). While inside, Context#zone returns :definitions so
        # DefinitionListRenderer renders the symbol definition list as a
        # two-column table (classic chain: WordFunction#dl_parse_table).
        def with_definitions
          old = @in_definitions
          @in_definitions = true
          yield
        ensure
          @in_definitions = old
        end

        # Enter an amend zone (:description or :newcontent). While inside,
        # Context#zone returns the amend sub-zone so StyleResolver can
        # apply BodyText for description and a3 (amend_newcontent) for
        # newcontent paragraphs.
        def with_amend(zone)
          old = @amend_zone
          old_count = @zone_paragraph_counts[zone]
          @amend_zone = zone
          @zone_paragraph_counts[zone] = 0
          yield
        ensure
          @amend_zone = old
          @zone_paragraph_counts[zone] = old_count
        end

        # Single enum view of the current rendering zone, derived from
        # the boolean flags. StyleResolver uses this for context-aware
        # dispatch (single source of truth).
        #
        # Priority order matters: most-specific zone first. Nested zones
        # (e.g., a note inside amend newcontent) win over their parent
        # zone so the inner content picks up the inner style.
        def zone
          return :note         if @in_note
          return :example      if @in_example
          return :table        if @in_table
          return :formula      if @in_formula
          return :figure       if @in_figure
          return :definitions  if @in_definitions
          return :amend_description if @amend_zone == :description
          return :amend_newcontent if @amend_zone == :newcontent
          return :annex        if @in_annex
          return :foreword     if @in_foreword
          return :introduction if @in_introduction
          return :normative    if @in_normative
          return :bibliography if @in_bibliography
          :body
        end

        # How many paragraphs have been rendered in the given zone during
        # the current with_* block. Used by StyleResolver to pick the
        # "continued" body-style variant for note/example zones where the
        # 2nd+ paragraphs use Noteindentcontinued / Exampleindentcontinued.
        def zone_paragraph_count(zone)
          @zone_paragraph_counts[zone] || 0
        end

        # Increment the current zone's paragraph counter. Called by
        # ParagraphRenderer after applying the zone's body style.
        def mark_zone_paragraph
          current = zone
          @zone_paragraph_counts[current] = @zone_paragraph_counts[current] + 1
        end
      end

      # Thread-safe ascending counter.
      class Counter
        def initialize(start = 0)
          @value = start
        end

        def next
          @value += 1
        end

        def current
          @value
        end
      end
    end
  end
end
