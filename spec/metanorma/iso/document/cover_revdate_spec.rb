# frozen_string_literal: true

require "spec_helper"

# isodoc prints the cover "Date:" from the version revision-date, else
# the "updated" date. The cover model used the "published" date first, so
# an international workshop agreement (published 2019-08-19, updated
# 2019-10-15) lost its "Date: 2019-10-15" line and showed a wrong draft
# date suffix.
RSpec.describe Metanorma::Iso::Document::Metadata::IsoBibliographicItem do
  def bibdata(dates: "", version: "")
    described_class.from_xml(<<~XML)
      <bibdata xmlns="http://riboseinc.com/isoxml" type="standard">
        <title language="en" type="main">T</title>
        #{version}
        #{dates}
      </bibdata>
    XML
  end

  let(:dates) do
    '<date type="published"><on>2019-08-19</on></date>' \
      '<date type="updated"><on>2019-10-15</on></date>'
  end

  it "prefers the updated date over the published date" do
    expect(bibdata(dates: dates).cover_published_date).to eq("2019-10-15")
  end

  it "prefers the version revision-date over the updated date" do
    version = "<version><revision-date>2020-01-02</revision-date>" \
              "<draft>2.1</draft></version>"
    expect(bibdata(dates: dates, version: version).cover_published_date)
      .to eq("2020-01-02")
  end

  it "falls back to the published date" do
    expect(bibdata(dates: '<date type="published"><on>2019-08-19</on></date>')
             .cover_published_date).to eq("2019-08-19")
  end

  it "does not repeat the date in the draft info when it is the draft" do
    version = "<version>2019-10-15</version>"
    expect(bibdata(dates: dates, version: version).cover_draftinfo)
      .to eq(" (draft 2019-10-15)")
  end

  describe "draft label" do
    def localised(lang, current: true)
      described_class.from_xml(<<~XML)
        <bibdata xmlns="http://riboseinc.com/isoxml" type="standard">
          <title language="#{lang}" type="main">T</title>
          <version>2016-05-01</version>
          <language#{current ? ' current="true"' : ''}>#{lang}</language>
        </bibdata>
      XML
    end

    it "uses the French label for a French document" do
      expect(localised("fr").cover_draftinfo)
        .to eq(" (brouillon 2016-05-01)")
    end

    it "keeps the English label for an English document" do
      expect(localised("en").cover_draftinfo)
        .to eq(" (draft 2016-05-01)")
    end

    it "falls back to the first language when none is marked current" do
      expect(localised("fr", current: false).cover_draftinfo)
        .to start_with(" (brouillon")
    end
  end
end
