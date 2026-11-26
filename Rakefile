require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "isodoc/gem_tasks"

IsoDoc::GemTasks.install

RSpec::Core::RakeTask.new(:spec)
RSpec::Core::RakeTask.new(:sts_spec) do |t|
  t.pattern = "spec/sts/**/*_spec.rb"
end

# The rice DOCX end-to-end spec: one file, one rice conversion. The main
# suite is not part of `rake`, so without this task CI would never run any
# DOCX spec (Phase 3 acceptance test, P3-005).
RSpec::Core::RakeTask.new(:docx_e2e_spec) do |t|
  t.pattern = "spec/isodoc/docx/rice_docx_e2e_spec.rb"
end

# Main spec suite blocked by rfcxml/lutaml-model version conflict upstream.
# Run sts_spec until resolved.
task default: %i[sts_spec docx_e2e_spec]

Dir.glob('tasks/*.rake').each { |t| load t }
