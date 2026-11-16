# frozen_string_literal: true

require "nokogiri"

module Metanorma
  module Iso
    module Sts
      # Validates OIML NISO STS XML against the OIML X 999:2026 constraints.
      #
      # The validator is a pure-Ruby implementation of the rules expressed in
      # `schematron/oiml-sts.sch`. (We avoid requiring a Schematron XSLT
      # engine at runtime; the rule logic is small enough to express in
      # Ruby directly, which is also faster.)
      #
      # Each rule corresponds to one Schematron pattern; the rule ids
      # match the `<assert id="...">` / `<report id="...">` attributes in
      # the .sch file so output is comparable.
      class Validator
        SCHEMATRON_PATH = File.expand_path("../schematron/oiml-sts.sch", __dir__).freeze

        # @param xml [String, Pathname, #read] OIML STS XML.
        # @return [ValidationReport]
        def validate(xml)
          doc = parse(xml)
          report = ValidationReport.new
          rules.each do |rule|
            rule.block.call(doc, report, rule)
          end
          report
        end

        private

        def parse(xml)
          case xml
          when Pathname then Nokogiri::XML(xml.read)
          when ->(x) { x.respond_to?(:read) } then Nokogiri::XML(xml.read)
          else Nokogiri::XML(xml.to_s)
          end
        end

        # Returns the list of rule implementations. Adding a new rule =
        # adding one entry (Open/Closed at the rule level).
        def rules
          [
            RuleImplementation.new(
              id: "oiml-x999-root-element",
              message: "Root element shall be <standard> or <adoption>.",
              apply: ->(doc, report, rule) {
                root = doc.root
                return if root&.name == "standard" || root&.name == "adoption"

                report.add(rule_id: rule.id, message: rule.message, xpath: "/")
              }
            ),
            RuleImplementation.new(
              id: "oiml-x999-processing-meta",
              message: "Every <standard> shall declare <processing-meta>.",
              apply: ->(doc, report, rule) {
                doc.xpath("//standard").each do |node|
                  next if node.at_xpath("./processing-meta")
                  next if node.ancestors("adoption").any?

                  report.add(rule_id: rule.id, message: rule.message,
                             xpath: node.path)
                end
              }
            ),
            RuleImplementation.new(
              id: "oiml-x999-std-title-and-date",
              message: "Every <std> shall carry <title>, and every <std-ref> shall declare datedness via @type.",
              apply: ->(doc, report, rule) {
                doc.xpath("//std").each do |node|
                  problems = []
                  problems << "missing required <title>" unless node.at_xpath("./title")
                  node.xpath("./std-ref").each do |std_ref|
                    type = std_ref["type"]
                    if type.nil? || type.empty?
                      problems << "<std-ref> does not declare @type (dated/undated)"
                    end
                  end
                  next if problems.empty?

                  report.add(rule_id: rule.id,
                             message: "<std>: #{problems.join('; ')} (OIML X 999 Clause 5.4).",
                             xpath: node.path)
                end
              }
            ),
            RuleImplementation.new(
              id: "oiml-x999-no-self-uri-in-xref",
              message: "<self-uri> shall not occur inside <self-xref>.",
              apply: ->(doc, report, rule) {
                doc.xpath("//self-xref//self-uri").each do |node|
                  report.add(rule_id: rule.id, message: rule.message, xpath: node.path)
                end
              }
            ),
            RuleImplementation.new(
              id: "oiml-x999-permission-on-reuse-disp-quote",
              message: "A <disp-quote> carrying <attrib> shall also carry <permissions>.",
              apply: ->(doc, report, rule) {
                doc.xpath("//disp-quote[attrib]").each do |node|
                  next if node.at_xpath("./permissions")

                  report.add(rule_id: rule.id, message: rule.message, xpath: node.path)
                end
              }
            )
          ]
        end

        # Tiny struct that binds a rule id + message to its apply lambda.
        class RuleImplementation
          attr_reader :id, :message, :block

          def initialize(id:, message:, apply:)
            @id = id
            @message = message
            @block = apply
          end
        end
      end
    end
  end
end
