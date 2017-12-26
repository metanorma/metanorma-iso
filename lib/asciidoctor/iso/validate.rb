require "asciidoctor/iso/utils"
require "nokogiri"
require "jing"

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
          title_validate(doc.root)
          filename = File.join(File.dirname(__FILE__), "validate.rng")
=begin
          filename = File.join(File.dirname(__FILE__), "validate.rng")
          schema = Nokogiri::XML::RelaxNG(File.read(filename))
          schema.validate(doc).each do |error|
            warn "RELAXNG Validation: #{error.message}"
          end
=end
          schema = Jing.new(filename)
          File.open(".tmp.xml", "w") { |f| f.write(doc.to_xml) }
          begin
            errors = schema.validate(".tmp.xml")
          rescue Jing::Error => e
            abort "what what what #{e}"
          end
          if errors.none?
            puts "Valid!"
          else
            errors.each do |error|
              puts "#{error[:message]} @ #{error[:line]}:#{error[:column]}"
            end
          end
        end

        def style(node, text)
          matched = /\b(?<number>[0-9]+\.[0-9]+)\b/.match text
          Utils::style_warning(node, "possible decimal point", matched[:number]) unless matched.nil?
          matched = /(?<!ISO )\b(?<number>[0-9][0-9][0-9][0-9]+)\b/.match text
          Utils::style_warning(node, "number not broken up in threes", matched[:number]) unless matched.nil?
          matched = /\b(?<number>[0-9.,]+%)/.match text
          Utils::style_warning(node, "no space before percent sign", matched[:number]) unless matched.nil?
          matched = /\b(?<number>[0-9.,]+ \u00b1 [0-9,.]+ %)/.match text
          Utils::style_warning(node, "unbracketed tolerance before percent sign", matched[:number]) unless matched.nil?
        end
      end
    end
  end
end
