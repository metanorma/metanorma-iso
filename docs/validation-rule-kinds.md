# Validation rule kinds

A validation finding reaches the document through one of four
implementation kinds. The kinds matter to the rule author, who implements
one of them; they do not matter to the document author, because suppression
matches the emission of a finding — its rule code — and never its
implementation. The suppression configuration keys are log codes, so one
vocabulary covers all four kinds, and an author silencing `ISO_39` does not
need to know which kind emits it.

This page describes the four kinds as implemented in the metanorma-iso
flavour, how each kind emits, and why the code is the interface that
suppression relies on.

## The four kinds

### Model-traversal rules

Model-traversal rules are `Metanorma::Iso::Validation::Rules::Base`
subclasses in `lib/metanorma/iso/validation/rules/`. A rule declares its
log key with `code "ISO_N"`, walks the Lutaml document model — often
through the `TreeTraversal` helpers — and returns an array of issues built
by `build_issue`, each carrying the code, the model location and the
message parameters. The registry
(`Metanorma::Iso::Validation::RuleRegistry`) discovers every concrete rule
class automatically, so a new rule file plus one autoload line is the whole
registration.

### Legacy regex checks

Legacy regex checks are the `LegacyChecks` methods in
`lib/metanorma/iso/validate.rb`, which test extracted text against regular
expressions and report through the shared log. Most of them share the
generic style-warning sink `STANDOC_48`. Their policy metadata lives in the
`LEGACY_POLICY` sidecar until they migrate into rule classes, and the
coverage specification `legacy_policy_spec` keeps the sidecar complete
against the source.

### Structural walkers

Structural walkers traverse the document order rather than single nodes:
the section-sequence check, the term-ordering and cross-reference-family
checks, and the unreferenced-asset sweep all walk ordered structures and
emit one finding per misplaced or unreferenced element, each under the
element's own code.

### Engine-profile verdicts

Engine-profile verdicts are the results reported by the conformance
engines, `svg_conform` and `png_conform`. These profiles own their policy
and their reporting, and their verdicts are not part of the suppression
configuration: a document does not silence them through
`metanorma-validation-suppression` files, in the same way that the
conform-profile ownership ruling keeps profile policy with the profile.

## How a finding is emitted

Every kind funnels into the shared log with the same anatomy: a rule code
(`ISO_N` or `STANDOC_N`), a severity, a category, a message template and an
element or location label. The code is registered in a log registry —
`ISO_LOG_MESSAGES` in `lib/metanorma/iso/log.rb`, `STANDOC_LOG_MESSAGES` in
metanorma-standoc — which holds the category, the message template and the
numeric severity (0 for aborts and 2 for serious findings map to `error`, 1
to `warning`, 3 to `info`). The registries are the single source of
severity: the rule classes read them, the policy page renders them, and the
flavour baseline carries them forward as declared defaults.

## Why suppression matches the emission

Because every kind emits through the shared log under a code, the
suppression filter of the log intercepts all kinds uniformly, and the
document-facing vocabulary stays implementation-free. The policy metadata
DSL (`policy` and `directives` on `Rules::Base`) documents each rule's
category, cited wording and functional tag; the generator
(`Metanorma::Iso::Validation::PolicyDoc`) renders it into the
validation-policy page and into the flavour baseline; and the coverage
specifications — `policy_metadata_spec`, `legacy_policy_spec`,
`policy_doc_spec` and `validation_baseline_spec` — enforce that a rule
declared, a rule documented and a baseline entry shipped are the same set
of codes.
