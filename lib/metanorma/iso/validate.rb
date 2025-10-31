require "metanorma-standoc"
require_relative "validate_style"
require_relative "validate_numeric"
require_relative "validate_requirements"
require_relative "validate_section"
require_relative "validate_title"
require_relative "validate_list"
require_relative "validate_xref"
require "nokogiri"
require "jing"
require "iev"

module Metanorma
  module Iso
    class Converter < Standoc::Converter
      COMMITTEE_XPATH = <<~XPATH.freeze
        //contributor[role/description = 'committee']/organization/subdivision
      XPATH

      def isosubgroup_validate(root)
        root.xpath("#{COMMITTEE_XPATH}[@type = 'Technical committee']/@subtype").each do |t|
          %w{TC PC JTC JPC}.include?(t.text) or
            @log.add("ISO_2", nil, params: [t.text])
        end
        root.xpath("#{COMMITTEE_XPATH}[@type = 'Subcommittee']/@subtype").each do |t|
          %w{SC JSC}.include?(t.text) or
            @log.add("ISO_3", nil, params: [t.text])
        end
      end

      def termdef_warn(text, regex, elem, term, msg)
        regex.match(text) && @log.add(msg, elem, params: [term])
      end

      # ISO/IEC DIR 2, 16.5.6
      def termdef_style(xmldoc)
        xmldoc.xpath("//term").each do |t|
          para = t.at("./definition/verbal-definition") || return
          term = t.at("./preferred//name").text
          @lang == "en" and
            termdef_warn(para.text, /\A(the|a)\b/i, t, term, "ISO_4")
          %(Cyrl Latn).include?(@script) and
            termdef_warn(para.text, /\.\Z/i, t, term, "ISO_35")
        end
      end

      def doctype_validate(_xmldoc)
        %w(international-standard technical-specification technical-report
           publicly-available-specification international-workshop-agreement
           guide amendment technical-corrigendum committee-document addendum
           recommendation)
          .include? @doctype or
          @log.add("ISO_5", nil, params: [@doctype])
      end

      def iteration_validate(xmldoc)
        iteration = xmldoc&.at("//bibdata/status/iteration")&.text or return
        /^\d+/.match(iteration) or
          @log.add("ISO_6", nil, params: [iteration])
      end

      def bibdata_validate(doc)
        doctype_validate(doc)
        iteration_validate(doc)
      end

      # DRG directives 3.7; but anticipated by standoc
      def subfigure_validate(xmldoc)
        elems = { footnote: "fn", note: "note", key: "dl" }
        xmldoc.xpath("//figure//figure").each do |f|
          elems.each do |k, v|
            f.xpath(".//#{v}").each do |n|
              @log.add("ISO_7", n, params: [k])
            end
          end
        end
      end

      def figure_validate(xmldoc)
        subfigure_validate(xmldoc)
      end

      def content_validate(doc)
        super
        root = doc.root
        title_validate(root)
        isosubgroup_validate(root)
        termdef_style(root)
        iso_xref_validate(root)
        bibdata_validate(root)
        bibitem_validate(root)
        figure_validate(root)
        list_validate(doc)
      end

      def list_validate(doc)
        listcount_validate(doc)
        list_punctuation(doc)
      end

      def bibitem_validate(xmldoc)
        xmldoc.xpath("//bibitem[date/on = '–']").each do |b|
          b.at("./note[@type = 'Unpublished-Status']") or
            @log.add("ISO_8", b)
        end
      end

      def schema_file
        case @doctype
        when "amendment", "technical-corrigendum" # @amd
          "isostandard-amd.rng"
        else "isostandard-compile.rng"
        end
      end
    end
  end
end
