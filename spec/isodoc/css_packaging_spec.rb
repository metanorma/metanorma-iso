# frozen_string_literal: true

require "spec_helper"

RSpec.describe "css packaging" do
  # The released gem must have and use compiled stylesheets: the packaging
  # job compiles scss via `rake build_scss` (release.yml pre_build_command);
  # converters reference the .css, never the .scss (no runtime
  # sassc-embedded require for gem consumers). The 2026-11 template sync
  # dropped the packaging line and releases 3.5.12-3.5.22 shipped
  # scss-only; they were yanked.
  lib = File.expand_path("../lib", __dir__)

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
    Dir[File.join(lib, "isodoc/iso/html/**/*.scss")].each do |scss|
      expect(File.exist?(scss.sub(/\.scss$/, ".css"))).to be(true),
        "missing compiled sibling for #{scss}"
    end
  end
end
