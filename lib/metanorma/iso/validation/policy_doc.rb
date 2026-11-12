# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      # Validation-policy-document generator (issue #1709).
      #
      # Emits the two policy artifacts from the ruleset of the RELEASED gem:
      #
      # - +validation-policy.adoc+ — the human page: one section per ISO
      #   House Style policy-tree category, one table row per rule, with the
      #   rule's log code, class (or legacy check name), cited wording,
      #   severity, citation source(s) and metanorma functional tag.
      # - +validation-policy.json+ — the machine index
      #   (schema +metanorma-validation-policy/1+), carrying the same records
      #   so metanorma.org can build filtered views.
      #
      # Per the owner rulings, the data supports THREE filters: the
      # policy-tree category path (+category+), the metanorma functional tag
      # (+mn_category+) and the citation source (+sources+: House Style vs
      # ISO/IEC DIR 2). The ADOC page groups by policy category and shows the
      # metanorma tag and the citation sources per row.
      #
      # Layers: model rules come from {RuleRegistry} (rule classes carrying
      # +policy_metadata+); legacy entries come from {LEGACY_POLICY}, keyed
      # by the LegacyChecks method name. Both render into the same tables,
      # marked by the +layer+ column/field.
      module PolicyDoc
        SCHEMA = "metanorma-validation-policy/1"
        FLAVOR = "iso"
        ADOC_FILENAME = "validation-policy.adoc"
        JSON_FILENAME = "validation-policy.json"

        # Canonical order of the ISO House Style 2026-08 top-level sections.
        # ADOC sections are ordered by the category's top-level segment
        # against this array (then lexicographically by full path); unknown
        # top-level sections append after the known ones, sorted. Adding a
        # section here reorders the page — no rendering change needed.
        CANONICAL_SECTIONS = [
          "Document structure",
          "Plain language",
          "Grammar",
          "Spelling and wording",
          "e.g., etc. family",
          "Abbreviated terms, abbreviations and contractions",
          "Abbreviated terms",
          "Numbers, values and dates",
          "Symbols",
          "Punctuation",
          "Lists",
          "Referencing",
          "Additional elements",
          "Vocabulary documents",
          "Relationship with the ISO/IEC Directives, Parts 1 and 2",
          "Formatting",
        ].freeze

        # Numeric log severity (lib/metanorma/iso/log.rb and the standoc
        # log registry) to the severity shown on the page. Matches the
        # mapping in Rules::Base#severity: 0=abort and 2=serious are both
        # errors.
        SEVERITY_NAMES = {
          0 => "error", 1 => "warning", 2 => "error", 3 => "info"
        }.freeze

        # Citation source vocabulary to its page label.
        SOURCE_LABELS = {
          house_style: "ISO House Style",
          directives: "ISO/IEC DIR 2:2021",
        }.freeze

        CANONICAL_SOURCES = %i[house_style directives].freeze

        ENTRY_KEYS = %i[
          code rule_class layer category rule sources directives
          mn_category severity
        ].freeze

        module_function

        # Generate both artifacts. Returns +{ adoc:, json: }+ with the
        # rendered strings; when +output_dir+ is given, the artifacts are
        # ALSO written there as +validation-policy.adoc+ /
        # +validation-policy.json+. +version+ is the released gem version
        # string the page declares (defaults to {Metanorma::Iso::VERSION});
        # +generated_at+ is the UTC ISO8601 timestamp.
        def generate(output_dir: nil, version: Metanorma::Iso::VERSION,
                     generated_at: Time.now.utc.xmlschema)
          entries = policy_entries
          adoc = render_adoc(entries, version: version,
                                      generated_at: generated_at)
          json = render_json(entries, version: version,
                                      generated_at: generated_at)
          if output_dir
            File.write(File.join(output_dir, ADOC_FILENAME), adoc)
            File.write(File.join(output_dir, JSON_FILENAME), json)
          end
          { adoc: adoc, json: json }
        end

        # The full policy record set: model-layer entries (sorted by rule
        # class name) followed by legacy-layer entries (sidecar order).
        def policy_entries
          model_entries + legacy_entries
        end

        def model_entries
          RuleRegistry.new.all.map do |cls|
            meta = cls.policy_metadata
            code = cls.code_value
            ENTRY_KEYS.zip(
              [
                code,
                cls.name.split("::").last,
                "model",
                Array(meta[:category]),
                meta[:rule],
                canonical_sources(meta[:source]),
                meta[:directives],
                meta[:mn_category].to_s,
                severity_for(code),
              ],
            ).to_h
          end.sort_by { |entry| entry[:rule_class] }
        end

        def legacy_entries
          LEGACY_POLICY.map do |check, meta|
            ENTRY_KEYS.zip(
              [
                meta[:code],
                check,
                "legacy",
                Array(meta[:category]),
                meta[:rule],
                canonical_sources(meta[:source]),
                meta[:directives],
                meta[:mn_category].to_s,
                severity_for(meta[:code]),
              ],
            ).to_h
          end
        end

        # Sources in canonical order (House Style first, then the
        # Directives), as strings for the JSON index.
        def canonical_sources(source)
          srcs = Array(source)
          CANONICAL_SOURCES.select { |s| srcs.include?(s) }.map(&:to_s)
        end

        # Numeric severity of a log code, from the ISO flavour's log
        # registry, falling back to the standoc registry for STANDOC_N
        # codes; nil when neither registry knows the code.
        def severity_for(code)
          code = code.to_s.to_sym
          spec = iso_log_spec[code] || standoc_log_spec[code]
          spec && spec[:severity]
        end

        # ADOC page. Public so the golden-file spec can pin the exact
        # rendering of a small frozen sample.
        def render_adoc(entries, version:, generated_at:)
          out = +"= Validation rules policy\n\n"
          out << intro(entries, version, generated_at)
          grouped_categories(entries).each do |category, rows|
            out << "\n== #{category}\n\n"
            out << adoc_table(rows)
          end
          out
        end

        # JSON index. Public so the golden-file spec can pin the exact
        # rendering of a small frozen sample.
        def render_json(entries, version:, generated_at:)
          "#{JSON.pretty_generate(
            'schema' => SCHEMA,
            'flavor' => FLAVOR,
            'gem_version' => version,
            'generated_at' => generated_at,
            'rules' => entries,
          )}\n"
        end

        # ADOC section order: categories grouped by their top-level segment
        # against {CANONICAL_SECTIONS}; unknown top-levels append sorted.
        def grouped_categories(entries)
          by_category = Hash.new { |h, k| h[k] = [] }
          entries.each do |entry|
            entry[:category].each { |cat| by_category[cat] << entry }
          end
          by_category.keys.sort_by { |cat| category_sort_key(cat) }
            .to_h { |cat| [cat, sort_rows(by_category[cat])] }
        end

        def category_sort_key(category)
          top = category.split(" > ").first.to_s
          idx = CANONICAL_SECTIONS.index(top)
          [idx ? 0 : 1, idx || 0, top, category]
        end

        def sort_rows(rows)
          rows.sort_by { |r| [r[:layer] == "model" ? 0 : 1, r[:rule_class]] }
        end

        def intro(entries, version, generated_at)
          models = entries.count { |e| e[:layer] == "model" }
          legacy = entries.count { |e| e[:layer] == "legacy" }
          <<~INTRO
            This page is the validation policy of the ISO flavour: every rule
            that the released metanorma-iso gem checks documents against, with
            the policy category it enforces, the citation that grounds it, and
            the metanorma functional tag that classifies it.

            Generated from metanorma-iso v#{version} on #{generated_at}:
            #{models} model-layer rule#{plural(models)} and
            #{legacy} legacy-layer check#{plural(legacy)}.

            The data on this page supports three filters: the ISO House Style
            policy-tree category (the section headings below), the metanorma
            functional tag (style, structure, references), and the citation
            source, which is named separately per row — rules sourced from the
            ISO House Style and rules restating the ISO/IEC Directives,
            Part 2:2021 are distinguishable. The machine-readable index
            alongside this page (#{JSON_FILENAME}) carries the same records
            under schema #{SCHEMA}.
          INTRO
        end

        def plural(count)
          count == 1 ? "" : "s"
        end

        def adoc_table(rows)
          out = +<<~TABLE
            [cols="1,2,6,1,2,1,1",options="header"]
            |===
            | Code | Rule | Summary | Severity | Citations | metanorma tag | Layer
          TABLE
          rows.each do |row|
            out << "\n"
            out << cells(row).map { |c| "| #{c}" }.join(" ")
            out << "\n"
          end
          out << "|===\n"
          out
        end

        def cells(row)
          [
            row[:code],
            row[:rule_class],
            row[:rule],
            SEVERITY_NAMES[row[:severity]] || "unknown",
            citations(row),
            row[:mn_category],
            row[:layer],
          ].map { |c| escape_cell(c.to_s) }
        end

        def citations(row)
          labels = []
          sources = Array(row[:sources])
          labels << SOURCE_LABELS[:house_style] if sources.include?("house_style")
          labels << "#{SOURCE_LABELS[:directives]} #{row[:directives]}" if sources.include?("directives")
          labels.join("; ")
        end

        def escape_cell(text)
          text.gsub("|", "\\|")
        end

        def iso_log_spec
          Metanorma::Iso::Converter::ISO_LOG_MESSAGES
        rescue NameError
          {}
        end

        def standoc_log_spec
          Metanorma::Standoc::Converter::STANDOC_LOG_MESSAGES
        rescue NameError
          {}
        end
      end
    end
  end
end
