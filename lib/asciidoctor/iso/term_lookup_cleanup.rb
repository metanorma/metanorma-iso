# frozen_string_literal: true.

module Asciidoctor
  module ISO
    # Intelligent term lookup xml modifier
    # Lookup all `term` and `calause` tags and replace `termxref` tags with
    # `xref`:target tag
    class TermLookupCleanup
      AUTOMATIC_GENERATED_ID_REGEXP = /\A_/
      EXISTING_TERM_REGEXP = /\Aterm-/

      attr_reader :xmldoc, :termlookup, :log

      def initialize(xmldoc, log)
        @xmldoc = xmldoc
        @log = log
        @termlookup = {}
      end

      def call
        @termlookup = replace_automatic_generated_ids_terms
        set_termxref_tags_target
      end

      private

      def set_termxref_tags_target
        xmldoc.xpath('//termxref').each do |node|
          target = normalize_ref_id(node.text)
          if termlookup[target].nil?
            remove_missing_ref(node, target)
            next
          end

          modify_ref_node(node, target)
        end
      end

      def remove_missing_ref(node, target)
        warn(%Q(Error: Term reference in `term[#{target}]` missing: \
                "#{target}" is not defined in document.).gsub(/\s+/, ' '))
        log.add('AsciiDoc Input', node, "#{target} does not refer to a real term")
        node.next.remove
        node.previous.remove
        node.remove
      end

      def modify_ref_node(node, target)
        node.name = 'xref'
        node['target'] = termlookup[target]
        node.children.remove
        node.remove_attribute('defaultref')
      end

      def replace_automatic_generated_ids_terms
        xmldoc.xpath('//term').each.with_object({}) do |term_node, res|
          next if AUTOMATIC_GENERATED_ID_REGEXP.match(term_node['id']).nil?

          normalize_id_and_memorize(term_node, res, './preferred')
        end
      end

      def normalize_id_and_memorize(term_node, res_table, text_selector)
        term_text = normalize_ref_id(term_node.at(text_selector).text)
        term_node['id'] = unique_text_id(term_text)
        res_table[term_text] = term_node['id']
      end

      def normalize_ref_id(text)
        text.downcase.gsub(/[[:space:]]/, '-')
      end

      def unique_text_id(text)
        return "term-#{text}" if xmldoc.at("//*[@id = 'term-#{text}']").nil?

        (1..Float::INFINITY).lazy.each do |index|
          if xmldoc.at("//*[@id = 'term-#{text}-#{index}']").nil?
            break("term-#{text}-#{index}")
          end
        end
      end
    end
  end
end
