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
        attr_reader :footnote_counter, :bookmark_counter, :comment_counter
        attr_accessor :in_note, :in_example, :in_table, :in_annex,
                      :in_normative, :in_foreword, :in_introduction,
                      :in_bibliography, :in_definition_dd, :section_depth,
                      :term_counter, :section_counter

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
          @section_depth = 0
          @section_counter = Counter.new(0)
          @term_counter = Counter.new(0)
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
          @in_note = true
          yield
        ensure
          @in_note = old
        end

        def with_example
          old = @in_example
          @in_example = true
          yield
        ensure
          @in_example = old
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
