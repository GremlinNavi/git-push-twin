# Security Model

## Core rule

Expression Addressing parses a tiny arithmetic language. It does not execute a general-purpose language.

Prohibited implementation shortcuts include:

```text
PowerShell Invoke-Expression
Python eval / exec
shell expansion
dynamic command construction from unvalidated source text
```

## Parser limits

Implementations should define explicit limits for:

- source length;
- token count;
- AST depth;
- numeric magnitude;
- rational numerator/denominator magnitude;
- supported numeral systems;
- supported operators.

The example policy file provides conservative draft values.

## Character handling

Draft v0.1 uses an ASCII operator set:

```text
+ - * / ( )
```

Roman numerals use ASCII `I V X L C D M`.

Implementations should reject unsupported Unicode lookalikes rather than silently normalizing confusable characters.

## Arithmetic errors

Reject:

- division by zero;
- malformed numerals;
- unsupported tokens;
- excessive nesting;
- values outside configured bounds;
- non-integer final results in integer-only namespaces.

## Resolver safety

A valid expression is not permission to access a target.

Resolution must be followed by policy and authorization checks.

A parser should never accept a hostname, command, path, script block, environment-variable expansion, or arbitrary function invocation as arithmetic.

## Git safety

The expression layer must not automatically use destructive recovery operations.

Force push, destructive reset, automatic merge, or automatic rebase should remain explicit operator decisions outside expression evaluation.

## Transport encodings

DNS, filenames, and Git refs may require safe serialization.

Transport encodings must be reversible, separately specified, and decoded before expression parsing. They must not introduce alternate arithmetic operators into the canonical grammar.
