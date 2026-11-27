source "https://rubygems.org"

gemspec
gem "metanorma-mirror", "~> 1.0"
gem "relaton", "~> 3.0"

gem "canon"
gem "isodoc", "~> 3.7.9" # carries the relaton-render range #846
gem "metanorma-plugin-lutaml", "~> 0.7"
gem "metanorma-utils", "~> 2.0" # GcBudget + the array-join table cell buffer
gem "metanorma-standoc", "~> 3.5.7" # Standoc::Document split + the pubid-dispatch refs world
# Dev pin: golden capture and the engine-delegation parity runs execute
# against the released engine (metanorma-document#165); the gemspec
# floor is raised in the engine-delegation wave.
# Dev-resolution pin: leptris 1.9.447 changes serialization bytes the STS goldens pin (drift isolated 2026-11-27); revisit when the goldens are re-baselined against 1.9.447+
gem "leptris", "1.9.441.0"
gem "metanorma-document", "~> 0.5.15"
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
gem "lutaml-model", "0.8.185" # drift pin: 0.8.187 serialization changes break the STS goldens (2026-11-27); revisit with a golden re-baseline
# html2doc >= 1.12 is required for correct OMML math handling in Word output
# (isodoc main also pins ~> 1.12).
gem "html2doc", "~> 1.12.0"
gem "omml", "~> 0.2.11" # 0.2.7+ carries the moxml-0.6 range (omml => moxml ~> 0.6.1)

eval_gemfile("Gemfile.devel") rescue nil
