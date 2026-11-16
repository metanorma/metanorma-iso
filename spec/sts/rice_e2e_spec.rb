# frozen_string_literal: true

require_relative "spec_helper"

# End-to-end coverage of the rice fixture through the full native STS
# pipeline (PXML → ISO-STS XML → HTML). Tagged :rice_e2e and excluded by
# default (see .rspec) because the source XML is ~1.2 MB and the typed
# model walk is slow. Run explicitly with:
#
#   bundle exec rspec spec/sts/rice_e2e_spec.rb --tag rice_e2e
RSpec.describe "rice.xml end-to-end STS pipeline", :rice_e2e do
  let(:source_xml) { File.read(rice_xml_path) }

  it "converts PXML to ISO-STS XML with iso-meta" do
    sts = Metanorma::Iso::Sts.convert(source_xml)
    expect(sts).to include("<standard")
    expect(sts).to include("<iso-meta")
    expect(sts).to include("<body")
  end

  it "renders an HTML page from the STS XML" do
    sts = Metanorma::Iso::Sts.convert(source_xml)
    html = Metanorma::Iso::Sts.render_html(sts)

    expect(html).to start_with("<!DOCTYPE html>")
    expect(html).to include("</html>")
    expect(html).to include("hero-title")
    expect(html).to include("<section")
    expect(html).to include("<table")
  end
end
