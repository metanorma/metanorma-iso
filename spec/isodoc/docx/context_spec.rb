# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe IsoDoc::Iso::Docx::Context do
  subject(:context) { described_class.new }

  describe "#initialize" do
    it "starts with default state" do
      expect(context.in_note).to be(false)
      expect(context.in_example).to be(false)
      expect(context.in_table).to be(false)
      expect(context.in_annex).to be(false)
      expect(context.in_normative).to be(false)
      expect(context.section_depth).to eq(0)
    end
  end

  describe IsoDoc::Iso::Docx::Counter do
    it "counts from 0" do
      counter = described_class.new
      expect(counter.current).to eq(0)
      expect(counter.next).to eq(1)
      expect(counter.next).to eq(2)
      expect(counter.current).to eq(2)
    end

    it "accepts a custom start value" do
      counter = described_class.new(10)
      expect(counter.next).to eq(11)
    end
  end

  describe "counter methods" do
    it "generates ascending footnote IDs" do
      expect(context.next_footnote_id).to eq(1)
      expect(context.next_footnote_id).to eq(2)
    end

    it "generates ascending bookmark IDs" do
      expect(context.next_bookmark_id).to eq(1)
    end

    it "generates ascending comment IDs" do
      expect(context.next_comment_id).to eq(1)
    end
  end

  describe "#with_annex" do
    it "sets in_annex during block, restores after" do
      expect(context.in_annex).to be(false)
      context.with_annex do
        expect(context.in_annex).to be(true)
      end
      expect(context.in_annex).to be(false)
    end

    it "restores even on error" do
      expect(context.in_annex).to be(false)
      expect { context.with_annex { raise "boom" } }.to raise_error("boom")
      expect(context.in_annex).to be(false)
    end
  end

  describe "#with_table" do
    it "sets in_table during block, restores after" do
      context.with_table do
        expect(context.in_table).to be(true)
      end
      expect(context.in_table).to be(false)
    end
  end

  describe "#with_note" do
    it "sets in_note during block, restores after" do
      context.with_note do
        expect(context.in_note).to be(true)
      end
      expect(context.in_note).to be(false)
    end
  end

  describe "#with_example" do
    it "sets in_example during block, restores after" do
      context.with_example do
        expect(context.in_example).to be(true)
      end
      expect(context.in_example).to be(false)
    end
  end

  describe "#with_normative" do
    it "sets in_normative during block, restores after" do
      expect(context.in_normative).to be(false)
      context.with_normative do
        expect(context.in_normative).to be(true)
      end
      expect(context.in_normative).to be(false)
    end

    it "sets custom value" do
      context.with_normative(false) do
        expect(context.in_normative).to be(false)
      end
    end

    it "restores even on error" do
      expect(context.in_normative).to be(false)
      expect { context.with_normative { raise "boom" } }.to raise_error("boom")
      expect(context.in_normative).to be(false)
    end
  end

  describe "section_depth" do
    it "tracks nesting depth" do
      context.section_depth = 1
      expect(context.section_depth).to eq(1)
      context.section_depth += 1
      expect(context.section_depth).to eq(2)
    end
  end
end
