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
                      .merge(existing_terms)
        set_termxref_tags_target
      end

      private

      def set_termxref_tags_target
        xmldoc.xpath('//termxref').each do |node|
          target = node.text
          # require 'byebug'
          # byebug
          if termlookup[target].nil?
            log.add("AsciiDoc Input",
                    node,
                    "#{target} does not refer to a real term")
            next
          end

          node.name = 'xref'
          node['target'] = termlookup[target]
          # Support for automatic clause numbering, delete text from xref
          if node['defaultref']
            node.children.remove
            node.remove_attribute('defaultref')
          end
        end
      end

      def existing_terms
        xmldoc.xpath('//clause').each.with_object({}) do |term_node, res|
          next if term_node['id'].match(EXISTING_TERM_REGEXP).nil?

          res[term_node.at('./title').text] = term_node['id']
        end
      end

      def replace_automatic_generated_ids_terms
        xmldoc.xpath('//term').each.with_object({}) do |term_node, res|
          # require 'byebug'
          # byebug
          next if AUTOMATIC_GENERATED_ID_REGEXP.match(term_node['id']).nil?

          term_text = term_node.at('./preferred').text
          term_node['id'] = unique_text_id(term_text)
          res[term_text] = term_node['id']
        end
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