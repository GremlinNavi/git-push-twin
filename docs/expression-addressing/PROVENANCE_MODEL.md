# Provenance and Data-History Model

## Principle

Expression Addressing preserves both state history and representation history.

A system that stores only:

```text
value = 3
```

cannot distinguish whether the original representation was:

```text
3
9/3
IX/III
1.5*2
```

The expression layer therefore treats the source representation as provenance.

## Recommended record

A machine-readable record should be able to include:

```text
rawExpression
canonicalExpression
ast
exactValue
namespace
specVersion
parserVersion
mappingVersion
mappingSha256
policyVersion
resolvedTargets
operation
gitCommit
timestamp
outcome
```

## Example

```json
{
  "rawExpression": "IX/III",
  "canonicalExpression": "(9/3)",
  "exactValue": "3",
  "namespace": "twin",
  "specVersion": "0.1-draft",
  "mappingVersion": "example-v1",
  "resolvedTargets": ["ca", "us", "jp"],
  "operation": "push",
  "gitCommit": "abc123..."
}
```

## Historical reconstruction

A durable record should answer separate questions:

```text
What did the operator write?
How did the parser understand it?
What value was computed?
Which mapping assigned infrastructure meaning?
Which targets were selected?
Which exact Git object was acted upon?
What happened at each target?
```

This matters because parsers, mappings, repository endpoints, and policy may change over time.

## Non-destructive normalization

Canonicalization must derive new data rather than overwrite old data.

```text
raw       -> preserved
canonical -> derived
value     -> derived
resolution-> derived under a specific mapping
```

## Integrity boundary

Expressions are descriptive provenance, not cryptographic proof.

Git object IDs, SHA-256 manifests, signatures, authenticated forge identities, and protected-branch controls remain separate evidence layers.

## Storage

Operational records can be local and untracked by default to avoid commit noise.

Important release or archival records may be committed explicitly as manifests.

A future implementation can also investigate Git notes for commit-associated metadata without modifying tree contents.
