# frozen_string_literal: true

require "tmpdir"
require "fileutils"
require_relative "../support/sts_sibling_parity"

# metanorma/metanorma-iso#1760 option 2: the ISO and OIML STS trees are
# mirrored copies; this spec fails when either drifts from the recorded sync.
# Set METANORMA_STS_SIBLING to the sibling repo root to also check its tree
# (default: a ../metanorma-{iso,oiml} checkout next to this repo).
RSpec.describe StsSiblingParity do # rubocop:disable RSpec/MultipleMemoizedHelpers
  let(:root) { File.expand_path("../..", __dir__) }
  let(:own) { described_class.own_flavour(root) }
  let(:other) { (described_class::FLAVOURS - [own]).first }
  let(:expected) { described_class.manifest(root) }
  let(:sibling_root) do
    path = ENV["METANORMA_STS_SIBLING"] ||
      File.expand_path("../metanorma-#{other}", root)
    path if File.directory?(described_class.tree_dir(path, other))
  end
  let(:sync_hint) do
    "Port the change to the sibling STS tree, then run " \
      "`ruby spec/support/sts_sibling_parity.rb --write <sibling repo>` and " \
      "commit #{described_class::MANIFEST} in both repos."
  end

  it "keeps this repo's STS tree at its last synced state" do
    expect(described_class.drift(root, own, expected)).to eq([]), sync_hint
  end

  it "records the files of both trees" do
    expect(expected.values.flat_map(&:keys).uniq.sort)
      .to eq(described_class::FLAVOURS)
  end

  it "keeps the sibling STS tree at its last synced state" do
    skip "no #{other} checkout (set METANORMA_STS_SIBLING)" unless sibling_root

    expect(described_class.drift(sibling_root, other, expected))
      .to eq([]), sync_hint
  end

  it "holds the same manifest as the sibling repo" do
    skip "no #{other} checkout (set METANORMA_STS_SIBLING)" unless sibling_root

    expect(described_class.manifest(sibling_root)).to eq(expected)
  end

  describe ".normalise" do # rubocop:disable RSpec/MultipleMemoizedHelpers
    it "collapses flavour names symmetrically" do
      oiml = described_class.normalise("module Oiml; oiml OIML; end")
      iso = described_class.normalise("module Iso; iso ISO; end")
      expect(oiml).to eq(iso)
    end
  end

  describe ".drift" do # rubocop:disable RSpec/MultipleMemoizedHelpers
    let(:dir) { Dir.mktmpdir }
    let(:manifest) do
      { "a.rb" => { "iso" => "stale" }, "gone.rb" => { "iso" => "x" } }
    end

    before do
      tree = File.join(dir, "lib/metanorma/iso/sts")
      FileUtils.mkdir_p(tree)
      %w[a.rb b.rb].each { |f| File.write(File.join(tree, f), f) }
    end

    after { FileUtils.remove_entry(dir) }

    it "reports changed, added and removed files" do
      expect(described_class.drift(dir, "iso", manifest))
        .to eq(["a.rb: changed", "b.rb: added", "gone.rb: removed"])
    end
  end
end
