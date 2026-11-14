source "https://rubygems.org"

gemspec
gem "metanorma-mirror", "~> 1.0"
gem "relaton", "~> 3.0"

gem "canon"
gem "isodoc", "~> 3.7.9" # carries the relaton-render range #846
gem "metanorma-plugin-lutaml", "~> 0.7"
gem "metanorma-utils", "~> 2.0" # GcBudget + the array-join table cell buffer
gem "metanorma-standoc", "~> 3.5.7" # Standoc::Document split + the pubid-dispatch refs world
gem "metanorma-document", "~> 0.5.3" # relaton 3.1 line; relaton-bib retired
gem "rake"
# relaton-bib is retired; its successors ship in the relaton 3.1 line.
gem "rspec"
gem "rubocop"
gem "rubocop-performance"
gem "rubocop-rspec"
gem "rubocop-rake"
gem "simplecov"
gem "timecop"
gem "webmock"
gem "uniword", path: "../uniword" if File.exist?(File.expand_path("../uniword/Gemfile", __dir__))
gem "lutaml-model", "~> 0.8"
# html2doc >= 1.12 is required for correct OMML math handling in Word output
# (isodoc main also pins ~> 1.12).
gem "html2doc", "~> 1.12.0"
gem "omml", "~> 0.2.11" # 0.2.7+ carries the moxml-0.6 range (omml => moxml ~> 0.6.1)

eval_gemfile("Gemfile.devel") rescue nil
