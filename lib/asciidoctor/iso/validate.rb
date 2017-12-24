require "nokogiri"

module Asciidoctor
  module ISO
    module Validate
      class << self
        def title_validate(root)
          if root.at("//title_en/title_intro").nil? &&
              !root.at("//title_fr/title_intro").nil?
            warn "No English Title Intro!"
          end
          if !root.at("//title_en/title_intro").nil? &&
              root.at("//title_fr/title_intro").nil?
            warn "No French Title Intro!"
          end
          if root.at("//title_en/title_part").nil? &&
              !root.at("//title_fr/title_part").nil?
            warn "No English Title Part!"
          end
          if !root.at("//title_en/title_part").nil? &&
              root.at("//title_fr/title_part").nil?
            warn "No French Title Part!"
          end
        end

        def validate(doc)
          filename = File.join(File.dirname(__FILE__), "validate.rng")
          schema = Nokogiri::XML::RelaxNG(File.read(filename))
          title_validate(doc.root)
          schema.validate(doc).each do |error|
            warn "RELAXNG Validation: #{error.message}"
          end
        end
      end
    end
  end
end
