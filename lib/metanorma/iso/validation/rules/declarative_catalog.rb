# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Bridges ISO rule classes to the standoc declarative rule engine
        # (issue #1732). Model input is projected by the engine's own
        # DocumentProjection: findings carry a strict XML node plus the
        # original model as +source_model+.

        module DeclarativeCatalog
          REGISTRATIONS_PATH = File.expand_path("declarative/iso-catalog.yml", __dir__)

          class ProjectionError < StandardError; end

          PATH = File.expand_path("declarative/iso-structure.yml", __dir__)
          NAMESPACE = "https://www.metanorma.org/ns/standoc"
          NAMESPACES = { "m" => NAMESPACE }.freeze
          PROJECTION_NAMESPACE = "urn:metanorma:iso:validation-projection:1"
          PROJECTION_NAMESPACES = NAMESPACES.merge("v" => PROJECTION_NAMESPACE).freeze
          SEQUENCE_PATH = File.expand_path("declarative/iso-sequence.yml", __dir__)
          ROOT_NAME = "metanorma"

          class << self
            def declaration
              @declaration ||= begin
                doc = YAML.safe_load_file(REGISTRATIONS_PATH, aliases: false)
                unless doc.is_a?(Hash) && doc["schema"] == "metanorma-iso-validation-catalog/1" &&
                    (doc.keys - %w[schema rulesets registrations]).empty?
                  raise ArgumentError, "unsupported ISO validation catalog"
                end
                Array(doc.fetch("rulesets")).each do |file|
                  unless file.is_a?(String) && /\A[a-z][a-z0-9-]*\.yml\z/.match?(file)
                    raise ArgumentError, "invalid ISO ruleset asset #{file.inspect}"
                  end
                end
                doc.freeze
              end
            end

            def registrations
              @registrations ||= begin
                entries = declaration.fetch("registrations")
                names = entries.map { |entry| entry.fetch("class") }
                raise ArgumentError, "duplicate ISO registration" unless names.uniq == names

                entries.each do |entry|
                  klass = Rules.const_get(entry.fetch("class"), false)
                  unless klass.is_a?(Class) && klass < Base && !klass.abstract_rule? &&
                      klass.code_value == entry.fetch("code")
                    raise ArgumentError, "invalid ISO registration #{entry.inspect}"
                  end
                  ids = Array(entry["rules"])
                  actual = klass.include?(DeclarativeDispatch) ? klass.declarative_rule_ids : []
                  expected_mode = actual.empty? ? "code" : "declarative"
                  unless ids == actual && entry.fetch("implementation") == expected_mode
                    raise ArgumentError, "registration mismatch for #{klass}"
                  end
                  entry.freeze
                end
                entries.freeze
              end
            end

            # Composition dispatches the declared corpus, with reflection used
            # only to reject an accidentally unregistered concrete ISO rule.
            def registered_classes
              classes = registrations.map { |entry| Rules.const_get(entry.fetch("class"), false) }
              undeclared = RuleRegistry.new.all - classes
              unless undeclared.empty?
                raise ArgumentError, "unregistered ISO rules: #{undeclared.map(&:name).join(', ')}"
              end
              classes.sort_by(&:name)
            end

            def available?
              !defined?(::Metanorma::Standoc::Validate::Rules::Engine).nil? &&
                !defined?(::Metanorma::Standoc::Validate::Rules::RuleSet).nil? &&
                !defined?(::Metanorma::Standoc::Validate::Rules::DocumentProjection).nil?
            end

            def rule_set
              @rule_set ||= declaration.fetch("rulesets").reduce(api::RuleSet.new([])) do |base, file|
                path = File.join(File.dirname(REGISTRATIONS_PATH), file)
                base.merge(api::RuleSet.load_file(path, registry: check_registry))
              end
            end

            # The subset of the catalog owned by +classes+, in catalog order.
            def rule_set_for(classes)
              ids = classes.flat_map(&:declarative_rule_ids)
              missing = ids - rule_set.rules.map(&:id)
              unless missing.empty?
                raise ArgumentError,
                      "undeclared rule ids: #{missing.join(', ')}"
              end

              api::RuleSet.new(rule_set.rules.select { |r| ids.include?(r.id) },
                               namespaces: rule_set.namespaces)
            end

            # A failed projection is an explicit validation failure, never an
            # empty finding set or a silently retained implementation.
            def findings_for(klass, context)
              raise ProjectionError, "standoc declarative engine is unavailable" unless available?

              projection = projection_for(context)
              set = context.registry ? context.registry.declarative_rule_set_for([klass]) : rule_set_for([klass])
              if klass.respond_to?(:active_declarative_rule_ids)
                ids = klass.active_declarative_rule_ids(context)
                set = api::RuleSet.new(set.rules.select { |rule| ids.include?(rule.id) },
                                       namespaces: set.namespaces)
              end
              api::Engine.new(set).findings(projection)
            end

            private

            # These predicates are generic XPath selection checks. The rule
            # data owns the order constraints. No Schematron mapping is given:
            # their projection-only metadata requires typed model preprocessing.
            def check_registry
              @check_registry ||= api::CheckRegistry.default.dup.tap do |registry|
                registry.register("iso.model_required", needs_target: true) { |node, _, _| node.nil? }
                registry.register("iso.model_forbidden", needs_target: true) { |node, _, _| !node.nil? }
                registry.register("iso.model_selected", required: ["select"],
                  validate_args: lambda { |args|
                    selected = Nokogiri::XML("<probe/>").xpath(args.fetch("select"), PROJECTION_NAMESPACES)
                    raise api::RuleError, "select must return nodes" unless selected.is_a?(Nokogiri::XML::NodeSet)
                  }) do |node, args, _|
                  node.xpath(args.fetch("select"), PROJECTION_NAMESPACES).include?(node)
                end
              end.freeze
            end

            public :check_registry

            def api
              ::Metanorma::Standoc::Validate::Rules
            end

            def projection_for(context)
              context.walk_cache.document_projection(context.root) do
                build_projection(context.root)
              end
            end

            public :projection_for

            # An explicit validation-only fact projection preserves model
            # order/cardinality that semantic serialization can normalize (for
            # example repeated references to a singular definitions model).
            def annotate_order_facts(root, xml)
              namespaces = xml.collect_namespaces
              if namespaces.key?("xmlns:v") && namespaces["xmlns:v"] != PROJECTION_NAMESPACE
                raise ProjectionError, "validation projection namespace collision for v"
              end
              if xml.xpath("//*[namespace-uri()='#{PROJECTION_NAMESPACE}']").any?
                raise ProjectionError, "validation projection metadata already exists"
              end
              namespace = xml.root.add_namespace_definition("v", PROJECTION_NAMESPACE)
              sequence = Nokogiri::XML::Node.new("sequence", xml)
              sequence.namespace = namespace
              xml.root.add_child(sequence)
              SectionSequenceRule.new.projection_sequence(root).each do |kind, location|
                item = Nokogiri::XML::Node.new("item", xml)
                item.namespace = namespace
                item["kind"] = kind.to_s
                item["location"] = location if location
                sequence.add_child(item)
              end
            end

            # A root outside the expected namespace would match no context
            # and silently report a clean document, so it is rejected.
            def build_projection(root)
              # ISO uses a Serializable root with RootAttributes rather than
              # inheriting Metanorma::Document::Root. Adapt that explicit type
              # through the public strict E2 parser and preserve source identity.
              projection = if root.is_a?(::Metanorma::Iso::Document::Root)
                             api::DocumentProjection.new(
                               api::DocumentProjection.parse_model(root),
                               source_model: root,
                             )
                           else
                             api::DocumentProjection.for(root)
                           end
              annotate_order_facts(root, projection.xml) if root.is_a?(::Metanorma::Iso::Document::Root)
              element = projection.xml.root
              return projection if element&.name == ROOT_NAME &&
                element.namespace&.href == NAMESPACE

              raise ProjectionError,
                    "unexpected projection root #{element&.namespace&.href.inspect}:#{element&.name.inspect}"
            rescue StandardError => e
              raise ProjectionError, "model projection failed: #{e.message}"
            end
          end
        end
      end
    end
  end
end
