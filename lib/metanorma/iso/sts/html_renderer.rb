# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      # HTML rendering for OIML STS XML (Liquid-based; see
      # html_renderer/ruby.rb).
      module HtmlRenderer
        autoload :Ruby, "#{__dir__}/html_renderer/ruby"

        module_function

        def render(sts_xml, **)
          Ruby.new.render(sts_xml, **)
        end
      end
    end
  end
end
