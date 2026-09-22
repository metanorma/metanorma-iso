# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      # Extracts converter state from a deserialized IsoDocument::Root.
      # Enables standalone API/CLI use without the user passing
      # doctype/lang/script explicitly — the model IS the source of truth.
      #
      # Used by API.validate when state isn't provided. Also available
      # for programmatic callers who want to inspect detected state.
      class StateExtractor
        DEFAULT_LANG = "en".freeze
        DEFAULT_SCRIPT = "Latn".freeze

        class << self
          # @param root [Metanorma::Iso::Document::Root, nil] Deserialized model.
          # @param document [String, nil] Source identifier for the report.
          # @return [ConverterState]
          def extract(root, document: nil)
            bibdata = root&.bibdata
            return empty_state(document) unless bibdata

            ConverterState.new(
              lang: extract_lang(bibdata),
              script: extract_script(bibdata),
              doctype: extract_doctype(bibdata),
              vocab: extract_vocab(bibdata),
              amd: extract_amd(extract_doctype(bibdata)),
              document: document
            )
          end

          private

          def empty_state(document)
            ConverterState.new(
              lang: DEFAULT_LANG, script: DEFAULT_SCRIPT, document: document
            )
          end

          def extract_lang(bibdata)
            return DEFAULT_LANG unless bibdata.class.method_defined?(:language)

            first_value(Array(bibdata.language)) || DEFAULT_LANG
          end

          def extract_script(bibdata)
            return DEFAULT_SCRIPT unless bibdata.class.method_defined?(:script)

            first_value(Array(bibdata.script)) || DEFAULT_SCRIPT
          end

          def extract_doctype(bibdata)
            ext = bibdata.ext if bibdata.class.method_defined?(:ext)
            return nil unless ext

            doctypes = Array(ext.doctype) if ext.class.method_defined?(:doctype)
            first_value(doctypes)
          end

          def extract_vocab(bibdata)
            ext = bibdata.ext if bibdata.class.method_defined?(:ext)
            return false unless ext
            return false unless ext.class.method_defined?(:subdoctype)

            ext.subdoctype.to_s == "vocabulary"
          end

          def extract_amd(doctype)
            %w[amendment technical-corrigendum].include?(doctype.to_s)
          end

          def first_value(collection)
            return nil if collection.nil? || collection.empty?

            item = collection.first
            return item.to_s unless item.is_a?(Lutaml::Model::Serializable)
            return item.value if item.class.method_defined?(:value)

            item.to_s
          end
        end
      end
    end
  end
end
