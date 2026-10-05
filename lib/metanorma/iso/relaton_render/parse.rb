module Relaton
  module Render
    module Iso
      class Parse < ::Relaton::Render::Parse
        def simple_or_host_xml2hash(doc, host)
          ret = super
          ret.merge(home_standard: home_standard(doc, ret[:publisher_raw]))
        end

        def home_standard(_doc, pubs)
          pubs&.any? do |r|
            ["International Organization for Standardization", "ISO",
             "International Electrotechnical Commission", "IEC"]
              .include?(r[:nonpersonal])
          end
        end
      end
    end
  end
end
