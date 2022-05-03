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
        eref_localities1(target,
                         prefix_clause(target, refs.first.at(ns("./locality"))),
                         l10n(ret[1..-1].join), nil, node, @lang)
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
          type == "list" || target&.match(/^IEV$|^IEC 60050-/)
      end

      def eref_localities1_zh(target, type, from, upto, node)
        ret = " 第#{from}" if from
        ret += "&ndash;#{upto}" if upto
        node["droploc"] != "true" && !subclause?(target, type, from) and
          ret += eref_locality_populate(type, node)
        ret += ")" if type == "list"
        ret
      end

      def eref_localities1(target, type, from, upto, node, lang = "en")
        return nil if type == "anchor"

        type = type.downcase
        lang == "zh" and
          return l10n(eref_localities1_zh(target, type, from, upto, node))
        ret = ""
        node["droploc"] != "true" && !subclause?(target, type, from) and
          ret = eref_locality_populate(type, node)
        ret += " #{from}" if from
        ret += "&ndash;#{upto}" if upto
        ret += ")" if type == "list"
        l10n(ret)
      end

      def prefix_container(container, linkend, target)
        delim = @xrefs.anchor(target, :type) == "listitem" ? " " : ", "
        l10n(@xrefs.anchor(container, :xref) + delim + linkend)
      end
    end
  end
end
