#!/usr/bin/env bash
# Migrate a flavor document model from metanorma-document to its own flavor gem.
# Usage: ./migrate-flavor.sh <flavor> <FlavorClass>

set -e

FLAVOR="$1"
FLAVOR_CLASS="$2"

DOC_CLASS="${FLAVOR_CLASS}Document"
GEM_NAME="metanorma-${FLAVOR}"
SRC="/Users/mulgogi/src/mn/metanorma-document"
DST="/Users/mulgogi/src/mn/${GEM_NAME}"
BRANCH="feat/move-${FLAVOR}-document"

if [ -z "$FLAVOR" ] || [ -z "$FLAVOR_CLASS" ]; then
  echo "Usage: $0 <flavor> <FlavorClass>"
  exit 1
fi

if [ ! -d "$DST" ]; then
  echo "ERROR: $DST does not exist"; exit 1
fi

if [ ! -d "$SRC/lib/metanorma/${FLAVOR}_document" ]; then
  echo "ERROR: $SRC/lib/metanorma/${FLAVOR}_document does not exist"; exit 1
fi

echo "=== Migrating $FLAVOR ($DOC_CLASS -> ${FLAVOR_CLASS}::Document) ==="

# 1. Create branch in flavor gem
cd "$DST"
git fetch origin main 2>&1 | tail -1
git checkout -B "$BRANCH" origin/main 2>&1 | tail -1

# 2. Copy files
mkdir -p "lib/metanorma/${FLAVOR}/document"
cp "$SRC/lib/metanorma/${FLAVOR}_document.rb" "lib/metanorma/${FLAVOR}/document.rb"
cp -R "$SRC/lib/metanorma/${FLAVOR}_document/." "lib/metanorma/${FLAVOR}/document/"

# 3. Sed rename namespace + paths
find "lib/metanorma/${FLAVOR}/document.rb" "lib/metanorma/${FLAVOR}/document" -type f -name "*.rb" -exec sed -i '' \
  -e "s|module ${FLAVOR_CLASS}Document|module ${FLAVOR_CLASS}::Document|g" \
  -e "s|Metanorma::${FLAVOR_CLASS}Document|Metanorma::${FLAVOR_CLASS}::Document|g" \
  -e "s|\"metanorma/${FLAVOR}_document/|\"metanorma/${FLAVOR}/document/|g" \
  -e "s|\"metanorma/${FLAVOR}_document\"|\"metanorma/${FLAVOR}/document\"|g" \
  -e 's|Metanorma::StandardDocument|Metanorma::Standoc::Document|g' \
  {} +

# 4. Patch the document.rb entry file
ENTRY="lib/metanorma/${FLAVOR}/document.rb"
TMPFILE=$(mktemp)
{
  echo '# frozen_string_literal: true'
  echo ''
  echo "# Forward-declare parent namespace so this file is safe to require"
  echo "# directly (without first requiring metanorma/${FLAVOR}.rb)."
  echo "module Metanorma"
  echo "  module ${FLAVOR_CLASS}"
  echo "  end"
  echo "end"
  echo ''
  tail -n +2 "$ENTRY"
} > "$TMPFILE"
mv "$TMPFILE" "$ENTRY"

# Append alias + deprecate
{
  echo ''
  echo "# Backwards-compat alias so external consumers that reference"
  echo "# Metanorma::${DOC_CLASS} keep resolving during the transition."
  echo "module Metanorma"
  echo "  existing = defined?(Metanorma::${DOC_CLASS}) && Metanorma::${DOC_CLASS}"
  echo "  if !existing.equal?(Metanorma::${FLAVOR_CLASS}::Document)"
  echo "    Metanorma.send(:remove_const, :${DOC_CLASS}) if existing"
  echo "    ${DOC_CLASS} = Metanorma::${FLAVOR_CLASS}::Document"
  echo "  end"
  echo "end"
  echo ''
  echo "if defined?(Metanorma::Registers::Setup.setup_${FLAVOR}_register)"
  echo "  Metanorma::Registers::Setup.setup_${FLAVOR}_register"
  echo "end"
  echo ''
  echo "module Metanorma"
  echo "  deprecate_constant :${DOC_CLASS}"
  echo "end"
} >> "$ENTRY"

# 5. Patch lib/metanorma/<flavor>.rb to require the new file
FLAVOR_ENTRY="lib/metanorma/${FLAVOR}.rb"
if [ -f "$FLAVOR_ENTRY" ] && ! grep -q "metanorma/${FLAVOR}/document" "$FLAVOR_ENTRY"; then
  TMPFILE=$(mktemp)
  awk -v flavor="$FLAVOR" '
    NR==1 && /^require/ { print; print "require \"metanorma/" flavor "/document\""; next }
    { print }
  ' "$FLAVOR_ENTRY" > "$TMPFILE" && mv "$TMPFILE" "$FLAVOR_ENTRY"
fi

