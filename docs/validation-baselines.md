# Flavor and taste validation baselines

A validation baseline is a data file that a flavour or a taste gem ships,
declaring the default severity of every validation rule code the flavour
emits. The declarative suppression mechanism
(metanorma/metanorma-standoc#1369) reads the baseline as the flavour layer
of its resolution chain; documents and tastes override it per rule code.
This page documents the format, the discovery paths, the ownership rules
and the generation of the baseline that metanorma-iso ships.

Per the conform-profile ownership ruling, the owner of the policy declares
what is active: flavours and tastes own their baselines, and the engine
never dictates policy to them.

## Format

The baseline lives at `lib/metanorma/<flavor>/validation_policy/metanorma.yml`
inside the flavour gem. The schema is `metanorma-validation-suppression/1`
and is frozen for the v1 mechanism, which is type-only: each rule code
carries a single `severity` action, and the vocabulary is `off`, `info`,
`warning` and `error`.

```yaml
schema: metanorma-validation-suppression/1
flavor: iso
rules:
  ISO_21:
    severity: warning
  STANDOC_48:
    severity: error
```

The `flavor` key names the flavour the file belongs to. The default state
of a flavour is declared explicitly rather than left implicit: the
metanorma-iso baseline places every code at its natural registry severity,
so the flavour suppresses nothing and downstream layers have a declared
starting point to deviate from.

## Discovery

The engine discovers the flavour baseline through
`Gem::Specification.find_by_name("metanorma-<flavor>")`, reading
`lib/metanorma/<flavor>/validation_policy/metanorma.yml` from the resolved
gem. This is the same discovery pattern as the `<type>_conform_profile/`
directories.

A taste layer applies on top of the flavour baseline when a taste is
active. The taste baseline lives at the same relative path inside the taste
gem (`metanorma-taste-<name>`, or a taste gem such as metanorma-pdfa), and
the taste becomes active through the document `:taste:` attribute, the
`METANORMA_TASTE` environment variable or the CLI taste selection. A
document that activates no taste resolves only the flavour and document
layers.

## Override precedence

The resolution order, from weakest to strongest, is:

1. engine default — every rule at its registered severity;
2. flavour baseline — `validation_policy/metanorma.yml` in the flavour gem;
3. taste overlay — `validation_policy/metanorma.yml` in the active taste
   gem;
4. document configuration — `:validation-config:` and the
   `:validation-off:` / `:validation-warning:` attributes.

Each layer overrides the previous one per rule code, and inline anchors
take the position above the document layer when the mechanism's second
phase lands. The resolved effective configuration is dumped into the log
with every conversion.

## Generation from rule metadata

The metanorma-iso baseline is generated, not hand-written. The source of
truth is the rule metadata of the validation-policy generator
(metanorma/metanorma-iso#1709): the `code` and `policy` declarations on the
rule classes discovered by `Metanorma::Iso::Validation::RuleRegistry`, and
the `LEGACY_POLICY` sidecar of the legacy checks. `Metanorma::Iso::Validation::PolicyDoc.baseline_yaml`
renders the file, ordering the entries in the canonical policy order (model
rules by class name, then the legacy sidecar order) and resolving each
severity from the ISO and standoc log registries. A code that neither
registry knows takes the registry default, `severity: error`, which the
file header documents.

The regeneration command is documented in the file header:

```
bundle exec ruby -I lib -r metanorma-iso \
  -e 'puts Metanorma::Iso::Validation::PolicyDoc.baseline_yaml' \
  > lib/metanorma/iso/validation_policy/metanorma.yml
```

Two specifications keep the shipped file honest:
`spec/metanorma/validation/validation_baseline_spec.rb` fails when the
committed file differs from what `baseline_yaml` generates, and its
coverage checks are bidirectional, so a new rule without a baseline entry,
or a baseline entry without a rule, fails the suite. Adding a rule to the
flavour is therefore followed by one regeneration, and the baseline never
silently misses a rule.
