# frozen_string_literal: true

# Golden STS parity harness (safety net for the engine delegation,
# metanorma-iso#1760 / metanorma-document#165).
#
# The manifest maps each golden slug to the real-document presentation
# XML it was captured from (spec/fixtures carries the mn-samples-iso
# smoke-subset documents in compiled form, plus the rice amendment and
# the IS/DIS/AMD pairs). `bundle exec rake sts:golden:capture` rewrites
# the goldens from the CURRENT pipeline; spec/sts/golden_spec.rb diffs
# every conversion against its golden byte-for-byte.

require "yaml"
require "fileutils"

GOLDEN_MANIFEST_PATH = "spec/sts/golden/manifest.yml"
GOLDEN_DIR = "spec/sts/golden"

def golden_manifest
  YAML.safe_load_file(GOLDEN_MANIFEST_PATH)
end

namespace :sts do
  namespace :golden do
    desc "Capture golden STS outputs from the real-document presentation fixtures"
    task :capture do
      require "metanorma-iso"
      require "fileutils"

      FileUtils.mkdir_p(GOLDEN_DIR)
      golden_manifest.each do |slug, input|
        warn "capturing #{slug} from #{input}"
        xml = Metanorma::Iso::Sts.convert(File.read(input))
        File.write(File.join(GOLDEN_DIR, "#{slug}.sts.xml"), xml)
      end
      warn "captured #{golden_manifest.size} goldens into #{GOLDEN_DIR}"
    end
  end
end
