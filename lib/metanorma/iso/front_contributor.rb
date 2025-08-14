module Metanorma
  module Iso
    class Converter < Standoc::Converter
      def default_publisher
        "ISO"
      end

      def org_abbrev
        { "International Organization for Standardization" => "ISO",
          "International Electrotechnical Commission" => "IEC",
          "International Organization for Standardization, International Electrotechnical Commission" => "ISO/IEC" }
      end

      def metadata_author(node, xml)
        org_contributor(node, xml,
                        { source: ["publisher", "pub"], role: "author",
                          default: default_publisher })
        committee_contributors(node, xml, default_publisher,
                               { approval: false })
        secretariat_contributor(node, xml, default_publisher)
      end

      def org_organization(node, xml, org)
        if org[:committee]
          contrib_committee_build(xml, org[:agency], org)
        else super
        end
      end

      def secretariat_contributor(node, xml, agency)
        node.attr("secretariat") or return
        o = committee_contrib_org_prep(node, "secretariat", agency, {})
        o[:desc] = "secretariat"
        org_contributor(node, xml, o)
      end

      def committee_contributors(node, xml, agency, opt)
        t = metadata_approval_committee_types(opt[:approval] ? node : nil)
        v = t.first
        if committee_number_or_name?(node, v, "")
          node.attr(v) or node.set_attr(v, "")
          o = committee_contrib_org_prep(node, v, agency, opt)
          o[:groups] = t
          o[:approval] = opt[:approval]
          org_contributor(node, xml, o)
        end
        opt[:approval] or committee_contributors_approval(node, xml, agency)
      end

      def committee_contrib_org_prep(node, type, agency, opt)
        agency_arr, agency_abbrev =
          committee_org_prep_agency(node, type, agency, [], [])
        { source: [type], role: opt[:approval] ? "authorizer" : "author",
          default_org: false, committee: true, agency: agency_arr,
          agency_abbrev:, desc: "committee",
          subdivtype: type.sub(/^approval-/, "").tr("-", " ").capitalize }
          .compact
      end

      def committee_org_prep_agency(node, type, agency, agency_arr, agency_abbr)
        i = 1
        suffix = ""
        while committee_number_or_name?(node, type, suffix)
          agency_arr << (node.attr("#{type}-agency#{suffix}") || agency)
          agency_abbr << node.attr("#{type}-agency-abbr#{suffix}")
          i += 1
          suffix = "_#{i}"
        end
        [agency_arr, agency_abbr]
      end

      def committee_contributors_approval(node, xml, agency)
        o = { name: agency, role: "authorizer", default_org: false,
              desc: "Agency", committee: false }
        org_contributor(node, xml, o)
      end

      def committee_abbrevs
        { "technical-committee" => "TC", "subcommittee" => "SC",
          "workgroup" => "WG" }
      end

      def committee_ident(type, number, level)
        number.nil? || number.empty? and return
        type ||= committee_abbrevs[level.sub(/^approval-/, "")]
        type == "Other" and type = ""
        "#{type} #{number}".strip
      end

      def contributors_committees_filter_empty?(committee)
        committee[:name].empty? &&
          (committee[:ident].nil? || %w(WG TC
                                        SC).include?(committee[:ident]))
      end

      def metadata_publisher(node, xml)
        super
        # approvals
        committee_contributors(
          node, xml,
          node.attr("approval-agency") || default_publisher, { approval: true }
        )
      end

      def metadata_approval_committee_types(node)
        types = %w(technical-committee subcommittee workgroup)
        !node.nil? && node.attr("approval-technical-committee-number") and
          types = %w(approval-technical-committee approval-subcommittee
                     approval-workgroup)
        types
      end
    end
  end
end
