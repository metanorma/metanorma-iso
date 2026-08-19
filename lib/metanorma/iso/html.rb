# frozen_string_literal: true

require "metanorma/html"

module Metanorma
  module Iso
    # HTML format adapter slice for the ISO flavor: the renderer,
    # registered with the harness from iso/document.rb.
    module Html
      autoload :Renderer, "#{__dir__}/html/renderer"
    end
  end
end
