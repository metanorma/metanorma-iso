# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      # HTML rendering for ISO STS XML (Liquid-templated; see
      # html_renderer/ruby.rb).
      module HtmlRenderer
        autoload :Ruby, "#{__dir__}/html_renderer/ruby"

        module_function

        def render(model_or_xml, **opts)
          Ruby.new.render(model_or_xml, **opts)
        end
      end
    end
  end
end
