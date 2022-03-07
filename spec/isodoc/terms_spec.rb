require "spec_helper"

RSpec.describe IsoDoc do
  it "processes IsoXML terms" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <sections>
          <terms id="_terms_and_definitions" obligation="normative"><title>Terms and Definitions</title>
            <term id="paddy1">
              <preferred><expression><name>paddy</name></expression></preferred>
              <domain>rice</domain>
              <definition><verbal-definition><p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">rice retaining its husk after threshing</p></verbal-definition></definition>
              <termexample id="_bd57bbf1-f948-4bae-b0ce-73c00431f892">
                <p id="_65c9a509-9a89-4b54-a890-274126aeb55c">Foreign seeds, husks, bran, sand, dust.</p>
                <ul>
                <li>A</li>
                </ul>
              </termexample>
              <termexample id="_bd57bbf1-f948-4bae-b0ce-73c00431f894">
                <ul>
                <li>A</li>
                </ul>
              </termexample>

              <termsource status="modified">
                <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011"><locality type="clause"><referenceFrom>3.1</referenceFrom></locality></origin>
                  <modification>
                  <p id="_e73a417d-ad39-417d-a4c8-20e4e2529489">The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here</p>
                </modification>
              </termsource>
            </term>

            <term id="paddy">
              <preferred><expression><name>paddy</name></expression></preferred>
              <admitted><expression><name>paddy rice</name></expression></admitted>
              <admitted><expression><name>rough rice</name></expression></admitted>
              <deprecates><expression><name>cargo rice</name></expression></deprecates>
              <definition><verbal-definition><p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">rice retaining its husk after threshing</p></verbal-definition></definition>
              <termnote id="_671a1994-4783-40d0-bc81-987d06ffb74e">
                <p id="_19830f33-e46c-42cc-94ca-a5ef101132d5">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
              </termnote>
              <termexample id="_bd57bbf1-f948-4bae-b0ce-73c00431f893">
                <ul>
                <li>A</li>
                </ul>
              </termexample>
              <termnote id="_671a1994-4783-40d0-bc81-987d06ffb74f">
              <ul><li>A</li></ul>
                <p id="_19830f33-e46c-42cc-94ca-a5ef101132d5">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
              </termnote>
              <termsource status="identical">
                <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011"><locality type="clause"><referenceFrom>3.1</referenceFrom></locality></origin>
              </termsource>
            </term>
            <term id="A">
              <preferred><expression><name>term1</name></expression></preferred>
              <definition><verbal-definition>term1 definition</verbal-definition></definition>
              <term id="B">
              <preferred><expression><name>term2</name></expression></preferred>
              <definition><verbal-definition>term2 definition</verbal-definition></definition>
              </term>
            </term>
          </terms>
        </sections>
      </iso-standard>
    INPUT
    presxml = <<~OUTPUT
      <?xml version='1.0'?>
      <iso-standard xmlns='http://riboseinc.com/isoxml' type="presentation">
        <sections>
          <terms id='_terms_and_definitions' obligation='normative' displayorder='1'>
          <title depth='1'>1<tab/>Terms and Definitions</title>

            <term id='paddy1'><name>1.1</name>
              <preferred><strong>paddy</strong></preferred>
              <definition>
                <p id='_eb29b35e-123e-4d1c-b50b-2714d41e747f'>&#x3c;rice&#x3e; rice retaining its husk after threshing</p>
              </definition>
              <termexample id='_bd57bbf1-f948-4bae-b0ce-73c00431f892'>
                <name>EXAMPLE 1</name>
                <p id='_65c9a509-9a89-4b54-a890-274126aeb55c'>Foreign seeds, husks, bran, sand, dust.</p>
                <ul>
                  <li>A</li>
                </ul>
              </termexample>
              <termexample id='_bd57bbf1-f948-4bae-b0ce-73c00431f894'>
                <name>EXAMPLE 2</name>
                <ul>
                  <li>A</li>
                </ul>
              </termexample>
              <termsource status='modified'>[SOURCE:
                <origin bibitemid='ISO7301' type='inline' citeas='ISO 7301:2011'><locality type='clause'><referenceFrom>3.1</referenceFrom></locality>ISO 7301:2011, 3.1</origin>, modified &#x2013; The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here]
              </termsource>
            </term>
            <term id='paddy'><name>1.2</name>
              <preferred><strong>paddy</strong></preferred>
              <admitted>paddy rice</admitted>
              <admitted>rough rice</admitted>
              <deprecates>cargo rice</deprecates>
              <definition>
                <p id='_eb29b35e-123e-4d1c-b50b-2714d41e747f'>rice retaining its husk after threshing</p>
              </definition>
              <termnote id='_671a1994-4783-40d0-bc81-987d06ffb74e'>
                <name>Note 1 to entry</name>
                <p id='_19830f33-e46c-42cc-94ca-a5ef101132d5'>The starch of waxy rice consists almost entirely of amylopectin. The
                  kernels have a tendency to stick together after cooking.</p>
              </termnote>
              <termnote id='_671a1994-4783-40d0-bc81-987d06ffb74f'>
                <name>Note 2 to entry</name>
                <ul>
                  <li>A</li>
                </ul>
                <p id='_19830f33-e46c-42cc-94ca-a5ef101132d5'>The starch of waxy rice consists almost entirely of amylopectin. The
                  kernels have a tendency to stick together after cooking.</p>
              </termnote>
              <termexample id='_bd57bbf1-f948-4bae-b0ce-73c00431f893'>
                <name>EXAMPLE</name>
                <ul>
                  <li>A</li>
                </ul>
              </termexample>
              <termsource status='identical'>[SOURCE:
                <origin bibitemid='ISO7301' type='inline' citeas='ISO 7301:2011'><locality type='clause'><referenceFrom>3.1</referenceFrom></locality>ISO 7301:2011, 3.1</origin>]
              </termsource>
            </term>
            <term id='A'>
              <name>1.3</name>
              <preferred><strong>term1</strong></preferred>
              <definition>term1 definition</definition>
              <term id='B'>
                <name>1.3.1</name>
                <preferred><strong>term2</strong></preferred>
                <definition>term2 definition</definition>
              </term>
            </term>
          </terms>
        </sections>
      </iso-standard>
    OUTPUT

    html = <<~OUTPUT
      #{HTML_HDR}
            <p class="zzSTDTitle1"/>
            <div id="_terms_and_definitions">
              <h1>1&#160; Terms and Definitions</h1>
              <p class="TermNum" id="paddy1">1.1</p><p class="Terms" style="text-align:left;"><b>paddy</b></p>

              <p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">&lt;rice&gt; rice retaining its husk after threshing</p>
              <div class="example" id="_bd57bbf1-f948-4bae-b0ce-73c00431f892">
                <p>
                  <span class="example_label">EXAMPLE 1</span>&#160; Foreign seeds, husks, bran, sand, dust.</p>
                <ul>
                  <li>A</li>
                </ul>
              </div>
              <div class="example" id="_bd57bbf1-f948-4bae-b0ce-73c00431f894">
                <p><span class="example_label">EXAMPLE 2</span>&#160;</p>
                <ul>
                  <li>A</li>
                </ul>
              </div>
              <p>[SOURCE:
                ISO 7301:2011, 3.1, modified &#8211;
                  The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here]</p>
              <p class="TermNum" id="paddy">1.2</p>
              <p class="Terms" style="text-align:left;"><b>paddy</b></p>
              <p class="AltTerms" style="text-align:left;">paddy rice</p>
              <p class="AltTerms" style="text-align:left;">rough rice</p>
              <p class="DeprecatedTerms" style="text-align:left;">DEPRECATED: cargo rice</p>
              <p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">rice retaining its husk after threshing</p>
              <div class="example" id="_bd57bbf1-f948-4bae-b0ce-73c00431f893">
                <p>
                  <span class="example_label">EXAMPLE</span>&#160;
                </p>
                <ul>
                  <li>A</li>
                </ul>
              </div>
              <div class="Note" id="_671a1994-4783-40d0-bc81-987d06ffb74e">
                <p>Note 1 to entry: The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
              </div>
              <div class="Note" id="_671a1994-4783-40d0-bc81-987d06ffb74f">
                <p>Note 2 to entry:
                  <ul>
                    <li>A</li></ul>
                  <p id="_19830f33-e46c-42cc-94ca-a5ef101132d5">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
                </p>
              </div>
              <p>[SOURCE: ISO 7301:2011, 3.1]</p>
              <p class='TermNum' id='A'>1.3</p>
              <p class='Terms' style='text-align:left;'><b>term1</b></p>
               term1 definition
              <p class='TermNum' id='B'>1.3.1</p>
              <p class='Terms' style='text-align:left;'><b>term2</b></p>
               term2 definition
            </div>
          </div>
        </body>
      </html>
    OUTPUT

    word = <<~OUTPUT
      <div id="_terms_and_definitions"><h1>1<span style="mso-tab-count:1">&#160; </span>Terms and Definitions</h1>
        <p class="TermNum" id="paddy1">1.1</p><p class="Terms" style="text-align:left;"><b>paddy</b></p>

        <p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f" class="Definition">&lt;rice&gt; rice retaining its husk after threshing</p>
        <div id="_bd57bbf1-f948-4bae-b0ce-73c00431f892" class="example"><p><span class="example_label">EXAMPLE 1</span><span style="mso-tab-count:1">&#160; </span>Foreign seeds, husks, bran, sand, dust.</p><ul>
          <li>A</li>
          </ul></div>
        <div id="_bd57bbf1-f948-4bae-b0ce-73c00431f894" class="example"><p><span class="example_label">EXAMPLE 2</span><span style="mso-tab-count:1">&#160; </span></p><ul>
          <li>A</li>
          </ul></div>

        <p class="Source">[SOURCE:
          ISO 7301:2011, 3.1, modified &#8211;
            The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here]</p>
        <p class="TermNum" id="paddy">1.2</p>
        <p class="Terms" style="text-align:left;"><b>paddy</b></p>
        <p class="AltTerms" style="text-align:left;">paddy rice</p>
        <p class="AltTerms" style="text-align:left;">rough rice</p>
        <p class="DeprecatedTerms" style="text-align:left;">DEPRECATED: cargo rice</p>
        <p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f" class="Definition">rice retaining its husk after threshing</p>
        <div id="_bd57bbf1-f948-4bae-b0ce-73c00431f893" class="example"><p><span class="example_label">EXAMPLE</span><span style="mso-tab-count:1">&#160; </span></p>
          <ul>
          <li>A</li>
          </ul>
        </div>
        <div id='_671a1994-4783-40d0-bc81-987d06ffb74e' class="Note"><p class="Note">Note 1 to entry: The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p></div>
        <div id='_671a1994-4783-40d0-bc81-987d06ffb74f' class="Note"><p class="Note">Note 2 to entry: <ul><li>A</li></ul><p id="_19830f33-e46c-42cc-94ca-a5ef101132d5">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p></p></div>
        <p class="Source">[SOURCE: ISO 7301:2011, 3.1]</p>
        <p class='TermNum' id='A'>1.3</p>
        <p class='Terms' style='text-align:left;'><b>term1</b></p>
         term1 definition
        <p class='TermNum' id='B'>1.3.1</p>
        <p class='Terms' style='text-align:left;'><b>term2</b></p>
         term2 definition
      </div>
    OUTPUT
    expect(xmlpp(IsoDoc::Iso::PresentationXMLConvert.new({})
      .convert("test", input, true)))
      .to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", presxml, true)))
      .to be_equivalent_to xmlpp(html)
    expect(xmlpp(IsoDoc::Iso::WordConvert.new({})
      .convert("test", presxml, true)
      .sub(%r{^.*<p class="zzSTDTitle1"/>}m, "")
      .sub(%r{</div>\s*<br.*$}m, "")))
      .to be_equivalent_to xmlpp(word)
  end
end
