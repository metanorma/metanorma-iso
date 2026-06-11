# TODO.iso-docx-analysis.md

ISO DOCX template and style audit based on analysis of real published ISO documents.

## Reference Files

### DIS Template Reference Files

| File | Document | Stage | Style Count (para/char) |
|---|---|---|---|
| `/Users/mulgogi/src/iso-8601-1/submission/20180724-to-isocs/20180724-8601-1-fdis.docx` | ISO 8601-1 FDIS | 50 | 54/22 (very old template: `Standard1`, `BasicFormat`) |
| `/Users/mulgogi/src/iso-8601-2/submissions/2019-revision/20181006-jianfang/ISO-TC154_N0973_ISO_FDIS 8601-2.docx` | ISO 8601-2 FDIS | 50 | 83/24 (older template: `example1`, `h2annex`, `biblio`) |
| `/Users/mulgogi/src/mn/iso-6709/reference-docs/ISO 6709 ed.3 - id.75147 Publication Word (fr).docx` | ISO 6709 ed.3 (FR) | 60 | 250/240 (DIS template; ignore Asian styles) |
| `/Users/mulgogi/src/mn/iso-6709/reference-docs/ISO 6709 ed.3 - id.75147 Publication Word (en).docx` | ISO 6709 ed.3 (EN) | 60 | 246/212 (**primary DIS reference**) |
| `/Users/mulgogi/src/mn/iso-690/reference-docs/comments/ISO_690_(DIS)E_2019-11-06.docx` | ISO 690 DIS | 40 | 93/31 (older template; ignore Finnish names `Otsikko3`, `Sisluet2`) |

### Simple Template Reference Files

| File | Document | Stage | Style Count (para/char) |
|---|---|---|---|
| `/Users/mulgogi/src/mn/iso-8000-118/submissions/202208-new-project/ISO-PWI_8000-118_-_003.docx` | ISO 8000-118 PWI | 00 | 188/132 (**hybrid: DIS base + html2doc styles**) |

> **NOTE**: ISO 8000-118 is NOT a true Simple template. It has `BaseText`/`BaseHeading` base styles,
> `BiblioEntry`, `ListNumber1`, all `bib*`/`std*`/`au*`/`cite*` character styles (DIS template features).
> It also contains html2doc pipeline styles (`h2annex`, `normref`, `biblio`, `coverpage-*`, `sourcetitle`).
> This is a DIS-based template processed through html2doc — a hybrid we should handle.

---

## Key Findings

### 1. Three Distinct Template Generations

ISO's Word templates have evolved over time. The reference files show three distinct generations:

| Generation | StyleIds | Examples |
|---|---|---|
| **V1 (very old)** | `Standard1`, `BasicFormat`, `Textbody`, `TermNote` | ISO 8601-1 FDIS (2018) |
| **V2 (older)** | `example1`, `note`, `biblio`, `normref`, `h2annex`, `figuretitle` | ISO 8601-2 FDIS (2018), ISO 690 DIS (2019) |
| **V3 (current DIS)** | `Example`, `Note`, `BiblioEntry`, `RefNorm`, `a2`-`a6`, `Figuretitle` | ISO 6709 ed.3 (2021), ISO 8000-118 (2022) |

Our `data/iso-dis/style_mapping.yml` maps to **V3 (current DIS)** styles. V1/V2 documents use
different styleIds — these are produced by older html2doc pipelines and are not our target for the
Uniword-based DOCX builder.

### 2. Bibliography Styles — Detailed Analysis

The DIS template defines a **rich bibliography semantic markup system** with 70+ character styles.
These are used to semantically tag parts of bibliography entries for consistent formatting.

#### Paragraph Styles

| StyleId | Usage | Description |
|---|---|---|
| `BiblioTitle` | 1x per doc | "Bibliography" section heading |
| `BiblioEntry` | 11-21x per doc | Individual bibliography entry paragraphs |
| `BiblioText` | 0x in samples | Continuation text for multi-line entries |
| `BiblioDescription` | 0x in samples | Bibliography description text |
| `RefNorm` | 2-5x per doc | Normative reference entries |

#### Character Styles for Bibliography Semantic Markup

