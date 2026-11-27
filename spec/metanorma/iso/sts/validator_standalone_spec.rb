# frozen_string_literal: true

require "open3"
require "rbconfig"
require "tempfile"

require_relative "../../../sts/spec_helper"

# The validator references Pathname and ValidationReport itself, so it must
# load in a process where nothing else has required them.
RSpec.describe Metanorma::Iso::Sts::Validator do
  let(:lib_dir) { File.expand_path("../../../../lib", __dir__) }

  def standalone_error_count(path)
    code = <<~RUBY
      require "metanorma/iso/sts/validator"
      report = Metanorma::Iso::Sts::Validator.new.validate(Pathname(ARGV.fetch(0)))
      puts report.errors.size
    RUBY
    out, err, status = Open3.capture3(RbConfig.ruby, "-I", lib_dir, "-e", code, path)
    raise err unless status.success?

    out.to_i
  end

  it "validates a file path in a process that required nothing else" do
    Tempfile.create(["standalone", ".xml"]) do |file|
      file.write("<standard><front/></standard>")
      file.flush
      expect(standalone_error_count(file.path)).to be >= 0
    end
  end
end
