require "uuidtools"
require "asciidoctor/iso/word/utils"

module Asciidoctor
  module ISO
    module Word
      module XrefGen
          include ::Asciidoctor::ISO::Word::Utils

          @@anchors = {}

          def get_anchors
            @@anchors
          end

          def back_anchor_names(docxml)
            docxml.xpath(ns("//annex")).each_with_index do |c, i|
              annex_names(c, (65 + i).chr.to_s)
            end
            docxml.xpath(ns("//iso_ref_title")).each do |ref|
              iso_ref_names(ref)
            end
            docxml.xpath(ns("//ref")).each do |ref|
              ref_names(ref)
            end
          end

          def initial_anchor_names(d)
            introduction_names(d.at(ns("//content[title = 'Introduction']")))
            section_names(d.at(ns("//clause[title = 'Scope']")), "1", 1)
            section_names(d.at(ns("//references[title = 'Normative References']")), "2", 1)
            section_names(d.at(ns("//terms")), "3", 1)
            middle_sections = "//clause[title = 'Scope'] | //references[title = 'Normative References'] | //terms | "\
              "//symbols_abbrevs | //clause[parent::sections]"
            sequential_asset_names(d.xpath(ns(middle_sections)))
          end

          def middle_anchor_names(docxml)
            symbols_abbrevs = docxml.at(ns("//symbols_abbrevs"))
            sect_num = 4
            if symbols_abbrevs
              section_names(symbols_abbrevs, sect_num.to_s, 1)
              sect_num += 1
            end
            # docxml.xpath(ns("//middle/clause")).each_with_index do |c, i|
            q = "//clause[parent::sections][not(xmlns:title = 'Scope')]"
            docxml.xpath(ns(q)).each_with_index do |c, i|
              section_names(c, (i + sect_num).to_s, 1)
            end
          end

          # extract names for all anchors, xref and label
          def anchor_names(docxml)
            initial_anchor_names(docxml)
            middle_anchor_names(docxml)
            back_anchor_names(docxml)
          end

          def sequential_figure_names(clause)
            i = 0
            j = 0
            clause.xpath(ns(".//figure")).each do |t|
              if t.parent.name == "figure"
                j += 1
                @@anchors[t["anchor"]] = { label: "Figure #{i}-#{j}",
                                           xref: "Figure #{i}-#{j}" }
              else
                j = 0
                i += 1
                @@anchors[t["anchor"]] = { label: "Figure #{i}",
                                           xref: "Figure #{i}" }
              end
            end
          end

          def sequential_asset_names(clause)
            clause.xpath(ns(".//table")).each_with_index do |t, i|
              @@anchors[t["anchor"]] = { label: "Table #{i + 1}",
                                         xref: "Table #{i + 1}" }
            end
            sequential_figure_names(clause)
            clause.xpath(ns(".//formula")).each_with_index do |t, i|
              @@anchors[t["anchor"]] = { label: (i + 1).to_s,
                                         xref: "Formula #{i + 1}" }
            end
          end

          def hierarchical_figure_names(clause, num)
            i = 0
            j = 0
            clause.xpath(ns(".//figure")).each do |t|
              if t.parent.name == "figure"
                j += 1
                @@anchors[t["anchor"]] = { label: "Figure #{num}.#{i}-#{j}",
                                           xref: "Figure #{num}.#{i}-#{j}" }
              else
                j = 0
                i += 1
                @@anchors[t["anchor"]] = { label: "Figure #{num}.#{i}",
                                           xref: "Figure #{num}.#{i}" }
              end
            end
          end

          def hierarchical_asset_names(clause, num)
            clause.xpath(ns(".//table")).each_with_index do |t, i|
              @@anchors[t["anchor"]] = { label: "Table #{num}.#{i + 1}",
                                         xref: "Table #{num}.#{i + 1}" }
            end
            hierarchical_figure_names(clause, num)
            clause.xpath(ns(".//formula")).each_with_index do |t, i|
              @@anchors[t["anchor"]] = { label: "#{num}.#{i + 1}",
                                         xref: "Formula #{num}.#{i + 1}" }
            end
          end

          def introduction_names(clause)
            clause.xpath(ns("./clause")).each_with_index do |c, i|
              section_names(c, "0.#{i + 1}")
            end
          end

          def section_names(clause, num, level)
            @@anchors[clause["anchor"]] = { label: num, xref: "Clause #{num}",
                                            level: level }
            clause.xpath(ns("./clause | ./termdef")).each_with_index do |c, i|
              section_names1(c, "#{num}.#{i + 1}", level + 1)
            end
          end

          def section_names1(clause, num, level)
            @@anchors[clause["anchor"]] = { label: num, xref: "Clause #{num}",
                                            level: level }
            clause.xpath(ns("./clause | ./termdef")).each_with_index do |c, i|
              section_names1(c, "#{num}.#{i + 1}", level + 1)
            end
          end

          def annex_names(clause, num)
            obligation = "(Informative)"
            obligation = "(Normative)" if clause["subtype"] == "normative"
            label = "<b>Annex #{num}</b><br/>#{obligation}"
            @@anchors[clause["anchor"]] = { label: label,
                                            xref: "Annex #{num}", level: 1 }
            clause.xpath(ns("./clause")).each_with_index do |c, i|
              annex_names1(c, "#{num}.#{i + 1}", 2)
            end
            hierarchical_asset_names(clause, num)
          end

          def annex_names1(clause, num, level)
            @@anchors[clause["anchor"]] = { label: num,
                                            xref: num,
                                            level: level }
            clause.xpath(ns(".//clause")).each_with_index do |c, i|
              annex_names1(c, "#{num}.#{i + 1}", level + 1)
            end
          end

          def iso_ref_names(ref)
            isocode = ref.at(ns("./isocode"))
            isodate = ref.at(ns("./isodate"))
            reference = "ISO #{isocode.text}"
            reference += ": #{isodate.text}" if isodate
            @@anchors[ref["anchor"]] = { xref: reference }
          end

          def ref_names(ref)
            linkend = ref.text
            linkend.gsub!(/[\[\]]/, "") unless /^\[\d+\]$/.match linkend
            @@anchors[ref["anchor"]] = { xref: linkend }
          end
      end
    end
  end
end