**Bibliographic entry parts** (`bib*` styles, 35+ defined):
| StyleId | Semantic | Example content |
|---|---|---|
| `bibnumber` | Reference number | `1`, `2` (inside `[1]`, `[2]`) |
| `bibfname` | Author first name | `John` |
| `bibsurname` | Author surname | `Smith` |
| `bibetal` | "et al." | `et al.` |
| `biborganization` | Organization | `IGNF`, `EPSG` |
| `bibarticle` | Article title | italicized article name |
| `bibjournal` | Journal name | journal name |
| `bibvolume` | Volume | `42` |
| `bibissue` | Issue | `3` |
| `bibfpage` | First page | `101` |
| `biblpage` | Last page | `120` |
| `bibyear` | Publication year | `2020` |
| `bibbook` | Book title | book name |
| `bibpublisher` | Publisher name | publisher |
| `biblocation` | Publication location | city |
| `bibdoi` | DOI | `10.1234/...` |
| `biburl` | URL | `https://...` |
| `bibisbn` | ISBN | `978-...` |
| + 18 more | Various bibliographic fields | see full list in style inventory |

**Standard reference parts** (`std*` styles, 10 defined):
| StyleId | Semantic | Example content |
|---|---|---|
| `stdpublisher` | Standards publisher | `ISO`, `ISO/IEC` |
| `stddocNumber` | Document number | `2382`, `6707` |
| `stddocPartNumber` | Part number | `1` |
| `stddocTitle` | Document title | `Information technology — Vocabulary` |
| `stdyear` | Publication year | `2015`, `2020` |
| `stdsection` | Section reference | `Section 5` |
| `stdfootnote` | Standard footnote reference | |

**Author/editor markup** (`au*` styles, 10 defined):
| StyleId | Semantic |
|---|---|
| `aufname` | Author first name |
| `ausurname` | Author surname |
| `auprefix` | Name prefix (von, de) |
| `ausuffix` | Name suffix (Jr., III) |
| `auorg` | Author organization |
| `aucollab` | Collaboration name |
| `audeg` | Academic degree |
| `aurole` | Author role |
| `aumember` | Member name |

**Citation reference styles** (`cite*` styles, 11 defined):
| StyleId | Semantic |
|---|---|
| `citebib` | Bibliography citation |
| `citefig` | Figure citation |
| `citetbl` | Table citation |
| `citeeq` | Equation citation |
| `citesection` | Section citation |
| `citeen` | Enumeration citation |
| `citefn` | Footnote citation |
| `citetfn` | Table footnote citation |
| `citebox` | Text box citation |
| `citeapp` | Appendix citation |
| `citebase` | Base citation |

#### Actual BiblioEntry Structure (from ISO 6709)

```xml
<w:p>
  <w:pPr><w:pStyle w:val="BiblioEntry"/></w:pPr>
  <w:r><w:t>[</w:t></w:r>
  <w:r><w:rPr><w:rStyle w:val="bibnumber"/></w:rPr><w:t>1</w:t></w:r>
  <w:r><w:t>]</w:t></w:r>
  <w:r><w:tab/></w:r>
  <w:r><w:rPr><w:rStyle w:val="biborganization"/></w:rPr><w:t>EPSG</w:t></w:r>
  <w:r><w:t> Geodetic Parameter Dataset [website]. Available from: </w:t></w:r>
  <w:hyperlink r:id="rId56">
    <w:r><w:rPr><w:rStyle w:val="Hyperlink"/></w:rPr><w:t>https://epsg.org</w:t></w:r>
  </w:hyperlink>
</w:p>
```

#### Actual BiblioEntry Structure (from ISO 8000-118)

```xml
<w:p>
  <w:pPr><w:pStyle w:val="BiblioEntry"/></w:pPr>
  <w:r><w:t>[1]</w:t></w:r>
  <w:r><w:tab/></w:r>
  <w:r><w:rPr><w:rStyle w:val="stdpublisher"/></w:rPr><w:t>ISO/IEC</w:t></w:r>
  <w:r><w:t> </w:t></w:r>
  <w:r><w:rPr><w:rStyle w:val="stddocNumber"/></w:rPr><w:t>2382</w:t></w:r>
  <w:r><w:t>:</w:t></w:r>
  <w:r><w:rPr><w:rStyle w:val="stdyear"/></w:rPr><w:t>2015</w:t></w:r>
  <w:r><w:t>, </w:t></w:r>
  <w:r><w:rPr><w:rStyle w:val="stddocTitle"/></w:rPr>
    <w:t>Information technology — Vocabulary</w:t></w:r>
</w:p>
```

