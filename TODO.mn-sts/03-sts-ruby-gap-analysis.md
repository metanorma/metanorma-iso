# 03 - Phase 1: sts-ruby Model Gap Analysis

## Element Coverage Map

Comparing elements found in reference STS XML vs sts-ruby model classes.

### Front (iso-meta) — Sts::IsoSts::IsoMeta

| STS Element | sts-ruby Class | Status |
|-------------|---------------|--------|
| `title-wrap` | `TitleWrap` | Present |
| `title-wrap/intro` | `TitleIntro` | Present |
| `title-wrap/main` | `TitleMain` | Present |
| `title-wrap/compl` | `TitleCompl` | Present |
| `title-wrap/full` | `TitleFull` | Present |
| `doc-ident` | `DocumentIdentification` | Present |
| `doc-ident/sdo` | — | Verify mapping |
| `doc-ident/proj-id` | — | Verify mapping |
| `doc-ident/language` | — | Verify mapping |
| `doc-ident/release-version` | — | Verify mapping |
| `doc-ident/urn` | — | Verify mapping |
| `std-ident` | `StandardIdentification` | Present |
| `std-ident/originator` | — | Verify mapping |
| `std-ident/doc-type` | — | Verify mapping |
| `std-ident/doc-number` | — | Verify mapping |
| `std-ident/part-number` | — | Verify mapping |
| `std-ident/edition` | `Edition` | Present |
| `std-ident/version` | — | Verify mapping |
| `content-language` | `NisoSts::ContentLanguage` | Present |
| `std-ref[@type]` | `StdRef` | Present |
| `doc-ref` | `DocRef` | Present |
| `pub-date` | `NisoSts::PubDate` | Present |
| `release-date` | `ReleaseDate` | Present |
| `meta-date[@type]` | `NisoSts::MetaDate` | Present |
| `comm-ref` | `CommRef` | Present |
| `secretariat` | `Secretariat` | Present |
| `ics` | `NisoSts::Ics` | Present |
| `page-count` | `PageCount` | Present |
| `std-xref[@type]` | `StandardCrossReference` | Present |
| `permissions` | `Permissions` | Present |
| `permissions/copyright-statement` | `CopyrightStatement` | Present |
| `permissions/copyright-year` | `CopyrightYear` | Present |
| `permissions/copyright-holder` | `CopyrightHolder` | Present |
| `custom-meta-group` | `NisoSts::CustomMetaGroup` | Present |
| `custom-meta-group/custom-meta` | — | Verify mapping |
| `custom-meta/meta-name` | — | Verify mapping |
| `custom-meta/meta-value` | — | Verify mapping |
| `is-proof` | `NisoSts::IsProof` | Present |

### Body — Sts::IsoSts::Body / Sts::IsoSts::Sec

| STS Element | sts-ruby Class | Status |
|-------------|---------------|--------|
| `sec[@sec-type]` | `Sec` | Present |
| `sec/label` | `Label` | Present |
| `sec/title` | `Title` | Present |
| `sec/p` | `Paragraph` | Present |
| `sec/list` | `List` | Present |
| `sec/list-item` | `ListItem` | Present |
| `sec/def-list` | `DefList` | Present |
| `sec/def-item` | `DefItem` | Present |
| `sec/disp-formula` | `DispFormula` | Present |
| `sec/inline-formula` | `InlineFormula` | Present |
| `sec/table-wrap` | `TbxIsoTml::TableWrap` | Present |
| `sec/fig` | `Fig` | Present |
| `sec/non-normative-note` | `NonNormativeNote` | Present |
| `sec/non-normative-example` | `NonNormativeExample` | Present |
| `sec/preformat` | `Preformat` | Present |
| `sec/styled-content` | `StyledContent` | Present |
| `sec/array` | `Array` | Present |
| `sec/ref-list` | `RefList` | Present |
| `sec/graphic` | `Graphic` | Present |
| `sec/std` | `Std` | Present |
| `sec/fn-group` | `FnGroup` | Present |
| `sec/xref` | `TbxIsoTml::Xref` | Present |
| `sec/ext-link` | `NisoSts::ExtLink` | Present |
| `sec/term-sec` | `TermSec` | Present |
| `sec/sec` (nested) | `Sec` (recursive) | Present |
| `disp-quote` | `NisoSts::DispQuote` | Present? |

### Term Sections — Sts::IsoSts::TermSec / Sts::TbxIsoTml

