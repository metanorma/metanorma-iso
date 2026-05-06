# frozen_string_literal: true

require "metanorma/document"
require "metanorma/iso_document"
require "sts"

module Metanorma
  module Iso
    module Sts
      autoload :Transformer, "#{__dir__}/sts/transformer"
    end
  end
end
