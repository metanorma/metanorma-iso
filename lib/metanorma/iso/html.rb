# frozen_string_literal: true

require "metanorma/html"

module Metanorma
  module Iso
    # HTML format adapter slice for the ISO flavor: the renderer,
    # registered with the harness from iso/document.rb.
    module Html
      autoload :Renderer, "#{__dir__}/html/renderer"

      # The ISO flavor owns its presentation theme: register it so
      # metanorma-document resolves Theme.load(:iso) to this gem's copy.
      Metanorma::Html::Theme.register_themes_dir(
        File.expand_path("themes", __dir__),
      )
    end
  end
end
