# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe "probe" do
  it "probes" do
    xml = <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="presentation" flavor="iso">
      <bibdata type="standard">
      <title language="en" type="title-main">Main T</title>
      </bibdata>
      <preface><foreword id="fw"><fmt-title>T</fmt-title><p>Hello <em>world</em> end</p></foreword></preface>
      <sections><clause id="c1"><fmt-title>C</fmt-title><p>x</p></clause></sections>
      </metanorma>
    XML
    [:leptris, :nokogiri].each do |ad|
      root = Lutaml::Model::AdapterScope.with(xml: ad) { Metanorma::Iso::Document::Root.from_xml(xml) }
      puts "#{ad}: root eo=#{root.element_order&.size.inspect} bib eo=#{root.bibdata&.element_order&.size.inspect}"
      puts "#{ad}: preface=#{root.preface.inspect[0, 60]} sections=#{root.sections&.element_order&.size.inspect}"
      para = root.preface&.foreword&.paragraphs&.first
      puts "#{ad}: para eo=#{para&.element_order&.size.inspect}"
      puts "#{ad}: title=#{root.bibdata.titles.for_language('en')&.title_main&.value.inspect}"
    end
  end
end
