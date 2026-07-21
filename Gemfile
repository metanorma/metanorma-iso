source "https://rubygems.org"

gemspec

gem "canon"
# isodoc PR branch: pubid 2 migration for std_docid_semantic +
# relaton-cli 3.0.0.pre allowance (both required by the pubid-2 /
# metanorma-document 0.4.0 chain); revert to branch: "main" once
# https://github.com/metanorma/isodoc/pull/825 merges.
gem "isodoc", github: "metanorma/isodoc", branch: "rt-pubid-2-migration"
gem "metanorma", github: "metanorma/metanorma", branch: "main"
# standoc PR branch allowing isodoc 3.7; revert to branch: "main" once
# https://github.com/metanorma/metanorma-standoc/pull/1215 merges.
gem "metanorma-standoc", github: "metanorma/metanorma-standoc", branch: "rt-allow-isodoc-3.7"
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
gem "moxml", "~> 0.1.23"

eval_gemfile("Gemfile.devel") rescue nil
