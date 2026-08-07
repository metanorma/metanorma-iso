require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::Base do
  let(:concrete_subclass) do
    Class.new(described_class) do
      code "ISO_5"
    end
  end

  it "raises when a subclass forgets the code declaration" do
    subclass = Class.new(described_class)
    expect { subclass.new.code }.to raise_error(NotImplementedError)
  end

  describe "severity lookup from ISO_LOG_MESSAGES" do
    it "maps severity 2 to error" do
      klass = Class.new(described_class) { code "ISO_5" }
      expect(klass.new.severity).to eq("error") # ISO_5 severity is 2
    end

    it "maps severity 1 to warning" do
      klass = Class.new(described_class) { code "ISO_21" }
      expect(klass.new.severity).to eq("warning") # ISO_21 severity is 1
    end

    it "maps severity 0 to error (abort treated as error in Issue severity)" do
      klass = Class.new(described_class) { code "ISO_52" }
      expect(klass.new.severity).to eq("error") # ISO_52 severity is 0
    end
  end

  describe "#category" do
    it "looks up category from ISO_LOG_MESSAGES by code" do
      klass = Class.new(described_class) { code "ISO_5" }
      expect(klass.new.category).to eq("Document Attributes")
    end
  end

  describe "#check" do
    it "defaults to no findings" do
      expect(concrete_subclass.new.check(nil)).to eq([])
    end
  end

  describe "#applicable?" do
    it "defaults to true" do
      expect(concrete_subclass.new).to be_applicable(nil)
    end
  end
end
