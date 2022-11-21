module IsoDoc
  module Iso
    class PresentationXMLConvert < IsoDoc::PresentationXMLConvert
      def xref_init(lang, script, klass, labels, options)
        @xrefs = Xref.new(lang, script, klass, labels, options)
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
        eref_localities1({ target: target, number: "pl",
                           type: prefix_clause(target, refs.first.at(ns("./locality"))),
                           from: l10n(ret[1..-1].join),
                           node: node, lang: @lang })
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
        (from&.match?(/\./) && type == "clause") ||
          type == "list" ||
          target&.gsub(/<[^>]+>/, "")&.match(/^IEV$|^IEC 60050-/)
      end

      # ISO has not bothered to communicate to us what most of these span classes mean
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
        m = /^(\s*)(.+?)(\s*)$/.match(ret) or return ret
        ret = [m[1], m[2], m[3]]
        spanclass = LOCALITY2SPAN[type.to_sym] and
          ret[1] = "<span class='#{spanclass}'>#{ret[1]}</span>"
        ret.join
      end

      def eref_localities1_zh(opt)
        ret = " 第#{opt[:from]}" if opt[:from]
        ret += "&#x2013;#{opt[:upto]}" if opt[:upto]
        opt[:node]["droploc"] != "true" &&
          !subclause?(opt[:target], opt[:type], opt[:from]) and
          ret += eref_locality_populate(opt[:type], opt[:node], "sg")
        ret += ")" if opt[:type] == "list"
        locality_span_wrap(ret, opt[:type])
      end

      def eref_localities1(opt)
        return nil if opt[:type] == "anchor"

        opt[:type] = opt[:type].downcase
        opt[:lang] == "zh" and return l10n(eref_localities1_zh(opt))
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

      def prefix_container(container, linkend, node, target)
        delim = ", "
        ref = if @xrefs.anchor(target, :type) == "listitem" &&
            !@xrefs.anchor(target, :refer_list)
                delim = " "
                @xrefs.anchor(container, :label)
                # 7 a) : Clause 7 a), but Clause 7 List 1 a)
              else
                anchor_xref(node, container)
              end

        l10n(ref + delim + linkend)
      end

      def expand_citeas(text)
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
    end
  end
end
