# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      module Transformer
        class Context
          attr_reader :source, :id_generator, :footnote_collector

          def initialize(source)
            @source = source
            @id_generator = IdGenerator.new
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
