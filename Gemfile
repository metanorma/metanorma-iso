source "https://rubygems.org"

gemspec

gem "canon"
# isodoc PR branch: pubid 2 migration for std_docid_semantic +
# relaton-cli 3.0.0.pre allowance (both required by the pubid-2 /
# metanorma-document 0.4.0 chain); revert to branch: "main" once
# https://github.com/metanorma/isodoc/pull/825 merges.
gem "isodoc", github: "metanorma/isodoc", branch: "main" # merged as isodoc#825; audit chain
gem "metanorma", github: "metanorma/metanorma", branch: "main"
# TEMPORARY cross-PR pin for the flavor-table restructure (metanorma-core#18)
gem "metanorma-core", github: "metanorma/metanorma-core", branch: "feat/flavor-table"
# standoc PR branch allowing isodoc 3.7; revert to branch: "main" once
# https://github.com/metanorma/metanorma-standoc/pull/1215 merges.
# TEMPORARY: pointing to feat/move-standard-document for the namespace
# rename (Metanorma::Standoc::Document). Revert to main once PR
# https://github.com/metanorma/metanorma-standoc/pull/1232 merges.
gem "metanorma-standoc", github: "metanorma/metanorma-standoc", branch: "feat/term-grammar-coverage" # TEMPORARY: stacked chain (1251+1252) for the audit; revert per PR notes on merge
# TEMPORARY: pointing to feat/model-validation-l1-declarations for the
# model extensions (SubElement recursive, StandardReferencesSection nested).
# Revert to main once PR
# https://github.com/metanorma/metanorma-document/pull/45 merges.
# TEMPORARY: full audit chain — flip to main on PR merges
gem "metanorma-document", github: "metanorma/metanorma-document", branch: "feat/render-new-vocabulary"
gem "metanorma-mirror", github: "metanorma/metanorma-mirror", branch: "feat/svgmap-imagemap-handlers"
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
gem "omml", github: "plurimath/omml", branch: "moxml-0.5-range" # TEMPORARY: plurimath/omml#11; flip on release
# pubid main is required for undated-reference parsing (pubid/pubid#138)
# and the SupplementIdentifier base rename (b23a084f, 1aae4e68); revert
# to the released gem once 2.0.0.pre.alpha.9 ships.
gem "pubid", github: "pubid/pubid", branch: "main"

eval_gemfile("Gemfile.devel") rescue nil
