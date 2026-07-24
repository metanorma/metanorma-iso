# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      module Transformer
        # Facade over the parsed {Metanorma::IsoDocument::Root} that provides
        # uniform read accessors for every transformer. Converting the source
        # tree (raw {Metanorma::IsoDocument::Root}, XML string, or anything
        # responding to +#read+) into a {SourceDocument} concentrates "how do
        # I read X from the source?" in one place — mirroring the OIML
        # transformer pipeline and giving us one seam to evolve when the
        # underlying model changes.
        class SourceDocument
          attr_reader :typed_root

          def self.parse(input)
            xml_string = parse_xml(input)
            new(Metanorma::IsoDocument::Root.from_xml(xml_string))
          end

          def self.parse_xml(input)
            return input if input.is_a?(Metanorma::IsoDocument::Root)
            return input.read if input.is_a?(IO) || input.is_a?(StringIO)

            input.to_s
          end
          private_class_method :parse_xml

          def initialize(typed_root)
            @typed_root = typed_root
          end

          def bibdata
            typed_root.bibdata
          end

          def preface
            typed_root.preface
          end

          def foreword
            preface&.foreword
          end

          def introduction
            preface&.introduction
          end

          def abstract
            preface&.abstract
          end

          def sections
            typed_root.sections
          end

          def annexes
            Array(typed_root.annex)
          end

          alias_method :annex, :annexes

          def indexsect
            typed_root.indexsect
          end

          def bibliography
            typed_root.bibliography
          end

          # Flat list of every <bibitem> across all <references> sections.
          # Used by the Context's bibitem_lookup so the inline transformer
          # can resolve any <eref rid="..."> to its citation text.
          def bibitems
            bibliography.flat_map { |section| Array(section.references) }
              .compact
          end

          def language
            return "en" unless bibdata

            langs = bibdata.language
            return "en" unless langs

            lang = langs.is_a?(Array) ? langs.first : langs
            lang = lang.is_a?(Metanorma::IsoDocument::Metadata::LanguageElement) ? lang.value : lang
            lang.to_s.strip.match?(/\A[a-z]{2}(-[A-Z]{2})?\z/) ? lang.to_s.strip : "en"
          end

          def docidentifier
            return nil unless bibdata

            ids = Array(bibdata.doc_identifier)
            return nil if ids.empty?

            primary = ids.find { |id| id.type.nil? } || ids.first
            extract_text(primary)
          end

          def has_front?
            !foreword.nil? || !introduction.nil? || !abstract.nil?
          end

          def has_metadata?
            !docidentifier.nil?
          end

          def has_back?
            annexes.any? || bibliography.any?
          end

          private

          def extract_text(obj)
            return obj.to_s unless obj
            return obj.to_s unless obj.class.method_defined?(:content)

            content = obj.content
            content.is_a?(Array) ? content.compact.join : content.to_s
          end
        end
      end
    end
  end
end
