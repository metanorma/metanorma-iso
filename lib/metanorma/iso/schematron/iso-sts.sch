<?xml version="1.0" encoding="UTF-8"?>
<!--
  Schematron rules for IEC/ISO NISO STS documents, extracted from
  "NISO STS 1.2 - IEC/ISO Coding Guidelines, Edition 2.1" (2025-02-17).

  Encodes the severity:error rules of
  lib/sts_specs/iso_guidelines/rules_catalog.md; each <assert>/<report> id
  matches a catalog rule id (iso-gdg-<section>-<n>) exactly.

  Namespace context: NISO STS elements are in no namespace (root <standard>);
  TBX terminology under urn:iso:std:iso:30042:ed-1; MathML under the W3C
  MathML namespace; XLink attributes under the W3C XLink namespace.

  The catalogue's warning-level rules (recommended practice) are documented
  in rules_catalog.md only and intentionally not encoded here.
-->
<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
        xmlns:xs="http://www.w3.org/2001/XMLSchema">
  <title>IEC/ISO NISO STS Coding Guidelines ed. 2.1 conformance rules</title>
  <ns prefix="tbx" uri="urn:iso:std:iso:30042:ed-1"/>
  <ns prefix="mml" uri="http://www.w3.org/1998/Math/MathML"/>
  <ns prefix="xlink" uri="http://www.w3.org/1999/xlink"/>

  <!-- ============================================================= -->
  <!-- Document structure (guidelines 3.4, 4.1, Annex A.2/A.3.1)     -->
  <!-- ============================================================= -->
  <pattern id="iso-gdg-document-structure">
    <rule context="/*">
      <assert id="iso-gdg-4.1-1" test="self::standard or self::adoption">
        The complete document shall be coded within the root &lt;standard&gt;
        (or &lt;adoption&gt; for adoptions per Annex A) (Guidelines 4.1).
      </assert>
      <assert id="iso-gdg-A.2-1" test="self::standard or self::adoption">
        The status of a derived document (translated, adopted, modified or
        not) shall be mentioned; adoptions use the &lt;adoption&gt; root
        (Annex A.2).
      </assert>
      <assert id="iso-gdg-3.4-1"
              test="not(//@rid[not(. = //@id) and not(. = //@xml:id)])">
        An element that is the target of a cross-reference always has an ID:
        every @rid shall resolve to an @id/@xml:id in the document
        (Guidelines 3.4).
      </assert>
      <assert id="iso-gdg-A.3.1-8"
              test="every $i in (//@id, //@xml:id)
                    satisfies count((//@id, //@xml:id)[. = $i]) = 1">
        Additional content requires new unique IDs: all @id/@xml:id values
        shall be unique within the document (Annex A.3.1 IDs).
      </assert>
      <report id="iso-gdg-9.2.7-1" test="//tbx:see">
        References from the terms and definitions to other clauses, tables,
        figures etc. now use &lt;xref&gt;; &lt;tbx:see&gt; shall not be used
        (Guidelines 9.2.7).
      </report>
      <report id="iso-gdg-A.3.1-5" test="//iso-meta | //reg-meta | //nat-meta">
        &lt;iso-meta&gt;, &lt;reg-meta&gt; and &lt;nat-meta&gt; are outdated
        and shall be avoided (Annex A.3.1, Annex C.1).
      </report>
      <report id="iso-gdg-B.2.1-1" test="//toc | //toc-entry | //toc-entry-group">
        Cover pages, tables of contents, page headers/footers and page-number
        indexes are not captured in the XML (Guidelines B.2.1).
      </report>
      <report id="iso-gdg-B.2.13-1" test="//boxed-text">
        Boxed text is deprecated and shall not be used in OSD documents;
        label-bearing content (Warning / Important / ...) is coded as notes
        (Guidelines B.2.13).
      </report>
    </rule>
    <rule context="standard">
      <assert id="iso-gdg-4.3.1-1" test="front">
        &lt;front&gt; is required in ISO/IEC standards (Guidelines 4.3.1).
      </assert>
      <assert id="iso-gdg-4.4.1-1" test="body">
        &lt;body&gt; is required in ISO/IEC documents (Guidelines 4.4.1).
      </assert>
      <assert id="iso-gdg-4.3.2-6"
              test="processing-meta[@base-tagset='interchange']
                                    [@mathml-version='3.0']
                                    [@table-model='xhtml']
                                    [@terminology-model='tbx']
                                    [@math-representation='mathml']
                                    [@tagset-family='sts']">
        &lt;processing-meta&gt; shall be a child of &lt;standard&gt; declaring
        the coding profile: base-tagset=interchange, mathml-version=3.0,
        table-model=xhtml, terminology-model=tbx,
        math-representation=mathml, tagset-family=sts (Guidelines 4.3.2).
      </assert>
      <assert id="iso-gdg-4.3.2-7"
              test="processing-meta/custom-meta-group/custom-meta
                      [meta-name='iec_iso_coding_guidelines_edition']
                      [normalize-space(meta-value) != '']">
        &lt;processing-meta&gt; shall carry a &lt;custom-meta&gt; with
        meta-name iec_iso_coding_guidelines_edition and the guidelines
        edition as meta-value (Guidelines 4.3.2).
      </assert>
      <assert id="iso-gdg-4.3.2-1"
              test="not(std-doc-meta//permissions)
                    and not(std-doc-meta//copyright-holder)
                    and not(std-doc-meta//copyright-statement)">
        Organization metadata are not captured in &lt;std-doc-meta&gt;; they
        are captured in &lt;std-meta&gt; (Guidelines 4.3.2).
      </assert>
      <assert id="iso-gdg-4.3.2-2" test="front//std-meta/permissions">
        Copyright information for the current document is captured in the
        metadata via the &lt;permissions&gt; element within &lt;std-meta&gt;
        (Guidelines 4.3.2).
      </assert>
      <assert id="iso-gdg-4.3.2-3"
              test="(not(front//std-meta//originator[normalize-space()='ISO'])
                    or count(front//std-meta/permissions) = 1)
                   and (not(front//std-meta//originator[normalize-space()='IEC'])
                    or exists(front//std-meta/permissions))">
        ISO coding sums all copyright statements in one &lt;permissions&gt;
        element; IEC coding divides them into individual &lt;permissions&gt;
        elements within &lt;std-meta&gt; (Guidelines 4.3.2).
      </assert>
      <assert id="iso-gdg-4.3.3-1"
              test="front/sec[@sec-type='foreword' and not(label)]">
        The foreword is required, unnumbered, and coded as &lt;sec&gt; with
        @sec-type="foreword"; it is the first titled clause (Guidelines 4.3.3).
      </assert>
      <assert id="iso-gdg-4.3.4-1"
              test="not(front/sec[matches(normalize-space(title), '^Introduction$', 'i')
                                  and not(@sec-type='intro')])">
        The introduction, when present, is coded as &lt;sec&gt; with
        @sec-type="intro" (Guidelines 4.3.4).
      </assert>
      <assert id="iso-gdg-4.4.2-2"
              test="body/sec[@sec-type='scope'][normalize-space(label)='1']">
        The Scope clause is required and is numbered 1, with
        @sec-type="scope" (Guidelines 4.4.2).
      </assert>
      <assert id="iso-gdg-4.4.2-3"
              test="body/sec[@sec-type='norm-refs'][normalize-space(label)='2']">
        The Normative references clause is required and is numbered 2; when
        there are none it still contains a paragraph stating that
        (Guidelines 4.4.2).
      </assert>
      <assert id="iso-gdg-4.4.2-8"
              test="body/sec[@sec-type='terms']
                    and (body/sec[@sec-type='terms']//tbx:termEntry
                         or body/sec[@sec-type='terms']//p)">
        The terms and definitions clause is required with
        @sec-type="terms"; with no terms it contains a statement to that
        effect (Guidelines 4.4.2).
      </assert>
      <assert id="iso-gdg-4.2-1"
              test="every $s in //sec[normalize-space(title) != ''] satisfies
                    (if (matches(normalize-space($s/title), '^Foreword$', 'i')) then $s/@sec-type = 'foreword'
                     else if (matches(normalize-space($s/title), '^Introduction$', 'i')) then $s/@sec-type = 'intro'
                     else if (matches(normalize-space($s/title), '^Scope$', 'i')) then $s/@sec-type = 'scope'
                     else if (matches(normalize-space($s/title), '^Normative [rR]eferences$')) then $s/@sec-type = 'norm-refs'
                     else if (matches(normalize-space($s/title), 'Terms') and matches(normalize-space($s/title), 'Definitions')) then $s/@sec-type = 'terms'
                     else true())">
        A clause whose title identifies a known clause type is flagged via
        @sec-type: Foreword/foreword, Introduction/intro, Scope/scope,
        Normative references/norm-refs, Terms and definitions/terms
        (Guidelines 4.2).
      </assert>
      <assert id="iso-gdg-4.5.2-1"
              test="if (back/ref-list[@content-type='bibl'])
                    then not(back/ref-list[@content-type='bibl']/following-sibling::*)
                    else true()">
        The bibliography is the last element in the document back matter,
        coded as a &lt;ref-list&gt; with @content-type="bibl" (Guidelines
        4.5.2).
      </assert>
    </rule>
    <rule context="adoption">
      <assert id="iso-gdg-A.3.1-1" test="standard">
        Organisations adopting an International Standard use the
        &lt;adoption&gt; element, and inside it the &lt;standard&gt; element
        contains the original or translated standard (Annex A.3.1).
      </assert>
      <assert id="iso-gdg-A.3.1-2" test="standard//std-meta[//originator]">
        The metadata of the originating organisation are preserved within the
        inner &lt;standard&gt; and must not be modified (full preservation is
        verified against the source document) (Annex A.3.1).
      </assert>
      <assert id="iso-gdg-A.3.1-3"
              test="exists(.//adoption-front) or count(.//std-meta) &lt;= 1">
        Metadata of the adopting organisation are contained in
        &lt;adoption-front&gt;, not mixed into the original &lt;std-meta&gt;
        (Annex A.3.1).
      </assert>
      <assert id="iso-gdg-4.3.2-4"
              test="not(standard//std-ident/originator[normalize-space()='IEC'])
                    or exists(standard//std-meta/permissions)">
        In adoptions of IEC documents the individual IEC copyright
        &lt;permissions&gt; statements must not be overwritten (full
        preservation is verified against the source document) (Guidelines
        4.3.2).
      </assert>
    </rule>
    <rule context="sec">
      <assert id="iso-gdg-4.4.2-1"
              test="if (sec) then exists(label) else true()">
        Clauses are captured in &lt;sec&gt; with the clause number as
        &lt;label&gt; and the title as &lt;title&gt;; a clause containing
        subclauses carries its number (Guidelines 4.4.2).
      </assert>
    </rule>
    <rule context="sec[@sec-type='numbered-paragraph']">
      <assert id="iso-gdg-4.4.2-9" test="label and not(title)">
        Numbered paragraphs are tagged as sections without a title with
        @sec-type="numbered-paragraph"; the text follows the label directly
        (Guidelines 4.4.2).
      </assert>
    </rule>
    <rule context="sec[@sec-type='terms']">
      <assert id="iso-gdg-9.1-1" test="not(sec[tbx:termEntry])">
        Subclauses of the terms and definitions clause are &lt;sec&gt;;
        terminological entries are term-sec/TBX and shall not be coded as
        subclauses (Guidelines 9.1).
      </assert>
    </rule>
    <rule context="app">
      <assert id="iso-gdg-4.5.1-1"
              test="@content-type = ('informative', 'normative')">
        All annexes are coded as &lt;app&gt; within an &lt;app-group&gt; with
        @content-type of informative or normative (Guidelines 4.5.1).
      </assert>
      <assert id="iso-gdg-4.5.1-2" test="label and title and not(annex-type)">
        The word "Annex" and the annex number are coded using &lt;label&gt;,
        the annex title in &lt;title&gt;; the annex type is derived from
        @content-type on rendering and is not coded as text
        (&lt;annex-type&gt; occurs only in traditional-chain ISO content)
        (Guidelines 4.5.1, B.2.6).
      </assert>
      <let name="anx-letter" value="substring(normalize-space(label), 7, 1)"/>
      <assert id="iso-gdg-4.5.1-3"
              test="not(starts-with(normalize-space(label), 'Annex '))
                    or every $l in .//sec/label
                       satisfies starts-with(normalize-space($l), $anx-letter || '.')">
        Clauses inside an annex are &lt;sec&gt; elements whose &lt;label&gt;
        inherits the label prefix of the parent annex (e.g. A.1, A.2)
        (Guidelines 4.5.1).
      </assert>
    </rule>
    <rule context="back">
      <assert id="iso-gdg-4.5.2-2"
              test="not(ref-list[@content-type='bibl']/ref[not(std) and not(mixed-citation)])">
        References inside the bibliography are tagged inside &lt;ref&gt;,
        either as &lt;std&gt; (standards) or as &lt;mixed-citation&gt;
        (Guidelines 4.5.2).
      </assert>
    </rule>
    <rule context="ref-list[@content-type='bibl']/ref/mixed-citation">
      <assert id="iso-gdg-4.5.2-3"
              test="not(name | person-group | element-citation | citation)">
        Author names and other details are not coded at any level of
        granularity; all the information is within &lt;mixed-citation&gt;
        (Guidelines 4.5.2).
      </assert>
    </rule>
  </pattern>

  <!-- ============================================================= -->
  <!-- Cross-reference integrity (guidelines 10.1, 9.2.6, 6.2.2)     -->
  <!-- ============================================================= -->
  <pattern id="iso-gdg-cross-references">
    <rule context="xref">
      <assert id="iso-gdg-10.1.1-1"
              test="@ref-type = ('abbreviation', 'app', 'bibr', 'custom',
                                 'disp-formula', 'fig', 'fn', 'list', 'sec',
                                 'table', 'table-fn')
                    and normalize-space(@rid) != ''
                    and (not(@ref-type = 'custom')
                         or @custom-type = ('term-entry', 'note', 'example'))">
        Document-internal cross-references are tagged &lt;xref&gt; with
        @ref-type from the enumeration (custom adds @custom-type of
        term-entry, note or example) and @rid holding the target ID
        (Guidelines 10.1.1).
      </assert>
      <assert id="iso-gdg-10.1.2-1"
              test="if (@ref-type = 'sec') then exists(//sec[@id = current()/@rid])
                    else if (@ref-type = 'table') then exists(//table-wrap[@id = current()/@rid])
                    else if (@ref-type = 'fig') then exists(//fig[@id = current()/@rid])
                    else if (@ref-type = 'disp-formula') then exists(//disp-formula[@id = current()/@rid])
                    else true()">
        References to sections, tables, figures and formulae use the ID of
        the respective &lt;sec&gt;, &lt;table-wrap&gt;, &lt;fig&gt; or
        &lt;disp-formula&gt; in @rid (Guidelines 10.1.2).
      </assert>
      <assert id="iso-gdg-10.1.3-1"
              test="if (@ref-type = 'custom' and @custom-type = 'note')
                    then exists(//non-normative-note[@id = current()/@rid])
                    else if (@ref-type = 'custom' and @custom-type = 'example')
                    then exists(//non-normative-example[@id = current()/@rid])
                    else true()">
        Cross-references to notes and examples use @ref-type="custom" with
        @custom-type="note"/"example" and the target ID in @rid (Guidelines
        10.1.3).
      </assert>
      <assert id="iso-gdg-10.1.4-1"
              test="if (@ref-type = 'abbreviation')
                    then exists(//def-list[@list-content='abbreviation']/def-item[@id = current()/@rid])
                    else true()">
        Cross-references to abbreviations target the &lt;def-item&gt;
        carrying the term/def pair inside a
        &lt;def-list @list-content="abbreviation"&gt; (Guidelines 10.1.4).
      </assert>
      <assert id="iso-gdg-10.1.5-1"
              test="if (@ref-type = 'list')
                    then exists(//list[@list-type = ('alpha-lower','arabic','roman-lower')]
                                      /list-item[@id = current()/@rid])
                    else true()">
        Only items in ordered lists can be referenced; cross-references to
        list items use @ref-type="list" with the list-item ID in @rid
        (Guidelines 10.1.5).
      </assert>
      <assert id="iso-gdg-10.1.6-1"
              test="if (@ref-type = 'bibr')
                    then exists(//ref-list[@content-type='bibl']/ref[@id = current()/@rid])
                    else true()">
        References to items in the bibliography use @ref-type="bibr" with
        the bibliographical entry ID in @rid (Guidelines 10.1.6).
      </assert>
      <assert id="iso-gdg-10.1.8-1"
              test="if (@ref-type = 'fn') then exists(//fn[@id = current()/@rid])
                    else true()">
        References to footnotes are tagged &lt;xref&gt; with
        @ref-type="fn"; the footnote content is an &lt;fn&gt; at the point
        of use (Guidelines 10.1.8).
      </assert>
      <assert id="iso-gdg-6.2.2-4"
              test="if (@ref-type = 'table-fn')
                    then exists(//table-wrap//fn[@id = current()/@rid])
                    else true()">
        References to table footnotes are contained in &lt;xref&gt; with
        @ref-type="table-fn" targeting an &lt;fn&gt; within the
        &lt;table-wrap&gt; (Guidelines 6.2.2).
      </assert>
      <assert id="iso-gdg-9.2.6-2"
              test="if (exists(//term-sec[@id = current()/@rid]
                               | //tbx:termEntry[@id = current()/@rid]))
                    then @ref-type = 'custom' and @custom-type = 'term-entry'
                    else true()">
        References to terms from outside the terms and definitions section
        are coded &lt;xref&gt; with @ref-type="custom" and
        @custom-type="term-entry" (Guidelines 9.2.6).
      </assert>
      <assert id="iso-gdg-10.1.7-1"
              test="not(self::std) or ancestor::ref-list
                    or exists(//ref-list[@content-type = ('norm-refs','bibl')]
                                //std-id[normalize-space(.) = normalize-space(current()/std-id)])">
        Items listed in the normative references and mentioned in the text
        are marked up as &lt;std&gt; (or &lt;mixed-citation&gt; for other
        documents) and are listed in the normative references or
        bibliography (Guidelines 10.1.7, 10.2).
      </assert>
    </rule>
    <rule context="std[not(ancestor::ref-list)]">
      <assert id="iso-gdg-10.2-1" test="std-id[@std-id-link-type='urn']">
        Where documents cited in the text appear in &lt;std&gt;, the standard
        is identified by a &lt;std-id&gt; with @std-id-link-type="urn"
        (Guidelines 10.2).
      </assert>
    </rule>
    <rule context="ext-link">
      <assert id="iso-gdg-10.1.9-1"
              test="@ext-link-type = 'uri' and exists(@xlink:href)">
        A URL is coded using &lt;ext-link&gt; with @ext-link-type="uri";
        @xlink:href contains the actual link (Guidelines 10.1.9).
      </assert>
    </rule>
  </pattern>

  <!-- ============================================================= -->
  <!-- Lists (guidelines 5.7)                                        -->
  <!-- ============================================================= -->
  <pattern id="iso-gdg-lists">
    <rule context="list">
      <assert id="iso-gdg-5.7-1" test="not(list)">
        Lists are coded &lt;list&gt; with each item a &lt;list-item&gt;;
        a change of indentation or hierarchical level starts a new list,
        nested through &lt;list-item&gt; (Guidelines 5.7).
      </assert>
      <assert id="iso-gdg-5.7-2"
              test="@list-type = ('alpha-lower', 'arabic', 'roman-lower',
                                  'dash', 'bullet')">
        OSD @list-type values are alpha-lower, arabic, roman-lower (ordered)
        and dash, bullet (unordered); simple, roman-upper and other values
        occur only in traditional-chain XML (Guidelines 5.7).
      </assert>
    </rule>
    <rule context="p">
      <assert id="iso-gdg-5.7-3" test="not(list)">
        All lists are coded outside the preceding &lt;p&gt; (Guidelines 5.7).
      </assert>
    </rule>
    <rule context="list[@list-type = ('alpha-lower','arabic','roman-lower')]/list-item">
      <assert id="iso-gdg-5.7-4" test="label and p">
        Within each &lt;list-item&gt; of an ordered list the actual
        number/letter is captured in &lt;label&gt; and the text is tagged
        inside &lt;p&gt; (Guidelines 5.7.1).
      </assert>
    </rule>
    <rule context="list[@list-type = ('dash','bullet')]/list-item">
      <assert id="iso-gdg-5.7.2-1" test="not(label)">
        For unordered lists the label is not present in the XML; it is
        derived from @list-type on rendering (Guidelines 5.7.2).
      </assert>
    </rule>
  </pattern>

  <!-- ============================================================= -->
  <!-- Notes, examples, quotations (guidelines 5.6, 5.9, B.2.9)      -->
  <!-- ============================================================= -->
  <pattern id="iso-gdg-notes-examples">
    <rule context="non-normative-note | non-normative-example">
      <assert id="iso-gdg-5.6-1"
              test="not(self::non-normative-note[@content-type])
                    or @content-type = 'warning'">
        Notes and examples in regular text are tagged
        &lt;non-normative-note&gt; and &lt;non-normative-example&gt;;
        warnings are notes with the label "WARNING" and
        @content-type="warning" (Guidelines 5.6).
      </assert>
      <assert id="iso-gdg-5.6-2"
              test="exists(label)
                    and matches(normalize-space(label), '^(NOTE|EXAMPLES?|WARNING)')">
        The designation text (NOTE, EXAMPLE or WARNING, including any
        numbers or punctuation) is captured in a &lt;label&gt;, retaining
        the capitalisation (Guidelines 5.6).
      </assert>
      <assert id="iso-gdg-5.6-3" test="p or list">
        The note/example text is coded with the usual elements used within
        &lt;sec&gt; (e.g. &lt;p&gt;, &lt;list&gt;); notes inside
        terminological entries use TBX instead (Guidelines 5.6).
      </assert>
    </rule>
    <rule context="disp-quote[attrib]">
      <assert id="iso-gdg-5.9-1" test="attrib[@specific-use='source']">
        The source of a quote is captured using &lt;attrib&gt; with
        @specific-use="source", and permissions information with
        &lt;permissions&gt; within the &lt;disp-quote&gt; (Guidelines 5.9).
      </assert>
    </rule>
    <rule context="styled-content">
      <assert id="iso-gdg-B.2.9-1"
              test="(not(@style-type)
                    or @style-type = ('addition', 'deletion', 'normal',
                                      'align-left', 'align-right',
                                      'align-center', 'valign-top',
                                      'valign-bottom', 'valign-middle',
                                      'indent'))
                   and (not(@specific-use)
                    or @specific-use = ('insert', 'delete', 'source'))">
        Meaning-bearing styling in legacy/redline content uses
        &lt;styled-content&gt;: redline additions/deletions via @style-type
        addition/deletion (ISO) or @specific-use insert/delete (IEC)
        (Guidelines B.2.8, B.2.9).
      </assert>
    </rule>
  </pattern>

  <!-- ============================================================= -->
  <!-- Graphics and code (guidelines 5.10, 5.11)                     -->
  <!-- ============================================================= -->
  <pattern id="iso-gdg-graphics-code">
    <rule context="p/graphic">
      <report id="iso-gdg-5.10-1" test=".">
        Graphics in the same line as the surrounding text are coded
        &lt;inline-graphic&gt;; block graphics &lt;graphic&gt; occur outside
        paragraphs (Guidelines 5.10).
      </report>
    </rule>
    <rule context="graphic | inline-graphic">
      <assert id="iso-gdg-5.10-2"
              test="not(matches(@xlink:href,
                                '\.(png|gif|jpe?g|svg|tiff?|eps|pdf)$', 'i'))">
        @xlink:href contains the reference to the graphic file without the
        file extension (Guidelines 5.10).
      </assert>
      <assert id="iso-gdg-5.10-3"
              test="(not(//std-meta//originator[normalize-space()='ISO'])
                    or not(contains(@xlink:href, '/')))
                   and (not(//std-meta//originator[normalize-space()='IEC'])
                    or contains(@xlink:href, '/'))">
        For formal figures the ISO graphic reference has no asset-folder
        prefix, while the IEC reference contains the asset folder name
        (Guidelines 5.10).
      </assert>
      <assert id="iso-gdg-5.10-4"
              test="(not(@specific-use)
                    or @specific-use = ('size:T', 'size:S', 'size:M', 'size:L'))
                   and not(self::inline-graphic and @specific-use = 'size:T')">
        @specific-use indicates the relative graphic size with values
        size:T, size:S, size:M, size:L; size:T is not enabled on
        &lt;inline-graphic&gt; (Guidelines 5.10).
      </assert>
    </rule>
    <rule context="styled-content[@style][not(ancestor::code)]">
      <report id="iso-gdg-5.11-1"
              test="matches(@style, '(Courier|monospace)', 'i')">
        Technical content in line with text is &lt;inline-code&gt;, code
        blocks are &lt;code&gt;; monospace-styled &lt;styled-content&gt;
        indicates untagged code (Guidelines 5.11).
      </report>
    </rule>
  </pattern>

  <!-- ============================================================= -->
  <!-- Tables (guidelines 6)                                         -->
  <!-- ============================================================= -->
  <pattern id="iso-gdg-tables">
    <rule context="table">
      <assert id="iso-gdg-6.1-1" test="not(descendant::table)">
        Tables are coded using XHTML; nested tables are not permitted
        (Guidelines 6.1).
      </assert>
      <assert id="iso-gdg-6.1-2"
              test="not(@width) or @width = ('33%', '66%', '100%')">
        The width of the table is determined with @width of 33%, 66% or
        100%; absence of @width means no specific width is required
        (Guidelines 6.1).
      </assert>
      <report id="iso-gdg-6.5-1" test="descendant::br">
        A soft break in a table cell is coded with &lt;break/&gt; and a new
        paragraph with &lt;p&gt;; XHTML &lt;br&gt; is not used (Guidelines
        6.5).
      </report>
    </rule>
    <rule context="table/tr">
      <report id="iso-gdg-6.2.2-2" test=".">
        Table headers and footers are coded in &lt;thead&gt; and
        &lt;table-wrap-foot&gt;; rows are grouped in tbody/thead (Guidelines
        6.2.2).
      </report>
    </rule>
    <rule context="td | th | tr | col">
      <assert id="iso-gdg-6.3.1-1"
              test="(not(@align) or @align = ('left', 'center', 'right', 'justify'))
                   and (not(@valign) or @valign = ('top', 'middle', 'bottom'))">
        @align carries horizontal alignment (left, center, right, justify)
        and @valign vertical alignment (top, middle, bottom) (Guidelines
        6.3.1).
      </assert>
    </rule>
    <rule context="td">
      <assert id="iso-gdg-6.4-1"
              test="(not(@rowspan) or @rowspan castable as xs:positiveInteger)
                   and (not(@colspan) or @colspan castable as xs:positiveInteger)">
        Merged cells are captured by @rowspan/@colspan in &lt;td&gt;; the
        value is the number of rows/columns being merged (Guidelines 6.4).
      </assert>
    </rule>
    <rule context="table//non-normative-note">
      <assert id="iso-gdg-6.2.2-5" test="ancestor::td or ancestor::table-wrap-foot">
        Notes in tables can appear inside a cell (&lt;td&gt;) or after the
        last row (inside &lt;table-wrap-foot&gt;) (Guidelines 6.2.2).
      </assert>
    </rule>
    <rule context="table-wrap">
      <assert id="iso-gdg-6.2.2-1"
              test="label and caption/title
                    and not(matches(normalize-space(label), '[.,:;]$'))">
        A formal table consists of a table with a label and a title within
        &lt;table-wrap&gt;; the &lt;label&gt; contains no punctuation and the
        title sits in &lt;caption&gt;/&lt;title&gt; (Guidelines 6.2.2).
      </assert>
      <assert id="iso-gdg-6.6-1"
              test="not(@orientation) or @orientation = ('landscape', 'portrait')">
        The orientation of a table is contained inside &lt;table-wrap&gt;
        with @orientation; landscape tables are coded with
        @orientation="landscape" (Guidelines 6.6).
      </assert>
    </rule>
    <rule context="table-wrap-foot">
      <assert id="iso-gdg-6.2.2-3"
              test="not(*[not(self::fn or self::non-normative-note or self::p)])">
        Table notes and footnotes and any other footer content are coded
        inside &lt;table-wrap-foot&gt;; footnotes in &lt;fn&gt;, notes as
        &lt;non-normative-note&gt;, other contents inside &lt;p&gt;
        (Guidelines 6.2.2).
      </assert>
    </rule>
    <rule context="table-wrap-foot/p">
      <report id="iso-gdg-6.2.2-7"
              test="@content-type and @content-type != 'dimension'">
        Text describing the units used in the table is captured as &lt;p&gt;
        with @content-type="dimension" in &lt;table-wrap-foot&gt;
        (Guidelines 6.2.2).
      </report>
    </rule>
    <rule context="array">
      <assert id="iso-gdg-5.8-1"
              test="not(ancestor::table-wrap) and not(caption | title | label) and table">
        Text aligned in columns without borders is laid out inside
        &lt;array&gt; containing a &lt;table&gt;, with no formal-table
        attributes (no table-wrap, caption, title, label) (Guidelines 5.8).
      </assert>
      <assert id="iso-gdg-6.2.1-1" test="not(ancestor::disp-formula)">
        An informal table (captionless &lt;table&gt; in &lt;array&gt;) is
        not used for keys to formulae; formula keys are coded as
        &lt;legend&gt; (Guidelines 6.2.1, 7.3).
      </assert>
    </rule>
    <rule context="array//col | array/table/col">
      <assert id="iso-gdg-5.8-2"
              test="every $w in (@colwidth, @width)[exists(.)]
                    satisfies matches($w, '^\d+(\.\d+)?%$')">
        Array column width is specified in percent, with "%" after the
        value (Guidelines 5.8).
      </assert>
    </rule>
  </pattern>

  <!-- ============================================================= -->
  <!-- Formulae (guidelines 7)                                       -->
  <!-- ============================================================= -->
  <pattern id="iso-gdg-formulae">
    <rule context="disp-formula | inline-formula">
      <assert id="iso-gdg-7.4-1" test="count(mml:math) = 1">
        The mathematical expression is coded with &lt;mml:math&gt;; several
        expressions on separate lines are contained in one &lt;mml:math&gt;
        (Guidelines 7.4).
      </assert>
    </rule>
    <rule context="disp-formula">
      <assert id="iso-gdg-7.1-2" test="label">
        The formula number is captured as a &lt;label&gt; within the
        &lt;disp-formula&gt;, numbered sequentially and independently
        throughout the document (Guidelines 7.1).
      </assert>
      <assert id="iso-gdg-7.3-1" test="count(legend) &lt;= 1">
        Formula keys are coded as &lt;legend&gt; inside
        &lt;disp-formula&gt;; there can be only one &lt;legend&gt; per
        &lt;disp-formula&gt; (Guidelines 7.3).
      </assert>
      <assert id="iso-gdg-7.2-1"
              test="not(non-normative-note[not(preceding-sibling::mml:math)])">
        &lt;disp-formula&gt; notes are coded as &lt;non-normative-note&gt;
        after the &lt;mml:math&gt; element (Guidelines 7.2).
      </assert>
    </rule>
    <rule context="inline-formula">
      <assert id="iso-gdg-7.1-1" test="not(label)">
        A formula embedded in the flow of text is captured in
        &lt;inline-formula&gt; without a formula number label (Guidelines
        7.1).
      </assert>
    </rule>
    <rule context="ref-list[@content-type='norm-refs']">
      <assert id="iso-gdg-4.4.2-4"
              test="not(ref[not(std) and not(mixed-citation)])">
        Normative references are coded as a &lt;ref-list&gt; with
        @content-type="norm-refs", each reference as a &lt;ref&gt;
        containing a &lt;std&gt; (Guidelines 4.4.2).
      </assert>
      <assert id="iso-gdg-4.4.2-7"
              test="not(ref[not(std) and not(mixed-citation)])">
        A reference in the normative reference section that is not a
        standard is coded as it appears (including formatting) using
        &lt;mixed-citation&gt; (Guidelines 4.4.2).
      </assert>
    </rule>
    <rule context="ref-list[@content-type='norm-refs']/ref/std">
      <assert id="iso-gdg-4.4.2-5"
              test="std-id[@std-id-link-type='urn']
                            [@std-id-type=('dated','undated')]
                   and std-ref and title">
        Each normative-reference &lt;std&gt; contains a &lt;std-id&gt; with
        @std-id-link-type="urn" and @std-id-type dated or undated, with the
        designation in &lt;std-ref&gt; and the title in &lt;title&gt;
        (Guidelines 4.4.2).
      </assert>
    </rule>
    <rule context="disp-formula/legend">
      <assert id="iso-gdg-7.3-2"
              test="matches(normalize-space(title), 'where', 'i')
                    and def-list
                    and every $d in def-list/def-item
                        satisfies exists($d/term) and exists($d/def)">
        Inside the formula-key &lt;legend&gt;, &lt;title&gt; contains the
        word "where" followed by a &lt;def-list&gt; whose &lt;def-item&gt;
        elements pair &lt;term&gt; and &lt;def&gt; (Guidelines 7.3).
      </assert>
    </rule>
  </pattern>

  <!-- ============================================================= -->
  <!-- Figures (guidelines 8)                                        -->
  <!-- ============================================================= -->
  <pattern id="iso-gdg-figures">
    <rule context="fig">
      <assert id="iso-gdg-8.1-1"
              test="not(@orientation) or @orientation = ('landscape', 'portrait')">
        The figure is coded in &lt;fig&gt;; @orientation can have the values
        landscape or portrait (Guidelines 8.1).
      </assert>
      <assert id="iso-gdg-8.1-2"
              test="label and caption/title and graphic
                    and not(non-normative-note[not(preceding-sibling::graphic)])">
        Within &lt;fig&gt;: figure number in &lt;label&gt;, designation in
        &lt;title&gt; within &lt;caption&gt;, image in &lt;graphic&gt;, and
        figure notes in &lt;non-normative-note&gt; after the &lt;graphic&gt;
        (Guidelines 8.1).
      </assert>
      <assert id="iso-gdg-8.3-1" test="count(legend) &lt;= 1">
        Figure keys are coded as &lt;legend&gt; inside &lt;fig&gt;; there can
        be only one &lt;legend&gt; per &lt;fig&gt; (Guidelines 8.3).
      </assert>
    </rule>
    <rule context="fig/legend">
      <assert id="iso-gdg-8.3-2"
              test="matches(normalize-space(title), 'Key', 'i')
                    and def-list
                    and every $d in def-list/def-item
                        satisfies exists($d/term) and exists($d/def)">
        Inside the figure-key &lt;legend&gt;, &lt;title&gt; contains the
        word "Key" followed by a &lt;def-list&gt; whose &lt;def-item&gt;
        elements pair &lt;term&gt; and &lt;def&gt; (Guidelines 8.3).
      </assert>
    </rule>
    <rule context="fig-group">
      <assert id="iso-gdg-8.2-1"
              test="count(legend) &lt;= 1
                    and not(*[not(self::fig or self::label
                                   or self::caption or self::legend)])">
        A figure group contains sub-figures (multiple &lt;fig&gt;); there is
        only one &lt;legend&gt; for the entire group, at the &lt;fig-group&gt;
        level (Guidelines 8.2).
      </assert>
      <assert id="iso-gdg-8.2-2"
              test="not(non-normative-note | non-normative-example)">
        Notes and examples remain at the sub-figure (&lt;fig&gt;) level;
        they are not permitted at &lt;fig-group&gt; level in NISO STS
        (Guidelines 8.2).
      </assert>
    </rule>
    <rule context="fig/caption/p">
      <report id="iso-gdg-8.4-1"
              test="matches(., 'Dimensions in', 'i') and not(@content-type = 'dimension')">
        A unit statement in a figure (e.g. "Dimensions in millimetres") is
        coded as &lt;p&gt; with @content-type="dimension" inside the figure
        caption (Guidelines 8.4).
      </report>
    </rule>
  </pattern>

  <!-- ============================================================= -->
  <!-- Terminology in TBX (guidelines 9.2, Annex A.3.2)              -->
  <!-- ============================================================= -->
  <pattern id="iso-gdg-terminology">
    <rule context="tbx:termEntry">
      <assert id="iso-gdg-9.2.1-1"
              test="tbx:langSet[tbx:definition][tbx:tig/tbx:term]">
        A terminological entry contains its core components inside
        &lt;tbx:langSet&gt;: terms (each in its own &lt;tbx:tig&gt;) and the
        definition (Guidelines 9.2.1).
      </assert>
    </rule>
    <rule context="tbx:definition">
      <assert id="iso-gdg-9.2.2-1" test="parent::tbx:langSet">
        A definition is coded in &lt;tbx:definition&gt;, inside
        &lt;tbx:langSet&gt; (Guidelines 9.2.2).
      </assert>
    </rule>
    <rule context="tbx:tig">
      <assert id="iso-gdg-9.2.3-1" test="count(tbx:term) = 1">
        Each term and its descriptive elements are contained in one
        individual &lt;tbx:tig&gt;; the &lt;tbx:term&gt; is mandatory
        (Guidelines 9.2.3).
      </assert>
    </rule>
    <rule context="tbx:partOfSpeech">
      <assert id="iso-gdg-9.2.3-2" test="@value = ('noun', 'verb', 'adj', 'adv')">
        &lt;tbx:partOfSpeech&gt; has the values noun, verb, adj, adv (absent
        for none) (Guidelines 9.2.3).
      </assert>
    </rule>
    <rule context="tbx:termType">
      <assert id="iso-gdg-9.2.3-3"
              test="@value = ('fullForm', 'abbreviation', 'symbol', 'formula')">
        &lt;tbx:termType&gt; can have the values fullForm (default,
        omittable), abbreviation, symbol, formula (Guidelines 9.2.3).
      </assert>
    </rule>
    <rule context="tbx:normativeAuthorization">
      <assert id="iso-gdg-9.2.3-4"
              test="@value = ('preferredTerm', 'admittedTerm', 'deprecatedTerm')">
        &lt;tbx:normativeAuthorization&gt; indicates the term status with the
        values preferredTerm, admittedTerm, deprecatedTerm (Guidelines
        9.2.3).
      </assert>
    </rule>
    <rule context="tbx:example">
      <assert id="iso-gdg-9.2.4-1"
              test="not(matches(normalize-space(string(.)), '^EXAMPLE', 'i'))">
        Examples in terminology are coded &lt;tbx:example&gt;; the word
        "Example" and the number/label are removed from the content
        (Guidelines 9.2.4).
      </assert>
    </rule>
    <rule context="tbx:note">
      <assert id="iso-gdg-9.2.5-1"
              test="not(matches(normalize-space(string(.)),
                                '^Note\s*[0-9IVXivx]*\s*to entry', 'i'))">
        Terminological notes are coded &lt;tbx:note&gt;; the words "Note X
        to entry", including the number, are not included in the content
        (Guidelines 9.2.5).
      </assert>
    </rule>
    <rule context="tbx:entailedTerm">
      <assert id="iso-gdg-9.2.6-1"
              test="ancestor::tbx:termEntry
                    and exists(//term-sec[@id = current()/@target]
                               | //tbx:termEntry[@id = current()/@target])">
        Cross-references between terminological entries are tagged
        &lt;tbx:entailedTerm&gt; with the referenced entry's ID in @target;
        the element is only used inside &lt;tbx:termEntry&gt; (Guidelines
        9.2.6).
      </assert>
    </rule>
    <rule context="tbx:source">
      <assert id="iso-gdg-9.2.8-1"
              test="parent::tbx:langSet
                    and not(matches(., 'SOURCE'))
                    and not(matches(., '\[|\]'))">
        A stated source is included in &lt;tbx:source&gt; within
        &lt;tbx:langSet&gt;; square brackets and the word "SOURCE" are not
        included and are added during rendering (Guidelines 9.2.8).
      </assert>
    </rule>
    <rule context="tbx:subjectField">
      <assert id="iso-gdg-9.2.9-1" test="parent::tbx:langSet">
        Subject fields are tagged &lt;tbx:subjectField&gt; within
        &lt;tbx:langSet&gt;; additional punctuation such as brackets is
        added during rendering (Guidelines 9.2.9).
      </assert>
    </rule>
    <rule context="tbx:langSet">
      <assert id="iso-gdg-A.3.2-1" test="exists(@xml:lang)">
        &lt;tbx:langSet&gt;'s @xml:lang is adapted to the language of the
        translation (Annex A.3.2).
      </assert>
    </rule>
    <rule context="term-sec">
      <assert id="iso-gdg-A.3.2-2" test="normalize-space(label) != ''">
        The &lt;label&gt; (not a TBX element) numbers the terminological
        entry; the original numbering is preserved and entries are not
        reordered in translation (Annex A.3.2).
      </assert>
    </rule>
  </pattern>

  <!-- ============================================================= -->
  <!-- Legacy-chain and amendment constructs (Annexes B, D, E)       -->
  <!-- ============================================================= -->
  <pattern id="iso-gdg-legacy-and-amendments">
    <rule context="p[not(ancestor::permissions)]">
      <report id="iso-gdg-B.2.1-2" test="matches(normalize-space(string(.)), '^©')">
        Copyright notices listed in the footer of the PDF document are
        captured in the metadata section using &lt;permissions&gt;, not as
        body text (Guidelines B.2.1).
      </report>
    </rule>
    <rule context="app">
      <report id="iso-gdg-B.2.6-1"
              test="@content-type = ('inform', 'norm')">
        IEC legacy files may use @content-type values inform / norm; OSD
        documents use informative / normative (Guidelines B.2.6).
      </report>
    </rule>
    <rule context="ref-list[@content-type='bibl']//ref-list">
      <report id="iso-gdg-B.2.6-2" test=".">
        Multiple lists inside the bibliography are legacy tagging and
        deprecated; reference IDs must be unique (Guidelines B.2.6).
      </report>
    </rule>
    <rule context="editing-instruction">
      <assert id="iso-gdg-D.1.1-1"
              test="not(@content-type)
                    or @content-type = ('addition', 'replacement',
                                        'deletion', 'modification')">
        Amendment instructions such as "Insert the following text" or
        "Delete ..." are coded inside &lt;editing-instruction&gt;, which may
        carry @content-type of addition, replacement, deletion or
        modification (Annex B.3.2, D.1.1).
      </assert>
    </rule>
    <rule context="supplementary-material[matches(@xlink:href, '\.pdf$', 'i')]">
      <assert id="iso-gdg-E.2-1" test="ancestor::sec[@sec-type='foreword']">
        The PDF of an IEC Interpretation Sheet is referenced via
        @xlink:href in a &lt;supplementary-material&gt; inside the foreword
        paragraph mentioning the ISH (Annex E.2).
      </assert>
    </rule>
    <rule context="supplementary-material">
      <assert id="iso-gdg-E.3-1" test="exists(@xlink:href)">
        IEC software supplements are linked via @xlink:href (into the asset
        folder) inside &lt;supplementary-material&gt; in the announcing
        foreword paragraph (Annex E.3).
      </assert>
    </rule>
  </pattern>
</schema>
