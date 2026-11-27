# frozen_string_literal: true

require_relative "spec_helper"

# One violating and one clean fixture per ISO NISO STS coding-guidelines
# rule (ed 2.1) not already covered in iso_guidelines_validator_spec.rb.
# Each pair differs only in the property the rule checks. A fixture is a
# body String (spliced into <body>), a [body, back] pair, or a Proc that
# rewrites the whole conforming document.
# rubocop:disable-next RSpec/EmptyExampleGroup, RSpec/SpecFilePathFormat
RSpec.describe Metanorma::Iso::Sts::Validator do
  def sec(inner, id: nil)
    attr = id ? %( id="#{id}") : ""
    %(<sec#{attr}><label>4</label><title>X</title>#{inner}</sec>)
  end

  def note(id: nil, label: "NOTE")
    attr = id ? %( id="#{id}") : ""
    %(<non-normative-note#{attr}><label>#{label}</label><p>n</p></non-normative-note>)
  end

  def bibl(ref)
    %(<back><ref-list content-type="bibl"><title>Bibliography</title>#{ref}</ref-list></back>)
  end

  def norm_refs(refs, label: "2")
    %(<sec sec-type="norm-refs"><label>#{label}</label><title>Normative references</title>#{refs}</sec>)
  end

  def mml(inner = "<mml:mi>x</mml:mi>")
    %(<mml:math xmlns:mml="http://www.w3.org/1998/Math/MathML">#{inner}</mml:math>)
  end

  def term_entry(inner, id: "t1")
    %(<tbx:termEntry id="#{id}">#{inner}</tbx:termEntry>)
  end

  def lang_set(inner)
    %(<tbx:langSet xml:lang="en">#{inner}</tbx:langSet>)
  end

  def tig(term = "term", extra = "")
    %(<tbx:tig><tbx:term>#{term}</tbx:term>#{extra}</tbx:tig>)
  end

  def terms_sec(inner)
    %(<sec sec-type="terms"><label>3</label><title>Terms and definitions</title>#{inner}</sec>)
  end

  def terms_doc(inner)
    ->(x) { x.sub(%r{<sec sec-type="terms">.*?</sec>}m, terms_sec(inner)) }
  end

  def full_entry(extra_lang = "", extra_tig = "", entry_extra = "")
    term_entry(lang_set(tig("term", extra_tig) +
                        "<tbx:definition>d</tbx:definition>#{extra_lang}") +
               entry_extra)
  end

  def legend_ok(word)
    %(<legend><title>#{word}</title><def-list><def-item><term>a</term><def><p>b</p></def></def-item></def-list></legend>)
  end

  def base_xml(body = "", back: "")
    <<~XML
      <?xml version="1.0"?>
      <standard xmlns:tbx="urn:iso:std:iso:30042:ed-1" xmlns:xlink="http://www.w3.org/1999/xlink" xml:lang="en" dtd-version="1.2">
        <processing-meta tagset-family="sts" base-tagset="interchange" table-model="xhtml" mathml-version="3.0" math-representation="mathml" terminology-model="tbx">
          <custom-meta-group><custom-meta><meta-name>iec_iso_coding_guidelines_edition</meta-name><meta-value>2.1</meta-value></custom-meta></custom-meta-group>
        </processing-meta>
        <front>
          <std-meta><permissions><copyright-statement>All rights reserved</copyright-statement></permissions></std-meta>
          <sec sec-type="foreword"><title>Foreword</title><p>Foreword text.</p></sec>
        </front>
        <body>
          <sec sec-type="scope"><label>1</label><title>Scope</title><p>Scope text.</p></sec>
          <sec sec-type="norm-refs"><label>2</label><title>Normative references</title><p>There are no normative references.</p></sec>
          <sec sec-type="terms"><label>3</label><title>Terms and definitions</title><p>No terms are defined.</p></sec>
          #{body}
        </body>
        #{back}
      </standard>
    XML
  end

  def build(fixture)
    case fixture
    when Proc then fixture.call(base_xml)
    when Array then base_xml(fixture[0].to_s, back: fixture[1].to_s)
    else base_xml(fixture.to_s)
    end
  end

  def ids_for(fixture)
    described_class.new.validate(build(fixture)).errors.map(&:rule_id)
  end

  def keep
    ->(x) { x }
  end

  def meta(originator)
    ->(x) { x.sub("<std-meta>", "<std-meta><std-ident><originator>#{originator}</originator></std-ident>") }
  end

  def table(cell: "a", tattrs: "", tdattrs: "", wattrs: "", foot: "")
    %(<table-wrap id="tw"#{wattrs}><label>Table 1</label><caption><title>T</title></caption><table#{tattrs}><tbody><tr><td#{tdattrs}>#{cell}</td></tr></tbody></table>#{foot}</table-wrap>)
  end

  def fig(inner = "", attrs: "", caption_extra: "")
    %(<fig#{attrs}><label>Figure 1</label><caption><title>F</title>#{caption_extra}</caption>#{inner}</fig>)
  end

  def disp_formula(inner)
    %(<disp-formula><label>(1)</label>#{inner}</disp-formula>)
  end

  def cross_ref(attrs, extra = "")
    sec(%(<p><xref #{attrs}>x</xref></p>) + extra)
  end

  def std_cite(urn: true)
    link = urn ? ' std-id-link-type="urn"' : ""
    sec(%(<p><std><std-id#{link}>ISO 1</std-id></std></p>))
  end

  def ref_std(link: ' std-id-link-type="urn"')
    %(<ref id="r1"><std><std-id#{link} std-id-type="dated">urn:iso:std:iso:1:ed-1</std-id><std-ref>ISO 1</std-ref><title>T</title></std></ref>)
  end

  def norm_doc(refs)
    ->(x) { x.sub(%r{<sec sec-type="norm-refs">.*?</sec>}m, norm_refs(%(<ref-list content-type="norm-refs">#{refs}</ref-list>))) }
  end

  def iso_doc(body)
    ->(_) { meta("ISO").call(base_xml(body)) }
  end

  def def_item(id)
    %(<def-list list-content="abbreviation"><def-item id="#{id}"><term>A</term><def><p>x</p></def></def-item></def-list>)
  end

  def g(href: "a", attrs: "")
    %(<graphic xlink:href="#{href}"#{attrs}/>)
  end

  def self.rule(id, &fixtures)
    describe id do
      it "fires on a violating fixture" do
        bad, = instance_exec(&fixtures)
        expect(ids_for(bad)).to include(id)
      end

      it "stays silent on the clean fixture" do
        _, good = instance_exec(&fixtures)
        expect(ids_for(good)).not_to include(id)
      end
    end
  end

  # -- cross references (10.1, 10.2) --------------------------------------
  rule("iso-gdg-10.1.3-1") do
    [cross_ref('ref-type="custom" custom-type="note" rid="n9"'),
     cross_ref('ref-type="custom" custom-type="note" rid="n9"', note(id: "n9"))]
  end
  rule("iso-gdg-10.1.4-1") do
    [cross_ref('ref-type="abbreviation" rid="a1"'),
     cross_ref('ref-type="abbreviation" rid="a1"', def_item("a1"))]
  end
  rule("iso-gdg-10.1.5-1") do
    lst = '<list list-type="arabic"><list-item id="l1"><label>1</label><p>a</p></list-item></list>'
    [cross_ref('ref-type="list" rid="l1"'),
     cross_ref('ref-type="list" rid="l1"', lst)]
  end
  rule("iso-gdg-10.1.6-1") do
    ref = '<ref id="r1"><mixed-citation>A</mixed-citation></ref>'
    [cross_ref('ref-type="bibr" rid="r1"'),
     [cross_ref('ref-type="bibr" rid="r1"'), bibl(ref)]]
  end
  rule("iso-gdg-10.1.7-1") do
    ref = '<ref id="r1"><std><std-id>ISO 1</std-id></std></ref>'
    [std_cite, [std_cite, bibl(ref)]]
  end
  rule("iso-gdg-10.2-1") { [std_cite(urn: false), std_cite] }

  # -- front matter and metadata (4.3, A.2, A.3) --------------------------
  rule("iso-gdg-4.3.2-1") do
    [->(x) { x.sub("</front>", "</front><std-doc-meta><permissions/></std-doc-meta>") },
     keep]
  end
  rule("iso-gdg-4.3.2-2") do
    [->(x) { x.sub(%r{<permissions>.*?</permissions>}m, "") }, keep]
  end
  rule("iso-gdg-4.3.2-3") do
    second = "</permissions><permissions><copyright-statement>b</copyright-statement></permissions>"
    [->(x) { meta("ISO").call(x).sub("</permissions>", second) }, meta("ISO")]
  end
  rule("iso-gdg-4.3.2-4") do
    iec = "<std-ident><originator>IEC</originator></std-ident>"
    adopt = ->(perm) { "<adoption><standard><front><std-meta>#{iec}#{perm}</std-meta></front></standard></adoption>" }
    [->(_) { adopt.call("") }, ->(_) { adopt.call("<permissions/>") }]
  end
  rule("iso-gdg-4.3.2-7") do
    [->(x) { x.sub(%r{<custom-meta-group>.*?</custom-meta-group>}m, "") }, keep]
  end
  rule("iso-gdg-4.3.3-1") do
    [->(x) { x.sub('<sec sec-type="foreword">', '<sec sec-type="foreword"><label>0</label>') }, keep]
  end
  rule("iso-gdg-4.3.4-1") do
    intro = ->(attr) { ->(x) { x.sub("</front>", "<sec#{attr}><title>Introduction</title><p>i</p></sec></front>") } }
    [intro.call(""), intro.call(' sec-type="intro"')]
  end
  rule("iso-gdg-A.2-1") { [->(_) { "<other/>" }, keep] }
  rule("iso-gdg-A.3.1-1") { [->(_) { "<adoption/>" }, ->(_) { "<adoption><standard/></adoption>" }] }
  rule("iso-gdg-A.3.1-2") do
    adopt = ->(inner) { ->(_) { "<adoption><standard><front><std-meta>#{inner}</std-meta></front></standard></adoption>" } }
    [adopt.call(""), adopt.call("<originator>ISO</originator>")]
  end
  rule("iso-gdg-A.3.1-3") do
    meta2 = "<standard><front><std-meta/></front></standard>"
    [->(_) { "<adoption>#{meta2}<std-meta/></adoption>" },
     ->(_) { "<adoption><adoption-front><std-meta/></adoption-front>#{meta2}</adoption>" }]
  end
  rule("iso-gdg-A.3.1-5") do
    [->(x) { x.sub("</front>", "<iso-meta/></front>") }, keep]
  end

  # -- normative references, annexes, bibliography (4.4, 4.5) -------------
  rule("iso-gdg-4.4.2-3") do
    [->(x) { x.sub("<label>2</label>", "<label>9</label>") }, keep]
  end
  %w[iso-gdg-4.4.2-4 iso-gdg-4.4.2-7].each do |id|
    rule(id) do
      [norm_doc('<ref id="r1"><label>[1]</label></ref>'),
       norm_doc('<ref id="r1"><mixed-citation>A</mixed-citation></ref>')]
    end
  end
  rule("iso-gdg-4.4.2-5") do
    [norm_doc(ref_std(link: "")), norm_doc(ref_std)]
  end
  rule("iso-gdg-4.4.2-8") do
    [terms_doc(""), keep]
  end
  rule("iso-gdg-4.4.2-9") do
    [sec('<sec sec-type="numbered-paragraph"><title>T</title><p>x</p></sec>'),
     sec('<sec sec-type="numbered-paragraph"><label>4.1</label><p>x</p></sec>')]
  end
  rule("iso-gdg-4.5.1-3") do
    app = lambda { |lbl|
      %(<back><app-group><app id="a" content-type="informative"><label>Annex A</label><title>T</title><sec><label>#{lbl}</label><title>S</title><p>x</p></sec></app></app-group></back>)
    }
    [["", app.call("1.1")], ["", app.call("A.1")]]
  end
  rule("iso-gdg-4.5.2-1") do
    bib = '<ref-list content-type="bibl"><title>B</title></ref-list>'
    [["", "<back>#{bib}<app-group/></back>"], ["", "<back><app-group/>#{bib}</back>"]]
  end
  rule("iso-gdg-4.5.2-2") do
    [["", bibl('<ref id="r1"><label>[1]</label></ref>')],
     ["", bibl('<ref id="r1"><mixed-citation>A</mixed-citation></ref>')]]
  end

  # -- graphics, notes, lists, quotes (5.x) -------------------------------
  rule("iso-gdg-5.10-1") do
    [sec(%(<p>t#{g}</p>)), sec(%(<p>t<inline-graphic xlink:href="a"/></p>))]
  end
  rule("iso-gdg-5.10-2") { [sec(g(href: "a.png")), sec(g)] }
  rule("iso-gdg-5.10-3") do
    [iso_doc(sec(g(href: "dir/a"))), iso_doc(sec(g))]
  end
  rule("iso-gdg-5.10-4") do
    [sec(g(attrs: ' specific-use="size:X"')), sec(g(attrs: ' specific-use="size:M"'))]
  end
  rule("iso-gdg-5.11-1") do
    sc = ->(style) { sec(%(<p><styled-content style="#{style}">x</styled-content></p>)) }
    [sc.call("font-family:Courier"), sc.call("color:red")]
  end
  rule("iso-gdg-5.6-1") do
    n = ->(t) { sec(%(<non-normative-note content-type="#{t}"><label>NOTE</label><p>n</p></non-normative-note>)) }
    [n.call("odd"), n.call("warning")]
  end
  rule("iso-gdg-5.6-2") do
    [sec("<non-normative-note><p>n</p></non-normative-note>"), sec(note)]
  end
  rule("iso-gdg-5.6-3") do
    [sec("<non-normative-note><label>NOTE</label></non-normative-note>"), sec(note)]
  end
  rule("iso-gdg-5.7-3") do
    lst = '<list list-type="dash"><list-item><p>a</p></list-item></list>'
    [sec("<p>t#{lst}</p>"), sec("<p>t</p>#{lst}")]
  end
  rule("iso-gdg-5.7-4") do
    li = ->(lbl) { sec(%(<list list-type="arabic"><list-item>#{lbl}<p>a</p></list-item></list>)) }
    [li.call(""), li.call("<label>1</label>")]
  end
  rule("iso-gdg-5.7.2-1") do
    li = ->(lbl) { sec(%(<list list-type="dash"><list-item>#{lbl}<p>a</p></list-item></list>)) }
    [li.call("<label>-</label>"), li.call("")]
  end
  rule("iso-gdg-5.8-1") do
    [sec("<array><label>x</label></array>"),
     sec("<array><table><tbody><tr><td>a</td></tr></tbody></table></array>")]
  end
  rule("iso-gdg-5.8-2") do
    arr = ->(w) { sec(%(<array><table><col width="#{w}"/><tbody><tr><td>a</td></tr></tbody></table></array>)) }
    [arr.call("10"), arr.call("50%")]
  end
  rule("iso-gdg-5.9-1") do
    q = ->(attrs) { sec(%(<disp-quote><p>q</p><attrib#{attrs}>A</attrib></disp-quote>)) }
    [q.call(""), q.call(' specific-use="source"')]
  end

  # -- tables (6.x) --------------------------------------------------------
  rule("iso-gdg-6.1-1") do
    nested = "<table><tbody><tr><td>x</td></tr></tbody></table>"
    [sec(table(cell: nested)), sec(table)]
  end
  rule("iso-gdg-6.1-2") do
    [sec(table(tattrs: ' width="50%"')), sec(table(tattrs: ' width="33%"'))]
  end
  rule("iso-gdg-6.2.1-1") do
    arr = "<array><table><tbody><tr><td>a</td></tr></tbody></table></array>"
    [sec(disp_formula(mml + arr)), sec(disp_formula(mml) + arr)]
  end
  rule("iso-gdg-6.2.2-1") do
    tw = ->(lbl) { sec(%(<table-wrap id="tw"><label>#{lbl}</label><caption><title>T</title></caption><table><tbody><tr><td>a</td></tr></tbody></table></table-wrap>)) }
    [tw.call("Table 1."), tw.call("Table 1")]
  end
  rule("iso-gdg-6.2.2-2") do
    tw = ->(rows) { sec(%(<table-wrap id="tw"><label>Table 1</label><caption><title>T</title></caption><table>#{rows}</table></table-wrap>)) }
    [tw.call("<tr><td>a</td></tr>"), tw.call("<tbody><tr><td>a</td></tr></tbody>")]
  end
  rule("iso-gdg-6.2.2-3") do
    foot = ->(inner) { sec(table(foot: "<table-wrap-foot>#{inner}</table-wrap-foot>")) }
    [foot.call('<list list-type="dash"><list-item><p>a</p></list-item></list>'), foot.call("<p>a</p>")]
  end
  rule("iso-gdg-6.2.2-4") do
    ref = '<p><xref ref-type="table-fn" rid="f1">a</xref></p>'
    [sec(ref + table),
     sec(ref + table(foot: '<table-wrap-foot><fn id="f1"><p>n</p></fn></table-wrap-foot>'))]
  end
  rule("iso-gdg-6.2.2-5") do
    bare = %(<table-wrap id="tw"><label>Table 1</label><caption><title>T</title></caption><table><tbody>#{note}</tbody></table></table-wrap>)
    [sec(bare), sec(table(cell: note))]
  end
  rule("iso-gdg-6.2.2-7") do
    foot = ->(attr) { sec(table(foot: "<table-wrap-foot><p#{attr}>a</p></table-wrap-foot>")) }
    [foot.call(' content-type="other"'), foot.call(' content-type="dimension"')]
  end
  rule("iso-gdg-6.3.1-1") do
    [sec(table(tdattrs: ' align="middle"')), sec(table(tdattrs: ' align="center"'))]
  end
  rule("iso-gdg-6.4-1") do
    [sec(table(tdattrs: ' rowspan="0"')), sec(table(tdattrs: ' rowspan="2"'))]
  end
  rule("iso-gdg-6.5-1") { [sec(table(cell: "a<br/>b")), sec(table(cell: "ab"))] }
  rule("iso-gdg-6.6-1") do
    [sec(table(wattrs: ' orientation="diagonal"')), sec(table(wattrs: ' orientation="landscape"'))]
  end

  # -- formulas (7.x) ------------------------------------------------------
  rule("iso-gdg-7.1-1") do
    inline = ->(lbl) { sec(%(<p><inline-formula>#{lbl}#{mml}</inline-formula></p>)) }
    [inline.call("<label>(1)</label>"), inline.call("")]
  end
  rule("iso-gdg-7.1-2") do
    [sec(%(<disp-formula id="formula_1">#{mml}</disp-formula>)), sec(disp_formula(mml))]
  end
  # IEC Guidelines 7.1 (ed 2.1, the unnumbered-formula annotation): "Generally,
  # <disp-formula> is used for unnumbered block formulae" and their IDs take the
  # form for-informal-X-Y. A block formula without a <label> is unnumbered.

  it "leaves an unnumbered block formula without a <label> alone (Guidelines 7.1)" do
    unnumbered = [sec(%(<disp-formula id="for-informal-5.1.3-1">#{mml}</disp-formula>)),
                  sec("<disp-formula>#{mml}</disp-formula>")]
    expect(unnumbered.flat_map { |xml| ids_for(xml) }).not_to include("iso-gdg-7.1-2")
  end

  rule("iso-gdg-7.2-1") do
    [sec(disp_formula(note + mml)), sec(disp_formula(mml + note))]
  end
  rule("iso-gdg-7.3-1") do
    [sec(disp_formula(mml + (legend_ok("where") * 2))), sec(disp_formula(mml + legend_ok("where")))]
  end
  rule("iso-gdg-7.3-2") do
    [sec(disp_formula(mml + legend_ok("Foo"))), sec(disp_formula(mml + legend_ok("where")))]
  end
  rule("iso-gdg-7.4-1") do
    [sec(disp_formula("")), sec(disp_formula(mml))]
  end

  # -- figures (8.x) -------------------------------------------------------
  rule("iso-gdg-8.1-1") do
    [sec(fig(g, attrs: ' orientation="diagonal"')), sec(fig(g, attrs: ' orientation="landscape"'))]
  end
  rule("iso-gdg-8.1-2") { [sec(fig), sec(fig(g))] }
  rule("iso-gdg-8.2-1") do
    [sec("<fig-group><label>Figure 2</label>#{fig(g)}<p>x</p></fig-group>"),
     sec("<fig-group><label>Figure 2</label>#{fig(g)}</fig-group>")]
  end
  rule("iso-gdg-8.2-2") do
    [sec("<fig-group><label>Figure 2</label>#{fig(g)}#{note}</fig-group>"),
     sec("<fig-group><label>Figure 2</label>#{fig(g)}</fig-group>")]
  end
  rule("iso-gdg-8.3-1") do
    [sec(fig(g + (legend_ok("Key") * 2))), sec(fig(g + legend_ok("Key")))]
  end
  rule("iso-gdg-8.3-2") do
    [sec(fig(g + legend_ok("Foo"))), sec(fig(g + legend_ok("Key")))]
  end
  rule("iso-gdg-8.4-1") do
    dim = ->(attr) { sec(fig(g, caption_extra: "<p#{attr}>Dimensions in mm</p>")) }
    [dim.call(""), dim.call(' content-type="dimension"')]
  end

  # -- terminology (9.x, A.3.2) -------------------------------------------
  rule("iso-gdg-9.1-1") do
    [terms_doc("<sec><title>c</title>#{full_entry}</sec>"), terms_doc(full_entry)]
  end
  rule("iso-gdg-9.2.1-1") do
    [terms_doc(term_entry('<tbx:langSet xml:lang="en"/>')), terms_doc(full_entry)]
  end
  rule("iso-gdg-9.2.2-1") do
    [terms_doc(term_entry("<tbx:definition>d</tbx:definition>")), terms_doc(full_entry)]
  end
  rule("iso-gdg-9.2.3-1") do
    two = term_entry(lang_set("<tbx:tig><tbx:term>a</tbx:term><tbx:term>b</tbx:term></tbx:tig><tbx:definition>d</tbx:definition>"))
    [terms_doc(two), terms_doc(full_entry)]
  end
  rule("iso-gdg-9.2.3-2") do
    [terms_doc(full_entry("", '<tbx:partOfSpeech value="pron"/>')),
     terms_doc(full_entry("", '<tbx:partOfSpeech value="noun"/>'))]
  end
  rule("iso-gdg-9.2.3-3") do
    [terms_doc(full_entry("", '<tbx:termType value="odd"/>')),
     terms_doc(full_entry("", '<tbx:termType value="fullForm"/>'))]
  end
  rule("iso-gdg-9.2.3-4") do
    [terms_doc(full_entry("", '<tbx:normativeAuthorization value="odd"/>')),
     terms_doc(full_entry("", '<tbx:normativeAuthorization value="preferredTerm"/>'))]
  end
  rule("iso-gdg-9.2.4-1") do
    [terms_doc(full_entry("<tbx:example>EXAMPLE foo</tbx:example>")),
     terms_doc(full_entry("<tbx:example>foo</tbx:example>"))]
  end
  rule("iso-gdg-9.2.5-1") do
    [terms_doc(full_entry("<tbx:note>Note 1 to entry: x</tbx:note>")),
     terms_doc(full_entry("<tbx:note>x</tbx:note>"))]
  end
  rule("iso-gdg-9.2.6-1") do
    [terms_doc(full_entry('<tbx:entailedTerm target="nowhere">x</tbx:entailedTerm>')),
     terms_doc(full_entry('<tbx:entailedTerm target="t1">x</tbx:entailedTerm>'))]
  end
  rule("iso-gdg-9.2.6-2") do
    ref = ->(attrs) { ->(x) { terms_doc(full_entry).call(x).sub("</body>", "#{sec(%(<p><xref #{attrs} rid="t1">x</xref></p>))}</body>") } }
    [ref.call('ref-type="sec"'), ref.call('ref-type="custom" custom-type="term-entry"')]
  end
  rule("iso-gdg-9.2.8-1") do
    [terms_doc(full_entry("<tbx:source>[SOURCE: ISO 1]</tbx:source>")),
     terms_doc(full_entry("<tbx:source>ISO 1</tbx:source>"))]
  end
  rule("iso-gdg-9.2.9-1") do
    [terms_doc(full_entry("", "", "<tbx:subjectField>f</tbx:subjectField>")),
     terms_doc(full_entry("<tbx:subjectField>f</tbx:subjectField>"))]
  end
  rule("iso-gdg-A.3.2-1") do
    no_lang = term_entry("<tbx:langSet>#{tig}<tbx:definition>d</tbx:definition></tbx:langSet>")
    [terms_doc(no_lang), terms_doc(full_entry)]
  end
  rule("iso-gdg-A.3.2-2") do
    ts = ->(lbl) { sec(%(<term-sec id="ts"><label>#{lbl}</label></term-sec>)) }
    [ts.call(" "), ts.call("3.1")]
  end

  # -- legacy and discouraged markup (B.2, E.2) ---------------------------
  rule("iso-gdg-B.2.1-1") { [sec("<toc/>"), sec("<p>x</p>")] }
  rule("iso-gdg-B.2.1-2") { [sec("<p>\u00a9 ISO</p>"), sec("<p>ISO</p>")] }
  rule("iso-gdg-B.2.6-1") do
    app = ->(t) { ["", %(<back><app-group><app id="a" content-type="#{t}"><label>Annex A</label><title>T</title><p>x</p></app></app-group></back>)] }
    [app.call("inform"), app.call("informative")]
  end
  rule("iso-gdg-B.2.6-2") do
    [["", bibl("<ref-list><title>sub</title></ref-list>")],
     ["", bibl('<ref id="r1"><mixed-citation>A</mixed-citation></ref>')]]
  end
  rule("iso-gdg-B.2.9-1") do
    sc = ->(t) { sec(%(<p><styled-content style-type="#{t}">x</styled-content></p>)) }
    [sc.call("bogus"), sc.call("addition")]
  end
  rule("iso-gdg-E.2-1") do
    pdf = '<supplementary-material id="m" xlink:href="a.pdf"/>'
    [sec(pdf), ->(x) { x.sub("<p>Foreword text.</p>", "<p>Foreword text.</p>#{pdf}") }]
  end
end
