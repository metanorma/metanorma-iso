# frozen_string_literal: true

require "rubygems/package"
require "tmpdir"

RSpec.describe "css packaging" do
  # The released gem must have and use compiled stylesheets: the packaging
  # job compiles scss via `rake build_scss` (release.yml pre_build_command);
  # converters reference the .css, never the .scss (no runtime
  # sassc-embedded require for gem consumers). The 2026-11 template sync
  # dropped the packaging line and releases 3.5.12-3.5.22 shipped
  # scss-only; they were yanked.
  root = File.expand_path("../..", __dir__)
  lib = File.join(root, "lib")

  let(:stylesheet_sources) do
    Dir[File.join(lib, "isodoc/iso/html/**/*.scss")]
  end

  it "references only css files that exist in the repo" do
    refs = Dir[File.join(lib, "isodoc/iso/**/*.rb")].flat_map do |f|
      File.read(f).scan(/html_doc_path\("([^"]+\.css)"\)/).flatten
    end
    expect(refs).not_to be_empty
    refs.each do |rel|
      expect(File.exist?(File.join(lib, "isodoc/iso/html", rel))).to be(true),
        "referenced stylesheet #{rel} is not in the repo"
    end
  end

  it "references no scss stylesheet at runtime" do
    refs = Dir[File.join(lib, "isodoc/iso/**/*.rb")].flat_map do |f|
      File.read(f).scan(/html_doc_path\("([^"]+\.scss)"\)/).flatten
    end
    expect(refs).to be_empty
  end

  it "has a compiled css sibling for every scss source" do
    expect(stylesheet_sources).not_to be_empty
    stylesheet_sources.each do |scss|
      expect(File.exist?(scss.sub(/\.scss$/, ".css"))).to be(true),
        "missing compiled sibling for #{scss}"
    end
  end

  it "ships the compiled stylesheets in the built gem" do
    spec = Dir.chdir(root) do
      Gem::Specification.load("metanorma-iso.gemspec")
    end
    expect(spec).not_to be_nil
    expect(stylesheet_sources).not_to be_empty

    Dir.mktmpdir("metanorma-iso-css-") do |dir|
      archive = File.join(dir, "metanorma-iso.gem")
      Dir.chdir(root) { Gem::Package.build(spec, true, false, archive) }
      packaged_files = Gem::Package.new(archive).contents
      local_context = packaged_files.grep(
        %r{(?:\A|/)(?:AGENTS\.md|CLAUDE\.md|\.codex-context|\.claude|\.codex)(?:/|\z)}
      )
      expect(local_context).to be_empty,
        "local assistant context is included in the built gem: #{local_context.join(', ')}"

      stylesheet_sources.each do |scss|
        css = scss.sub(/\.scss$/, ".css").delete_prefix("#{root}/")
        expect(packaged_files).to include(css),
          "compiled stylesheet #{css} is missing from the built gem"
      end
    end
  end
end
