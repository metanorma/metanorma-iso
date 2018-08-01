require "asciidoctor/extensions"
module Asciidoctor
  module ISO
    class AltTermInlineMacro < Asciidoctor::Extensions::InlineMacroProcessor
      use_dsl
      named :alt
      parse_content_as :text
      using_format :short

      def process(parent, _target, attrs)
        out = Asciidoctor::Inline.new(parent, :quoted, attrs["text"]).convert
        %{<admitted>#{out}</admitted>}
      end
    end

    class DeprecatedTermInlineMacro <
      Asciidoctor::Extensions::InlineMacroProcessor
      use_dsl
      named :deprecated
      parse_content_as :text
      using_format :short

      def process(parent, _target, attrs)
        out = Asciidoctor::Inline.new(parent, :quoted, attrs["text"]).convert
        %{<deprecates>#{out}</deprecates>}
      end
    end

    class DomainTermInlineMacro < Asciidoctor::Extensions::InlineMacroProcessor
      use_dsl
      named :domain
      parse_content_as :text
      using_format :short

      def process(parent, _target, attrs)
        out = Asciidoctor::Inline.new(parent, :quoted, attrs["text"]).convert
        %{<domain>#{out}</domain>}
      end
    end

    class PlantUMLBlockMacroBackend
      # https://stackoverflow.com/questions/2108727/which-in-ruby-checking-if-program-exists-in-path-from-ruby
      def self.plantuml_installed?
        cmd = "plantuml"
        exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
        ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
          exts.each do |ext|
            exe = File.join(path, "#{cmd}#{ext}")
            return exe if File.executable?(exe) && !File.directory?(exe)
          end
        end
        nil
      end

      def self.generate_file parent, reader
        src = reader.source
        reader.lines.first.sub(/\s+$/, "") != "@startuml" or
          src = "@startuml\n#{src}\n@enduml\n"
        filename = parent.document.reader.lineno
        system "mkdir -p plantuml"
        File.open("plantuml/#{filename}.pml", "w") { |f| f.write src }
        system "plantuml plantuml/#{filename}.pml"
        filename
      end

      def self.generate_attrs attrs
        through_attrs = %w(id align float title role width height alt).
          inject({}) do |memo, key|
          memo[key] = attrs[key] if attrs.has_key? key
          memo
        end
      end
    end

    class PlantUMLBlockMacro < Asciidoctor::Extensions::BlockProcessor
      use_dsl
      named :plantuml
      on_context :literal
      parse_content_as :raw

      def process(parent, reader, attrs)
        if PlantUMLBlockMacroBackend.plantuml_installed?
          filename = PlantUMLBlockMacroBackend.generate_file parent, reader
          through_attrs = PlantUMLBlockMacroBackend.generate_attrs attrs
          through_attrs["target"] = "plantuml/#{filename}.png"
          create_image_block parent, through_attrs
        else
          warn "PlantUML not installed"
          # attrs.delete(1) : remove the style attribute
          create_listing_block parent, reader.source, attrs.reject { |k, v| k == 1 }
        end
      end
    end
  end
end
