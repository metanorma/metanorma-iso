# frozen_string_literal: true

require "spec_helper"
require "yaml"

# Golden STS parity: every conversion of the real-document presentation
# fixtures must reproduce its committed golden byte-for-byte. The
# goldens are the safety net for the engine delegation
# (metanorma-iso#1760 / metanorma-document#165): after every delegation
# step this spec must stay green unchanged.
#
# Re-capture with: bundle exec rake sts:golden:capture
RSpec.describe "STS golden parity" do
  manifest = YAML.safe_load_file("spec/sts/golden/manifest.yml")

  manifest.each do |slug, input|
    it "reproduces the golden output for #{slug}" do
      golden = File.read("spec/sts/golden/#{slug}.sts.xml")
      current = Metanorma::Iso::Sts.convert(File.read(input))
      File.write("/tmp/rspec-#{slug}.xml", current) if ENV["RSPEC_DUMP"]

      expect(current).to eq(golden)
    end
  end
end
