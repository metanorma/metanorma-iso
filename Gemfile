source "https://rubygems.org"

gemspec
gem "metanorma-mirror", "~> 1.0"
gem "relaton", "~> 3.0"

gem "canon"
gem "isodoc", "~> 3.7.9" # carries the relaton-render range #846
gem "metanorma-plugin-lutaml", "~> 0.7"
gem "metanorma-utils", "~> 2.0" # GcBudget + the array-join table cell buffer
# Declarative rules backend, pending release of Standoc PR #1408 (stacked on #1398).
gem "metanorma-standoc", git: "https://github.com/metanorma/metanorma-standoc.git",
    ref: "0238ae06847d8754186d4ed8db10fa4bc0128036"
gem "metanorma-core", git: "https://github.com/metanorma/metanorma-core.git",
    ref: "231ea6e236a6ccb199ff236df675b6a1edc0240a"
gem "metanorma-taste", git: "https://github.com/metanorma/metanorma-taste.git",
    ref: "d0c26613f78bf44fb10c07290b38b7e87aeaf544"
gem "metanorma-document", git: "https://github.com/metanorma/metanorma-document.git",
    ref: "3911acbb4ce9d8497a94579610a42d663b8a78cd"
# Native presentation integration uses the shared LADL profile and typed adapter.
# Runtime callers inject their labeler; the ISO gem adds no engine dependency.
gem "metanorma-ladl", git: "https://github.com/metanorma/metanorma-ladl.git",
    ref: "361b29106e7dd7ffa753e0e35b097cd0cbf622f5"
gem "amath", "= 0.2.0"
gem "bigdecimal", "= 3.3.1"
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
gem "lutaml-model", "~> 0.8"
# html2doc >= 1.12 is required for correct OMML math handling in Word output
# (isodoc main also pins ~> 1.12).
gem "html2doc", "~> 1.12.0"
gem "omml", "~> 0.2.11" # 0.2.7+ carries the moxml-0.6 range (omml => moxml ~> 0.6.1)

eval_gemfile("Gemfile.devel") rescue nil
