# Expression Addressing Specification — Draft v0.1

## Purpose

OSWAP Expression Addressing uses restricted arithmetic expressions as inspectable identifiers and selectors.

Two different expressions may resolve to the same semantic value while retaining distinct syntactic/provenance identity.

```text
9/3    -> 3
6/2    -> 3
IX/III -> 3
1.5*2  -> 3
```

The resolved value may identify a family, count, or namespace-specific selector. The original expression remains historical data.

## Identity model

Implementations must distinguish:

```text
raw identity       = exact user-supplied expression
canonical identity = normalized parser representation
semantic identity  = exact evaluated value
resource identity  = resolver output under a named mapping version
```

Semantic equality does not imply syntactic equality.

For example, `9/3` and `IX/III` may both resolve to `3`, but their raw identities remain different.

## Draft v0.1 grammar

```text
expression := term (("+" | "-") term)*
term       := factor (("*" | "/") factor)*
factor     := number | roman | "-" factor | "(" expression ")"
number     := decimal integer or finite decimal literal
roman      := canonical Roman numeral using I,V,X,L,C,D,M
```

The core division operator is `/`.

PowerShell already recognizes `/` as division; the expression specification therefore does not use `d` as a division operator. Any DNS- or filename-safe encoding is a separate transport concern and must not change the canonical expression grammar.

## Arithmetic

Evaluation should use exact rational arithmetic rather than binary floating point.

Examples:

```text
1.5*2   -> 3
0.1+0.2 -> 3/10
9/3     -> 3
```

A resolver may require a final positive integer even though intermediate arithmetic is rational.

## Roman numerals

Roman numerals are optional lexical representations of positive integers.

```text
III     -> 3
IX/III  -> 3
XII/IV  -> 3
```

Draft v0.1 accepts canonical modern Roman forms only. Historical variants such as `IIII` should be rejected unless a future profile explicitly permits them.

Roman numeral normalization occurs before evaluation, while the raw representation is retained.

Example:

```text
raw:       IX/III
canonical: (9/3)
value:     3
```

## Canonicalization

Canonicalization is deterministic and additive: it creates a derived representation without replacing the raw input.

An implementation should record both.

Parentheses may be inserted in canonical output to make the AST explicit.

## Namespaces

Arithmetic values have no universal infrastructure meaning.

A namespace resolver assigns meaning:

```text
repo:3
twin:3
archive:3
region:3
build:3
```

The same numeric result may resolve differently under different namespaces.

## Multi-member selection

A single arithmetic expression and a set of member expressions are different data types.

Existing design examples such as:

```text
twin=(9/3)+12/4
```

must not be flattened to the arithmetic result `6` when `+` is intended as member composition.

A production implementation should represent the selection as a collection of independently parsed expressions before resolution. A future selection grammar may standardize the human-facing syntax.

## Non-goals

The draft does not:

- replace Git object IDs;
- authenticate users;
- provide cryptographic integrity;
- execute arbitrary PowerShell;
- define DNS encoding;
- make mathematically equivalent repositories content-equivalent.
