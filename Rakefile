require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "isodoc/gem_tasks"

IsoDoc::GemTasks.install

RSpec::Core::RakeTask.new(:spec)
RSpec::Core::RakeTask.new(:sts_spec) do |t|
  t.pattern = "spec/sts/**/*_spec.rb"
end

# Main spec suite blocked by rfcxml/lutaml-model version conflict upstream.
# Run sts_spec until resolved.
task default: :sts_spec
