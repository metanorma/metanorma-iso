# frozen_string_literal: true

require "bundler/setup"
require "metanorma/document"
require "metanorma-iso"
require "metanorma/iso/document"
require "json"
require "open3"
require "tmpdir"

RSpec.describe Metanorma::Iso::Html::Renderer do
  before(:example, :browser) do
    skip "Set HTML_THEME_PARITY=1 after installing Puppeteer/Chromium" unless ENV["HTML_THEME_PARITY"] == "1"
  end

  let(:fixture) { File.expand_path("../../../fixtures/html-theme-parity/document.xml", __dir__) }
  let(:browser_script) { File.expand_path("../../../support/html_theme_parity.mjs", __dir__) }
  let(:theme_dir) { File.expand_path("../../../../lib/metanorma/iso/themes/iso", __dir__) }
  let(:properties) do
    %w[font-family font-size font-weight font-style line-height color
       background-color margin-top margin-bottom padding-top padding-bottom letter-spacing]
  end
  let(:probes) do
    {
      "foreword" => "#parity-foreword > :is(h1,h2)",
      "scope" => "#parity-scope > :is(h1,h2)",
      "subclause" => "#parity-subclause > :is(h1,h2,h3)",
      "paragraph" => "#parity-paragraph",
      "detail" => "#parity-detail",
    }.map { |name, selector| { name: name, legacy: selector, theme: selector } }
  end

  def compare(directory, legacy, theme)
    input = { pages: { legacy: legacy, theme: theme }, probes: probes, properties: properties }
    input_path = File.join(directory, "comparison.json")
    File.write(input_path, JSON.generate(input))
    stdout, stderr, status = Open3.capture3("node", browser_script, input_path)
    raise "Browser comparison failed (#{status.exitstatus}): #{stderr}" unless status.success?

    JSON.parse(stdout)
  end

  def render_theme(path)
    # Resolve in isolation using this gem's registration, never the bundled YAML.
    script = <<~RUBY
      require "metanorma/document"
      require "metanorma/iso/document"
      require "metanorma/iso/html"
      document = Metanorma::Iso::Document::Root.from_xml(File.read(ARGV.fetch(0)))
      theme = Metanorma::Html::Theme.load(:iso)
      abort "ISO theme registration was bypassed" unless theme.theme_dir == ARGV.fetch(1)
      print Metanorma::Iso::Html::Renderer.new.generate_full_document(document, theme: theme)
    RUBY
    lib = File.expand_path("../../../../lib", __dir__)
    html, error, status = Open3.capture3(RbConfig.ruby, "-I", lib, "-e", script, fixture, theme_dir)
    raise "ISO renderer failed (#{status.exitstatus}): #{error}" unless status.success?

    File.write(path, html)
  end

  def render_comparison(directory)
    legacy = File.join(directory, "legacy.html")
    theme = File.join(directory, "theme.html")
    IsoDoc::Iso::HtmlConvert.new({})
      .convert(File.join(directory, "sample.xml"), File.read(fixture), false, legacy)
    render_theme(theme)
    result = compare(directory, legacy, theme)
    if ENV["HTML_THEME_PARITY_OUTPUT"]
      output = File.join(ENV.fetch("HTML_THEME_PARITY_OUTPUT"), "iso")
      FileUtils.mkdir_p(output)
      FileUtils.cp([legacy, theme], output)
      File.write(File.join(output, "comparison.json"), JSON.pretty_generate(result))
    end
    result
  end

  def compare_markup(legacy_html, theme_html = legacy_html)
    Dir.mktmpdir("iso-parity-control") do |directory|
      legacy = File.join(directory, "legacy.html")
      theme = File.join(directory, "theme.html")
      File.write(legacy, legacy_html)
      File.write(theme, theme_html)
      compare(directory, legacy, theme).fetch("mismatches")
    end
  end

  it "loads the ISO theme registered by this gem" do
    expect(Metanorma::Html::Theme.load(:iso).theme_dir).to eq(theme_dir)
  end

  it "matches legacy structure and computed key styles", :browser do
    Dir.mktmpdir("iso-theme-parity") do |directory|
      mismatches = render_comparison(directory).fetch("mismatches")
      expect(mismatches).to be_empty, mismatches.join("\n")
    end
  end

  it "detects changed text and computed styles", :browser do
    html = '<!doctype html><html><body><p id="parity-paragraph">Original</p></body></html>'
    changed = html.sub("Original", "Changed").sub("<p ", '<p style="font-size: 20px" ')
    expect(compare_markup(html, changed).join("\n")).to include("paragraph.text:", "paragraph.font-size:")
  end

  it "rejects missing probes rather than passing empty output", :browser do
    mismatches = compare_markup("<!doctype html><html><body></body></html>")
    expect(mismatches).to eq(probes.map do |probe|
      "#{probe[:name]}: expected one element per renderer, legacy=0, theme=0"
    end)
  end
end
