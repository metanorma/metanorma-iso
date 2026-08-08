require "metanorma-standoc"

module Metanorma
  module Iso
    class Validate < Standoc::Validate
      # ISO_10/11/12/13/14/15 title bilingual pairing: migrated to
      # TitlePairingRule (TODO 11).
      # ISO_16 subpart IEC: migrated to SubpartIecRule (TODO 12).
      # ISO_17/18 title names doctype: migrated to TitleNamesDoctypeRule (TODO 13).
      # ISO_19 title first level: migrated to TitleFirstLevelRule (TODO 14).
      # ISO_20 title siblings consistency: migrated to
      # TitleSiblingsConsistencyRule (TODO 14).

      # https://www.iso.org/ISO-house-style.html#iso-hs-s-text-r-p-full
      def title_no_full_stop_validate(root)
        root.xpath("//preface//title | //sections//title | //annex//title | " \
                   "//references/title | //preface//name | //sections//name | " \
                   "//annex//name").each do |t|
          style_regex(/\A(?<num>.+\.\Z)/i,
                      "No full stop at end of title or caption",
                      t, t.text.strip)
        end
      end

      def title_validate(root)
        title_no_full_stop_validate(root)
      end
    end
  end
end
