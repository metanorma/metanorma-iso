module Metanorma
  module ISO
    class Converter < Standoc::Converter
      def org_abbrev
        { "International Organization for Standardization" => "ISO",
          "International Electrotechnical Commission" => "IEC" }
      end

      def metadata_author(node, xml)
        publishers = node.attr("publisher") || "ISO"
        metadata_contrib_sdo(node, xml, publishers,
                             { role: "author",
                               default_org: !node.attr("publisher") })
        committee_contributors(node, xml, false)
      end

      def metadata_contrib_sdo(node, xml, publishers, opt)
        csv_split(publishers).each do |p|
          xml.contributor do |c|
            c.role type: opt[:role] do |r|
              opt[:desc] and r << opt[:desc]
            end
            c.organization do |a|
              (opt[:committee] and
                contrib_committee_build(a, opt[:agency],
                                        { name: p, id: opt[:ident] })) or
                organization(a, p, opt[:role] == "publisher", node,
                             opt[:default_org])
            end
          end
        end
      end

      def committee_contributors(node, xml, approval, agency = "ISO")
        types = metadata_approval_committee_types(approval ? node : nil)
        types.each do |v|
          n = node.attr("#{v}-number") or next
          t = committee_abbrev(node.attr("#{v}-type"), n, v)
          metadata_contrib_sdo(
            node, xml, node.attr(v),
            { role: approval ? "authorizer" : "author", ident: t,
              default_org: false, committee: true, agency: agency,
              desc: v.sub(/^approval-/, "").gsub("-", " ").capitalize }
          )
        end
        approval and
          metadata_contrib_sdo(node, xml,
                               node.attr("approval-agency") || agency,
                               { role: "authorizer", default_org: false,
                                 desc: "Agency", committee: false })
      end

      def contrib_committee_build(xml, agency, committee)
        n = org_abbrev.invert[agency] and agency = n
        xml.name agency
        xml.subdivision committee[:name]
        committee[:abbr] and xml.abbreviation committee[:abbr]
        committee[:id] and xml.identifier committee[:id]
      end

      COMMITTEE_ABBREVS =
        { "technical-committee" => "TC", "subcommittee" => "SC",
          "workgroup" => "WG" }.freeze

      def committee_abbrev(type, number, level)
        type ||= COMMITTEE_ABBREVS[level.sub(/^approval-/, "")]
        type == "Other" and type = ""
        "#{type} #{number}".strip
      end

      def metadata_publisher(node, xml)
        publishers = node.attr("publisher") || "ISO"
        metadata_contrib_sdo(node, xml, publishers,
                             { role: "publisher",
                               default_org: !node.attr("publisher") })
        committee_contributors(node, xml, true)
      end

      def metadata_copyright(node, xml)
        publishers = node.attr("copyright-holder") || node.attr("publisher") ||
          "ISO"
        csv_split(publishers).each do |p|
          xml.copyright do |c|
            c.from (node.attr("copyright-year") || Date.today.year)
            c.owner do |owner|
              owner.organization do |o|
                organization(
                  o, p, true, node,
                  !(node.attr("copyright-holder") || node.attr("publisher"))
                )
              end
            end
          end
        end
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
        list = ["ISO"] if list.nil? || list.empty?
        list.each do |v|
          xml.agency v
        end
      end
    end
  end
end
