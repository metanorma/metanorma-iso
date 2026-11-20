# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe Metanorma::Iso::Sts::Transformer::FigureTransformer do
  def figures_in(figures_xml)
    source = Metanorma::Iso::Sts::Transformer::SourceDocument.parse(<<~XML)
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic">
        <bibdata type="standard"><title language="en" type="main">T</title>
          <docidentifier>ISO 1</docidentifier><language>en</language></bibdata>
        <sections><clause id="c1"><title>Scope</title>#{figures_xml}</clause></sections>
      </metanorma>
    XML
    context = Metanorma::Iso::Sts::Transformer::Context.new(source)
    transformer = described_class.new(context)
    source.sections.first.figures.map { |f| Nokogiri::XML(transformer.transform(f).to_xml).root }
  end

  it "emits <fig> with a renumbered fig_N id, caption title and graphic" do
    fig, = figures_in(<<~XML)
      <figure id="_uuid1" anchor="fa" autonum="1"><name>Overview</name>
        <image id="_i1" src="a.png" mimetype="image/png"/></figure>
    XML

    expect(fig.name).to eq("fig")
    expect(fig["id"]).to eq("fig_1")
    expect(fig.at_xpath("./caption/title").text).to eq("Overview")
    expect(fig.at_xpath("./graphic")).not_to be_nil
  end

  it "numbers figures in document order" do
    figs = figures_in(<<~XML)
      <figure id="_a" anchor="a"><name>One</name></figure>
      <figure id="_b" anchor="b"><name>Two</name></figure>
    XML

    expect(figs.map { |f| f["id"] }).to eq(%w[fig_1 fig_2])
  end

  it "labels the figure 'Figure N' from the presentation autonum" do
    fig, = figures_in(%(<figure id="_a" anchor="a" autonum="3"><name>X</name></figure>))

    expect(fig.at_xpath("./label")&.text).to eq("Figure 3")
  end

  it "emits no label when the figure has no autonum" do
    fig, = figures_in(%(<figure id="_a" anchor="a"><name>X</name></figure>))

    expect(fig.at_xpath("./label")).to be_nil
  end

  describe "graphic reference" do
    def href_for(src)
      fig, = figures_in(%(<figure id="_a" anchor="a"><name>X</name><image id="_i" src="#{src}" mimetype="image/png"/></figure>))
      fig.at_xpath("./graphic")["xlink:href"]
    end

    it "strips the images/ prefix and the file extension" do
      expect(href_for("images/diagram.svg")).to eq("diagram")
    end

    it "strips only the last extension" do
      expect(href_for("fig.v2.png")).to eq("fig.v2")
    end

    it "leaves a reference without prefix or extension alone" do
      expect(href_for("plain")).to eq("plain")
    end

    it "emits no graphic for a figure with no image" do
      fig, = figures_in(%(<figure id="_a" anchor="a"><name>X</name></figure>))

      expect(fig.at_xpath("./graphic")).to be_nil
    end
  end

  it "emits no caption title for a figure without a name" do
    fig, = figures_in(%(<figure id="_a" anchor="a"/>))

    expect(fig.at_xpath("./caption/title")).to be_nil
  end
end
