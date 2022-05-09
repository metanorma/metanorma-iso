require "relaton-render"

module Relaton
  module Render
    module Iso
      class General < ::Relaton::Render::IsoDoc::General
        def config_loc
          YAML.load_file(File.join(File.dirname(__FILE__), "config.yml"))
        end
      end
    end
  end
end
