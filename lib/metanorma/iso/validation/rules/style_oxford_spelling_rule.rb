# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warnings for spellings that violate the ISO House Style
        # Oxford-spelling word lists (www.iso.org/ISO-house-style.html).
        # Flat word-list checks only; each pattern names the offending
        # form and the House Style correction.
        #
        #   - -ize verbs: organise/organisation etc. -> organize
        #   - -yse verbs: analyze etc. -> analyse
        #   - -re nouns: center, fiber, liter -> centre, fibre, litre.
        #     Standalone "meter" is exempt: as a measuring instrument the
        #     spelling is identical under both conventions and the sense
        #     cannot be resolved from flat text.
        #   - -our nouns: color, favor ... -> colour, favour
        #   - -ogue nouns: catalog, dialog ... -> catalogue, dialogue
        #   - ll-doubling: canceled, labeled, traveled -> cancelled,
        #     labelled, travelled, with the enrolment/fulfilment
        #     single-l exceptions
        #   - -ence nouns: defense -> defence; licence (noun) vs license
        #     (verb) -- the noun is detected by a preceding determiner
        #   - practice (noun) vs practise (verb)
        #   - programme except computer program
        #   - Petri dish capitalized; sulfur/sulfate/sulfide (IUPAC);
        #     artefact; focused; acknowledgement; ageing; judgement
        #     (legal usage is exempt from the House Style, but the
        #     exemption cannot be detected from flat text)
        #
        # Math (<stem>) content is stripped from the extracted prose text
        # by StyleRule#prose_exclusions (technical-exception escape).
        # <sourcecode> blocks are never paragraph children, so they are
        # excluded structurally.
        class StyleOxfordSpellingRule < StyleRule
          code "ISO_107"

          policy category: "Spelling and wording > Spelling",
                 rule: "use Oxford English spelling ('-ize', '-re', '-our', '-ogue'; e.g. 'organize', 'centre', 'colour')",
                 source: :house_style, mn_category: :style

          # -ize verbs. advertise/advise/arise/comprise/compromise/
          # enterprise/exercise/franchise/revise/supervise are correct as
          # -ise in Oxford spelling and are deliberately not matched.
          IZE_SPELLING_REGEX = /
            \b(?:organis(?:ations?|ational|e|es|ed|ing)
               |recognis(?:e|es|ed|ing|able)
               |standardis(?:ations?|e|es|ed|ing)
               |harmonis(?:ations?|e|es|ed|ing)
               |realis(?:ations?|e|es|ed|ing))\b
          /xi.freeze
          YSE_SPELLING_REGEX = /
            \b(?:analyz(?:e|es|ed|ing|able|ers?)
               |paralyz(?:e|es|ed|ing)
               |catalyz(?:e|es|ed|ing)
               |hydrolyz(?:e|es|ed|ing))\b
          /xi.freeze
          RE_SPELLING_REGEX = /
            \b(?:calibers?
               |cent(?:er|ers|ered|ering)
               |fibers?
               |liters?
               |(?:centi|milli|kilo)meters?
               |specters?
               |theaters?)\b
          /xi.freeze
          OUR_SPELLING_REGEX = /
            \b(?:colors?|colored|coloring|colorants?|colorful|colorless
               |favors?|favored|favorable|favorites?
               |flavors?|flavored|flavorful
               |harbors?|harbored|harboring
               |honors?|honored|honoring
               |labors?|labored|laboring
               |neighbors?|neighboring|neighborhoods?
               |rumors?|rumored)\b
          /xi.freeze
          OGUE_SPELLING_REGEX = /
            \b(?:analogs?|catalog(?:s|ed|ing|ers?)?|dialogs?
               |monologs?|homologs?)\b
          /xi.freeze
          LL_SPELLING_REGEX = /
            \b(?:cancel(?:ed|ing)|label(?:ed|ing)|model(?:ed|ing)
               |signal(?:ed|ing)|travel(?:ed|ing|ers?)
               |enrollments?|fulfillments?)\b
          /xi.freeze
          ENCE_SPELLING_REGEX = /
            \b(?:defenses?|offenses?|pretenses?|
                (?:a|an|the|this|your|its|our|their|no|valid)\s+licenses?)\b
          /xi.freeze
          PRACTISE_REGEX = /\bpractic(?:ing|ed)\b/xi.freeze
          PROGRAMME_REGEX = /
            \b(?<!computer[ ]|Computer[ ])programs?\b
          /xi.freeze
          PETRI_DISH_REGEX = /\bpetri[ ]dish(?:es)?\b/x.freeze
          SULFUR_REGEX = /\bsulph\w*/xi.freeze

          OXFORD = {
            IZE_SPELLING_REGEX =>
              "style: '-ise' spelling (use '-ize': organize, recognize, " \
              "standardize, harmonize, realize)",
            YSE_SPELLING_REGEX =>
              "style: '-yze' spelling (use '-yse': analyse, paralyse, " \
              "catalyse, hydrolyse)",
            RE_SPELLING_REGEX =>
              "style: '-er' noun spelling (use '-re': calibre, centre, " \
              "fibre, litre, spectre, theatre)",
            OUR_SPELLING_REGEX =>
              "style: '-or' noun spelling (use '-our': colour, favour, " \
              "flavour, harbour, honour, labour, neighbour, rumour)",
            OGUE_SPELLING_REGEX =>
              "style: '-og' spelling (use '-ogue': analogue, catalogue, " \
              "dialogue, monologue, homologue)",
            LL_SPELLING_REGEX =>
              "style: single 'l' (use double 'l': cancelled, labelled, " \
              "modelled, signalled, travelled, traveller; but enrolment, " \
              "fulfilment)",
            ENCE_SPELLING_REGEX =>
              "style: '-ense' noun (use '-ence': defence, offence, " \
              "pretence; 'licence' for the noun, 'license' for the verb)",
            PRACTISE_REGEX =>
              "style: 'practicing'/'practiced' (use 'practising'/" \
              "'practised'; 'practice' is the noun, 'practise' the verb)",
            PROGRAMME_REGEX =>
              "style: 'program' (use 'programme', except 'computer program')",
            PETRI_DISH_REGEX =>
              "style: 'petri dish' (use 'Petri dish')",
            SULFUR_REGEX =>
              "style: 'sulph-' (use IUPAC spelling: sulfur, sulfate, sulfide)",
            /\bartifacts?\b/i =>
              "style: 'artifact' (use 'artefact')",
            /\bfocuss(?:ed|ing)\b/i =>
              "style: 'focussed'/'focussing' (use 'focused'/'focusing')",
            /\backnowledgments?\b/i =>
              "style: 'acknowledgment' (use 'acknowledgement')",
            /\baging\b/i =>
              "style: 'aging' (use 'ageing')",
            # Legal usage retains 'judgment'; the exemption cannot be
            # detected from flat text, so the warning names the exemption.
            /\bjudgments?\b/i =>
              "style: 'judgment' (use 'judgement'; legal usage may retain " \
              "'judgment')"
          }.freeze

          def scan_text(node, text)
            OXFORD.filter_map do |regex, label|
              next unless text.match?(regex)

              build_warning(node, label)
            end
          end
        end
      end
    end
  end
end
