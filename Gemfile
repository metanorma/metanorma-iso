source "https://rubygems.org"

gemspec
gem "metanorma-mirror", "~> 1.0", github: "metanorma/metanorma-mirror", branch: "main"
gem "relaton", "~> 3.0"

gem "canon"
gem "isodoc", "~> 3.7.4.pre.alpha" # carries the relaton-render range #846
# plugin-lutaml main carries LutamlDataPreprocessor (registered by
# standoc main's converter); released 0.7.53 does not define it yet.
gem "metanorma-plugin-lutaml", github: "metanorma/metanorma-plugin-lutaml", branch: "main"
gem "metanorma-utils", "~> 2.0" # GcBudget + the array-join table cell buffer
gem "metanorma-standoc", "~> 3.5.1.pre.alpha" # Standoc::Document split + the pubid-dispatch refs world
gem "metanorma-document", "~> 0.5.2.pre.alpha" # relaton-bib 2.2.0.pre allowance
gem "rake"
# relaton-bib 2.2.0.pre is the pubid-2-native line required by
# metanorma-document 0.4.0.
gem "rspec"
gem "rubocop"
gem "rubocop-performance"
gem "simplecov"
gem "timecop"
gem "webmock"
gem "uniword", path: "../uniword" if File.exist?(File.expand_path("../uniword/Gemfile", __dir__))
gem "lutaml-model", "~> 0.8"
# html2doc >= 1.12 is required for correct OMML math handling in Word output
# (isodoc main also pins ~> 1.12).
gem "html2doc", "~> 1.12.0"
gem "omml", "~> 0.2.6" # 0.2.6 (2026-09-08) carries the moxml-0.5 range (plurimath/omml#11)

eval_gemfile("Gemfile.devel") rescue nil
