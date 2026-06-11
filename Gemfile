source "https://rubygems.org"

gemspec

gem "canon"
gem "isodoc", github: "metanorma/isodoc", branch: "main"
gem "metanorma", github: "metanorma/metanorma", branch: "main"
gem "metanorma-standoc", github: "metanorma/metanorma-standoc", branch: "main"
gem "rake"
gem "relaton-bib", "~>2.1"
gem "rspec"
gem "rubocop"
gem "rubocop-performance"
gem "simplecov"
gem "timecop"
gem "webmock"
gem "uniword", path: "../uniword" if File.exist?(File.expand_path("../uniword/Gemfile", __dir__))
gem "lutaml-model", path: "../../lutaml/lutaml-model" if File.exist?(File.expand_path("../../lutaml/lutaml-model/Gemfile", __dir__))
gem "moxml", "~> 0.1.23"

eval_gemfile("Gemfile.devel") rescue nil
