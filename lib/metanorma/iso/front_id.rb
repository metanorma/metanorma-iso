require "date"
require "twitter_cldr"
require "pubid"

module Metanorma
  module Iso
    class Converter < Standoc::Converter
      def metadata_id_primary_type(node)
        "ISO"
      end

      def metadata_id_nonprimary(node, xml)
        node.attr("tc-docnumber")&.split(/,\s*/)&.each do |n|
          add_noko_elem(xml, "docidentifier", n, type: "iso-tc")
        end
      end

      DOCTYPE2HASHID =
        { directive: :dir, "technical-report": :tr, "guide": :guide,
          "technical-specification": :ts,
          "publicly-available-specification": :pas,
          "committee-document": :tc, "recommendation": :r }.freeze

      # @param type [nil, :tr, :ts, :amd, :cor, :guide, :dir, :tc, Type]
      # document's type, eg. :tr, :ts, :amd, :cor, Type.new(:tr)
      def get_typeabbr(node, amd: false)
        node.attr("amendment-number") and return :amd
        node.attr("addendum-number") and return :add
        node.attr("supplement-number") and return :sup
        node.attr("extract-number") and return :ext
        node.attr("corrigendum-number") and return :cor
        DOCTYPE2HASHID[doctype(node).to_sym]
      end

      def metadata_id_primary(node, xml)
        (!@amd && node.attr("docnumber") || node.attr("adopted-from")) ||
          (@amd && node.attr("updates")) or return
        params = iso_id_params(node)
        iso_id_out(xml, params)
      end

      def iso_id_params(node)
        params = iso_id_params_core(node)
        params2 = iso_id_params_add(node)
        num = node.attr("docnumber")
        orig = node.attr("updates") || node.attr("adopted-from")
        /[[:alpha:]]/.match?(num) and orig ||= num
        orig and orig_id = orig_id_parse(orig)
        iso_id_params_resolve(params, params2, node, orig_id)
      end

      def cen?(str)
        /^C?EN/.match?(str)
      end

      def orig_id_parse(orig)
        cen?(orig) and return Pubid::CenCenelec::Identifier.parse(orig)
        ret = case orig
              when /^IEC/ then Pubid::Iec::Identifier.parse(orig)
              else Pubid::Iso::Identifier.parse(orig)
              end
        ret.edition ||= Pubid::Components::Edition.new(number: 1)
        ret
      end

      def base_pubid
        Pubid::Iso::Identifier
      end

      def pubid_select(params)
        if cen?(Array(params[:publisher])&.first || "")
          Pubid::CenCenelec::Identifier
        else base_pubid
        end
      end

      def compact_blank(hash)
        hash.compact.reject { |_, v| v.is_a?(String) && v.empty? }
      end

      # unpublished is for internal use
      def iso_id_params_core(node)
        pub = iso_id_pub(node)
        ret = { number: node.attr("docnumber"),
                part: node.attr("partnumber"),
                language: node.attr("language") || "en",
                type: get_typeabbr(node),
                publisher: pub[0],
                unpublished: /^[0-5]/.match?(get_stage(node)),
                copublisher: pub[1..] }
        ret[:copublisher].empty? and ret.delete(:copublisher)
        compact_blank(ret)
      end

      def iso_id_pub(node)
        (node.attr("publisher_abbr") || node.attr("publisher") ||
         default_publisher).split(/[;,]/)
          .map(&:strip).map { |x| org_abbrev[x] || x }
      end

      def iso_id_params_add(node)
        stage = iso_id_stage(node)
        ret = { number: node.attr("amendment-number") ||
          node.attr("corrigendum-number") ||
          node.attr("addendum-number") ||
          node.attr("supplement-number") ||
          node.attr("extract-number"),
                year: iso_id_year(node),
                iteration: node.attr("iteration") }
        iso_id_stage_populate(ret, node, stage)
        tc_number(ret, node)
        compact_blank(ret)
      end

      def tc_number(ret, node)
        doctype(node) == "committee-document" or return ret
        { sc: "subcommittee", tc: "technical-committee",
          wg: "workgroup" }.each do |k, v|
          n = node.attr("#{v}-number") and
            ret.merge!({ "#{k}type": node.attr("#{v}-type") || k.to_s.upcase,
                         "#{k}number": n })
        end
        ret
      end

      def iso_id_stage_populate(ret, node, stage)
        if stage && !cen?(node.attr("publisher"))
          ret[:stage] = stage
          ret[:stage] == "60.00" and ret[:stage] = :PRF
          # ret[:stage] == "60.60" and ret[:stage] = nil
        end
        ret
      end

      def iso_id_stage(node)
        "#{get_stage(node)}.#{get_substage(node)}"
      end

      def iso_id_year(node)
        (node.attr("copyright-year") || node.attr("updated-date") ||
         node.attr("published-date"))
          &.sub(/-.*$/, "") || Date.today.year
      end

      def iso_id_params_resolve(params, params2, node, orig_id)
        if orig_id && (node.attr("amendment-number") ||
            node.attr("corrigendum-number") ||
                      node.attr("addendum-number") ||
                      node.attr("supplement-number") ||
                      node.attr("extract-number"))
          %i(unpublished part).each { |x| params.delete(x) }
          params2[:base] = orig_id
        elsif orig_id &&
            ![Pubid::Iso::Identifier,
              Pubid::Iec::Identifier].include?(pubid_select(params))
          params2[:adopted] = orig_id
        end
        params.merge!(params2)
        params
      end

      def iso_id_out(xml, params)
        cen?(params[:publisher]) and return cen_id_out(xml, params)
        iso_id_out_common(xml, params)
        @amd and return
        iso_id_out_non_amd(xml, params)
      rescue StandardError, *STAGE_ERROR => e
        @log.add("ISO_52", "Document identifier: #{e}")
        # a taste layered on this flavour (:docstage-valid:) manages its
        # own stage repertoire and docidentifier template: do not abort
        # when pubid cannot parse a taste-supplied stage
        @docstage_valid and return
        clean_abort("Document identifier: #{e}", xml)
      end

      def cen_id_out(xml, params)
        add_noko_elem(xml, "docidentifier",
                      iso_id_default(params).to_s,
                      **attr_code(type: "CEN", primary: "true"))
      end

      def iso_id_out_common(xml, params)
        params1 = skip_60_60(params)
        add_noko_elem(xml, "docidentifier",
                      iso_id_default(params1).to_s,
                      **attr_code(type: "ISO", primary: "true"))
        add_noko_elem(xml, "docidentifier", iso_id_reference(params1).to_s,
                      **attr_code(type: "iso-reference"))
        add_noko_elem(xml, "docidentifier", iso_id_reference(params).to_urn,
                      **attr_code(type: "URN"))
      end

      def iso_id_out_non_amd(xml, params)
        params1 = skip_60_60(params)
        add_noko_elem(xml, "docidentifier",
                      iso_id_undated(params1).to_s,
                      **attr_code(type: "iso-undated"))
        add_noko_elem(xml, "docidentifier",
                      iso_id_with_lang(params1).to_s,
                      **attr_code(type: "iso-with-lang"))
      end

      # work around breakages in pubid-iso
      def skip_60_60(params)
        ret = params.dup
        ret[:stage] == "60.60" and ret[:stage] = nil
        ret
      end

      def iso_id_default(params)
        params_nolang = params.dup.tap { |hs| hs.delete(:language) }
        params1 = params_nolang
        params1.delete(:unpublished)
        pubid_create(params1)
      end

      def iso_id_undated(params)
        params_nolang = params.dup.tap { |hs| hs.delete(:language) }
        params2 = params_nolang.dup.tap do |hs|
          hs.delete(:year)
          hs.delete(:unpublished)
        end
        pubid_create(params2)
      end

      def iso_id_with_lang(params)
        params1 = params
        params1.delete(:unpublished)
        pubid_create(params1, lang_form: :long)
      end

      def iso_id_reference(params)
        params1 = params.dup.tap { |hs| hs.delete(:unpublished) }
        pubid_create(params1, lang_form: :short)
      end

      def id_add_year(docnum, node)
        year = node.attr("copyright-year")
        @amd and year ||= node.attr("updated-date")&.sub(/-.*$/, "")
        docnum += ":#{year}" if year
        docnum
      end

      def get_stage(node)
        a = node.attr("status")
        a = node.attr("docstage") if a.nil? || a.empty?
        a = "60" if a.nil? || a.empty?
        a
      end

      def get_substage(node)
        stage = get_stage(node)
        ret = node.attr("docsubstage")
        ret = (stage == "60" ? "60" : "00") if ret.nil? || ret.empty?
        ret
      end

      # ── pubid 2.x construction layer ────────────────────────────────
      #
      # pubid 2 replaced pubid-iso 1.x's `Identifier.create(**params)`
      # with flavor-based identifier classes built from typed components
      # (Pubid::Iso::Identifiers::*, Pubid::CenCenelec::Identifiers::*).
      # The helpers below translate the legacy params hash (produced by
      # iso_id_params_core/iso_id_params_add) into those constructions.

      # Legacy doctype abbreviation -> pubid 2 type code.
      ISO_TYPE_CODES = {
        dir: "dir", tr: "tr", guide: "guide", ts: "ts", pas: "pas",
        tc: "tc", r: "rec", amd: "amd", cor: "cor", add: "add",
        sup: "suppl", ext: "ext",
      }.freeze

      # Build a pubid Identifier from the legacy params hash.
      #
      # @param params [Hash] legacy identifier params (see iso_id_params_core)
      # @param lang_form [:none, :short, :long] language-code rendering:
      #   :none hides the language suffix entirely (ISO house style),
      #   :short renders a single-char code ("(E)"), :long the ISO
      #   language code ("(en)").
      def pubid_create(params, lang_form: :none)
        if cen?(Array(params[:publisher])&.first || params[:publisher] || "")
          cen_pubid_create(params, lang_form)
        else
          iso_pubid_create(params, lang_form)
        end
      end

      def iso_pubid_create(params, lang_form)
        type_code = ISO_TYPE_CODES[params[:type]] || "is"
        klass = Pubid::Iso.locate_type(type_code)
        klass.new(**iso_pubid_attributes(params, lang_form, type_code))
      end

      def iso_pubid_attributes(params, lang_form, type_code)
        attrs = {}
        attrs[:number] = pubid_code(params[:number]) if params[:number]
        attrs[:part] = pubid_code(params[:part]) if params[:part]
        attrs[:date] = pubid_date(params[:year]) if params[:year]
        attrs[:publisher] = iso_pubid_publisher(params)
        cops = Array(params[:copublisher])
        attrs[:copublishers] = cops.map do |cp|
          Pubid::Iso::Components::Publisher.new(publisher: cp)
        end
        langs = pubid_languages(params[:language], lang_form)
        attrs[:languages] = langs if langs.any?
        stage = pubid_typed_stage(params[:stage], type_code)
        attrs[:typed_stage] = stage if stage
        attrs[:base] = params[:base] if params[:base]
        if params[:iteration]
          attrs[:stage_iteration] =
            Pubid::Components::Iteration.new(number: params[:iteration].to_s)
        end
        tc_pubid_attributes(attrs, params) if type_code == "tc"
        attrs
      end

      # Committee-document committee fields (TC/SC/WG type + number).
      def tc_pubid_attributes(attrs, params)
        %w[sc tc wg].each do |k|
          type = params[:"#{k}type"]
          number = params[:"#{k}number"]
          attrs[:"#{k}_type"] = pubid_code(type) if type
          attrs[:"#{k}_number"] = pubid_code(number) if number
        end
      end

      def cen_pubid_create(params, lang_form)
        attrs = {}
        attrs[:number] = pubid_code(params[:number]) if params[:number]
        attrs[:part] = pubid_code(params[:part]) if params[:part]
        attrs[:date] = pubid_date(params[:year]) if params[:year]
        attrs[:publisher] = Pubid::Components::Publisher.new(
          publisher: params[:publisher],
        )
        langs = pubid_languages(params[:language], lang_form)
        attrs[:languages] = langs if langs.any?
        stage = params[:stage]
        if stage && stage != "60.60"
          stage = "60.00" if stage == :PRF
          ts = Pubid::CenCenelec.all_typed_stages.find do |s|
            s.harmonized_stages&.include?(stage.to_s)
          end
          attrs[:typed_stage] = ts if ts
        end
        if params[:adopted]
          attrs[:adopted_identifier] = params[:adopted]
          Pubid::CenCenelec::Identifiers::AdoptedEuropeanNorm.new(**attrs)
        else
          Pubid::CenCenelec::Identifiers::EuropeanNorm.new(**attrs)
        end
      end

      # Resolve a legacy stage token ("50.00" harmonized code, or the :PRF
      # shorthand for 60.00) to a pubid 2 typed stage, within the document
      # type's stage family (FDIS for IS, FDTR for TR, ...). 60.60 (published)
      # resolves to the type's published typed stage (abbr "IS"/"TR"/...).
      # Unresolvable stage codes are illegal and must surface (pubid 1.x
      # raised here; the ISO_9 illegal-stage warning depends on it).
      def pubid_typed_stage(stage, type_code)
        return nil if stage.nil?

        stage = "60.00" if stage == :PRF
        ts = Pubid::Iso.all_typed_stages.find do |s|
          s.harmonized_stages&.include?(stage.to_s) &&
            s.type_code.to_s == type_code
        end
        ts || raise(ArgumentError, "Illegal document stage: #{stage}")
      end

      # The visible abbreviation of a typed stage: pubid 2 stages can carry
      # an empty first variant (e.g. published IS has ["", "IS"]); the
      # non-empty variant is the one ISO renders as the stage abbreviation.
      def pubid_stage_abbr(typed_stage)
        typed_stage.abbr.find { |a| !a.to_s.empty? } || typed_stage.abbr.first
      end

      def iso_pubid_publisher(params)
        cops = Array(params[:copublisher])
        Pubid::Iso::Components::Publisher.new(
          publisher: params[:publisher],
          copublisher: (cops unless cops.empty?),
        )
      end

      def pubid_code(value)
        Pubid::Iso::Components::Code.new(value: value.to_s)
      end

      def pubid_date(year)
        Pubid::Components::Date.new(year: year.to_i)
      end

      # Language components for the requested rendering form. :short
      # renders the single-char code for languages that have one ("(E)",
      # "(F)", "(R)", "(A)", "(S)", "(D)" — pubid's CHAR_MAP), falling back
      # to the ISO code for languages without a single-char form. :long
      # renders the ISO code ("(en)"). URN always uses the lowercase ISO code.
      LANG_SINGLE_CHAR = {
        "en" => "E", "fr" => "F", "ru" => "R",
        "ar" => "A", "es" => "S", "de" => "D",
      }.freeze

      def pubid_languages(language, lang_form)
        return [] if language.nil? || lang_form == :none

        lang = language.to_s
        original = if lang_form == :short
                     LANG_SINGLE_CHAR[lang] || lang
                   else
                     lang
                   end
        [Pubid::Components::Language.new(code: lang, original_code: original)]
      end
    end
  end
end