| STS Element | sts-ruby Class | Status |
|-------------|---------------|--------|
| `term-sec` | `TermSec` | Present |
| `term-sec/label` | `Label` | Present |
| `tbx:termEntry` | `TbxIsoTml::TermEntry` | Present |
| `tbx:langSet` | `TbxIsoTml::LangSet` | Present |
| `tbx:definition` | `TbxIsoTml::Definition` | Present |
| `tbx:term` | `TbxIsoTml::Term` | Present |
| `tbx:tig` | `TbxIsoTml::TermInformationGroup` | Present |
| `tbx:partOfSpeech` | `TbxIsoTml::PartOfSpeech` | Present |
| `tbx:termType` | `TbxIsoTml::TermType` | Present |
| `tbx:normativeAuthorization` | `TbxIsoTml::NormativeAuthorization` | Present |
| `tbx:note` | `TbxIsoTml::Note` | Present |
| `tbx:example` | `TbxIsoTml::Example` | Present |
| `tbx:source` | `TbxIsoTml::Source` | Present |
| `tbx:see` | `TbxIsoTml::See` | Present |
| `tbx:entailedTerm` | `TbxIsoTml::EntailedTerm` | Present |
| `tbx:subjectField` | `TbxIsoTml::SubjectField` | Present |
| `tbx:usageNote` | — | Verify mapping |
| `tbx:grammaticalGender` | `TbxIsoTml::GrammaticalGender` | Present |
| `tbx:grammaticalNumber` | `TbxIsoTml::GrammaticalNumber` | Present |
| `tbx:pronunciation` | `TbxIsoTml::Pronunciation` | Present |

### Back — Sts::IsoSts::Back

| STS Element | sts-ruby Class | Status |
|-------------|---------------|--------|
| `app-group` | `AppGroup` | Present |
| `app` | `App` | Present |
| `app/label` | `Label` | Present |
| `app/title` | `Title` | Present |
| `ref-list[@content-type='bibl']` | `RefList` | Present |
| `ref[@id]` | `Ref` | Present |
| `ref/label` | `Label` | Present |
| `ref/mixed-citation` | `MixedCitation` | Present |
| `ref/std` | `Std` | Present |
| `ref/std-ref` | `StdRef` | Present |
| `fn-group` | `FnGroup` | Present |
| `fn` | `Fn` | Present |

### Inline (within Paragraph and other mixed-content elements)

| STS Element | sts-ruby Class | Status |
|-------------|---------------|--------|
| `bold` | `Bold` | Present |
| `italic` | `Italic` | Present |
| `sc` (small caps) | `NisoSts::Sc` | Present |
| `sub` | `NisoSts::Sub` | Present |
| `sup` | `NisoSts::Sup` | Present |
| `monospace` | `NisoSts::Monospace` | Present |
| `underline` | `NisoSts::Underline` | Present |
| `strike` | `NisoSts::Strike` | Present |
| `overline` | `NisoSts::Overline` | Present |
| `roman` | `NisoSts::Roman` | Present |
| `sans-serif` | `NisoSts::SansSerif` | Present |
| `ext-link` | `NisoSts::ExtLink` | Present |
| `xref[@rid][@ref-type]` | `TbxIsoTml::Xref` | Present |
| `std` | `Std` | Present |
| `std-ref` | `StdRef` | Present |
| `styled-content` | `StyledContent` | Present |
| `inline-formula` | `InlineFormula` | Present |
| `fn` | `TbxIsoTml::Fn` | Present |
| `break` | `Break` | Present |
| `target` | — | Verify mapping |
| `named-content` | — | Verify mapping |
| `graphic` (inline) | `Graphic` | Present |
| `mml:math` | `Mathml2::Math` | Present |

## Critical Ordering Concern

The **#1 issue** for round-trip fidelity is element ordering. STS XML has mixed content:
```xml
<p>This is <bold>important</bold> text with <xref rid="tab_1">Table 1</xref>.</p>
```

Without proper ordered/mixed content support, the text nodes, bold, and xref would lose their interleaving.

**Elements requiring ordered mixed content**:
- `Paragraph` — uses `mixed_content` ✓
- `MixedCitation` — needs verification
- `StyledContent` — needs verification
- `Caption` — needs verification
- `Bold`, `Italic`, etc. — needs verification
- `Title` — needs verification
- `Sec` — needs verification (interleaved label, title, p, list, sec...)

## Execution Order

1. Set up test harness with all reference files
2. Run round-trips, capture all failures
3. For each failure: identify the missing/wrong model attribute
4. Fix the model
5. Re-run until all pass
