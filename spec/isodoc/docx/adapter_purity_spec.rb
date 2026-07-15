# frozen_string_literal: true

require_relative "spec_helper"

# Adapter purity spec: enforces architectural invariants by static scan.
#
# 1. No styleId string literals in renderer code (styleIds must flow
#    from YAML via StyleResolver).
# 2. No Heading# or TOC# interpolation literals.
# 3. No `paragraph_style(...) || ...` fallback chains.
# 4. No private `send` calls.
# 5. No `respond_to?` for type checks.
# 6. No `require_relative` for library code.
# 7. No `instance_variable_set` / `instance_variable_get`.
# 8. Adapter dispatch must flow through Renderers::Registry (no parallel
#    @simple_renderers hash duplicating Registry's lookup logic).
RSpec.describe "Adapter purity" do
  SOURCE_DIR = Pathname.new("lib/isodoc/iso/docx").expand_path(__dir__ + "/../../..")

  # Files that legitimately handle styleIds as data (YAML loader, library,
  # validator, extractor, resolver alias map). Adding a file here requires
  # design review.
  WHITELIST_BASENAMES = %w[
    docx_style_mapping.rb
    style_library.rb
    style_mapping_validator.rb
    template_extractor.rb
    style_resolver.rb
    document_properties.rb
  ].freeze

  let(:library) { IsoDoc::Iso::Docx::StyleLibrary.load_default }
  let(:all_style_ids) { library.all_style_ids }

  def source_files
    return @source_files if defined?(@source_files)

    @source_files = SOURCE_DIR.glob("**/*.rb").reject do |p|
      WHITELIST_BASENAMES.include?(p.basename.to_s)
    end
    @source_files
  end

  def read_file_stripped(path)
    content = File.binread(path).force_encoding("UTF-8")
    # Strip full-line comments and trailing comments. Naive — does not
    # understand strings containing '#', but adequate for this scan.
    content.lines.reject { |l| l.lstrip.start_with?("#") }.map do |l|
      l.sub(/#.*$/, "")
    end.join
  end

  it "contains no styleId string literals in renderer code" do
    offenders = []
    source_files.each do |path|
      src = read_file_stripped(path)
      all_style_ids.each do |sid|
        next if sid.nil? || sid.to_s.empty?
        pattern = /["']#{Regexp.escape(sid.to_s)}["']/
        offenders << "#{path}:#{sid}" if pattern.match?(src)
      end
    end
    expect(offenders).to be_empty,
      "hardcoded styleIds found: #{offenders.inspect}"
  end

  it "contains no Heading# interpolation literals" do
    offenders = []
    source_files.each do |path|
      read_file_stripped(path).scan(/["']Heading#\{[^}]+\}["']/) do |m|
        offenders << "#{path}:#{m}"
      end
    end
    expect(offenders).to be_empty
  end

  it "contains no TOC# interpolation literals" do
    offenders = []
    source_files.each do |path|
      read_file_stripped(path).scan(/["']TOC#\{[^}]+\}["']/) do |m|
        offenders << "#{path}:#{m}"
      end
    end
    expect(offenders).to be_empty
  end

  it "contains no paragraph_style fallback chains" do
    offenders = []
    source_files.each do |path|
      src = read_file_stripped(path)
      next unless src.match?(/paragraph_style[^)]*\)\s*\|\|/)

      offenders << path
    end
    expect(offenders).to be_empty
  end

  it "does not call .send with a symbol (private dispatch)" do
    offenders = []
    source_files.each do |path|
      read_file_stripped(path).scan(/\.send\(\s*:/) do |m|
        offenders << "#{path}:#{m}"
      end
    end
    expect(offenders).to be_empty
  end

  it "does not use respond_to? for type checks" do
    offenders = []
    source_files.each do |path|
      read_file_stripped(path).scan(/\.respond_to\?\s*\(?/) do |m|
        offenders << "#{path}:#{m}"
      end
    end
    expect(offenders).to be_empty
  end

  it "does not use require_relative for library code" do
    offenders = []
    source_files.each do |path|
      read_file_stripped(path).scan(/^require_relative\s+/) do |m|
        offenders << "#{path}:#{m}"
      end
    end
    expect(offenders).to be_empty
  end

  it "does not access instance variables via _set/_get" do
    offenders = []
    source_files.each do |path|
      read_file_stripped(path).scan(/instance_variable_(set|get)/) do |m|
        offenders << "#{path}:#{m}"
      end
    end
    expect(offenders).to be_empty
  end

  it "does not reintroduce a parallel @simple_renderers hash in Adapter" do
    adapter_src = File.read(SOURCE_DIR + "adapter.rb")
    expect(adapter_src).not_to match(/@simple_renderers/),
      "Adapter must dispatch through Renderers::Registry, not a parallel hash"
    expect(adapter_src).not_to match(/def lookup_simple_renderer/),
      "lookup_simple_renderer duplicates Registry#lookup — remove it"
  end
end
