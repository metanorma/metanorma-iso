# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      module Transformer
        class Context
          attr_reader :source, :id_generator, :footnote_collector

          def initialize(source)
            @source = source
            # Claim the renamed ids (annex apps, terms sections, terms,
            # figures) in document order before any transform runs, so
            # xref rid values pointing forward resolve.
            @id_generator = IdGenerator.new.pre_register(source)
            @footnote_collector = FootnoteCollector.new
          end

          def language
            source.language || "en"
          end

          def docidentifier
            source.docidentifier
          end
        end
      end
    end
  end
end
