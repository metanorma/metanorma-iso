# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      module Transformer
        class IdGenerator
          def initialize
            @registry = {}
            @counter = 0
          end

          def register(source_id, sts_id)
            @registry[source_id] = sts_id
          end

          def remap(source_id)
            @registry[source_id]
          end

          def id_for(obj, prefix: "sec")
            return nil unless obj
            source_id = obj.id if obj.is_a?(Lutaml::Model::Serializable) && obj.class.method_defined?(:id)
            source_id ||= nil

            if source_id && !source_id.empty?
              return @registry[source_id] if @registry.key?(source_id)
              register(source_id, source_id)
              return source_id
            end

            @counter += 1
            "#{prefix}_#{@counter}"
          end
        end
      end
    end
  end
end
