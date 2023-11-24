module Metanorma
  module ISO
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

      # def metadata_author(node, xml)
      # publishers = node.attr("publisher") || home_agency
      # metadata_contrib_sdo(node, xml, publishers,
      # { role: "author",
      # default_org: !node.attr("publisher") })
      # committee_contributors(node, xml, false, home_agency)
      # end
      #

      def metadata_author(node, xml)
        org_contributor(node, xml,
                        { source: ["publisher", "pub"], role: "author",
                          default: default_publisher })
        committee_contributors(node, xml, false, default_publisher)
      end

      # def metadata_contrib_sdo(node, xml, publishers, opt)
      # publishers.nil? and return
      # csv_split(publishers).each do |p|
      # xml.contributor do |c|
      # c.role type: opt[:role] do |r|
      # opt[:desc] and r << opt[:desc]
      # end
      # c.organization do |a|
      # (opt[:committee] and
      # contrib_committee_build(a, opt[:agency],
      # { name: p, id: opt[:ident] })) or
      # organization(a, p, opt[:role] == "publisher", node,
      # opt[:default_org])
      # end
      # end
      # end
      # end

      def org_organization(node, xml, org)
        #require "debug"; binding.b
        org[:committee] and
          contrib_committee_build(xml, org[:agency], org) or
                                  #{ name: org[:name], id: org[:ident] }) or
          super
      end

      # def committee_contributors(node, xml, approval, agency)
      # types = metadata_approval_committee_types(approval ? node : nil)
      # types.each do |v|
      # n = node.attr("#{v}-number") or next
      # t = committee_abbrev(node.attr("#{v}-type"), n, v)
      # metadata_contrib_sdo(
      # node, xml, node.attr(v),
      # { role: approval ? "authorizer" : "author", ident: t,
      # default_org: false, committee: true, agency: agency,
      # desc: v.sub(/^approval-/, "").gsub("-", " ").capitalize }
      # )
      # end
      # approval and
      # metadata_contrib_sdo(node, xml, agency,
      # { role: "authorizer", default_org: false,
      # desc: "Agency", committee: false })
      # end

      def committee_contributors(node, xml, approval, agency)
        types = metadata_approval_committee_types(approval ? node : nil)
        types.each do |v|
          node.attr("#{v}-number") or next
          node.attr(v) or node.set_attr(v, "")
          # t = committee_abbrev(node.attr("#{v}-type"), n, v)
          # metadata_contrib_sdo(
          # node, xml, node.attr(v),
          o = { source: [v], role: approval ? "authorizer" : "author",
                default_org: false, committee: true, agency: agency,
                desc: v.sub(/^approval-/, "").gsub("-", " ").capitalize }
          #require "debug"; binding.b
          org_contributor(node, xml, o)
        end
        if approval
          o = { name: agency, role: "authorizer", default_org: false,
                desc: "Agency", committee: false }
          org_contributor(node, xml, o)
        end
      end

      def extract_org_attrs_complex(node, opts, source, suffix)
        #require "debug"; binding.b
        n = node.attr("#{source}-number#{suffix}")
        t = committee_abbrev(node.attr("#{source}-type#{suffix}"), n, source)
        super.merge(ident: t).compact
      end

      def contrib_committee_build(xml, agency, committee)
        #require "debug"; binding.b
        n = org_abbrev.invert[agency] and agency = n
        xml.name agency
        xml.subdivision committee[:name]
        committee[:abbr] and xml.abbreviation committee[:abbr]
        committee[:ident] and xml.identifier committee[:ident]
      end

      COMMITTEE_ABBREVS =
        { "technical-committee" => "TC", "subcommittee" => "SC",
          "workgroup" => "WG" }.freeze

      def committee_abbrev(type, number, level)
        type ||= COMMITTEE_ABBREVS[level.sub(/^approval-/, "")]
        type == "Other" and type = ""
        "#{type} #{number}".strip
      end

      # def metadata_publisher(node, xml)
      # publishers = node.attr("publisher") || home_agency
      # metadata_contrib_sdo(node, xml, publishers,
      # { role: "publisher",
      # default_org: !node.attr("publisher") })
      ## approvals
      # committee_contributors(node, xml, true,
      # node.attr("approval-agency") || home_agency)
      # end

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

      # def metadata_copyright(node, xml)
      #  publishers = node.attr("copyright-holder") || node.attr("publisher") ||
      #    home_agency
      #  csv_split(publishers).each do |p|
      #    xml.copyright do |c|
      #      c.from (node.attr("copyright-year") || Date.today.year)
      #      c.owner do |owner|
      #        owner.organization do |o|
      #          organization(
      #            o, p, true, node,
      #            !(node.attr("copyright-holder") || node.attr("publisher"))
      #          )
      #        end
      #      end
      #    end
      #  end
      # end

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
