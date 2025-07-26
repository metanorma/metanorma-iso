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
        committee_contributors(node, xml, false, default_publisher)
      end

      def org_organization(node, xml, org)
        if org[:committee]
          contrib_committee_build(xml, org[:agency], org)
        else super
        end
      end

      def committee_contributors(node, xml, approval, agency)
        t = metadata_approval_committee_types(approval ? node : nil)
        v = t.first
        if node.attr("#{v}-number")
          node.attr(v) or node.set_attr(v, "")
          o = committee_contrib_org_prep(node, v, approval, agency)
          o[:groups] = t
          o[:approval] = approval
          org_contributor(node, xml, o)
        end
        approval or committee_contributors_approval(node, xml, agency)
      end

      # KILL
      def contributors_committees_nestx(committees)
        committees = committees.reverse
        committees.each_with_index do |m, i|
          i.zero? and next
          m[:subdiv] = committees[i - 1]
        end
        committees[-1]
      end

      def committee_contrib_org_prep(node, type, approval, agency)
        agency_arr, agency_abbrev =
          committee_org_prep_agency(node, type, agency, [], [])
        { source: [type], role: approval ? "authorizer" : "author",
          default_org: false, committee: true, agency: agency_arr,
          agency_abbrev:,
          desc: type.sub(/^approval-/, "").tr("-", " ").capitalize }.compact
      end

      def committee_org_prep_agency(node, type, agency, agency_arr, agency_abbr)
        i = 1
        suffix = ""
        while node.attr("#{type}-number#{suffix}") ||
            node.attr("#{type}#{suffix}")
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

      def extract_org_attrs_complex(node, opts, source, suffix)
        n = node.attr("#{source}-number#{suffix}")
        t = committee_abbrev(node.attr("#{source}-type#{suffix}"), n, source)
        super.merge(ident: t).compact
      end

      def contrib_committee_build(xml, agency, committee)
        if name = org_abbrev.invert[agency]
          committee[:agency_abbrev] = agency
          agency = name
        end
        xml.name agency
        s = committee
        loop do
          contrib_committee_subdiv(xml, s)
          s = s[:subdiv] or break
        end
        abbr = committee[:agency_abbrev] and xml.abbreviation abbr
        full_committee_id(xml.parent)
      end

      def contrib_committee_subdiv(xml, committee)
        xml.subdivision **attr_code(type: committee[:desc]) do |o|
          o.name committee[:name]
          # s = committee[:subdiv] and contrib_committee_subdiv(o, s)
          committee[:abbr] and o.abbreviation committee[:abbr]
          committee[:ident] and o.identifier committee[:ident]
        end
      end

      def full_committee_id(contrib)
        ids = []
        ret = full_committee_agency_id(contrib)
        ids = contrib.xpath("./subdivision").map { |x| x.at("./identifier")&.text }
        ins = contrib.at("./subdivision/identifier") and
          ins.next = "<identifier type='full'>#{ret}#{ids.join('/')}</identifier>"
      end

      def full_committee_agency_id(contrib)
        agency = contrib.at("./abbreviation")&.text
        ret = agency == default_publisher ? "" : "#{agency} "
        /^\s+/.match?(ret) and ret = ""
        ret
      end

      COMMITTEE_ABBREVS =
        { "technical-committee" => "TC", "subcommittee" => "SC",
          "workgroup" => "WG" }.freeze

      def committee_abbrev(type, number, level)
        number.nil? || number.empty? and return
        type ||= COMMITTEE_ABBREVS[level.sub(/^approval-/, "")]
        type == "Other" and type = ""
        "#{type} #{number}".strip
      end

      def org_attrs_parse(node, opts)
        opts_orig = opts.dup
        ret = []
        ret << super&.map&.with_index do |x, i|
          x.merge(agency: opts.dig(:agency, i),
                  agency_abbrev: opts.dig(:agency_abbrev, i), abbr: opts[:abbr],
                  committee: opts[:committee], default_org: opts[:default_org])
        end
        opts_orig[:groups]&.each_with_index do |g, i|
          i.zero? and next
          contributors_committees_pad_multiples(ret, node, g)
          opts = committee_contrib_org_prep(node, g, opts_orig[:approval], nil)
          ret << super
        end
        ret = contributors_committees_filter_empty(ret)
        ret.first
        contributors_committees_nest1(ret)
      end

      # ensure there is subcommittee, workingroup _2, _3 etc
      # to parse mutlple tech committees
      def contributors_committees_pad_multiples(committees, node, group)
        committees.each_with_index do |_r, j|
          suffix = j.zero? ? "" : "_#{j + 1}"
          node.attr("#{group}#{suffix}") or
            node.set_attr("#{group}#{suffix}", "")
        end
      end

      def contributors_committees_filter_empty(committees)
        committees.map do |c|
          c.reject do |c1|
            c1[:name].empty? &&
              (c1[:ident].nil? || %w(WG TC SC).include?(c1[:ident]))
          end
        end.reject(&:empty?)
      end

      def contributors_committees_nest1(committees)
        committees.empty? and return committees
        committees = committees.reverse
        committees.each_with_index do |m, i|
          i.zero? and next
          m.each_with_index do |m1, j|
            m1[:subdiv] = committees[i - 1][j]
          end
        end
        committees[-1]
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
            a.parent.xpath("./#{v.gsub('-', '_')}[not(node())][not(@number)]")
              .each(&:remove)
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
            a.parent.xpath("./#{v.gsub('-', '_')}[not(node())][not(@number)]")
              .each(&:remove)
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
