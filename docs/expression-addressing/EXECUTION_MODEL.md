# Expression-Aware Execution Model

## Execution boundary

The expression-aware layer sits between human symbolic input and consequential infrastructure actions.

```text
input
 -> parse
 -> validate
 -> canonicalize
 -> evaluate
 -> resolve
 -> authorize
 -> plan
 -> execute
 -> record
```

No network-changing action should occur during parsing, validation, canonicalization, evaluation, or resolution.

## Required stages

### 1. Parse

Convert supported tokens into a typed AST. Do not call `Invoke-Expression`, Python `eval`, a shell, or another general-purpose interpreter.

### 2. Validate

Apply grammar and resource limits before resolution.

Examples include maximum expression length, token count, nesting depth, numeric magnitude, and final-domain constraints.

### 3. Canonicalize

Produce a deterministic representation while retaining the exact raw input.

### 4. Evaluate

Use exact rational arithmetic.

### 5. Resolve

Apply a versioned namespace mapping.

Example:

```text
namespace: twin
expression: 9/3
value: 3
mapping: twin-map-v1
```

The mapping determines what `3` means.

### 6. Authorize

Check repository policy, operator intent, credentials, protected branches, or other adapter-specific rules.

### 7. Plan

Produce a complete inspectable execution plan before side effects.

A dry run should be able to stop here.

### 8. Execute

Pass already-resolved targets to ordinary adapters such as Git.

The adapter should not re-interpret the raw arithmetic expression.

### 9. Record

Persist sufficient provenance to reconstruct the decision path.

## Determinism target

Given the same:

```text
raw expression
parser/spec version
namespace
mapping configuration
policy configuration
```

the system should generate the same canonical AST, exact value, and resolution plan.

External systems may still change, so execution success is a separate property.

## Final-value policy

For repository-count or repository-index namespaces, a reasonable default is:

```text
intermediate domain: exact rational
final domain: positive integer
```

Thus:

```text
9/3   -> 3   ACCEPT
1.5*2 -> 3   ACCEPT
3/2   -> 3/2 REJECT for integer-only namespace
1/0          REJECT
```

## Infrastructure adapters

The expression engine should be reusable independently of Git.

Potential adapters include:

- Git remotes and repository families;
- archival storage;
- deployment regions;
- CI/CD target groups;
- build profiles;
- package mirrors.

This separation is what allows the concept to become infrastructure rather than a Git-specific trick.
