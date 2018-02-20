require "asciidoctor/iso/utils"
require_relative "./validate_style.rb"
require_relative "./validate_requirements.rb"
require_relative "./validate_section.rb"
require "nokogiri"
require "jing"
require "pp"

module Asciidoctor
  module ISO
    module Validate
      def title_intro_validate(root)
        title_intro_en = root.at("//title-intro[@language='en']")
        title_intro_fr = root.at("//title-intro[@language='fr']")
        if title_intro_en.nil? && !title_intro_fr.nil?
          warn "No English Title Intro!"
        end
        if !title_intro_en.nil? && title_intro_fr.nil?
          warn "No French Title Intro!"
        end
      end

      def title_part_validate(root)
        title_part_en = root.at("//title-part[@language='en']")
        title_part_fr = root.at("//title-part[@language='fr']")
        (title_part_en.nil? && !title_part_fr.nil?) &&
          warn("No English Title Part!")
        (!title_part_en.nil? && title_part_fr.nil?) &&
          warn("No French Title Part!")
        subpart = root.at("//bibdata/docidentifier/project-number[@subpart]")
        iec = root.at("//bibdata/contributor[xmlns:role/@type = 'publisher']/"\
                      "organization[name = 'IEC']")
        warn("Subpart defined on non-IEC document!") if subpart && !iec
      end

      def title_names_type_validate(root)
        doctypes = /International\sStandard | Technical\sSpecification |
        Publicly\sAvailable\sSpecification | Technical\sReport | Guide /xi
        title_main_en = root.at("//title-main[@language='en']")
        if doctypes.match? title_main_en.text
          warn "Main Title may name document type"
        end
        title_intro_en = root.at("//title-intro[@language='en']")
        if !title_intro_en.nil? && doctypes.match?(title_intro_en.text)
          warn "Part Title may name document type"
        end
      end

      def title_first_level_validate(root)
        root.xpath(SECTIONS_XPATH).each do |s|
          title = s.at("./title").text
          s.xpath("./subsection | ./terms").each do |ss|
            subtitle = ss.at("./title") 
            !subtitle&.text&.empty? ||
              warn("#{title}: each first-level subclause must have a title")
          end
        end
      end

      def title_all_siblings(xpath, label)
        notitle = false
        withtitle = false
        xpath.each do |s|
          sublabel = s&.at("./title")&.text || s["id"]
          title_all_siblings(s.xpath("./subsection | ./terms"), sublabel)
          subtitle = s.at("./title")
          notitle = true if !subtitle || subtitle.text.empty?
          withtitle = true if !subtitle&.text&.empty?
        end
        if notitle && withtitle
          warn("#{label}: all subclauses must have a title, or none")
        end
      end

      def title_validate(root)
        title_intro_validate(root)
        title_part_validate(root)
        title_names_type_validate(root)
        title_first_level_validate(root)
        title_all_siblings(root.xpath(SECTIONS_XPATH), "(top level)")
      end

      def onlychild_clause_validate(root)
        q = "//subsection"
        root.xpath(q).each do |c|
          next unless c.xpath("../subsection").size == 1
          title = c.at("./title")
          location = c["id"] || c.text[0..60] + "..."
          location += ":#{title.text}" if c["id"] && !title.nil?
          warn "ISO style: #{location}: subsection is only child"
        end
      end

      def iso8601_validate(root)
        root.xpath("//review/@date | //revision-date").each do |d|
          /^\d{8}(T\d{4,6})?$/.match? d.text or
            warn "ISO style: #{d.text} is not an ISO 8601 date"
        end
      end

      def isosubgroup_validate(root)
        root.xpath("//technical-committee/@type").each do |t|
          unless %w{TC PC JTC JPC}.include? t.text
            warn "ISO: invalid technical committee type #{t}"
          end
        end
        root.xpath("//subcommittee/@type").each do |t|
          unless %w{SC JSC}.include? t.text
            warn "ISO: invalid subcommittee type #{t}"
          end
        end
      end

      def normative_target(target)
        return target.at("./ancestor::*[@normstatus = 'normative']") ||
          target.at("./ancestor::references[title = 'Normative References']")
      end

      def see_xrefs_validate(root)
        root.xpath("//xref").each do |t|
          # does not deal with preceding text marked up
          preceding_text = t.at("./preceding-sibling::text()[last()]")
          next unless !preceding_text.nil? && /\bsee\s*$/mi.match?(preceding_text)
          target = root.at("//*[@id = '#{t['target']}']")
          if normative_target(target)
            warn "ISO: 'see #{t.to_s}' is pointing to a normative reference"
          end
        end
      end

      def content_validate(doc)
        title_validate(doc.root)
        isosubgroup_validate(doc.root)
        section_validate(doc)
        iso8601_validate(doc.root)
        onlychild_clause_validate(doc.root)
        see_xrefs_validate(doc.root)
      end

      def schema_validate(doc, filename)
        File.open(".tmp.xml", "w") { |f| f.write(doc.to_xml) }
        begin
          errors = Jing.new(filename).validate(".tmp.xml")
        rescue Jing::Error => e
          abort "what what what #{e}"
        end
        warn "Valid!" if errors.none?
        errors.each do |error|
          warn "#{error[:message]} @ #{error[:line]}:#{error[:column]}"
        end
      end

      # RelaxNG cannot cope well with wildcard attributes. So we strip
      # any attributes from FormattedString instances (which can contain
      # xs:any markup, and are signalled with @format) before validation.
      def formattedstr_strip(doc)
        doc.xpath("//*[@format]").each do |n|
          n.elements.each do |e|
            e.traverse do |e1|
              next unless e1.element?
              e1.each { |k, v| e.delete(k) }
            end
          end
        end
        doc
      end

      def validate(doc)
        content_validate(doc)
        schema_validate(formattedstr_strip(doc.dup), 
                        File.join(File.dirname(__FILE__), "isostandard.rng"))
      end
    end
  end
end
