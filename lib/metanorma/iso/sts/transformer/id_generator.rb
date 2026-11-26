# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      module Transformer
        # Derives document-unique STS ids for the elements that cannot keep
        # their source ids:
        #
        # - annexes serialize as <app> with letter ids (sec_A, sec_B, …);
        # - terms sections fall back to sec_terms (uniquified sec_terms_1, …)
        #   when the section carries no number;
        # - terms split one source id into a sec_-prefixed <term-sec> id and
        #   a term_-prefixed <tbx:termEntry> id (xs:ID forbids sharing);
        # - figures are numbered fig_1, fig_2, … in document order.
        #
        # Everything else (clauses, paragraphs, tables, formulas, dl) keeps
        # its source id — xref rid values pass through `remap`, which falls
        # back to the source id for unregistered targets, so IDREF values
        # stay resolvable.
        #
        # `pre_register` walks the document up front so an xref pointing at
        # a LATER element resolves: at transform time the target's claimed
        # id already sits in the registry. The walk mirrors
        # BlockDispatcher::TYPED_ATTR_DISPATCH (shared constant), so new
        # dispatched block attributes are walked automatically.
        class IdGenerator < Metanorma::Document::Sts::Transformer::IdGenerator
          def initialize
            @registry = {}
            @kinds = {}
            @normative_refs = {}
            @entry_ids = {}
            @issued_ids = {}
            @annex_count = 0
            @figure_count = 0
            @counter = 0
          end

          def register(source_id, sts_id, kind = nil)
            @registry[source_id] = sts_id
            @kinds[source_id] = kind if kind
          end

          # Emission kind registered for the source id ("ref", "norm-ref",
          # "annex", "table", "figure", "formula", "clause"); nil when unknown.
          def kind_for(source_id)
            @kinds[source_id]
          end

          # Identity of a normative reference (<ref> in norm-refs), keyed by
          # its source id: { identifier:, urn:, type: }. An in-text citation
          # to it is emitted as an inline <std>, not a bibr <xref>.
          def register_normative_ref(source_id, identity)
            return unless source_id && identity

            @normative_refs[source_id] = identity
          end

          def normative_ref_for(source_id)
            @normative_refs[source_id]
          end

          # Records the kind of a block that keeps its source id
          # (formula, table), so an xref to it gets the right @ref-type.
          def mark_kind(source_id, kind)
            @kinds[source_id] ||= kind if source_id && !source_id.empty?
          end

          def remap(source_id)
            @registry[source_id] || source_id
          end

          # Document-unique variant of +base+: on collision appends _1, _2,
          # … (xs:ID values must be unique across the whole document).
          def claim(base)
            return nil unless base

            seen = @issued_ids[base] || 0
            @issued_ids[base] = seen + 1
            seen.zero? ? base : "#{base}_#{seen}"
          end

          # ---- Pre-registration pass ------------------------------------------

          def pre_register(source)
            @source = source
            walk = IdWalk.new(source, self)
            walk.run
            self
          end

          # ---- Section ids ----------------------------------------------------

          # Annexes: sec_<number> from the section autonum ("A"), letters
          # in document order when unnumbered. The letter also feeds the
          # Annex label, so label and id stay consistent.
          def id_for_annex(annex, autonum)
            return registered_or_claim(annex, "annex") { claim("sec_#{autonum}") } if autonum

            letter = alpha_suffix(@annex_count, "A")
            @annex_count += 1
            registered_or_claim(annex, "annex") { claim("sec_#{letter}") }
          end

          # Terms sections: sec_<number> when numbered, else the fallback
          # sec_terms uniquified per terms section.
          def id_for_terms(terms, autonum)
            base = autonum ? "sec_#{autonum}" : "sec_terms"
            registered_or_claim(terms, "clause") { claim(base) }
          end

          # Clauses keep their source id (identity-claimed so generated
          # ids cannot collide with it).
          def id_for_clause(clause)
            source_id = read_id(clause)
            return nil unless source_id

            registered_or_claim_by_source(source_id, "clause") { claim(source_id) }
          end

          # One nested <term-sec> per term with the sec_ prefix, and the
          # termEntry with the term_ prefix, off the same suffix: the term
          # autonum ("3.1.2") when known, else the source id stripped of
          # its uuid decoration. xs:ID forbids sharing one value between
          # the section and the entry. Idempotent: the pre-registration
          # pass claims first, the transform reads the same claim.
          def term_ids(term)
            registered = term.id ? @registry[term.id] : nil
            return [registered, @entry_ids[term.id]] if registered

            suffix = term_id_suffix(term)
            return [nil, nil] if suffix.empty?

            sec_id = claim("sec_#{suffix}")
            entry_id = claim("term_#{suffix}")
            register(term.id, sec_id, "clause") if term.id
            @entry_ids[term.id] = entry_id if term.id
            [sec_id, entry_id]
          end

          # Figures are numbered fig_1, fig_2, … in document order — the
          # mnconvert numbering. Pre-registration assigns first so xrefs
          # pointing forward resolve; on-demand assignment covers figures
          # outside the walked containers.
          def figure_id(figure)
            key = figure_key(figure)
            @registry[key] ||= claim("fig_#{(@figure_count += 1)}")
          end

          # A sub-figure group with no image of its own is not emitted
          # (FigureTransformer#sub_figure_models): its first sub-figure
          # carries the group's fig id, so cross-references to the group
          # (iso-gdg-10.1.2-1) and to that sub-figure both resolve.
          def alias_figure(sub, group)
            @registry[figure_key(sub)] = figure_id(group)
          end

          def id_for(obj, prefix: "sec")
            return nil unless obj
            source_id = read_id(obj)
            if source_id && !source_id.empty?
              return @registry[source_id] if @registry.key?(source_id)
              register(source_id, claim(source_id))
              return @registry[source_id]
            end

            @counter += 1
            "#{prefix}_#{@counter}"
          end

          def id_map
            @registry
          end

          private

          def read_id(obj)
            return nil unless obj.is_a?(Lutaml::Model::Serializable)

            obj.id
          end

          # A pre-registered id wins; otherwise compute + register now.
          # Keyed by source id so the transform and the pre-pass agree.
          def registered_or_claim(element, kind = nil, &block)
            source_id = read_id(element)
            if source_id && @registry.key?(source_id)
              @registry[source_id]
            else
              id = block.call
              register(source_id, id, kind) if source_id
              id
            end
          end

          def registered_or_claim_by_source(source_id, kind = nil, &block)
            return @registry[source_id] if @registry.key?(source_id)

            id = block.call
            register(source_id, id, kind)
            id
          end

          def figure_key(figure)
            read_id(figure) || "object:#{figure.object_id}"
          end

          # The semantic <term> id is a uuid, usually "_8b70fb0a-…"; strip
          # the leading underscore and any legacy term_ prefix so both
          # derived ids stay valid NCNames. The presentation autonum
          # ("3.1.2") wins when the source carries one.
          def term_id_suffix(term)
            autonum = @source&.term_autonum_for(term.id) if term.id
            return autonum.to_s unless autonum.nil? || autonum.to_s.empty?

            term.id.to_s.sub(/\A_?term_?/, "").delete_prefix("_")
          end

          # Letter index in base-26: 0 → +first_letter+, 25 → "Z", 26 → "AA".
          def alpha_suffix(n, first_letter)
            suffix = ""
            loop do
              suffix = ((n % 26) + first_letter.ord).chr + suffix
              n = n / 26 - 1
              break if n.negative?
            end
            suffix
          end

          # Document-order walk that claims the ids of every renamed
          # element (annex, terms section, term, figure) before the
          # transform runs. Attribute order mirrors
          # BlockDispatcher::TYPED_ATTR_DISPATCH, so the walk visits the
          # same blocks in the same order the dispatch will.
          class IdWalk
            def initialize(source, generator)
              @source = source
              @generator = generator
              @seen = {}
            end

            def run
              @source.annexes.each { |annex| visit_section(annex) }
              @source.sections.each { |sec| visit_section(sec) }
            end

            private

            def visit_section(section)
              return if seen?(section)

              case section.class.name&.split("::")&.last
              when "IsoAnnexSection", "AnnexSection"
                @generator.id_for_annex(section, autonum_of(section))
              when "IsoTermsSection", "TermsSection"
                @generator.id_for_terms(section, autonum_of(section))
              else
                @generator.id_for_clause(section) if read_id(section)
              end

              walk_blocks(section)
              walk_children(section)
            end

            def walk_children(section)
              Array(try(section, :clause)).each { |c| visit_section(c) }
              Array(try(section, :terms)).each { |t| visit_section(t) }
              Array(try(section, :term)).each { |t| @generator.term_ids(t) }
            end

            WALK_ATTRS = BlockDispatcher::TYPED_ATTR_DISPATCH.keys.freeze

            def walk_blocks(section)
              WALK_ATTRS.each do |attr|
                next unless section.class.attributes.key?(attr)

                Array(try(section, attr)).each do |item|
                  walk_item(item)
                end
              end
            end

            def walk_item(item)
              case item.class.name&.split("::")&.last
              when "FigureBlock"
                walk_figure(item)
              when "FormulaBlock"
                @generator.mark_kind(read_id(item), "formula")
              end
              walk_siblings(item)
            end

            # Sub-figures are claimed in document order too, so an xref
            # that precedes its figure still resolves.
            def walk_figure(figure)
              @generator.figure_id(figure)
              subs = Array(try(figure, :figure))
              return if subs.empty?

              unless FigureTransformer.own_graphic?(figure)
                @generator.alias_figure(subs.first, figure)
              end
              subs.each { |sub| walk_figure(sub) }
            end

            def walk_siblings(item)
              %i[note example].each do |attr|
                next unless item.class.attributes.key?(attr)

                Array(try(item, attr))
              end
            end

            def autonum_of(section)
              RenderedTextExtractor.autonum_of(section)
            end

            def try(obj, attr)
              obj.public_send(attr) if obj.class.attributes.key?(attr)
            rescue StandardError
              nil
            end

            def read_id(obj)
              return nil unless obj.is_a?(Lutaml::Model::Serializable)
              obj.id
            end

            def seen?(obj)
              key = read_id(obj) || obj.object_id
              return true if @seen[key]

              @seen[key] = true
              false
            end
          end
        end
      end
    end
  end
end
