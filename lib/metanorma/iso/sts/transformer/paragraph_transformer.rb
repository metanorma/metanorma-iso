# frozen_string_literal: true
module Metanorma
  module Iso
    module Sts
      module Transformer
        class ParagraphTransformer < Base
          PRESENTATION_CLASSES = %w[
            FmtTitleElement FmtXrefLabelElement FmtNameElement FmtFnLabelElement
            FmtAnnotationStartElement FmtAnnotationEndElement FmtConceptElement
            FmtStemElement
            LocalizedString LocalizedStrings FmtVal AsciiMath
            BrElement TabElement Bookmark
          ].freeze

          # Collects the paragraph's inline content as [kind, value]
          # entries, consecutive text runs already merged. Shared by the
          # paragraph path and the TBX/def appenders
          # (InlineTransformer#apply_inline_content).
          #
          # inline_std: true lets a citation of a normative reference
          # come out as a [:std, model] entry (text-flow containers that
          # carry <std>); other callers keep the <xref> form.
          def entries_for(source_para, inline_std: false)
            @seen_nodes = {}
            @stem_mirrors = build_stem_mirror_map(source_para)
            entries = []
            current_text = nil
            flush_text = lambda do
              return if current_text.nil?
              entries << [:text, clean_text(current_text)]
              current_text = nil
            end

            walk_inline(source_para) do |kind, node, text|
              case kind
              when :text
                current_text = (current_text || "") + text
              when :bold
                flush_text.call
                entries << [:bold, text]
              when :italic
                flush_text.call
                entries << [:italic, text]
              when :sub
                flush_text.call
                entries << [:sub, text]
              when :sup
                flush_text.call
                entries << [:sup, text]
              when :tt
                flush_text.call
                entries << [:monospace, text]
              when :stem
                formula = build_inline_formula(node)
                if formula
                  flush_text.call
                  entries << [:inline_formula, formula]
                else
                  text = mirror_text(node)
                  current_text = (current_text || "") + text if text && !text.empty?
                end
              when :xref
                citations = build_citation_entries(node, inline_std: inline_std)
                unless citations.empty?
                  flush_text.call
                  entries.concat(citations)
                end
              when :link
                l = build_link(node)
                if l
                  flush_text.call
                  entries << [:ext_link, l]
                end
              when :ext_link
                # An already-built ExtLink model (the eref+fmt-link mirror
                # pair emits the whole link with the semantic citeas).
                flush_text.call
                entries << [:ext_link, node]
              when :eref
                if text && !text.empty?
                  current_text = (current_text || "") + text
                end
              when :concept
                if text && !text.empty?
                  current_text = (current_text || "") + text
                end
              when :fn
                fn = build_fn(node)
                if fn
                  flush_text.call
                  entries << [:fn, fn]
                end
              end
            end
            flush_text.call
            entries
          end

          def transform(source_para)
            entries = entries_for(source_para, inline_std: true)

            ::Sts::NisoSts::Paragraph.new(id: id_val_of(source_para)) do |p|
              entries.each do |kind, value|
                case kind
                when :text then p.text value
                when :bold then p.bold value
                when :italic then p.italic value
                when :sub then p.sub value
                when :sup then p.sup value
                when :monospace then p.monospace value
                when :inline_formula then p.inline_formula value
                when :xref then p.xref value
                when :std then p.std value
                when :ext_link then p.ext_link value
                when :fn then p.fn value
                end
              end
            end
          end

          private

          def id_val_of(source_para)
            source_para.id
          end

          def walk_inline(obj, &block)
            nodes = obj.each_mixed_content.to_a
            nodes.each_with_index do |node, index|
              following = nodes[index + 1]
              if semantic_with_mirror?(node, following)
                emit_mirror(node, following, &block)
                next
              end

              walk_node(node, &block)
            end
          end

          # A semantic element (<link>, <eref>, ...) immediately followed
          # by its <semx> presentation mirror (semx@source == element@id):
          # the pair is emitted as ONE unit — the mirror carries the
          # renderable form, the semantic original lends its kind
          # (style/type) when the mirror doesn't declare one (NISO STS
          # @ref-type maps from Metanorma's @type/@style).
          def semantic_with_mirror?(node, following)
            return false if node.is_a?(String)
            # <identifier> + <fmt-identifier> mirrors render as ONE
            # monospace run (Guidelines: requirement paths in <tt>).
            if node.is_a?(Metanorma::Document::Components::Inline::IdentifierElement)
              return following.is_a?(Metanorma::Document::Components::Inline::FmtIdentifierElement)
            end
            return false unless following.is_a?(Metanorma::Document::Components::Inline::SemxElement)
            return false if following.source.nil? || following.source.empty?

            !node.id.nil? && !node.id.empty? && node.id == following.source
          end

          def emit_mirror(node, mirror, &block)
            # Eref + fmt-link mirror: the LinkElement reader loses the
            # span texts (delimiter fragments only) — the reference text
            # lives in the semantic eref's citeas, the URL in the mirror
            # link's target. Emit the pair as ONE ext-link.
            if node.is_a?(Metanorma::Document::Components::Inline::ErefElement) &&
                (link = Array(mirror.fmt_link).first) && link.target
              ext = ModelBuilder.ext_link(xlink_href: link.target,
                                          content: [node.citeas])
              @seen_nodes[mirror.object_id] = true
              yield(:ext_link, ext, nil)
              return
            end

            # Identifier + fmt-identifier: emit the mirror's <tt> runs as
            # monospace (matches ISO HTML's tt rendering of /req/ paths).
            if node.is_a?(Metanorma::Document::Components::Inline::IdentifierElement) &&
                mirror.is_a?(Metanorma::Document::Components::Inline::FmtIdentifierElement)
              @seen_nodes[mirror.object_id] = true
              Array(mirror.tt).each { |tt| walk_node(tt, &block) }
              return
            end

            @mirror_style = node_style(node)
            walk_node(mirror, &block)
          ensure
            @mirror_style = nil
          end

          def node_style(node)
            %i[style type].each do |attr|
              next unless node.class.attributes.key?(attr)

              val = node.public_send(attr).to_s
              return val unless val.empty?
            end
            nil
          end

          # Walks a single node yielded by each_mixed_content. Recurses
          # into SemxElement wrappers so fmt-preferred / fmt-concept trees
          # (which wrap content in semx) walk the same way as body
          # paragraphs (which usually have direct inline children).
          # Semx mirrors inline children into named attributes as well as
          # its mixed content — @seen_nodes prevents double-yielding.
          def walk_node(node, &block)
            if node.is_a?(String)
              yield(:text, node, node)
              return
            end
            return if @seen_nodes[node.object_id]

            @seen_nodes[node.object_id] = true

            class_name = node.class.name&.split("::")&.last
            return if PRESENTATION_CLASSES.include?(class_name)
            return if presentation_span?(node)

            case class_name
            when "SemxElement"
              # Mixed content first; named child attributes only as a
              # fallback for fmt trees that store inlines there (the two
              # views mirror each other — walking both duplicates links.
              yield_count = 0
              counting = lambda do |kind, node, text|
                yield_count += 1
                yield(kind, node, text)
              end
              walk_inline(node, &counting)
              walk_semx_named_children(node, &counting) if yield_count.zero?
            when "EmRawElement", "EmElement"
              yield(:italic, node, build_inline_container(node, ::Sts::TbxIsoTml::Italic))
            when "StrongRawElement", "StrongElement"
              yield(:bold, node, build_inline_container(node, ::Sts::TbxIsoTml::Bold))
            when "SubElement"
              yield(:sub, node, build_inline_container(node, ::Sts::NisoSts::Sub))
            when "SupElement"
              yield(:sup, node, build_inline_container(node, ::Sts::NisoSts::Sup))
            when "TtElement", "MonospaceElement"
              yield(:tt, node, build_inline_container(node, ::Sts::NisoSts::Monospace))
            when "StemInlineElement", "StemBlockElement"
              yield(:stem, node, nil)
            when "AsciimathElement"
              nil
            when "SpanElement"
              walk_inline(node, &block)
            when "LinkElement"
              yield(:link, node, text_of(node))
            when "XrefElement"
              yield(:xref, node, nil)
            when "FmtXrefElement", "FmtErefElement"
              yield(:xref, node, RenderedTextExtractor.text_of(node))
            when "ErefElement"
              yield(:eref, node, eref_text(node))
            when "ConceptElement"
              yield(:concept, node, concept_text(node))
            when "FnElement"
              yield(:fn, node, nil)
            else
              # Never silently drop content: unhandled inline classes
              # degrade to their extracted text.
              fallback_text = RenderedTextExtractor.text_of(node)
              yield(:text, node, fallback_text) if fallback_text && !fallback_text.empty?
            end
          end

          # Named child attributes on SemxElement that store inline
          # content (strong_child, em_child, fmt_xref, etc.). Walked
          # when each_mixed_content yields nothing — fmt-* mirrors land
          # here because the typed model promotes them out of mixed
          # content into dedicated typed collections.
          SEMX_NAMED_CHILDREN = %i[
            stem_child strong em sup sub tt underline strike
            preferred_child name_child title_child
            verbal_definition_child definition_child
            concept_child fn_child link_child
            fmt_xref fmt_eref fmt_concept fmt_link fmt_stem fmt_preferred
            fmt_definition fmt_termsource fmt_name fmt_fn_body
          ].freeze

          def walk_semx_named_children(semx, &block)
            SEMX_NAMED_CHILDREN.each do |attr|
              next unless semx.class.attributes.key?(attr)
              val = semx.public_send(attr)
              next if val.nil?
              Array(val).each { |v| walk_node(v, &block) }
            end
          end

          # Build a typed Sts inline container (Bold/Italic/Sub/Sup/
          # Monospace) whose content is the recursively-walked children
          # of `node`. Used for inline elements that wrap further inline
          # content — most importantly <strong>max capacity (<stem>
          # E_max </stem>)</strong>, where the stem must survive as an
          # inline-formula INSIDE the bold (not as a sibling text drop).
          def build_inline_container(node, klass)
            children = build_inline_children(node)
            klass.new do |container|
              children.each { |child| attach_inline_child(container, child) }
            end
          end

          # Routes a child to the matching typed-collection attribute on
          # the container. NisoSts stores text on a different attribute
          # per class (Paragraph#text, TbxIsoTml::Bold/Italic#value,
          # everything else has #content). Sub/Sup only declare content,
          # so non-string children degrade to their #to_s form.
          def attach_inline_child(container, child)
            case container
            when ::Sts::NisoSts::Paragraph
              attach_to_paragraph(container, child)
            when ::Sts::TbxIsoTml::Bold, ::Sts::TbxIsoTml::Italic
              attach_to_rich_inline(container, child)
            else
              container.content child.to_s
            end
          end

          def attach_to_rich_inline(container, child)
            case child
            when String                          then container.value child
            when ::Sts::NisoSts::InlineFormula    then container.value inline_formula_text(child)
            when ::Sts::TbxIsoTml::Bold             then container.bold child
            when ::Sts::TbxIsoTml::Italic           then container.italic child
            when ::Sts::NisoSts::Sub              then container.sub child
            when ::Sts::NisoSts::Sup              then container.sup child
            when ::Sts::NisoSts::Monospace        then container.monospace child
            when ::Sts::TbxIsoTml::Xref          then container.xref child
            when ::Sts::NisoSts::ExtLink          then container.ext_link child
            else
              container.value child.to_s
            end
          end

          # sts 0.6.0's TbxIsoTml::Bold/Italic don't declare an
          # inline_formula collection, so a formula nested inside a
          # <strong>/<em>wider container</strong> can't keep its MathML.
          # Fall back to the formula's visible text — matches what a
          # text-only reader sees in the source (e.g. "E_max" inside
          # "<strong>max capacity (<stem>E_max</stem>)</strong>").
          # Leading/trailing whitespace is preserved so "(<stem>v</stem>)"
          # renders as "( v )" matching MN's text extraction.
          def inline_formula_text(formula)
            math = formula.math
            return "" unless math

            text = math.to_xml.to_s
                         .gsub(/<[^>]+>/, " ")
                         .gsub(/\s+/, " ")
            text = " #{text.strip} " unless text.strip.empty?
            text
          end

          def attach_to_paragraph(container, child)
            case child
            when String                          then container.text child
            when ::Sts::NisoSts::InlineFormula    then container.inline_formula child
            when ::Sts::TbxIsoTml::Bold             then container.bold child
            when ::Sts::TbxIsoTml::Italic           then container.italic child
            when ::Sts::NisoSts::Sub              then container.sub child
            when ::Sts::NisoSts::Sup              then container.sup child
            when ::Sts::NisoSts::Monospace        then container.monospace child
            when ::Sts::TbxIsoTml::Xref          then container.xref child
            when ::Sts::NisoSts::ExtLink          then container.ext_link child
            when ::Sts::NisoSts::Fn              then container.fn child
            else
              container.text child.to_s
            end
          end

          def plain_text_children(node)
            text = [node.content, *Array(node.sub).flat_map { |s| plain_text_children(s) }].join
            text.empty? ? [] : [clean_text(text)]
          end

          # Recursively walks node's children, returning an array of
          # strings and Sts inline model instances (InlineFormula, Xref,
          # ExtLink, Bold, Italic, Sub, Sup) in document order. Stems
          # become InlineFormula via MathML passthrough; nested strong/
          # em become nested Bold/Italic.
          def build_inline_children(node)
            # SubElement is not a mixed-content model: its text sits on
            # +content+ (nested <sub> on +sub+), which walk_inline never
            # yields — it would emit an empty <sub/>.
            return plain_text_children(node) if node.is_a?(Metanorma::Document::Components::Inline::SubElement)

            entries = []
            current_text = nil
            # SubElement keeps its text in a plain +content+ string, not in
            # mixed content, so the walk below never yields it.
            if node.is_a?(Metanorma::Document::Components::Inline::SubElement)
              current_text = node.content
            end

            walk_inline(node) do |kind, child, payload|
              case kind
              when :text
                current_text = (current_text || "") + payload
              when :bold, :italic, :sub, :sup, :tt
                if current_text
                  entries << clean_text(current_text)
                  current_text = nil
                end
                entries << payload
              when :stem
                formula = build_inline_formula(child)
                next unless formula

                if current_text
                  entries << clean_text(current_text)
                  current_text = nil
                end
                entries << formula
              when :xref
                x = build_xref(child)
                next unless x

                if current_text
                  entries << clean_text(current_text)
                  current_text = nil
                end
                entries << x
              when :link
                l = build_link(child)
                next unless l

                if current_text
                  entries << clean_text(current_text)
                  current_text = nil
                end
                entries << l
              when :eref, :concept
                current_text = (current_text || "") + payload if payload && !payload.empty?
              end
            end
            entries << clean_text(current_text) if current_text
            entries
          end
          # MathML passthrough: parse the stem's <math> into Mml::V3::Math
          # and wrap it in an InlineFormula. Prefers the formatted mirror
          # (fmt-stem) when one exists for this stem's id — the formatted
          # version carries rendered MathML (European decimal commas,
          # applied symbol rules) matching MN's HTML output.
          def build_inline_formula(stem_node)
            mirror = lookup_stem_mirror(stem_node)
            source_for_math = mirror || stem_node
            ::Metanorma::Iso::Sts::MathmlBuilder.inline_formula_from_stem(source_for_math)
          end

          # Footnote bodies become a sibling <fn> element inside the
          # paragraph. Each fn paragraph is run through paragraph_
          # transformer; the result is flattened to text because
          # Sts::TbxIsoTml::Fn#p is typed as NisoSts::Paragraph (uses
          # :text, not :content) and the math roundtrip drops msub.
          def build_fn(fn_element)
            paragraphs = Array(fn_element.p).map.with_index do |p, i|
              build_fn_paragraph_text(p, fn_element, first: i.zero?)
            end
            return nil if paragraphs.empty?

            attrs = { id: fn_element.id, paragraph: paragraphs }
            label = fn_element.reference if fn_element.is_a?(Metanorma::Document::Components::Inline::FnElement)
            attrs[:label] = ::Sts::NisoSts::Label.new(content: [label]) if label && !label.to_s.empty?
            ::Sts::NisoSts::Fn.new(attrs)
          end

          def build_fn_paragraph_text(mn_p, fn_element, first:)
            text = RenderedTextExtractor.text_of(mn_p)
            label = fn_element.reference if fn_element.is_a?(Metanorma::Document::Components::Inline::FnElement)
            text = "#{label})#{text}" if first && label && !label.to_s.empty? && !text.empty?
            ::Sts::NisoSts::Paragraph.new(text: [text])
          end

          # Builds a map of stem_id → FmtStemElement mirror by scanning
          # the paragraph's descendant fmt-stem elements. Each fmt-stem's
          # inner semx carries a `source` matching the original stem's id.
          def build_stem_mirror_map(paragraph)
            map = {}


            walk_all(paragraph) do |node|
              next unless node.is_a?(Metanorma::Document::Components::Inline::FmtStemElement)
              Array(node.semx).each do |semx|
                source = semx.source
                map[source] = node if source && !source.empty?
              end
            end
            map
          end

          def lookup_stem_mirror(stem_node)

            return nil unless stem_node.id

            @stem_mirrors ? @stem_mirrors[stem_node.id] : nil
          end

          # When a fmt-stem mirror carries plain text (no MathML — e.g.
          # numbers with thousands separator: "3 000", "1 000"), MN
          # renders them as text rather than math. Expose the mirror's
          # text so the caller can emit it as a plain string instead
          # of dropping the content.
          def mirror_text(stem_node)
            mirror = lookup_stem_mirror(stem_node)
            return nil unless mirror

            Array(mirror.semx).map do |semx|
              next nil unless semx.is_a?(Metanorma::Document::Components::Inline::SemxElement)
              semx.text
            end.compact.join
          rescue StandardError
            nil
          end

          # Depth-first walk of every node under `root` (no dedup — we
          # need to find every fmt-stem even when one is nested inside
          # another's semx).
          def walk_all(root, &block)
            queue = [root]
            until queue.empty?
              node = queue.shift
              next if node.nil?
              if node.is_a?(String)
                block.call(node)
                next
              end
              block.call(node)
              node.class.attributes.each do |attr_name, _|
                next unless node.class.attributes.key?(attr_name)
                val = node.public_send(attr_name) rescue next
                next if val.nil?
                Array(val).each { |v| queue << v if v.is_a?(Lutaml::Model::Serializable) }
              end
            end
          end

          # <xref> for a bibliography or other target; for a normative
          # reference whose URN identity is known, an inline <std> (NISO STS
          # idiom: guidelines 10.1.7 and 10.2) followed by the citation's
          # locality as paragraph text. No bibr xref may target a norm-refs
          # entry (guidelines 10.1.6).
          def build_citation_entries(node, inline_std:)
            x = build_xref(node)
            return [] unless x

            identity = inline_std && id_generator.normative_ref_for(x.rid)
            return [[:xref, x]] unless identity

            std, locality = build_inline_std(x, identity)
            entries = [[:std, std]]
            entries << [:text, clean_text(locality)] if locality
            entries
          end

          # The inline <std> for a cited normative reference, and the
          # locality after its designation (", Clause 5"), or nil. <std-ref>
          # carries the designation as the reference names it; <std-id>
          # carries the reference's own URN, the link that guidelines 10.1.7
          # matches against the norm-refs <std-id>. The locality stays
          # outside <std>: the sts model serializes a <std>'s mixed text
          # before its child elements, which would reorder "Designation,
          # Clause 5" to ", Clause 5Designation".
          def build_inline_std(xref, identity)
            designation = identity[:identifier]
            visible = xref.value.to_s
            plain_visible = visible.tr("\u00a0", " ")
            plain_designation = designation.tr("\u00a0", " ")

            if plain_visible.start_with?(plain_designation)
              std_ref = designation
              locality = plain_visible[plain_designation.length..]
            else
              std_ref = visible.empty? || visible == xref.rid ? designation : visible
              locality = nil
            end
            locality = nil if locality.to_s.empty?

            type = identity[:type]
            std = ReferenceTransformer::ReferenceStandardWithId.new(
              type: type,
              std_ref: [::Sts::NisoSts::StandardRef.new(type: type, value: std_ref)],
              std_id_element: [::Sts::NisoSts::StdId.new(
                std_id_link_type: "urn", std_id_type: type,
                content: identity[:urn]
              )],
            )
            [std, locality]
          end

          def build_xref(node)
            rid = nil
            [:target, :refid, :to].each do |attr|
              next unless node.class.attributes.key?(attr)
              val = node.public_send(attr)
              rid = val if val.is_a?(String) && !val.empty?
              break if rid
            end
            return nil unless rid

            # rid is xs:IDREF: remap through the id registry so targets
            # renamed by the id derivation (annex apps, terms sections,
            # terms, figures) stay resolvable. Unregistered ids pass
            # through unchanged.
            rid = id_generator.remap(rid)

            visible = xref_visible_text(node, rid)
            ModelBuilder.xref(rid: rid, ref_type: ref_type_for(node, rid), value: visible)
          end

          def xref_visible_text(node, rid)
            explicit = text_of(node)
            return explicit unless explicit.empty?
            raw = node.target.to_s
            case raw
            when /\Asec-(.+)\z/, /\Afig-(.+)\z/, /\Atable-(.+)\z/, /\Afn-(.+)\z/
              "#{Regexp.last_match(1)} "
            else
              explicit.empty? ? rid : explicit
            end
          end

          # @ref-type per the guidelines 10.1.1 enumeration, derived from
          # the target: the engine's own id scheme prefixes (sec_/tab_/fig_/
          # formula_) and the requirement-model anchors preserved inside
          # requirement tables (r-/rc-/cc-/ct-/action- prefixes, clause
          # anchors) map by inspecting the remapped rid.
          def ref_type_for(node, rid)
            kind = id_generator.kind_for(rid)
            mapped = case kind
                     # "norm-ref" reaches here only when no inline <std>
                     # is possible (no URN identity, or a TBX container).
                     when "ref", "norm-ref" then "bibr"
                     when "annex" then "app"
                     when "table" then "table"
                     when "figure" then "fig"
                     when "formula" then "disp-formula"
                     when "clause", "terms" then "sec"
                     end
            return mapped if mapped

            case rid
            when /\Asec_[A-Z]+\z/ then "app"
            when /\Asec_/ then "sec"
            when /\Atab_/ then "table"
            when /\Afig_/ then "fig"
            when /\Aformula_/ then "disp-formula"
            when /\Afn_/ then "fn"
            else requirement_anchor_ref_type(node, rid)
            end
          end

          def requirement_anchor_ref_type(node, rid)
            # FmtXrefElement#type is the DISPLAY form ("inline"), not the
            # reference kind — mirrors always take the semantic original's
            # style via @mirror_style.
            style =
              if node.is_a?(Metanorma::Document::Components::Inline::FmtXrefElement)
                ""
              else
                node.style.to_s
              end
            # The presentation mirror carries no kind of its own: the
            # semantic original (the emit_mirror pair) lends its style.
            style = @mirror_style.to_s if style.empty? && @mirror_style
            case style
            when "clause", "section" then "sec"
            when "table" then "table"
            when "figure", "fig" then "fig"
            when "fn", "footnote" then "fn"
            else "table"
            end
          end

          def build_link(node)
            href = nil
            [:target, :href].each do |attr|
              next unless node.class.attributes.key?(attr)
              val = node.public_send(attr)
              href = val if val.is_a?(String) && !val.empty?
              break if href
            end
            visible = link_text(node)
            if href.nil? || href.empty?
              # The presentation mirror carries no target: the visible URL
              # is the link (Guidelines 10.1.9 requires @xlink:href).
              href = visible.to_s.empty? ? nil : visible
            end
            return nil unless href

            visible = href.start_with?("mailto:") ? href.sub("mailto:", "") : visible
            ModelBuilder.ext_link(xlink_href: href, content: [visible])
          end

          def link_text(node)
            c = node.content
            c = Array(c) unless c.is_a?(Array)
            joined = c.map(&:to_s).join.strip
            joined.empty? ? text_of(node) : joined
          end

          def eref_text(node)
            citeas = node.citeas
            return citeas.to_s if citeas && !citeas.to_s.empty?
            text_of(node)
          end

          def concept_text(node)
            renderterm = Array(node.renderterm).first.to_s
            xref_node = Array(node.xref).first
            return renderterm unless xref_node

            rid = xref_node.target
            autonum = source.term_autonum_for(rid) if rid
            return "#{renderterm} (#{autonum})" if autonum && !autonum.empty?
            "#{renderterm} (#{rid})"
          end

          def presentation_span?(node)
            return false unless node.is_a?(Metanorma::Document::Components::Inline::SpanElement)
            cls = node.class_attr
            cls.is_a?(String) && %w[fmt-autonum-delim fmt-caption-delim citesec citefig citetbl stdpublisher stddocNumber stdyear].any? { |c| cls.include?(c) }
          end

          def text_of(obj)
            return obj.to_s if obj.is_a?(String)
            return "" unless obj
            RenderedTextExtractor.text_of(obj)
          end

          def clean_text(text)
            text.to_s.gsub(/link:mailto:([^\s\[]+)/, '\1').gsub(/link:([^\s\[]+)/, '\1')
          end
        end
      end
    end
  end
end
