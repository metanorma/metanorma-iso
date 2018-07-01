# coding: utf-8

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "asciidoctor/iso/version"

Gem::Specification.new do |spec|
  spec.name          = "asciidoctor-iso"
  spec.version       = Asciidoctor::ISO::VERSION
  spec.authors       = ["Ribose Inc."]
  spec.email         = ["open.source@ribose.com"]

  spec.summary       = "asciidoctor-iso lets you write ISO standards "\
    "in AsciiDoc."
  spec.description   = <<~DESCRIPTION
    asciidoctor-iso lets you write ISO standards in AsciiDoc syntax.

    This gem is in active development.
  DESCRIPTION

  spec.homepage      = "https://github.com/riboseinc/asciidoctor-iso"
  spec.license       = "MIT"

  spec.bindir        = "bin"
  spec.require_paths = ["lib"]
  spec.files         = `git ls-files`.split("\n")
  spec.test_files    = `git ls-files -- {spec}/*`.split("\n")
  spec.required_ruby_version = Gem::Requirement.new(">= 2.4.0")

  spec.add_dependency "asciidoctor", "~> 1.5.7"
  spec.add_dependency "ruby-jing"
  spec.add_dependency "isodoc", ">= 0.8"
  spec.add_dependency "isobib", "~> 0.1.8"
  spec.add_dependency "iso-bib-item", "~> 0.1.6"

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "byebug", "~> 9.1"
  spec.add_development_dependency "equivalent-xml", "~> 0.6"
  spec.add_development_dependency "guard", "~> 2.14"
  spec.add_development_dependency "guard-rspec", "~> 4.7"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "rspec", "~> 3.6"
  spec.add_development_dependency "rubocop", "~> 0.50"
  spec.add_development_dependency "simplecov", "~> 0.15"
  spec.add_development_dependency "timecop", "~> 0.9"
  spec.add_development_dependency "metanorma", "~> 0.2.4"
end
