# frozen_string_literal: true

module Metanorma
  module Iso::Document
    module Terms
      autoload :IsoTermCollection,
               "#{__dir__}/terms/iso_term_collection"
      autoload :IsoTerm, "#{__dir__}/terms/iso_term"
      autoload :TermDesignation, "#{__dir__}/terms/term_designation"
      autoload :TermDomainElement, "#{__dir__}/terms/term_domain_element"
      autoload :TermExpression, "#{__dir__}/terms/term_expression"
      autoload :TermDefinition, "#{__dir__}/terms/term_definition"
      autoload :VerbalDefinition, "#{__dir__}/terms/verbal_definition"
      autoload :TermSource, "#{__dir__}/terms/term_source"
      autoload :TermsourceElement, "#{__dir__}/terms/term_source"
      autoload :TermOrigin, "#{__dir__}/terms/term_origin"
      autoload :TermNote, "#{__dir__}/terms/term_note"
      autoload :TermExample, "#{__dir__}/terms/term_example"
    end
  end
end
