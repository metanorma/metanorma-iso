require_relative "init"
require "isodoc"

module IsoDoc
  module Iso

    # A {Converter} implementation that generates HTML output, and a document
    # schema encapsulation of the document for validation
    #
    class PresentationXMLConvert < IsoDoc::PresentationXMLConvert
      def initialize(options)
        super
      end

      def xref_init(lang, script, klass, labels, options)
        @xrefs = Xref.new(lang, script, klass, labels, options)
      end

      def figure1(f)
        return if labelled_ancestor(f) && f.ancestors("figure").empty?
        lbl = @xrefs.anchor(f['id'], :label, false) or return
        figname = f.parent.name == "figure" ? "" : "#{@figure_lbl} "
        prefix_name(f, "&nbsp;&mdash; ", l10n("#{figname}#{lbl}"), "name")
      end

      def example1(f)
        n = @xrefs.get[f["id"]]
        lbl = (n.nil? || n[:label].nil? || n[:label].empty?) ? @example_lbl :
          l10n("#{@example_lbl} #{n[:label]}")
        prefix_name(f, "&nbsp;&mdash; ", lbl, "name")
      end

      include Init
    end
  end
end
