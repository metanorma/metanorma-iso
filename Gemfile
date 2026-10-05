source "https://rubygems.org"

gemspec
gem "metanorma-mirror", "~> 1.0"
# The family prerelease the CitationStyle port targets; the floor pin
# names it for resolution (isodoc's range alone is prerelease-blind).
gem "relaton", "~> 3.0.0.pre.alpha.11"

gem "canon"
# isodoc main carries the relaton-render >= 1.3.0, < 1.5.0 range (#846)
# that the relaton 3 prerelease chain co-resolves with; the released
# 3.7.3 still pins ~> 1.3.0 and conflicts. Revert to the gem once an
# isodoc release carries #846.
gem "isodoc", github: "metanorma/isodoc", branch: "main"
# plugin-lutaml main carries LutamlDataPreprocessor (registered by
# standoc main's converter); released 0.7.53 does not define it yet.
gem "metanorma-plugin-lutaml", github: "metanorma/metanorma-plugin-lutaml", branch: "main"
# standoc main carries the Metanorma::Standoc::Document split and the
# pubid-dispatch refs world (1251/1252/1267/1268); the released 3.5.0
# gem does not define Standoc::Document yet. Revert to the gem once a
# standoc release carries it.
gem "metanorma-standoc", github: "metanorma/metanorma-standoc", branch: "main"# metanorma-document main carries the relaton-bib 2.2.0.pre allowance;
# the released 0.5.1 does not yet, so the pin stays until that release.
gem "metanorma-document", github: "metanorma/metanorma-document", branch: "main"
gem "rake"
# relaton-bib 2.2.0.pre is the pubid-2-native line required by
# metanorma-document 0.4.0.
gem "relaton-bib", "~> 2.2.0.pre.alpha.1"
gem "rspec"
gem "rubocop"
gem "rubocop-performance"
gem "simplecov"
gem "timecop"
gem "webmock"
gem "uniword", path: "../uniword" if File.exist?(File.expand_path("../uniword/Gemfile", __dir__))
gem "lutaml-model", path: "../../lutaml/lutaml-model" if File.exist?(File.expand_path("../../lutaml/lutaml-model/Gemfile", __dir__))
# html2doc >= 1.12 is required for correct OMML math handling in Word output
# (isodoc main also pins ~> 1.12).
gem "html2doc", "~> 1.12.0"
gem "moxml", "~> 0.5" # leptris wave (metanorma-document#60)
gem "omml", "~> 0.2.6" # 0.2.6 (2026-09-08) carries the moxml-0.5 range (plurimath/omml#11)

eval_gemfile("Gemfile.devel") rescue nil
