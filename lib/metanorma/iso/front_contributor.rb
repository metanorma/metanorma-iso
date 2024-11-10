module Metanorma
  module Iso
    class Converter < Standoc::Converter
      # def home_agency
      # "ISO"
      # end

      def default_publisher
        "ISO"
      end

      def org_abbrev
        { "International Organization for Standardization" => "ISO",
          "International Electrotechnical Commission" => "IEC" }
      end

      def metadata_author(node, xml)
        org_contributor(node, xml,
                        { source: ["publisher", "pub"], role: "author",
                          default: default_publisher })
        committee_contributors(node, xml, false, default_publisher)
      end

      def org_organization(node, xml, org)
        org[:committee] and
          contrib_committee_build(xml, org[:agency], org) or
          super
      end

      def committee_contributors(node, xml, approval, agency)
        metadata_approval_committee_types(approval ? node : nil).each do |v|
          node.attr("#{v}-number") or next
          node.attr(v) or node.set_attr(v, "")
          o = { source: [v], role: approval ? "authorizer" : "author",
                default_org: false, committee: true, agency:,
                desc: v.sub(/^approval-/, "").tr("-", " ").capitalize }
          org_contributor(node, xml, o)
        end
        approval or committee_contributors_approval(node, xml, agency)
      end

      def committee_contributors_approval(node, xml, agency)
        o = { name: agency, role: "authorizer", default_org: false,
              desc: "Agency", committee: false }
        org_contributor(node, xml, o)
      end

      def extract_org_attrs_complex(node, opts, source, suffix)
        n = node.attr("#{source}-number#{suffix}")
        t = committee_abbrev(node.attr("#{source}-type#{suffix}"), n, source)
        super.merge(ident: t).compact
      end

      def contrib_committee_build(xml, agency, committee)
        name = org_abbrev.invert[agency] and agency = name
        xml.name agency
        xml.subdivision do |o|
            o.name committee[:name]
            committee[:abbr] and o.abbreviation committee[:abbr]
            committee[:ident] and o.identifier committee[:ident]
        end
      end

      COMMITTEE_ABBREVS =
        { "technical-committee" => "TC", "subcommittee" => "SC",
          "workgroup" => "WG" }.freeze

      def committee_abbrev(type, number, level)
        type ||= COMMITTEE_ABBREVS[level.sub(/^approval-/, "")]
        type == "Other" and type = ""
        "#{type} #{number}".strip
      end

      def org_attrs_parse(node, opts)
        super&.map do |x|
          x.merge(agency: opts[:agency], abbr: opts[:abbr],
                  committee: opts[:committee], default_org: opts[:default_org])
        end
      end

      def metadata_publisher(node, xml)
        super
        # approvals
        committee_contributors(node, xml, true,
                               node.attr("approval-agency") || default_publisher)
      end

      def metadata_committee(node, xml)
        metadata_editorial_committee(node, xml)
        metadata_approval_committee(node, xml)
      end

      def metadata_editorial_committee(node, xml)
        xml.editorialgroup do |a|
          %w(technical-committee subcommittee workgroup).each do |v|
            node.attr("#{v}-number") and committee_component(v, node, a)
          end
          node.attr("secretariat") and a.secretariat(node.attr("secretariat"))
        end
      end

      def metadata_approval_committee(node, xml)
        types = metadata_approval_committee_types(node)
        xml.approvalgroup do |a|
          metadata_approval_agency(a, node.attr("approval-agency")
            &.split(%r{[/,;]}))
          types.each do |v|
            node.attr("#{v}-number") and committee_component(v, node, a)
          end
        end
      end

      def metadata_approval_committee_types(node)
        types = %w(technical-committee subcommittee workgroup)
        !node.nil? && node.attr("approval-technical-committee-number") and
          types = %w(approval-technical-committee approval-subcommittee
                     approval-workgroup)
        types
      end

      def metadata_approval_agency(xml, list)
        list = [default_publisher] if list.nil? || list.empty?
        list.each do |v|
          xml.agency v
        end
      end
    end
  end
end
