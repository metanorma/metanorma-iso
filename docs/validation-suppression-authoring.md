# Suppressing validation warnings in your document

Metanorma checks an ISO document against the ISO House Style policy and the
ISO/IEC Directives, Part 2, and reports every violation with a stable rule
code such as `ISO_21` or `STANDOC_48`. Some checks do not fit a particular
document: an annex may legitimately remain unreferenced, or a house may have
resolved that the generic style findings of one template carry no weight. The
declarative suppression attributes let the document author silence or
reclassify named rules for the whole document, and every suppressed entry
remains visible in an audit category, so a suppression is a recorded decision
rather than a silent drop.

## Rule codes

Every finding names its rule code. The codes of the ISO flavour are
documented, with their policy category, cited wording and severity, in the
validation policy page that the metanorma-iso gem generates
(`validation-policy.adoc` and `validation-policy.json`). The code is the
stable key for all suppression: an author never needs to know which
implementation kind produces a finding.

## The one-line attributes

The common cases are one document attribute line. Both take a
comma-separated list of rule codes.

`:validation-off:` stops the named rules from being reported at all:

```adoc
:validation-off: ISO_21, ISO_39
```

`:validation-warning:` reclassifies the findings of the named rules as
warnings, so they still appear but no longer abort the build:

```adoc
:validation-warning: STANDOC_48
```

The severities `info`, `warning` and `error` are all available through the
configuration file, which is the form to use when a document needs a
reclassification other than these two.

## The configuration file

A document can carry a suppression configuration file referenced through the
`:validation-config:` attribute, resolved like `:i18nyaml:`:

```adoc
:validation-config: validation.yml
```

The file schema is `metanorma-validation-suppression/1` and is frozen for
the v1 mechanism. Each entry names a rule code and carries a single
`severity` action:

```yaml
schema: metanorma-validation-suppression/1
rules:
  ISO_21:
    severity: off
  ISO_39:
    severity: warning
  STANDOC_48:
    severity: info
```

The action vocabulary is `off` (the rule is not reported), `info`,
`warning` and `error` (the rule is reported at that severity). Per-line,
element-scoped and message-regex exclusions are planned for the coradoc
era, which provides the line-anchored positions they require.

## How the layers resolve

The effective configuration is resolved from four layers, each overriding
the previous one per rule code:

1. the engine default, which reports every rule at its registered severity;
2. the flavour baseline, the `validation_policy/metanorma.yml` file that
   each flavour gem ships (metanorma-iso declares the ISO House Style
   baseline);
3. the taste overlay, applied when the document selects a taste through the
   `:taste:` attribute or the environment;
4. the document configuration, through `:validation-config:` or the
   one-line attributes.

The resolved effective configuration is dumped into the log with every
conversion, so a reader of the log can see which layer set each code.

## What happens to a suppressed entry

A suppressed finding is never deleted. It is moved to the dedicated
Suppressed category of the log, and each entry carries its original code,
message, element and the configuration line that suppressed it. The error
file gains a Suppressed section, so reviewers see what the author silenced
and can challenge it. Counting suppressed entries in CI arrives with the
second phase of the mechanism (`--fail-on-suppressed`).

The older `log-filter-severity`, `log-filter-category`, `log-filter-error-ids`,
`log-filter-error-regex` and `log-filter-error-loc` attributes are
deprecated: they map onto this configuration internally, and they were the
only suppression lever that removed entries silently.

## Worked example

An author working on an ISO technical report finds that the build fails on
findings the document intentionally carries: a Scope that contains
subclauses (`ISO_39`), and a stream of generic House Style findings
(`STANDOC_48`) that the drafting team has already dispositioned. The author
adds one line to the document header:

```adoc
:validation-off: ISO_39
:validation-warning: STANDOC_48
```

The build now reports the House Style findings as warnings, and the Scope
finding no longer appears; both decisions are recorded in the Suppressed
section of the error file for the reviewer to confirm.
