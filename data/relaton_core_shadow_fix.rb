# frozen_string_literal: true

# Generator-local load shim (NOT part of the gem).
#
# Bundle context: relaton-core 0.0.13 (pulled by relaton-bib
# 2.2.0.pre.alpha via metanorma-document 0.4.0) shadows relaton 3.0.8's
# vendored lib/relaton/core/processor.rb, so Relaton::Core::Processor
# lacks #pubid_class when the registry routes identifiers
# (Relaton::Db::Registry#processor_by_pubid). Reopening the class with
# relaton's own file restores the method union.
require File.join(Gem::Specification.find_by_name("relaton").full_gem_path,
                  "lib/relaton/core/processor")
