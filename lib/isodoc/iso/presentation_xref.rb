module IsoDoc
  module Iso
    class PresentationXMLConvert < IsoDoc::PresentationXMLConvert
      def xref_init(lang, script, _klass, labels, options)
        html = HtmlConvert.new(language: @lang, script: @script)
        @xrefs = Xref.new(lang, script, html, labels, options)
      end

      def eref_delim(delim, type)
        if delim == ";" then ";"
        else type == "list" ? " " : delim
        end
      end

      def can_conflate_eref_rendering?(refs)
        super or return false
        first = subclause?(nil, refs.first.at(ns("./locality/@type"))&.text,
                           refs.first.at(ns("./locality/referenceFrom"))&.text)
        refs.all? do |r|
          subclause?(nil, r.at(ns("./locality/@type"))&.text,
                     r.at(ns("./locality/referenceFrom"))&.text) == first
        end
      end

      def locality_delimiter(loc)
        loc&.next_element&.attribute("type")&.text == "list" and return " "
        super
      end

      def eref_localities_conflated(refs, target, node)
        droploc = node["droploc"]
        node["droploc"] = true
        ret = resolve_eref_connectives(eref_locality_stacks(refs, target,
                                                            node))
        node["droploc"] = droploc
        eref_localities1({ target:, number: "pl",
                           type: prefix_clause(target,
                                               refs.first.at(ns("./locality"))),
                           from: l10n(ret[1..].join),
                           node:, lang: @lang })
      end

      def prefix_clause(target, loc)
        loc["type"] == "clause" or return loc["type"]

        if subclause?(target, loc["type"],
                      loc&.at(ns("./referenceFrom"))&.text)
          ""
        else "clause"
        end
      end

      def subclause?(target, type, from)
        (from&.include?(".") && type == "clause") ||
          type == "list" ||
          target&.gsub(/<[^<>]+>/, "")&.match(/^IEV$|^IEC 60050-/)
      end

      # ISO has not bothered to communicate to us what most of these
      # span classes mean
      LOCALITY2SPAN = {
        annex: "citeapp",
        dunno: "citebase",
        dunno2: "citebib",
        dunno3: "citebox",
        dunno4: "citeen",
        dunno5: "citeeq",
        figure: "citefig",
        dunno6: "citefn",
        clause: "citesec",
        dunno7: "citesection",
        table: "citetbl",
        dunno8: "citetfn",
      }.freeze

      def locality_span_wrap(ret, type)
        type or return ret
        m = /\A(\s*)(?=\S)(.+?)(\s*)\Z/m.match(ret) or return ret
        ret = [m[1], m[2], m[3]]
        spanclass = LOCALITY2SPAN[type.to_sym] and
          ret[1] = "<span class='#{spanclass}'>#{ret[1]}</span>"
        ret.join
      end

      def eref_localities1_zh(opt)
        ret = " 第<esc>#{opt[:from]}</esc>" if opt[:from]
        ret += "&#x2013;<esc>#{opt[:upto]}</esc>" if opt[:upto]
        opt[:node]["droploc"] != "true" &&
          !subclause?(opt[:target], opt[:type], opt[:from]) and
          ret += eref_locality_populate(opt[:type], opt[:node], "sg")
        ret += ")" if opt[:type] == "list"
        locality_span_wrap(ret, opt[:type])
      end

      def eref_localities1(opt)
        opt[:type] == "anchor" and return nil
        opt[:type] = opt[:type].downcase
        %w(zh ko ja).include?(opt[:lang]) and
          return l10n(eref_localities1_zh(opt))
        ret = ""
        opt[:node]["droploc"] != "true" &&
          !subclause?(opt[:target], opt[:type], opt[:from]) and
          ret = eref_locality_populate(opt[:type], opt[:node], opt[:number])
        ret += " #{opt[:from]}" if opt[:from]
        ret += "&#x2013;#{opt[:upto]}" if opt[:upto]
        ret += ")" if opt[:type] == "list"
        ret = l10n(ret)
        locality_span_wrap(ret, opt[:type])
      end

      # 7 a) : Clause 7 a), but Clause 7 List 1 a)
      def prefix_container(container, linkend, node, target)
        prefix_container?(container, node) or return linkend
        container_container = @xrefs.anchor(container, :container, false)
        nested_xref, container_label =
          prefix_container_template(container, node, target)
        container_label = prefix_container(container_container,
                                           container_label, node, target)
        l10n(connectives_spans(nested_xref
          .sub("%1", "<span class='fmt-xref-container'><esc>#{container_label}</esc></span>")
          .sub("%2", "<esc>#{linkend}</esc>")))
      end

      def prefix_container_template(container, node, target)
        nested_xref = @i18n.nested_xref
        container_label = anchor_xref(node, container)
        if @xrefs.anchor(target, :type) == "listitem" &&
            !@xrefs.anchor(target, :refer_list)
          nested_xref = "%1 %2"
          # n = @xrefs.anchor(container, :label) and container_label = n
        end
        [nested_xref, container_label]
      end

      def expand_citeas(text)
        ret = super or return
        ret.include?("<span") and return ret
        std_docid_semantic(super)
      end

      def anchor_value(id)
        locality_span_wrap(super, @xrefs.anchor(id, :subtype) ||
                           @xrefs.anchor(id, :type))
      end

      def anchor_linkend1(node)
        locality_span_wrap(super, @xrefs.anchor(node["target"], :subtype) ||
                           @xrefs.anchor(node["target"], :type))
      end

      def origin(docxml)
        super
        bracketed_refs_processing(docxml)
      end

      # style [1] references as [Reference 1], eref or origin
      def bracketed_refs_processing(docxml)
        (docxml.xpath(ns("//semx[@element = 'eref']")) -
        docxml.xpath(ns("//semx[@element = 'erefstack']//semx[@element = 'eref']")))
          .each { |n| bracket_eref_style(n) }
        docxml.xpath(ns("//semx[@element = 'erefstack']")).each do |n|
          bracket_erefstack_style(n)
        end
        docxml.xpath(ns("//semx[@element = 'origin']")).each do |n|
          bracket_origin_style(n)
        end
      end

      def bracket_eref_style(elem)
        semx = bracket_eref_original(elem) or return
        if semx["style"] == "superscript"
          elem.children.wrap("<sup></sup>")
          remove_preceding_space(elem)
        else
          r = @i18n.reference
          elem.add_first_child l10n("#{r} ")
        end
      end

      # is the eref corresponding to this semx a simple [n] reference?
      def bracket_eref_original(elem)
        semx = elem.document.at("//*[@id = '#{elem['source']}']") or return
        non_locality_elems(semx).empty? or return
        /^\[\d+\]$/.match?(semx["citeas"]) or return
        semx
      end

      def bracket_erefstack_style(elem)
        semx, erefstack_orig = bracket_erefstack_style_prep(elem)
        semx.empty? and return
        if erefstack_orig && erefstack_orig["style"]
          elem.children.each do |e|
            e.name == "span" and e.remove
            e.text.strip.empty? and e.remove
          end
          elem.children.wrap("<sup></sup>")
          remove_preceding_space(elem)
        else
          r = @i18n.inflect(@i18n.reference, number: "pl")
          elem.add_first_child l10n("#{r} ")
        end
      end

      def bracket_erefstack_style_prep(elem)
        semx = elem.xpath(ns(".//semx[@element = 'eref']"))
          .map { |e| bracket_eref_original(e) }.compact
        erefstack_orig = elem.document.at("//*[@id = '#{elem['source']}']")
        [semx, erefstack_orig]
      end

      def bracket_origin_style(elem)
        bracket_eref_style(elem)
      end

      def remove_preceding_space(elem)
        # Find the preceding text node that has actual content
        prec = elem.at("./preceding-sibling::text()" \
          "[normalize-space(.) != ''][1]") or return
        prec.content.end_with?(" ") and prec.content = prec.content.rstrip
      end
    end
  end
end
