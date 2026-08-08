module Metanorma
  module Iso
    class Validate < Standoc::Validate
      # ISO_46/47/48 see-xrefs migrated to SeeXrefsRule (TODO 24).
      # ISO_50/51 term-xrefs migrated to TermXrefsRule (TODO 26).
      # ISO_21/22 unreferenced assets migrated to UnreferencedAssetsRule (TODO 23).
      # ISO_49 locality erefs migrated to LocalityErefsRule (TODO 25).

      def iso_xref_validate(_doc)
        # All xref rules migrated to Layer 3.
      end

      def xrefs_mandate_validate(_doc); end
      def xrefs_mandate_validate1(*); end
      def locality_erefs_validate(_root); end
      def see_xrefs_validate(_root); end
      def see_erefs_validate(_root); end
      def term_xrefs_validate(_xmldoc); end
      def term_xrefs_validate1(*); end
      def extract_anchor_norm(_root); {}; end
      def extract_bibitem_anchors(_root); {}; end
    end
  end
end
