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
                      :in_normative, :section_depth

        def initialize
          @footnote_counter = Counter.new
          @bookmark_counter = Counter.new
          @comment_counter = Counter.new
          @in_note = false
          @in_example = false
          @in_table = false
          @in_annex = false
          @in_normative = false
          @section_depth = 0
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

        def with_normative(value = true)
          old = @in_normative
          @in_normative = value
          yield
        ensure
          @in_normative = old
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
