# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      class Transformer::AppContentAdapter
        # The block dispatcher addresses its targets with Section-shaped
        # setters (Section is the dispatch contract: paragraphs, def_list,
        # disp_formula, …). An annex body dispatches straight into an
        # Sts::NisoSts::App, whose attribute set is narrower and names
        # paragraphs +paragraph+: this adapter translates the supported
        # setters onto the App builder and rejects the unsupported ones
        # loudly instead of silently dropping annex content.
        def initialize(app)
          @app = app
        end

        def paragraphs(model)
          @app.paragraph model
        end

        def list(model)
          @app.list model
        end

        def table_wrap(model)
          @app.table_wrap model
        end

        def fig(model)
          @app.fig model
        end

        def non_normative_note(model)
          @app.non_normative_note model
        end

        def non_normative_example(model)
          @app.non_normative_example model
        end

        def preformat(model)
          @app.preformat model
        end

        def boxed_text(model)
          @app.boxed_text model
        end

        def graphic(model)
          @app.graphic model
        end

        def sec(model)
          @app.sec model
        end

        def ref_list(model)
          @app.ref_list model
        end

        # Sts::NisoSts::App maps no def-list, disp-formula, disp-quote or
        # term-sec element; raising keeps annex content loss visible at
        # the transform site instead of emitting a silently incomplete
        # document.
        def def_list(_model)
          raise_unsupported("def-list")
        end

        def disp_formula(_model)
          raise_unsupported("disp-formula")
        end

        def disp_quote(_model)
          raise_unsupported("disp-quote")
        end

        def term_sec(_model)
          raise_unsupported("term-sec")
        end

        private

        def raise_unsupported(element)
          raise ArgumentError,
                "Sts::NisoSts::App has no #{element} mapping: cannot " \
                "place annex content in the <app> element"
        end
      end
    end
  end
end
