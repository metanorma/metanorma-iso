module Metanorma
  module Iso
    # Canonical "is this node published by ISO / IEC?" check, shared across the
    # metanorma-converter layer (bare xpath) and the isodoc layer (namespaced
    # xpath). Pass the converter's #ns as the `ns:` resolver in the isodoc layer;
    # the default identity resolver is correct for the un-namespaced Semantic XML
    # of the cleanup layer. Deliberately NOT pub_class, which is sort-oriented and
    # overridden per flavour.
    module PublisherIdentity
      PUBLISHER = "./contributor[role/@type = 'publisher']/organization".freeze
      ISO_NAME = "International Organization for Standardization".freeze
      IEC_NAME = "International Electrotechnical Commission".freeze
      IDENTITY_NS = ->(xpath) { xpath }

      module_function

      def iso_publisher?(node, ns: IDENTITY_NS)
        publisher_match?(node, ns, "ISO", ISO_NAME)
      end

      def iec_publisher?(node, ns: IDENTITY_NS)
        publisher_match?(node, ns, "IEC", IEC_NAME)
      end

      def iso_iec_publisher?(node, ns: IDENTITY_NS)
        iso_publisher?(node, ns: ns) || iec_publisher?(node, ns: ns)
      end

      def publisher_match?(node, ns, abbr, name)
        node or return false
        !!(node.at(ns.call("#{PUBLISHER}[abbreviation = '#{abbr}']")) ||
           node.at(ns.call("#{PUBLISHER}[name = '#{name}']")))
      end
    end
  end
end
