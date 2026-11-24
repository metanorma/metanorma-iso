# frozen_string_literal: true

require "moxml"
require "set"

module Metanorma
  module Iso
    module Sts
      # Validates ISO NISO STS XML against the IEC/ISO Coding Guidelines
      # ed 2.1 (ANSI/NISO Z39.102-2022, STS 1.2).
      #
      # Pure-Ruby implementation of the error-severity rules in
      # `schematron/iso-sts.sch` (vendored from metanorma/sts-specs); each
      # rule id matches the schematron's <assert>/<report> id and the
      # authority catalog's rule id (iso-gdg-<section>-<n>) exactly, so
      # findings are traceable to the guidelines section that mandates
      # them. Warning-level rules live in the catalog only and are not
      # encoded here.
      class Validator
        # Prefixes used in the rule selectors, bound to the namespace URIs the
        # schematron declares, so documents are matched by URI whatever
        # prefixes they choose.
        NS = {
          "tbx" => "urn:iso:std:iso:30042:ed-1",
          "mml" => "http://www.w3.org/1998/Math/MathML",
          "xlink" => "http://www.w3.org/1999/xlink",
        }.freeze

        SCHEMATRON_PATH = File.expand_path("../schematron/iso-sts.sch", __dir__).freeze

        # @return [Array<String>] every implemented rule id.
        def self.rule_ids
          new.send(:rules).map(&:id)
        end

        # @param xml [String, Pathname, #read] ISO STS XML.
        # @return [ValidationReport]
        def validate(xml)
          doc = parse(xml)
          report = ValidationReport.new
          rules.each do |rule|
            doc.xpath(absolute_context(rule.context), NS).each do |node|
              # A check returns nil/true (pass), a message, or a list of
              # messages (one per offending child, e.g. absence_check).
              Array(rule.check.call(node, doc)).each do |msg|
                next unless msg.is_a?(String) && !msg.empty?

                report.add(rule_id: rule.id,
                           message: "#{msg} (#{rule.guideline}).",
                           xpath: node.path,
                           severity: rule.severity)
              end
            end
          end
          report
        end

        private

        # Rule contexts are written document-relative ("sec", "app",
        # "tbx:termEntry"); evaluate them document-wide. Absolute
        # contexts ("/", "//x") pass through; union alternatives are
        # each absolutized.
        def absolute_context(context)
          return context if context.start_with?("/")

          context.split("|").map do |part|
            part = part.strip
            part.start_with?("/") ? part : "//#{part}"
          end.join(" | ")
        end

        def parse(xml)
          case xml
          when Pathname then Moxml.parse(xml.read)
          when ->(x) { x.respond_to?(:read) } then Moxml.parse(x.read)
          else Moxml.parse(xml.to_s)
          end
        end

        # -- check helpers -------------------------------------------------
        # Moxml has no at_xpath; first-match helper over #xpath.
        def at(node, selector)
          node.xpath(selector, NS).first
        end

        def xlink_href(node)
          at(node, "@xlink:href")&.value.to_s
        end

        def nbsp_strip(text)
          case text
          when Moxml::Node then text.text.to_s.tr(" ", " ").strip
          else text.to_s.tr(" ", " ").strip
          end
        end

        # required: true mirrors `@a = (...)` (absent fails); otherwise
        # `not(@a) or @a = (...)`. An empty value fails either way.
        def enum_check(attr, allowed, label:, required: false)
          lambda do |node, *_|
            v = node[attr]
            return nil if v.nil? && !required
            return nil if allowed.include?(v)

            "#{label} @#{attr}='#{v}' is not one of: #{allowed.join(', ')}"
          end
        end

        def presence_check(selector, what)
          ->(node, *) do
            at(node, selector) ? nil : "#{what} is required"
          end
        end

        def absence_check(selector, what)
          lambda do |node, *_|
            node.xpath(selector, NS).map do |bad|
              "#{what}: <#{bad.name}> is not permitted"
            end
          end
        end

        def legend_check(word)
          lambda do |node, *_|
            title = nbsp_strip(at(node, "./title"))
            return "The <legend> <title> carries '#{word}'" unless
              title.match?(/#{Regexp.escape(word)}/i)
            return "The <legend> carries a <def-list>" unless at(node, "./def-list")

            bad = node.xpath("./def-list/def-item").find do |d|
              !at(d, "./term") || !at(d, "./def")
            end
            return "Each <def-item> pairs <term> and <def>" if bad

            nil
          end
        end

        def all_ids(doc)
          doc.xpath("//*[@id or @xml:id]").flat_map do |n|
            [n["id"], n["xml:id"]].compact
          end
        end

        # -- rule table ----------------------------------------------------

        def rules
          @rules ||= begin
            list = []
            r = ->(id, guideline, context, check) do
              list << Rule.new(id, guideline, context, check, :error)
            end

            define_document_structure_rules(r)
            define_cross_reference_rules(r)
            define_list_rules(r)
            define_note_rules(r)
            define_graphic_rules(r)
            define_table_rules(r)
            define_formula_rules(r)
            define_figure_rules(r)
            define_terminology_rules(r)
            define_legacy_rules(r)
            list.freeze
          end
        end

        # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        def define_document_structure_rules(r)
          r.call("iso-gdg-4.1-1", "Guidelines 4.1", "/*",
                 lambda do |node, *_|
                   %w[standard adoption].include?(node.name) ||
                     "the complete document shall be coded within the root " \
                     "<standard> (or <adoption> per Annex A); got <#{node.name}>"
                 end)
          r.call("iso-gdg-A.2-1", "Annex A.2", "/*",
                 lambda do |node, *_|
                   %w[standard adoption].include?(node.name) ||
                     "the status of a derived document shall be mentioned; " \
                     "adoptions use the <adoption> root; got <#{node.name}>"
                 end)
          r.call("iso-gdg-3.4-1", "Guidelines 3.4", "/*",
                 lambda do |_, doc|
                   ids = all_ids(doc).to_set
                   dangling = doc.xpath("//@rid").map(&:value)
                     .uniq.reject { |rid| ids.include?(rid) }
                   dangling.empty? || "every @rid shall resolve to an " \
                     "@id/@xml:id; unresolved: #{dangling.first(5).join(', ')}"
                 end)
          r.call("iso-gdg-A.3.1-8", "Annex A.3.1", "/*",
                 lambda do |_, doc|
                   ids = all_ids(doc)
                   dup = ids.group_by(&:itself)
                     .select { |_, v| v.size > 1 }.keys
                   dup.empty? || "all @id/@xml:id values shall be unique " \
                     "within the document; duplicated: #{dup.first(5).join(', ')}"
                 end)
          r.call("iso-gdg-9.2.7-1", "Guidelines 9.2.7", "//tbx:see",
                 ->(*) { "references from the terms and definitions to " \
                         "other clauses use <xref>; <tbx:see> is not used" })
          r.call("iso-gdg-A.3.1-5", "Annex A.3.1, Annex C.1",
                 "//iso-meta | //reg-meta | //nat-meta",
                 ->(node, *) { "<#{node.name}> is outdated and shall be avoided" })
          r.call("iso-gdg-B.2.1-1", "Guidelines B.2.1",
                 "//toc | //toc-entry | //toc-entry-group",
                 ->(node, *) { "cover pages, tables of contents and " \
                               "page-number indexes are not captured in the " \
                               "XML: <#{node.name}>" })
          r.call("iso-gdg-B.2.13-1", "Guidelines B.2.13", "//boxed-text",
                 ->(*) { "<boxed-text> is deprecated and shall not be used " \
                         "in OSD documents" })

          r.call("iso-gdg-4.3.1-1", "Guidelines 4.3.1", "standard",
                 presence_check("./front", "<front>"))
          r.call("iso-gdg-4.4.1-1", "Guidelines 4.4.1", "standard",
                 presence_check("./body", "<body>"))
          r.call("iso-gdg-4.3.2-6", "Guidelines 4.3.2", "standard",
                 lambda do |node, *_|
                   pm = at(node, "./processing-meta")
                   if pm.nil?
                     return "<processing-meta> shall be a child of <standard> " \
                       "declaring the coding profile: tagset-family=sts, " \
                       "base-tagset=interchange, mathml-version=3.0, " \
                       "table-model=xhtml, terminology-model=tbx, " \
                       "math-representation=mathml"
                   end
                   return nil if pm["tagset-family"] == "sts" &&
                     pm["base-tagset"] == "interchange" &&
                     pm["mathml-version"] == "3.0" &&
                     pm["table-model"] == "xhtml" &&
                     pm["terminology-model"] == "tbx" &&
                     pm["math-representation"] == "mathml"

                   "<processing-meta> shall declare the coding profile: " \
                     "tagset-family=sts, base-tagset=interchange, " \
                     "mathml-version=3.0, table-model=xhtml, " \
                     "terminology-model=tbx, math-representation=mathml"
                 end)
          r.call("iso-gdg-4.3.2-7", "Guidelines 4.3.2", "standard",
                 lambda do |node, *_|
                   cms = node.xpath("./processing-meta/custom-meta-group/" \
                                    "custom-meta[meta-name=" \
                                    "'iec_iso_coding_guidelines_edition']", NS)
                   return nil if cms.any? do |cm|
                     !nbsp_strip(at(cm, "./meta-value")).empty?
                   end

                   "<processing-meta> shall carry a <custom-meta> with " \
                     "meta-name iec_iso_coding_guidelines_edition and the " \
                     "guidelines edition as meta-value"
                 end)
          r.call("iso-gdg-4.3.2-1", "Guidelines 4.3.2", "standard",
                 absence_check("./std-doc-meta//permissions | " \
                               "./std-doc-meta//copyright-holder | " \
                               "./std-doc-meta//copyright-statement",
                               "organization metadata are not captured in " \
                               "<std-doc-meta> (they live in <std-meta>)"))
          r.call("iso-gdg-4.3.2-2", "Guidelines 4.3.2", "standard",
                 presence_check("./front//std-meta/permissions",
                                "copyright is captured via <permissions> " \
                                "within <std-meta>"))
          r.call("iso-gdg-4.3.2-3", "Guidelines 4.3.2", "standard",
                 lambda do |node, *_|
                   perms = node.xpath("./front//std-meta/permissions")
                   iso = node.xpath("./front//std-meta//originator" \
                                    "[normalize-space()='ISO']").any?
                   iec = node.xpath("./front//std-meta//originator" \
                                    "[normalize-space()='IEC']").any?
                   if iso && perms.size != 1
                     "ISO coding sums all copyright statements in one " \
                       "<permissions> element; found #{perms.size}"
                   elsif iec && perms.empty?
                     "IEC coding divides copyright into individual " \
                       "<permissions> elements; none found"
                   end
                 end)
          r.call("iso-gdg-4.3.3-1", "Guidelines 4.3.3", "standard",
                 presence_check(
                   "./front/sec[@sec-type='foreword' and not(label)]",
                   "the foreword as <sec @sec-type='foreword'> without label",
                 ))
          r.call("iso-gdg-4.3.4-1", "Guidelines 4.3.4", "standard",
                 lambda do |node, *_|
                   bad = node.xpath("./front/sec").find do |s|
                     nbsp_strip(at(s, "./title")).match?(/\Aintroduction\z/i) &&
                       s["sec-type"] != "intro"
                   end
                   bad && "the introduction shall be coded as <sec> with " \
                     "@sec-type='intro'"
                 end)
          r.call("iso-gdg-4.4.2-2", "Guidelines 4.4.2", "standard",
                 presence_check(
                   "./body/sec[@sec-type='scope'][normalize-space(label)='1']",
                   "the Scope clause numbered 1 with @sec-type='scope'",
                 ))
          r.call("iso-gdg-4.4.2-3", "Guidelines 4.4.2", "standard",
                 presence_check(
                   "./body/sec[@sec-type='norm-refs'][normalize-space(label)='2']",
                   "the Normative references clause numbered 2 with " \
                   "@sec-type='norm-refs'",
                 ))
          r.call("iso-gdg-4.4.2-8", "Guidelines 4.4.2", "standard",
                 lambda do |node, *_|
                   terms = node.xpath("./body/sec[@sec-type='terms']")
                   return nil if terms.any? do |s|
                     at(s, ".//tbx:termEntry") || at(s, ".//p")
                   end

                   "the terms and definitions clause is required with " \
                     "@sec-type='terms'; with no terms it contains a " \
                     "statement to that effect"
                 end)
          r.call("iso-gdg-4.2-1", "Guidelines 4.2", "standard",
                 lambda do |node, *_|
                   node.xpath("//sec[title]").each do |s|
                     t = nbsp_strip(at(s, "./title"))
                     expected = case t
                                when /\Aforeword\z/i then "foreword"
                                when /\Aintroduction\z/i then "intro"
                                when /\Ascope\z/i then "scope"
                                when /\Anormative references\z/i then "norm-refs"
                                else
                                  (t.match?(/terms/i) && t.match?(/definitions/i)) ?
                                    "terms" : nil
                                end
                     next if expected.nil? || s["sec-type"] == expected

                     return "a clause whose title identifies a known clause " \
                       "type is flagged via @sec-type: '#{t}' requires " \
                       "@sec-type='#{expected}'"
                   end
                   nil
                 end)
          r.call("iso-gdg-4.5.2-1", "Guidelines 4.5.2", "standard",
                 lambda do |node, *_|
                   back = at(node, "./back") or return nil
                   bibl = at(back, "./ref-list[@content-type='bibl']")
                   return nil unless bibl

                   bibl.xpath("./following-sibling::*").empty? ||
                     "the bibliography is the last element in the back matter"
                 end)

          r.call("iso-gdg-A.3.1-1", "Annex A.3.1", "adoption",
                 presence_check("./standard", "<standard> inside <adoption>"))
          r.call("iso-gdg-A.3.1-2", "Annex A.3.1", "adoption",
                 presence_check("./standard//std-meta[//originator]",
                                "originator <std-meta> inside the inner " \
                                "<standard>"))
          r.call("iso-gdg-A.3.1-3", "Annex A.3.1", "adoption",
                 lambda do |node, *_|
                   return nil if at(node, ".//adoption-front") ||
                     node.xpath(".//std-meta").size <= 1

                   "metadata of the adopting organisation belong in " \
                     "<adoption-front>, not mixed into <std-meta>"
                 end)
          r.call("iso-gdg-4.3.2-4", "Guidelines 4.3.2", "adoption",
                 lambda do |node, *_|
                   iec = node.xpath("./standard//std-ident/originator" \
                                    "[normalize-space()='IEC']").any?
                   return nil if !iec ||
                     at(node, "./standard//std-meta/permissions")

                   "in adoptions of IEC documents the individual IEC " \
                     "copyright <permissions> shall be preserved"
                 end)

          r.call("iso-gdg-4.4.2-1", "Guidelines 4.4.2", "sec",
                 lambda do |node, *_|
                   # The unnumbered Foreword and Introduction (4.2) hold
                   # numbered subclauses (0.1, ...) but carry no number.
                   return nil if !node.xpath("./sec").any? ||
                     at(node, "./label") ||
                     %w[foreword intro].include?(node["sec-type"])

                   "a clause containing subclauses carries its number in <label>"
                 end)
          r.call("iso-gdg-4.4.2-9", "Guidelines 4.4.2",
                 "sec[@sec-type='numbered-paragraph']",
                 lambda do |node, *_|
                   return nil if at(node, "./label") &&
                     !at(node, "./title")

                   "numbered paragraphs carry <label> and no <title>"
                 end)
          r.call("iso-gdg-9.1-1", "Guidelines 9.1", "sec[@sec-type='terms']",
                 absence_check("./sec/tbx:termEntry",
                               "terminological entries coded as subclauses " \
                               "of the terms clause (use term-sec/TBX)"))
          r.call("iso-gdg-4.5.1-1", "Guidelines 4.5.1", "app",
                 enum_check("content-type", %w[informative normative],
                            label: "annex", required: true))
          r.call("iso-gdg-4.5.1-2", "Guidelines 4.5.1, B.2.6", "app",
                 lambda do |node, *_|
                   problems = []
                   problems << "missing <label>" unless at(node, "./label")
                   problems << "missing <title>" unless at(node, "./title")
                   problems << "<annex-type> is not coded (derived from " \
                     "@content-type on rendering)" if at(node, "./annex-type")
                   problems.empty? || "annex coding: #{problems.join('; ')}"
                 end)
          r.call("iso-gdg-4.5.1-3", "Guidelines 4.5.1", "app",
                 lambda do |node, *_|
                   label = nbsp_strip(at(node, "./label"))
                   return nil unless label.start_with?("Annex ")

                   letter = label[6, 1]
                   bad = node.xpath(".//sec/label").find do |l|
                     !nbsp_strip(l).start_with?("#{letter}.")
                   end
                   bad && "clauses inside an annex carry the annex label " \
                     "prefix ('#{letter}.'); got '#{nbsp_strip(bad)}'"
                 end)
          r.call("iso-gdg-4.5.2-2", "Guidelines 4.5.2", "back",
                 absence_check(
                   "./ref-list[@content-type='bibl']/ref[not(std) and " \
                   "not(mixed-citation)]",
                   "bibliography <ref> without <std> or <mixed-citation>",
                 ))
          r.call("iso-gdg-4.5.2-3", "Guidelines 4.5.2",
                 "ref-list[@content-type='bibl']/ref/mixed-citation",
                 absence_check("./name | ./person-group | " \
                               "./element-citation | ./citation",
                               "granular citation coding inside " \
                               "<mixed-citation>"))
        end
        # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

        def define_cross_reference_rules(r)
          ref_types = %w[abbreviation app bibr custom disp-formula fig fn
                         list sec table table-fn]
          r.call("iso-gdg-10.1.1-1", "Guidelines 10.1.1", "//xref",
                 lambda do |node, *_|
                   rt = node["ref-type"]
                   return "@ref-type shall come from the enumeration " \
                     "(abbreviation, app, bibr, custom, disp-formula, fig, " \
                     "fn, list, sec, table, table-fn); got '#{rt}'" unless
                     ref_types.include?(rt)
                   return "@rid shall hold the target ID" if
                     nbsp_strip(node["rid"]).empty?
                   return nil if rt != "custom" ||
                     %w[term-entry note example].include?(node["custom-type"])

                   "@ref-type='custom' requires @custom-type of term-entry, " \
                     "note or example"
                 end)
          targets = {
            "sec" => "//sec", "table" => "//table-wrap",
            "fig" => "//fig", "disp-formula" => "//disp-formula",
          }
          r.call("iso-gdg-10.1.2-1", "Guidelines 10.1.2", "//xref",
                 lambda do |node, doc|
                   sel = targets[node["ref-type"]] or return nil
                   doc.xpath("#{sel}[@id='#{node['rid']}']").any? ||
                     "@ref-type='#{node['ref-type']}' shall target the ID of " \
                     "a <#{sel.sub('//', '')}>; '#{node['rid']}' not found"
                 end)
          r.call("iso-gdg-10.1.3-1", "Guidelines 10.1.3", "//xref",
                 lambda do |node, doc|
                   return nil unless node["ref-type"] == "custom"
                   return nil unless %w[note example].include?(node["custom-type"])

                   sel = node["custom-type"] == "note" ?
                           "//non-normative-note" : "//non-normative-example"
                   doc.xpath("#{sel}[@id='#{node['rid']}']").any? ||
                     "cross-references to notes/examples shall target the " \
                     "#{sel.sub('//', '')} ID; '#{node['rid']}' not found"
                 end)
          r.call("iso-gdg-10.1.4-1", "Guidelines 10.1.4", "//xref",
                 lambda do |node, doc|
                   return nil unless node["ref-type"] == "abbreviation"

                   doc.xpath("//def-list[@list-content='abbreviation']" \
                             "/def-item[@id='#{node['rid']}']").any? ||
                     "cross-references to abbreviations target the <def-item> " \
                     "in a <def-list @list-content='abbreviation'>"
                 end)
          r.call("iso-gdg-10.1.5-1", "Guidelines 10.1.5", "//xref",
                 lambda do |node, doc|
                   return nil unless node["ref-type"] == "list"

                   doc.xpath("//list[@list-type='alpha-lower' or @list-type='arabic' " \
                             "or @list-type='roman-lower']/list-item" \
                             "[@id='#{node['rid']}']").any? ||
                     "only items in ordered lists can be referenced with " \
                     "@ref-type='list'"
                 end)
          r.call("iso-gdg-10.1.6-1", "Guidelines 10.1.6", "//xref",
                 lambda do |node, doc|
                   return nil unless node["ref-type"] == "bibr"

                   doc.xpath("//ref-list[@content-type='bibl']" \
                             "/ref[@id='#{node['rid']}']").any? ||
                     "bibliography cross-references target the bibliography " \
                     "<ref> ID"
                 end)
          r.call("iso-gdg-10.1.8-1", "Guidelines 10.1.8", "//xref",
                 lambda do |node, doc|
                   return nil unless node["ref-type"] == "fn"

                   doc.xpath("//fn[@id='#{node['rid']}']").any? ||
                     "footnote cross-references target an <fn> ID"
                 end)
          r.call("iso-gdg-6.2.2-4", "Guidelines 6.2.2", "//xref",
                 lambda do |node, doc|
                   return nil unless node["ref-type"] == "table-fn"

                   doc.xpath("//table-wrap//fn[@id='#{node['rid']}']").any? ||
                     "table footnote references target an <fn> within the " \
                     "<table-wrap>"
                 end)
          r.call("iso-gdg-9.2.6-2", "Guidelines 9.2.6", "//xref",
                 lambda do |node, doc|
                   rid = node["rid"]
                   is_term = doc.xpath("//term-sec[@id='#{rid}'] | " \
                                       "//tbx:termEntry[@id='#{rid}']",
                                       NS).any?
                   return nil unless is_term
                   return nil if node["ref-type"] == "custom" &&
                     node["custom-type"] == "term-entry"

                   "references to terms use @ref-type='custom' with " \
                     "@custom-type='term-entry'"
                 end)
          r.call("iso-gdg-10.1.7-1", "Guidelines 10.1.7, 10.2",
                 "std[not(ancestor::ref-list)]",
                 lambda do |node, doc|
                   sid = nbsp_strip(at(node, "./std-id"))
                   return nil if sid.empty?
                   return nil if doc.xpath("//ref-list[@content-type='norm-refs' or " \
                                           "@content-type='bibl']//std-id" \
                                           "[normalize-space()='#{sid}']").any?

                   "a <std> cited in text shall be listed in the normative " \
                     "references or bibliography ('#{sid}')"
                 end)
          r.call("iso-gdg-10.2-1", "Guidelines 10.2",
                 "std[not(ancestor::ref-list)]",
                 lambda do |node, *_|
                   return nil if node.xpath("./std-id[@std-id-link-type='urn']").any?

                   "a <std> cited in text shall identify the standard with " \
                     "<std-id @std-id-link-type='urn'>"
                 end)
          r.call("iso-gdg-10.1.9-1", "Guidelines 10.1.9", "//ext-link",
                 lambda do |node, *_|
                   return nil if node["ext-link-type"] == "uri" &&
                     at(node, "@xlink:href")

                   "a URL is coded as <ext-link @ext-link-type='uri'> with " \
                     "@xlink:href"
                 end)
        end

        def define_list_rules(r)
          r.call("iso-gdg-5.7-1", "Guidelines 5.7", "//list",
                 absence_check("./list",
                               "a <list> nested directly inside a <list> " \
                               "(nest through <list-item>)"))
          r.call("iso-gdg-5.7-2", "Guidelines 5.7", "//list",
                 enum_check("list-type",
                            %w[alpha-lower arabic roman-lower dash bullet],
                            label: "OSD list", required: true))
          r.call("iso-gdg-5.7-3", "Guidelines 5.7", "//p",
                 absence_check("./list", "lists are coded outside the " \
                               "preceding <p>"))
          r.call("iso-gdg-5.7-4", "Guidelines 5.7.1",
                 "list[@list-type='alpha-lower' or @list-type='arabic' or @list-type='roman-lower']/list-item",
                 lambda do |node, *_|
                   problems = []
                   problems << "<label>" unless at(node, "./label")
                   problems << "<p>" unless at(node, "./p")
                   problems.empty? || "ordered <list-item> carries the number " \
                     "in <label> and the text in <p>: missing " \
                     "#{problems.join(' and ')}"
                 end)
          r.call("iso-gdg-5.7.2-1", "Guidelines 5.7.2",
                 "list[@list-type='dash' or @list-type='bullet']/list-item",
                 lambda do |node, *_|
                   at(node, "./label") &&
                     "unordered <list-item> carries no <label> (derived from " \
                     "@list-type on rendering)"
                 end)
        end

        def define_note_rules(r)
          r.call("iso-gdg-5.6-1", "Guidelines 5.6",
                 "non-normative-note | non-normative-example",
                 lambda do |node, *_|
                   return nil unless node.name == "non-normative-note"
                   return nil if node["content-type"].nil? ||
                     node["content-type"] == "warning"

                   "notes with @content-type may only declare 'warning'"
                 end)
          r.call("iso-gdg-5.6-2", "Guidelines 5.6",
                 "non-normative-note | non-normative-example",
                 lambda do |node, *_|
                   label = nbsp_strip(at(node, "./label"))
                   return nil if label.match?(/\A(NOTE|EXAMPLES?|WARNING)/)

                   "the designation text (NOTE, EXAMPLE, WARNING, with " \
                     "numbers/punctuation) is captured in <label>; " \
                     "got '#{label[0, 20]}'"
                 end)
          r.call("iso-gdg-5.6-3", "Guidelines 5.6",
                 "non-normative-note | non-normative-example",
                 lambda do |node, *_|
                   return nil if at(node, "./p") || at(node, "./list")

                   "the note/example text is coded with <p> or <list>"
                 end)
          r.call("iso-gdg-5.9-1", "Guidelines 5.9", "disp-quote[attrib]",
                 lambda do |node, *_|
                   node.xpath("./attrib").all? { |a| a["specific-use"] == "source" } ||
                     "the source of a quote is captured as <attrib " \
                     "@specific-use='source'>"
                 end)
          r.call("iso-gdg-B.2.9-1", "Guidelines B.2.8, B.2.9", "//styled-content",
                 lambda do |node, *_|
                   st = node["style-type"]
                   su = node["specific-use"]
                   st_ok = st.nil? || %w[addition deletion normal align-left
                                         align-right align-center valign-top
                                         valign-bottom valign-middle
                                         indent].include?(st)
                   su_ok = su.nil? || %w[insert delete source].include?(su)
                   return nil if st_ok && su_ok

                   "<styled-content> redline meaning uses @style-type " \
                     "addition/deletion (ISO) or @specific-use insert/delete " \
                     "(IEC); got @style-type='#{st}', @specific-use='#{su}'"
                 end)
        end

        def define_graphic_rules(r)
          r.call("iso-gdg-5.10-1", "Guidelines 5.10", "//p/graphic",
                 ->(*) { "graphics in the same line as text are " \
                         "<inline-graphic>; block <graphic> occurs outside " \
                         "paragraphs" })
          r.call("iso-gdg-5.10-2", "Guidelines 5.10", "graphic | inline-graphic",
                 lambda do |node, *_|
                   href = xlink_href(node)
                   return nil if href.start_with?("data:")
                   return nil unless href.match?(/\.(png|gif|jpe?g|svg|tiff?|eps|pdf)\z/i)

                   "@xlink:href carries the graphic reference without the " \
                     "file extension: '#{href}'"
                 end)
          r.call("iso-gdg-5.10-3", "Guidelines 5.10", "graphic | inline-graphic",
                 lambda do |node, doc|
                   href = xlink_href(node)
                   # An embedded data: URI has no asset folder either way.
                   return nil if href.start_with?("data:")

                   if doc.xpath("//std-meta//originator[normalize-space()='ISO']").any? &&
                     href.include?("/")
                     "ISO graphic references carry no asset-folder prefix: '#{href}'"
                   elsif doc.xpath("//std-meta//originator[normalize-space()='IEC']").any? &&
                     !href.include?("/")
                     "IEC graphic references carry the asset folder name: '#{href}'"
                   end
                 end)
          r.call("iso-gdg-5.10-4", "Guidelines 5.10", "graphic | inline-graphic",
                 lambda do |node, *_|
                   su = node["specific-use"]
                   return nil if su.nil?
                   return "size:T is not permitted on <inline-graphic>" if
                     node.name == "inline-graphic" && su == "size:T"
                   return nil if %w[size:T size:S size:M size:L].include?(su)

                   "@specific-use carries the relative graphic size " \
                     "(size:T/S/M/L); got '#{su}'"
                 end)
          r.call("iso-gdg-5.11-1", "Guidelines 5.11",
                 "styled-content[@style][not(ancestor::code)]",
                 lambda do |node, *_|
                   node["style"].match?(/(Courier|monospace)/i) &&
                     "monospace-styled <styled-content> indicates untagged " \
                     "code: technical content in line is <inline-code>, code " \
                     "blocks are <code>"
                 end)
        end

        def define_table_rules(r)
          r.call("iso-gdg-6.1-1", "Guidelines 6.1", "//table",
                 absence_check(".//table", "nested tables"))
          r.call("iso-gdg-6.1-2", "Guidelines 6.1", "//table",
                 enum_check("width", %w[33% 66% 100%], label: "table"))
          r.call("iso-gdg-6.5-1", "Guidelines 6.5", "//table//br",
                 ->(*) { "a soft break in a table cell is <break/> and a new " \
                         "paragraph is <p>; XHTML <br> is not used" })
          r.call("iso-gdg-6.2.2-2", "Guidelines 6.2.2", "//table/tr",
                 ->(*) { "table rows are grouped in <thead>/<tbody> and " \
                         "footers in <table-wrap-foot>; rows are not coded " \
                         "directly under <table>" })
          r.call("iso-gdg-6.3.1-1", "Guidelines 6.3.1",
                 "//td | //th | //tr | //col",
                 lambda do |node, *_|
                   al = node["align"]
                   va = node["valign"]
                   al_ok = al.nil? || %w[left center right justify].include?(al)
                   va_ok = va.nil? || %w[top middle bottom].include?(va)
                   return nil if al_ok && va_ok

                   "@align carries left/center/right/justify and @valign " \
                     "top/middle/bottom; got @align='#{al}', @valign='#{va}'"
                 end)
          r.call("iso-gdg-6.4-1", "Guidelines 6.4", "//td",
                 lambda do |node, *_|
                   bad = %w[rowspan colspan].filter_map do |a|
                     v = node[a]
                     next nil if v.nil? || v.match?(/\A[1-9][0-9]*\z/)

                     a
                   end
                   bad.empty? || "merged cells use positive-integer " \
                     "@#{bad.join('/@')}"
                 end)
          r.call("iso-gdg-6.2.2-5", "Guidelines 6.2.2",
                 "//table//non-normative-note",
                 lambda do |node, *_|
                   return nil if at(node, "./ancestor::td") ||
                     at(node, "./ancestor::table-wrap-foot")

                   "notes in tables appear inside a cell (<td>) or in " \
                     "<table-wrap-foot>"
                 end)
          r.call("iso-gdg-6.2.2-1", "Guidelines 6.2.2", "//table-wrap",
                 lambda do |node, *_|
                   label = nbsp_strip(at(node, "./label"))
                   return "a formal table carries a <label>" if label.empty?
                   unless at(node, "./caption/title")
                     return "a formal table carries its designation in " \
                       "<caption>/<title>"
                   end
                   return "the <label> carries no punctuation: '#{label}'" if
                     label.match?(/[.,:;]\z/)

                   nil
                 end)
          r.call("iso-gdg-6.6-1", "Guidelines 6.6", "//table-wrap",
                 enum_check("orientation", %w[landscape portrait],
                            label: "table"))
          r.call("iso-gdg-6.2.2-3", "Guidelines 6.2.2", "//table-wrap-foot",
                 lambda do |node, *_|
                   bad = node.xpath("./*").reject do |c|
                     %w[fn non-normative-note p].include?(c.name)
                   end
                   bad.empty? || "table footer content is coded as <fn>, " \
                     "<non-normative-note> or <p>; found <#{bad.first.name}>"
                 end)
          r.call("iso-gdg-6.2.2-7", "Guidelines 6.2.2", "//table-wrap-foot/p",
                 lambda do |node, *_|
                   ct = node["content-type"]
                   return nil if ct.nil? || ct == "dimension"

                   "unit descriptions in <table-wrap-foot> use " \
                     "@content-type='dimension'; got '#{ct}'"
                 end)
          r.call("iso-gdg-5.8-1", "Guidelines 5.8", "//array",
                 lambda do |node, *_|
                   return "text aligned in columns without borders is an " \
                     "<array> with a <table>, not inside <table-wrap>" if
                     at(node, "./ancestor::table-wrap")
                   return "<array> carries no caption/title/label" if
                     at(node, "./caption | ./title | ./label")
                   return "<array> contains a <table>" unless at(node, "./table")

                   nil
                 end)
          r.call("iso-gdg-6.2.1-1", "Guidelines 6.2.1, 7.3", "//array",
                 lambda do |node, *_|
                   at(node, "./ancestor::disp-formula") &&
                     "formula keys are coded as <legend>, not as an informal " \
                     "table in <array>"
                 end)
          r.call("iso-gdg-5.8-2", "Guidelines 5.8", "//array//col",
                 lambda do |node, *_|
                   problems = %w[colwidth width].filter_map do |a|
                     v = node[a]
                     next nil if v.nil? || v.match?(/\A\d+(\.\d+)?%\z/)

                     "@#{a}='#{v}'"
                   end
                   problems.empty? || "array column width is a percentage: " \
                     "#{problems.join(', ')}"
                 end)
        end

        def define_formula_rules(r)
          r.call("iso-gdg-7.4-1", "Guidelines 7.4",
                 "disp-formula | inline-formula",
                 lambda do |node, *_|
                   c = node.xpath("./mml:math", NS).size
                   return nil if c == 1

                   "the mathematical expression is coded with exactly one " \
                     "<mml:math>; got #{c}"
                 end)
          r.call("iso-gdg-7.1-2", "Guidelines 7.1", "disp-formula",
                 presence_check("./label", "the formula number in <label>"))
          r.call("iso-gdg-7.3-1", "Guidelines 7.3", "disp-formula",
                 lambda do |node, *_|
                   c = node.xpath("./legend").size
                   return nil if c <= 1

                   "only one <legend> per <disp-formula>; got #{c}"
                 end)
          r.call("iso-gdg-7.2-1", "Guidelines 7.2", "disp-formula",
                 lambda do |node, *_|
                   bad = node.xpath("./non-normative-note").find do |n|
                     n.xpath("./preceding-sibling::mml:math", NS).empty?
                   end
                   bad && "<disp-formula> notes follow the <mml:math> element"
                 end)
          r.call("iso-gdg-7.1-1", "Guidelines 7.1", "inline-formula",
                 lambda do |node, *_|
                   at(node, "./label") &&
                     "a formula embedded in the flow of text carries no " \
                     "formula-number <label>"
                 end)
          r.call("iso-gdg-4.4.2-4", "Guidelines 4.4.2",
                 "ref-list[@content-type='norm-refs']",
                 absence_check("./ref[not(std) and not(mixed-citation)]",
                               "normative-references <ref> without <std> or " \
                               "<mixed-citation>"))
          r.call("iso-gdg-4.4.2-7", "Guidelines 4.4.2",
                 "ref-list[@content-type='norm-refs']",
                 absence_check("./ref[not(std) and not(mixed-citation)]",
                               "a non-standard normative reference is coded " \
                               "as <mixed-citation>"))
          r.call("iso-gdg-4.4.2-5", "Guidelines 4.4.2",
                 "ref-list[@content-type='norm-refs']/ref/std",
                 lambda do |node, *_|
                   problems = []
                   unless node.xpath("./std-id[@std-id-link-type='urn']" \
                                     "[@std-id-type='dated' or " \
                                     "@std-id-type='undated']", NS).any?
                     problems << "<std-id @std-id-link-type='urn'> with " \
                       "@std-id-type dated/undated"
                   end
                   problems << "<std-ref>" unless at(node, "./std-ref")
                   problems << "<title>" unless at(node, "./title")
                   problems.empty? || "each normative-reference <std> carries " \
                     "#{problems.join(' and ')}"
                 end)
          r.call("iso-gdg-7.3-2", "Guidelines 7.3", "disp-formula/legend",
                 legend_check("where"))
        end

        def define_figure_rules(r)
          r.call("iso-gdg-8.1-1", "Guidelines 8.1", "fig",
                 enum_check("orientation", %w[landscape portrait],
                            label: "figure"))
          r.call("iso-gdg-8.1-2", "Guidelines 8.1", "fig",
                 lambda do |node, *_|
                   problems = []
                   problems << "<label>" unless at(node, "./label")
                   unless at(node, "./caption/title")
                     problems << "<caption>/<title>"
                   end
                   problems << "<graphic>" unless at(node, "./graphic")
                   bad_note = node.xpath("./non-normative-note").find do |n|
                     n.xpath("./preceding-sibling::graphic").empty?
                   end
                   problems << "notes after the <graphic>" if bad_note
                   problems.empty? || "<fig> requires #{problems.join(' and ')}"
                 end)
          r.call("iso-gdg-8.3-1", "Guidelines 8.3", "fig",
                 lambda do |node, *_|
                   c = node.xpath("./legend").size
                   return nil if c <= 1

                   "only one <legend> per <fig>; got #{c}"
                 end)
          r.call("iso-gdg-8.3-2", "Guidelines 8.3", "fig/legend",
                 legend_check("Key"))
          r.call("iso-gdg-8.2-1", "Guidelines 8.2", "fig-group",
                 lambda do |node, *_|
                   c = node.xpath("./legend").size
                   if c > 1
                     return "only one <legend> per <fig-group>; got #{c}"
                   end
                   bad = node.xpath("./*").reject do |ch|
                     %w[fig label caption legend].include?(ch.name)
                   end
                   bad.empty? || "a <fig-group> contains sub-figures (<fig>) " \
                     "plus label/caption/legend; found <#{bad.first.name}>"
                 end)
          r.call("iso-gdg-8.2-2", "Guidelines 8.2", "fig-group",
                 absence_check("./non-normative-note | ./non-normative-example",
                               "notes/examples stay at <fig> level"))
          r.call("iso-gdg-8.4-1", "Guidelines 8.4", "fig/caption/p",
                 lambda do |node, *_|
                   return nil unless nbsp_strip(node).match?(/dimensions in/i)
                   return nil if node["content-type"] == "dimension"

                   "a unit statement in a figure caption is <p> with " \
                     "@content-type='dimension'"
                 end)
        end

        def define_terminology_rules(r)
          r.call("iso-gdg-9.2.1-1", "Guidelines 9.2.1", "tbx:termEntry",
                 presence_check(
                   "./tbx:langSet[tbx:definition][tbx:tig/tbx:term]",
                   "<tbx:langSet> with <tbx:definition> and " \
                   "<tbx:tig>/<tbx:term>",
                 ))
          r.call("iso-gdg-9.2.2-1", "Guidelines 9.2.2", "tbx:definition",
                 lambda do |node, *_|
                   node.parent&.name == "langSet" ||
                     "a definition is coded in <tbx:definition> inside "                      "<tbx:langSet>"
                 end)
          r.call("iso-gdg-9.2.3-1", "Guidelines 9.2.3", "tbx:tig",
                 lambda do |node, *_|
                   c = node.xpath("./tbx:term", NS).size
                   return nil if c == 1

                   "each <tbx:tig> contains exactly one <tbx:term>; got #{c}"
                 end)
          r.call("iso-gdg-9.2.3-2", "Guidelines 9.2.3", "tbx:partOfSpeech",
                 enum_check("value", %w[noun verb adj adv],
                            label: "<tbx:partOfSpeech>", required: true))
          r.call("iso-gdg-9.2.3-3", "Guidelines 9.2.3", "tbx:termType",
                 enum_check("value", %w[fullForm abbreviation symbol formula],
                            label: "<tbx:termType>", required: true))
          r.call("iso-gdg-9.2.3-4", "Guidelines 9.2.3", "tbx:normativeAuthorization",
                 enum_check("value",
                            %w[preferredTerm admittedTerm deprecatedTerm],
                            label: "<tbx:normativeAuthorization>", required: true))
          r.call("iso-gdg-9.2.4-1", "Guidelines 9.2.4", "tbx:example",
                 lambda do |node, *_|
                   nbsp_strip(node.text).match?(/\Aexample/i) &&
                     'the word "Example" and its number are removed from ' \
                     "<tbx:example> content (added at rendering)"
                 end)
          r.call("iso-gdg-9.2.5-1", "Guidelines 9.2.5", "tbx:note",
                 lambda do |node, *_|
                   nbsp_strip(node.text).match?(/\Anote\s*[0-9ivx]*\s*to entry/i) &&
                     'the words "Note X to entry" are removed from <tbx:note> ' \
                     "content (added at rendering)"
                 end)
          r.call("iso-gdg-9.2.6-1", "Guidelines 9.2.6", "tbx:entailedTerm",
                 lambda do |node, doc|
                   target = node["target"]
                   if !at(node, "./ancestor::tbx:termEntry")
                     return "<tbx:entailedTerm> is only used inside " \
                       "<tbx:termEntry>"
                   end
                   return "@target is required" if target.nil? || target.empty?
                   return nil if doc.xpath("//term-sec[@id='#{target}'] | " \
                                           "//tbx:termEntry[@id='#{target}']",
                                           NS).any?

                   "@target='#{target}' does not resolve to a terminological entry"
                 end)
          r.call("iso-gdg-9.2.8-1", "Guidelines 9.2.8", "tbx:source",
                 lambda do |node, *_|
                   return "a stated source is included in <tbx:source> " \
                     "within <tbx:langSet>" unless node.parent&.name == "langSet"
                   return 'the word "SOURCE" is added at rendering; remove it ' \
                     "from <tbx:source> content" if node.text.match?(/SOURCE/)
                   return "square brackets are added at rendering; remove them " \
                     "from <tbx:source> content" if node.text.match?(/[\[\]]/)

                   nil
                 end)
          r.call("iso-gdg-9.2.9-1", "Guidelines 9.2.9", "tbx:subjectField",
                 lambda do |node, *_|
                   node.parent&.name == "langSet" ||
                     "subject fields are tagged <tbx:subjectField> within " \
                     "<tbx:langSet>"
                 end)
          r.call("iso-gdg-A.3.2-1", "Annex A.3.2", "tbx:langSet",
                 lambda do |node, *_|
                   node["xml:lang"].to_s.empty? &&
                     "<tbx:langSet> carries @xml:lang for the entry language"
                 end)
          r.call("iso-gdg-A.3.2-2", "Annex A.3.2", "term-sec",
                 lambda do |node, *_|
                   nbsp_strip(at(node, "./label")).empty? &&
                     "the terminological entry is numbered via <label>; the " \
                     "original numbering is preserved"
                 end)
        end

        def define_legacy_rules(r)
          r.call("iso-gdg-B.2.1-2", "Guidelines B.2.1",
                 "p[not(ancestor::permissions)]",
                 lambda do |node, *_|
                   nbsp_strip(node.text).start_with?("©") &&
                     "copyright notices are captured in <permissions>, not as " \
                     "body text"
                 end)
          r.call("iso-gdg-B.2.6-1", "Guidelines B.2.6", "//app",
                 lambda do |node, *_|
                   %w[inform norm].include?(node["content-type"]) &&
                     "IEC legacy @content-type inform/norm; OSD documents use " \
                     "informative/normative"
                 end)
          r.call("iso-gdg-B.2.6-2", "Guidelines B.2.6",
                 "ref-list[@content-type='bibl']//ref-list",
                 ->(*) { "multiple lists inside the bibliography are legacy " \
                         "tagging and deprecated" })
          r.call("iso-gdg-D.1.1-1", "Annex B.3.2, D.1.1", "editing-instruction",
                 enum_check("content-type",
                            %w[addition replacement deletion modification],
                            label: "<editing-instruction>"))
          r.call("iso-gdg-E.2-1", "Annex E.2",
                 "supplementary-material[contains(@xlink:href, '.pdf')]",
                 lambda do |node, *_|
                   node.xpath("./ancestor::sec[@sec-type='foreword']").any? ||
                     "an IEC Interpretation Sheet PDF is referenced inside the " \
                     "foreword"
                 end)
          r.call("iso-gdg-E.3-1", "Annex E.3", "supplementary-material",
                 presence_check("@xlink:href",
                                "IEC software supplements link via @xlink:href"))
        end

        # Tiny struct binding a rule id + guideline reference + context
        # xpath to its check lambda (nil passes, String reports).
        # +severity+ is :error (fails the gate) or :warning (report-only);
        # the vendored schematron ships the 110 error-severity rules.
        Rule = Struct.new(:id, :guideline, :context, :check, :severity)
      end
    end
  end
end
