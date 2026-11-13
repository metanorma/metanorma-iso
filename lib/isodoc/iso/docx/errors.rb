# frozen_string_literal: true

require "yaml"

module IsoDoc
  module Iso
    module Docx
      # Raised when StyleResolver cannot find a style for a given key.
      # Strict mode: StyleResolver raises this rather than returning nil,
      # so that missing mappings surface during development rather than
      # silently producing wrong DOCX output.
      class UnknownStyleError < StandardError
        attr_reader :key, :context, :role

        def initialize(key, role:, context: nil)
          @key     = key
          @role    = role
          @context = context
          super(message)
        end

        def message
          ctx_str = context ? " (#{context_describe})" : ""
          "Unknown style key #{key.inspect} for #{role}#{ctx_str}. " \
            "Add a mapping in data/iso-dis/style_mapping.yml."
        end

        private

        def context_describe
          return "zone=#{context.zone}" if context.is_a?(IsoDoc::Iso::Docx::Context)

          context.to_s
        end
      end

      # Loads numbering.yml and exposes abstract_num_id? / num_id? queries.
      class NumberingLibrary
        attr_reader :definitions, :abstract_num_ids, :num_ids

        def self.load_default(template: :dis)
          path = DocxTemplates.config_dir(template) + "/numbering.yml"
          from_file(path)
        end

        def self.from_file(path)
          new(YAML.load_file(path))
        end

        def initialize(data)
          @definitions = data.fetch("definitions", [])
          @abstract_num_ids = @definitions
            .select { |d| d["kind"] == "abstractNum" }
            .map { |d| d["id"] }.to_set
          @num_ids = @definitions
            .select { |d| d["kind"] == "num" }
            .map { |d| d["id"] }.to_set
        end

        def abstract_num_id?(id)
          @abstract_num_ids.include?(id.to_s)
        end

        def num_id?(id)
          @num_ids.include?(id.to_s)
        end

        # Given a numId, return the abstractNumId it is bound to.
        def abstract_num_id_for_num_id(num_id)
          d = @definitions.find { |x| x["kind"] == "num" && x["id"] == num_id.to_s }
          d && d["abstract_num_id"]
        end

        def abstract_num_definition_for(id)
          @definitions.find { |d| d["kind"] == "abstractNum" && d["id"] == id.to_s }
        end

        def num_definition_for(num_id)
          @definitions.find { |d| d["kind"] == "num" && d["id"] == num_id.to_s }
        end
      end
    end
  end
end
