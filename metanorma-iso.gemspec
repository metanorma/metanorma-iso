# coding: utf-8

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "metanorma/iso/version"

Gem::Specification.new do |spec|
  spec.name          = "metanorma-iso"
  spec.version       = Metanorma::ISO::VERSION
  spec.authors       = ["Ribose Inc."]
  spec.email         = ["open.source@ribose.com"]

  spec.summary       = "metanorma-iso lets you write ISO standards "\
                       "in AsciiDoc."
  spec.description   = <<~DESCRIPTION
    metanorma-iso lets you write ISO standards in AsciiDoc syntax.

    This gem is in active development.

    Formerly known as asciidoctor-iso.
  DESCRIPTION

  spec.homepage      = "https://github.com/metanorma/metanorma-iso"
  spec.license       = "BSD-2-Clause"

  spec.bindir        = "bin"
  spec.require_paths = ["lib"]
  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features|bin|.github)/}) \
    || f.match(%r{Rakefile|bin/rspec})
  end
  spec.test_files    = `git ls-files -- {spec}/*`.split("\n")
  spec.required_ruby_version = Gem::Requirement.new(">= 2.7.0")

  spec.add_dependency "metanorma-standoc", "~> 2.8.2"
  spec.add_dependency "mnconvert", "~> 1.14"
  spec.add_dependency "pubid-iso"
  spec.add_dependency "pubid-cen"
  spec.add_dependency "pubid-iec"
  spec.add_dependency "ruby-jing"
  spec.add_dependency "tokenizer", "~> 0.3.0"
  spec.add_dependency "twitter_cldr"

  spec.add_development_dependency "debug"
  spec.add_development_dependency "equivalent-xml", "~> 0.6"
  spec.add_development_dependency "guard", "~> 2.14"
  spec.add_development_dependency "guard-rspec", "~> 4.7"
  spec.add_development_dependency "iev", "~> 0.3.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.6"
  spec.add_development_dependency "rubocop", "~> 1.5.2"
  spec.add_development_dependency "sassc", "2.4.0"
  spec.add_development_dependency "simplecov", "~> 0.15"
  spec.add_development_dependency "timecop", "~> 0.9"
  spec.add_development_dependency "vcr", "~> 6.1.0"
  spec.add_development_dependency "webmock"
end