# 6. Patch root.rb to require metanorma/standoc
ROOT_FILE="lib/metanorma/${FLAVOR}/document/root.rb"
if [ -f "$ROOT_FILE" ] && ! grep -q 'require "metanorma/standoc"' "$ROOT_FILE"; then
  TMPFILE=$(mktemp)
  {
    echo '# frozen_string_literal: true'
    echo ''
    echo 'require "metanorma/standoc"'
    tail -n +3 "$ROOT_FILE"
  } > "$TMPFILE"
  mv "$TMPFILE" "$ROOT_FILE"
fi

# 6b. Also require metanorma/standoc from document.rb entry (some trees
#     reference Standoc::Document::* without going through root.rb)
ENTRY="lib/metanorma/${FLAVOR}/document.rb"
if ! grep -q 'require "metanorma/standoc"' "$ENTRY"; then
  TMPFILE=$(mktemp)
  {
    echo '# frozen_string_literal: true'
    echo ''
    echo 'require "metanorma/standoc"'
    awk 'NR<=2 {next} {print}' "$ENTRY"
  } > "$TMPFILE"
  mv "$TMPFILE" "$ENTRY"
fi

# 6c. Strip any prior Metanorma::Registers::Setup.<flavor>_register call
#     from the body (it's now wrapped in defined? below)
sed -i '' "/^Metanorma::Registers::Setup.setup_${FLAVOR}_register\$/d" "$ENTRY"

# 7. Update Gemfile (write directly to avoid perl regex issues)
if [ ! -f Gemfile.original ]; then
  cp Gemfile Gemfile.original
fi
cat > Gemfile <<'GEMEOF'
source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}" }

gemspec

# TEMPORARY: cross-PR branch pins so CI can resolve the in-flight
# metanorma-standoc namespace rename (Metanorma::Standoc::Document)
# and the pubid-2 / relaton-bib 2.2 / metanorma-document 0.5 chain.
# Revert each pin once the corresponding PR merges:
#   - https://github.com/metanorma/metanorma-standoc/pull/1232
#   - https://github.com/metanorma/metanorma-document/pull/45
gem "metanorma-standoc", github: "metanorma/metanorma-standoc", branch: "feat/move-standard-document"
gem "metanorma-document", github: "metanorma/metanorma-document", branch: "feat/model-validation-l1-declarations"
gem "isodoc", github: "metanorma/isodoc", branch: "rt-pubid-2-migration"
gem "relaton-bib", "~> 2.2.0.pre.alpha.1"
gem "pubid", github: "pubid/pubid", branch: "main"

eval_gemfile("Gemfile.devel") rescue nil
GEMEOF

# 8. Add namespace spec
cat > "spec/${FLAVOR}_document_namespace_spec.rb" <<SPECEOF
# frozen_string_literal: true

# Self-contained: avoids pulling in the gem's full spec_helper (which
# may load unrelated code with pre-existing pubid-* dependency issues).
require "bundler/setup"
require "metanorma/${FLAVOR}/document"

RSpec.describe "Metanorma::${FLAVOR_CLASS}::Document namespace" do
  describe "canonical namespace" do
    it "exposes Metanorma::${FLAVOR_CLASS}::Document as a Module" do
      expect(Metanorma::${FLAVOR_CLASS}::Document).to be_a(Module)
    end

    it "exposes Root with the canonical name" do
      expect(Metanorma::${FLAVOR_CLASS}::Document::Root.name)
        .to eq("Metanorma::${FLAVOR_CLASS}::Document::Root")
    end

    it "Root is a lutaml Serializable" do
      expect(Metanorma::${FLAVOR_CLASS}::Document::Root < Lutaml::Model::Serializable).to be(true)
    end
  end

  describe "backwards-compat alias" do
    it "Metanorma::${DOC_CLASS} aliases to the new namespace" do
      expect(Metanorma::${DOC_CLASS}).to eq(Metanorma::${FLAVOR_CLASS}::Document)
    end

    it "the alias preserves class identity" do
      expect(Metanorma::${DOC_CLASS}::Root.equal?(
               Metanorma::${FLAVOR_CLASS}::Document::Root)).to be(true)
    end
  end

  describe "parent namespace" do
    it "Metanorma::Standoc::Document is available" do
      expect(Metanorma::Standoc::Document).to be_a(Module)
    end

    it "Metanorma::StandardDocument alias is available" do
      expect(Metanorma::StandardDocument).to eq(Metanorma::Standoc::Document)
    end
  end
end
SPECEOF

echo "=== bundle install ==="
rm -f Gemfile.lock
bundle install 2>&1 | tail -3

echo "=== smoke test ==="
bundle exec ruby -Ilib -e "
require 'metanorma/${FLAVOR}'
puts '${FLAVOR_CLASS}::Document::Root: ' + Metanorma::${FLAVOR_CLASS}::Document::Root.name
puts 'alias same? ' + Metanorma::${DOC_CLASS}.equal?(Metanorma::${FLAVOR_CLASS}::Document).to_s
" 2>&1 | tail -3

echo "=== spec ==="
bundle exec rspec "spec/${FLAVOR}_document_namespace_spec.rb" 2>&1 | tail -5
