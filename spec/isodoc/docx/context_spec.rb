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

  describe "#with_foreword" do
    it "sets in_foreword during block, restores after" do
      expect(context.in_foreword).to be(false)
      context.with_foreword do
        expect(context.in_foreword).to be(true)
      end
      expect(context.in_foreword).to be(false)
    end
  end

  describe "#with_introduction" do
    it "sets in_introduction during block, restores after" do
      expect(context.in_introduction).to be(false)
      context.with_introduction do
        expect(context.in_introduction).to be(true)
      end
      expect(context.in_introduction).to be(false)
    end
  end

  describe "#with_bibliography" do
    it "sets in_bibliography during block, restores after" do
      expect(context.in_bibliography).to be(false)
      context.with_bibliography do
        expect(context.in_bibliography).to be(true)
      end
      expect(context.in_bibliography).to be(false)
    end
  end

  describe "#with_figure" do
    it "sets in_figure during block, restores after" do
      expect(context.in_figure).to be(false)
      context.with_figure do
        expect(context.in_figure).to be(true)
        expect(context.zone).to be(:figure)
      end
      expect(context.in_figure).to be(false)
      expect(context.zone).to be(:body)
    end
  end

  describe "#with_amend" do
    it "sets amend_zone during block, restores after" do
      expect(context.amend_zone).to be_nil
      context.with_amend(:newcontent) do
        expect(context.amend_zone).to be(:newcontent)
        expect(context.zone).to be(:amend_newcontent)
      end
      expect(context.amend_zone).to be_nil
      expect(context.zone).to be(:body)
    end

    it "supports nested amend zones (description → newcontent)" do
      context.with_amend(:description) do
        expect(context.zone).to be(:amend_description)
        context.with_amend(:newcontent) do
          expect(context.zone).to be(:amend_newcontent)
        end
        expect(context.zone).to be(:amend_description)
      end
    end

    it "yields inner zone (note) over amend zone for nested content" do
      context.with_amend(:newcontent) do
        expect(context.zone).to be(:amend_newcontent)
        context.with_note do
          expect(context.zone).to be(:note),
            "nested note inside amend should win over amend zone"
        end
        expect(context.zone).to be(:amend_newcontent)
      end
    end
  end

  describe "section numbering" do
    it "generates ascending section numbers" do
      expect(context.next_section_number).to eq(1)
      expect(context.next_section_number).to eq(2)
      expect(context.current_section_number).to eq(2)
    end
  end

  describe "term numbering" do
    it "generates section.term terms within a terms section" do
      context.next_section_number  # 1
      context.next_section_number  # 2
      context.next_section_number  # 3

      context.with_terms_section(3) do
        expect(context.next_term_number).to eq("3.1")
        expect(context.next_term_number).to eq("3.2")
        expect(context.next_term_number).to eq("3.3")
      end
    end

    it "restores term counter after with_terms_section" do
      context.next_section_number  # 1
      context.next_section_number  # 2

      context.with_terms_section(2) do
        expect(context.next_term_number).to eq("2.1")
      end

      context.with_terms_section(2) do
        expect(context.next_term_number).to eq("2.1")
      end
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
