require "nokogiri"

module Asciidoctor
  module ISO
    module Validate
      class << self
        def validate(doc)
          schema = Nokogiri::XML::RelaxNG(File.read(File.join(File.dirname(__FILE__), "validate.rng")))
          root = doc.root
          warn "No English Title Intro!" if root.at("//title_en/title_intro").nil? && !root.at("//title_fr/title_intro").nil?
          warn "No French Title Intro!" if !root.at("//title_en/title_intro").nil? && root.at("//title_fr/title_intro").nil?
          warn "No English Title Part!" if root.at("//title_en/title_part").nil? && !root.at("//title_fr/title_part").nil?
          warn "No French Title Part!" if !root.at("//title_en/title_part").nil? && root.at("//title_fr/title_part").nil?
          schema.validate(doc).each do |error|
            $stderr.puts "RELAXNG Validation: #{error.message}"
          end
        end
      end
    end
  end
end
