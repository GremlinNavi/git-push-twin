# OSWAP Expression Addressing

Status: draft specification scaffold with a working side-effect-free reference parser and separate PowerShell publication implementation.

OSWAP Standard 0.2.0 is normative for current `push twin=<expression>` arithmetic, including `^` exponentiation. This draft additionally explores canonical Roman-numeral lexical forms and exact rational arithmetic. Until the reference parser, PowerShell parser, and conformance vectors implement the same feature set, those differences are experimental rather than portable syntax guarantees.

This directory separates the proposed Order-of-Operations addressing layer from the existing PS-twin Git adapter and native Git `twin` remote architecture.

The core model is:

```text
raw expression
  -> restricted parser
  -> typed AST
  -> exact arithmetic value
  -> namespace resolver
  -> policy / authorization
  -> execution plan
  -> adapter
  -> provenance record
```

The expression layer is not native Git syntax and must not execute arbitrary PowerShell or Python.

## Documents

- `EXPRESSION_SPEC.md` — grammar, identities, Roman numerals, canonicalization.
- `EXECUTION_MODEL.md` — safe evaluation and infrastructure-resolution pipeline.
- `GIT_INTEGRATION.md` — integration with PS-twin without changing Git itself.
- `PROVENANCE_MODEL.md` — data-history and reproducibility fields.
- `SECURITY_MODEL.md` — parser and execution safety boundaries.

## Supporting files

- `../../config/expression-policy.json` — example parser/evaluator limits.
- `../../config/repository-map.example.json` — example namespace mapping.
- `../../reference/expression_parser.py` — side-effect-free reference parser.
- `../../tests/conformance/expression_vectors.txt` — cross-language test vectors.

The reference parser is intentionally independent of Git and network operations. Production adapters should consume validated resolution results rather than raw expressions.
