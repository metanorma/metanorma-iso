module Metanorma
  class Requirements
    class Modspec
      # Don't want to inherit from Metanorma::Requirements::Modspec
      class Iso < ::Metanorma::Requirements::Modspec
        def initialize(options)
          super
          @test1 = "BYZ"
        end

        def test1
          "XYZ"
        end

        def recommend_title(node, out)
          label = node.at(ns("./identifier")) or return
          out.add_child("<tr><td>#{@labels['modspec']['identifier']}</td>"\
                        "<td><tt>#{label.children.to_xml}</tt></td>")
        end
      end
    end
  end
end
