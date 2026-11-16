# frozen_string_literal: true

require "metanorma/document"
require "metanorma/iso/document"

module Metanorma
  module Iso
    module Sts
      module Transformer
        class SourceDocument
          attr_reader :typed_root

          def self.parse(input)
            xml_string = input.class.method_defined?(:read) ? input.read : input.to_s
            typed = Metanorma::Iso::Document::Root.from_xml(xml_string)
            new(typed)
          end

          # Reader entry point for the metanorma-core document_transformers
          # contract (+reader.from_xml(String) -> model+); an alias of {.parse}.
          def self.from_xml(input)
            parse(input)
          end

          def initialize(typed_root)
            @typed_root = typed_root
          end

          def bibdata
            typed_root.bibdata
          end

          def language
            return "en" unless bibdata
            langs = bibdata.language rescue nil
            return "en" unless langs
            lang = langs.is_a?(Array) ? langs.first : langs
            val = lang.is_a?(String) ? lang : lang.value.to_s
            val.strip.match?(/\A[a-z]{2}(-[A-Z]{2})?\z/) ? val.strip : "en"
          end

          def docidentifier
            return nil unless bibdata
            ids = bibdata.doc_identifier rescue nil
            return nil unless ids
            Array(ids).each do |id_obj|
              next if id_obj.type
              return text_of(id_obj)
            end
            text_of(Array(ids).first)
          end

          def text_of(obj)
            return obj.to_s if obj.is_a?(String)
            return "" unless obj
            val = (obj.value rescue nil) || (obj.content rescue nil)
            return "" unless val
            Array(val).map { |v| v.is_a?(String) ? v : text_of(v) }.join.strip
          end

          def title(type: nil)
            return nil unless bibdata
            titles = bibdata.titles rescue nil
            return nil unless titles
            titles = Array(titles)
            t = titles.find { |x| type.nil? || (x.type == type rescue false) } || titles.first
            text_of(t)
          end

          def formatted_title
            return title unless bibdata
            # The composed model #title can raise on documents whose front
            # lacks the title structure it expects; fall back to the
            # generic wrapper title rather than failing the transform.
            iso_title = (bibdata.title rescue nil)
            return title unless iso_title
            main = abstract_title_value(iso_title.title_main)
            part_prefix = abstract_title_value(iso_title.title_part_prefix)
            part = abstract_title_value(iso_title.title_part)
            segments = [main]
            if part_prefix && !part_prefix.empty?
              segments << (part && !part.empty? ? "#{part_prefix}:#{part}" : part_prefix)
            elsif part && !part.empty?
              segments << part
            end
            segments.reject! { |s| s.nil? || s.empty? }
            return title if segments.empty?
            segments.join(" — ")
          end

          def abstract_title_value(abstract)
            return nil if abstract.nil?
            val = abstract.value rescue nil
            val.nil? ? nil : val.to_s.strip
          end

          def copyright_year
            return nil unless bibdata
            cps = bibdata.copyright rescue nil
            return nil unless cps
            cp = Array(cps).first
            return nil unless cp
            from = cp.from rescue nil
            return text_of(from) unless from.nil?
            nil
          end

          def copyright_holder
            return nil unless bibdata
            cps = bibdata.copyright rescue nil
            return nil unless cps
            cp = Array(cps).first
            return nil unless cp
            owner = cp.owner rescue nil
            return nil unless owner
            org = Array(owner.organization).first rescue nil
            return nil unless org
            text_of(org.name) rescue nil
          end

          def publisher
            copyright_holder
          end

          def pub_date
            copyright_year
          end

          def foreword
            typed_root.preface&.foreword
          end

          def introduction
            typed_root.preface&.introduction
          end

          # Top-level sections of every kind — <clause>, <terms>,
          # <definitions>, <references> (normative references) — in
          # document order. The XML's physical order differs (references
          # trails the clauses); displayorder carries the intended one.
          SECTION_COLLECTIONS = %i[clause terms definitions references].freeze

          def sections
            secs = typed_root.sections
            return [] unless secs

            SECTION_COLLECTIONS.flat_map { |attr| Array(secs.public_send(attr)) }
              .sort_by do |s|
                s.class.method_defined?(:displayorder) && s.displayorder ? s.displayorder : Float::INFINITY
              end
          end

          def annexes
            Array(typed_root.annex)
          end

          def bibliography
            bib = typed_root.bibliography
            return [] unless bib
            Array(bib.references)
          end

          def front?
            !foreword.nil? || !introduction.nil?
          end

          def has_metadata?
            !docidentifier.nil?
          end

          def has_back?
            annexes.any? || bibliography.any?
          end

          def term_autonum_for(term_id)
            @term_autonum_cache ||= build_term_autonum_cache
            @term_autonum_cache[term_id]
          end

          private

          def build_term_autonum_cache
            cache = {}
            walk_for_terms(typed_root) do |term|
              next unless term.is_a?(Metanorma::IsoDocument::Terms::IsoTerm)
              autonum = extract_term_autonum(term)
              next unless autonum && !autonum.empty?
              cache[term.id] = autonum if term.id
              anchor = term.anchor if term.class.method_defined?(:anchor)
              cache[anchor] = autonum if anchor && !cache.key?(anchor)
            end
            cache
          end

          def walk_for_terms(node, seen = {}, &blk)
            return unless node.is_a?(Object) && !node.is_a?(String)
            return if seen[node.object_id]
            seen[node.object_id] = true
            blk.call(node)
            attrs = node.class.instance_variable_get(:@attributes) rescue nil
            return unless attrs
            attrs.each do |name, _|
              next unless node.class.method_defined?(name)
              val = node.public_send(name) rescue next
              next if val.nil?
              Array(val).each { |v| walk_for_terms(v, seen, &blk) if v.is_a?(Object) && !v.is_a?(String) && !v.is_a?(Array) }
            end
          end

          def extract_term_autonum(term)
            label_arr = Array(term.fmt_xref_label)
            label = label_arr.first
            return nil unless label
            return nil unless label.class.method_defined?(:each_mixed_content)
            parts = []
            label.each_mixed_content do |n|
              if n.is_a?(String) && !n.strip.empty?
                parts << n.strip
              else
                cn = n.class.name.split("::").last
                txt = semx_text(n) if cn == "SemxElement"
                txt = span_text(n) if cn == "SpanElement"
                parts << txt if txt && !txt.empty?
              end
            end
            parts.join.strip
          end

          def semx_text(semx)
            return "" unless semx.class.method_defined?(:each_mixed_content)
            parts = []
            semx.each_mixed_content { |n| parts << n if n.is_a?(String) }
            parts.join
          end

          def span_text(span)
            return "" unless span.class.method_defined?(:each_mixed_content)
            parts = []
            span.each_mixed_content { |n| parts << n if n.is_a?(String) }
            parts.join
          end
        end
      end
    end
  end
end
