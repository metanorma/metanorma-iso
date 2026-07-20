# frozen_string_literal: true

module Metanorma
  module IsoDocument
    module Sections
      autoload :IsoAbstractSection, "#{__dir__}/sections/iso_abstract_section"
      autoload :IsoAmendmentClause, "#{__dir__}/sections/iso_amendment_clause"
      autoload :IsoAnnexSection, "#{__dir__}/sections/iso_annex_section"
      autoload :IsoClauseSection, "#{__dir__}/sections/iso_clause_section"
      autoload :IsoForewordSection, "#{__dir__}/sections/iso_foreword_section"
      autoload :IsoPreface, "#{__dir__}/sections/iso_preface"
      autoload :IsoSections, "#{__dir__}/sections/iso_sections"
      autoload :IsoTermsSection, "#{__dir__}/sections/iso_terms_section"
      autoload :Colophon, "#{__dir__}/sections/colophon"
    end
  end
end
