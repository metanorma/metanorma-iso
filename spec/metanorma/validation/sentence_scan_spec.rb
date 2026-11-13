require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::SentenceScan do
  describe ".sentences" do
    it "splits on periods followed by whitespace and a capital" do
      sentences = described_class.sentences(
        "The samples are dried. The measurement follows."
      )
      expect(sentences.map(&:text)).to eq(
        ["The samples are dried.", "The measurement follows."]
      )
    end

    it "splits on question marks and exclamation marks" do
      expect(described_class.split("Is the value set? It is! Yes.")).to eq(
        ["Is the value set?", "It is!", "Yes."]
      )
    end

    it "splits on a single space" do
      expect(described_class.split("One. Two")).to eq(["One.", "Two"])
    end

    it "emits a final sentence without terminal punctuation" do
      expect(described_class.split("First sentence. Second")).to eq(
        ["First sentence.", "Second"]
      )
    end

    it "returns an empty array for nil and empty text" do
      expect(described_class.sentences(nil)).to eq([])
      expect(described_class.sentences("")).to eq([])
    end

    it "returns an empty array for whitespace-only text" do
      expect(described_class.sentences("   \n  ")).to eq([])
    end

    it "does not split decimals" do
      expect(described_class.split(
        "The thickness is 3.5 mm. The stack is 3.5.2 mm thick."
      )).to eq(
        ["The thickness is 3.5 mm.", "The stack is 3.5.2 mm thick."]
      )
    end

    it "does not split exempted abbreviations even before a capital" do
      texts = {
        "e.g." => "Use a reference method e.g. This one is preferred. " \
                  "Discard the rest.",
        "i.e." => "Use method B i.e. The accelerated method. Discard " \
                  "the rest.",
        "approx." => "The delay is approx. 5 min at 20 °C. Then it holds.",
        "ca." => "Use ca. 5 g of the reagent. The yield follows.",
        "no." => "Use vessel no. 4 for the test. Discard it afterwards.",
        "No." => "Refer to vessel No. 5 in Fig. 3. It is optional.",
        "etc." => "Include water, acids etc. The list is open. " \
                  "Chlorides are excluded.",
        "Fig." => "See Fig. 2 for the layout. The dimensions follow.",
        "min." => "Heat for 10 min. The sample is then stable. It cools.",
        "al." => "See Smith et al. The study covers this case. It continues."
      }
      texts.each do |abbr, text|
        expect(described_class.split(text).size).to eq(2),
          "expected '#{abbr}' not to split: #{text.inspect}"
      end
    end

    it "does not split single-capital initials" do
      expect(described_class.split(
        "The design by J. Smith was reviewed. It was accepted."
      )).to eq(
        ["The design by J. Smith was reviewed.", "It was accepted."]
      )
    end

    it "does not split when the next word starts lowercase" do
      expect(described_class.split(
        "The mass fraction is 50 per cent. per unit mass"
      )).to eq(["The mass fraction is 50 per cent. per unit mass"])
    end

    it "does not split an ellipsis of decimals" do
      expect(described_class.split(
        "The values 1.2 and 3.4 differ. The rest agree."
      ).size).to eq(2)
    end

    it "strips leading and trailing whitespace of each sentence" do
      sentences = described_class.sentences("  First.   Second .  ")
      expect(sentences.map(&:text)).to eq(["First.", "Second ."])
    end

    it "reports the start offset of each sentence in the source text" do
      text = "Alpha beta. Gamma delta."
      sentences = described_class.sentences(text)
      expect(sentences.map(&:start)).to eq([0, 12])
      sentences.each_with_index do |sentence, i|
        expect(text[sentence.start...]).to start_with(sentence.text)
      end
    end

    it "reports the start offset past the whitespace gap" do
      text = "Alpha beta.   Gamma delta."
      sentences = described_class.sentences(text)
      expect(sentences.map(&:start)).to eq([0, 14])
    end

    it "numbers sentences consecutively from zero" do
      sentences = described_class.sentences("One. Two. Three.")
      expect(sentences.map(&:index)).to eq([0, 1, 2])
    end

    it "handles newlines as sentence separators" do
      expect(described_class.split("First ends here.\nSecond follows.")).to eq(
        ["First ends here.", "Second follows."]
      )
    end

    it "does not split ISO-flavored normative prose incorrectly" do
      text = "The test shall be carried out in accordance with " \
             "ISO 12345. Samples of ca. 5 mm thickness are used. " \
             "The measurement uncertainty is 3.5 %."
      expect(described_class.split(text)).to eq([
        "The test shall be carried out in accordance with ISO 12345.",
        "Samples of ca. 5 mm thickness are used.",
        "The measurement uncertainty is 3.5 %."
      ])
    end

    it "splits on a terminator at the end of the text" do
      expect(described_class.split("Only one sentence.")).to eq(
        ["Only one sentence."]
      )
    end
  end

  describe ".split" do
    it "returns sentence texts only" do
      expect(described_class.split("Alpha. Beta? Gamma!")).to eq(
        ["Alpha.", "Beta?", "Gamma!"]
      )
    end

    it "keeps a single capital letter with its following word together" do
      expect(described_class.split("A. B testing follows.")).to eq(
        ["A. B testing follows."]
      )
    end
  end

  describe ".starts_sentence?" do
    it "is true for the offset of each sentence start" do
      text = "Alpha beta. Gamma."
      expect(described_class.starts_sentence?(text, 0)).to be(true)
      expect(described_class.starts_sentence?(text, 12)).to be(true)
    end

    it "is false for offsets inside a sentence" do
      expect(described_class.starts_sentence?("Alpha beta.", 6)).to be(false)
      expect(described_class.starts_sentence?("Alpha beta.", 11)).to be(false)
    end
  end
end