### 3. Styles Used in Real Documents (Not in Our Mapping)

Styles found in ISO 6709 ed.3 (DIS template, V3) that are **missing from `data/iso-dis/style_mapping.yml`**:

| StyleId | Frequency | Category | Priority |
|---|---|---|---|
| `ListNumber1` | 119x | Lists (numbered) | HIGH |
| `ListContinue1` | 56x | Lists (continuation) | HIGH |
| `Examplecontinued` | 45x | Examples | HIGH |
| `ForewordText` | 12x | Foreword body | HIGH |
| `RefNorm` | 5x | Normative references | HIGH |
| `zzCover` | 7-9x | Cover page | MEDIUM |
| `BodyTextIndent2` | 1x | Indented body text | MEDIUM |
| `FigureGraphic` | 1x | Figure graphic container | MEDIUM |
| `Figurenote` | 1x | Figure note | MEDIUM |
| `MainTitle1` | 1x | Main title on cover | LOW |
| `IntroTitle` | already mapped | OK | — |
| `zzSTDTitle` | already mapped | OK | — |
| `KeyTitle`/`KeyText` | 0x in samples | Key section | LOW |
| `BiblioText` | 0x in samples | Bib continuation | LOW |
| `BiblioDescription` | 0x in samples | Bib description | LOW |

### 4. Clean Template Requirements

The current files in `data/iso-dis/` and `data/iso-simple/` are **unclean copies** of existing
documents with content. We need clean, empty templates.

**Clean template = empty DOCX with:**
- All style definitions (styles.xml)
- Numbering definitions (numbering.xml)
- Font table (fontTable.xml)
- Theme (theme1.xml)
- Page layout defaults (in document.xml settings)
- NO body content (empty `<w:body><w:sectPr>...</w:sectPr></w:body>`)

**Approach options:**
1. **Strip content from ISO 6709 template** — remove all paragraphs/tables, keep styles
2. **Build from scratch via Uniword** — define all styles programmatically from YAML
3. **Extract styles to YAML, apply to empty document** — best of both worlds

Option 3 is best: extract all style definitions to YAML files, then use Uniword to build
clean templates by applying the YAML-defined styles to an empty document.

### 5. YAML Extraction Requirements

Extract from DIS template to YAML:
- [ ] All 246 paragraph style definitions (name, baseStyle, font, size, color, spacing, alignment, indent)
- [ ] All 212 character style definitions
- [ ] Numbering definitions (abstractNum + num → abstractNum mappings)
- [ ] Font table entries
- [ ] Theme colors/fonts
- [ ] Default section/page properties (margins, page size, columns)
- [ ] Header/footer default content structure

---

## Action Items

### Phase 1: Complete the bib* style support
- [ ] Add `bib*` character styles to `data/iso-dis/style_mapping.yml`
- [ ] Add `std*` character styles for standard references
- [ ] Add `cite*` character styles for cross-reference formatting
- [ ] Add `au*` character styles for author/editor markup
- [ ] Add missing paragraph styles: `ForewordText`, `RefNorm`, `ListNumber1`, `ListContinue1`, `Examplecontinued`
- [ ] Implement bib* character style application in the adapter's bibliography rendering

### Phase 2: Extract DIS template to YAML
- [ ] Use Uniword to extract all style definitions from ISO 6709 template
- [ ] Create `data/iso-dis/styles.yml` with complete style definitions
- [ ] Create `data/iso-dis/numbering.yml` with numbering definitions
- [ ] Create `data/iso-dis/theme.yml` with theme colors/fonts
- [ ] Create `data/iso-dis/page_layout.yml` with default page properties

### Phase 3: Create clean templates
- [ ] Build clean empty DIS template from YAML via Uniword
- [ ] Build clean empty Simple template from YAML via Uniword
- [ ] Replace `data/iso-dis/template.docx` with clean version
- [ ] Replace `data/iso-simple/template.dotx` with clean version

### Phase 4: Verify against all reference documents
- [ ] Generate DOCX for ISO 6709 content using DIS template
- [ ] Compare style usage against reference document
- [ ] Verify bibliography rendering matches published documents
- [ ] Test normative reference rendering with `RefNorm` style
