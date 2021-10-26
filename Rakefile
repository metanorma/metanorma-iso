require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "isodoc/gem_tasks"

IsoDoc::GemTasks.install
RSpec::Core::RakeTask.new(:spec)

task default: :spec
