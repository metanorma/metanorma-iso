# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      # Per-render memoization of document facts that several rules would
      # otherwise re-derive independently.
      #
      # One instance lives on {Context} for one validation run and dies with
      # it: every key is a node of that run's deserialized model, so the
      # caches cannot outlive the model they refer to. Memoization changes
      # where a fact is computed, never what the fact is: every accessor
      # wraps an unmodified {Rules::TreeTraversal} walk or extraction.
      #
      # Keys are compared BY IDENTITY ({Hash#compare_by_identity}). lutaml
      # models define value-based #eql?/#hash (ComparableModel), which
      # deep-walks the whole subtree — model nodes as ordinary Hash keys
      # would re-hash entire documents on every lookup. Identity keys are
      # O(1) and hold their nodes alive for the life of the cache, so node
      # identity is stable while the cache exists.
      #
      # Memoized facts (only what rules genuinely recompute per run):
      # - {#paragraphs_with_parent}: the (paragraph, immediate container)
      #   pairs that every text-linting rule re-walks;
      # - {#text_of}: extracted node text, per (node, strip) — style rules
      #   re-extract every paragraph's text once per rule;
      # - {#xrefs}: every inline xref, re-enumerated by the xref rules;
      # - {#terms}: every term, re-enumerated by the term rules.
      #
      # Memoized strings are shared between consumers and MUST stay
      # read-only: {#text_of} hands out a fresh duplicate per call, so a
      # consumer cannot contaminate the cache or another rule. Cached
      # collections are frozen for the same reason.
      class WalkCache
        include Rules::TreeTraversal

        def initialize
          @paragraph_pairs = {}.compare_by_identity
          @texts = Hash.new { |hash, node| hash[node] = {} }.compare_by_identity
          @xrefs = {}.compare_by_identity
          @terms = {}.compare_by_identity
        end

        # Every (paragraph, immediate container) pair in the document, in
        # TreeTraversal walk order — identical to the per-rule
        # #each_paragraph_with_parent traversal, computed once per run.
        #
        # @return [Array(Array(Node, Node))] frozen pair list
        def paragraphs_with_parent(root)
          @paragraph_pairs[root] ||= each_paragraph_with_parent(root).to_a.freeze
        end

        # Extracted text content of +node+, memoized per (node, strip) pair.
        # +strip+ carries model attribute names whose subtree is excluded,
        # exactly as {Rules::TreeTraversal#extract_text} interprets it: the
        # result depends on the strip set, so it is part of the key.
        #
        # @return [String] a fresh, unfrozen duplicate per call
        def text_of(node, strip: [])
          (@texts[node][strip] ||= extract_text(node, strip: strip)).dup
        end

        # Every inline xref element in the document, in TreeTraversal walk
        # order.
        #
        # @return [Array] frozen xref list
        def xrefs(root)
          @xrefs[root] ||= each_xref(root).to_a.freeze
        end

        # Every term in the document (including nested subterms), in
        # TreeTraversal walk order.
        #
        # @return [Array] frozen term list
        def terms(root)
          @terms[root] ||= each_term(root).to_a.freeze
        end
      end
    end
  end
end
