# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      # Turns the mnconvert NISO STS output (+:sts+ leg) into schema-valid
      # NISO STS (NISO STS extended-1 MathML3 XSD).
      #
      # mnconvert passes Metanorma-internal constructs through verbatim, so
      # the emitted document carries three classes of schema violations:
      #
      # - flavor build attributes (e.g. the +:iso-cen-parallel:+ document
      #   attribute) surface as undeclared elements inside +<std-meta>+
      #   with mnconvert's "unprocessed bibdata elements" warning spliced
      #   in around them as character content;
      # - inline +<identifier>+ elements from Metanorma requirements models
      #   survive as undeclared inline markup inside +<p>+;
      # - generated +sec+ ids can collide (e.g. two "Scope" clauses both
      #   become +id="sec_scope"+), violating +xs:ID+ uniqueness.
      #
      # Each fix class is one registered sanitizer; adding a fix means
      # adding a class to {SANITIZERS} (Open/Closed). Every sanitizer is
      # idempotent: on already-clean input it is a no-op, so the pipeline
      # stays correct when mnconvert tightens its own emission.
      module OutputSanitizer
        autoload :FrontLeakSanitizer,
                 "#{__dir__}/output_sanitizer/front_leak_sanitizer"
        autoload :InlineIdentifierSanitizer,
                 "#{__dir__}/output_sanitizer/inline_identifier_sanitizer"
        autoload :UniqueIdSanitizer,
                 "#{__dir__}/output_sanitizer/unique_id_sanitizer"

        SANITIZERS = [
          FrontLeakSanitizer,
          InlineIdentifierSanitizer,
          UniqueIdSanitizer,
        ].freeze

        class << self
          # Sanitize a NISO STS XML string.
          #
          # @param xml [String] the mnconvert NISO STS output.
          # @return [String] the schema-valid NISO STS XML.
          def sanitize(xml)
            doc = Nokogiri::XML(xml)
            SANITIZERS.each { |sanitizer| sanitizer.apply(doc) }
            doc.to_xml
          end

          # Sanitize a NISO STS XML file in place.
          #
          # @param path [String, Pathname] the written mnconvert output.
          # @return [void]
          def sanitize_file(path)
            File.write(path, sanitize(File.read(path, encoding: "utf-8")))
          end
        end
      end
    end
  end
end
