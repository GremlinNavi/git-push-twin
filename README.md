# OSWAP Twin Transport

OSWAP is a domain-specific programming language (DSL) for expressing auditable digital access, authorization, replication, preservation, provenance, and accountability workflows. OSWAP Twin Transport is the PowerShell/Git reference transport component of the Open-Source World Access Project (OSWAP), implementing part of that language's preview-first multi-destination publication and cautious multi-source retrieval semantics.

Current version: `0.1.0-beta.1`
OSWAP Standard: `0.2.1`
License: Apache-2.0
Status: experimental public beta

## At a glance

| Concept | Meaning |
| --- | --- |
| `twin` | Cardinality: how many independently selected copies or sources participate. |
| `joker` | Policy: how eligible copies or sources are selected or used. Experimental in the OSWAPSACW documentation; it is not implemented as a synonym for `twin`. |
| <code>&#124;&amp;</code> | Ordered OSWAP OR/AND logic-gate token. Token ordering is standardized; detailed execution semantics remain experimental. |
| Y/N authorization | `Y` authorizes the stated attempt; `N` cancels. Neither input is a credential or proof of successful execution. |
| `oswap upload twin=N` | Canonical user-facing publication form. |
| `git push twin` | Compatibility transport mechanism for configured all-destination pushes. |
| Accountability Ballchain | OSWAP accountability/provenance terminology inspired by the physical chain connecting military identity dog tags. It is not cryptocurrency or Bitcoin. |

See [GLOSSARY.md](GLOSSARY.md) for terminology and implementation-status notes.

## Public mirrors

This project is intentionally published on more than one forge:

- GitHub: <https://github.com/GremlinNavi/PS-twin>
- GitLab: <https://gitlab.com/GremlinNavi-group/git-push-twin>

The hosting slugs differ for compatibility reasons; the component name is `OSWAP Twin Transport`. Equivalent mirror snapshots can have different Git commit IDs when the same content is committed separately on each forge. See [MIRRORS.md](MIRRORS.md) for verification guidance.

## Quick start

Requirements:

- Git
- PowerShell 7+ recommended for the documented `pwsh` commands; current scripts retain Windows PowerShell 5.1 compatibility where practical
- one or more Git remotes you are authorized to use

Clone either public mirror:

```powershell
git clone https://github.com/GremlinNavi/PS-twin.git
Set-Location PS-twin
```

Run the local test suite:

```powershell
pwsh -NoLogo -NoProfile -File ./tests/Run-All.ps1
```

Preview an OSWAP publication without writing to a remote:

```powershell
./Invoke-OSWAPPush.ps1 'upload' 'twin=(4+3)/2'
```

Execute only after reviewing the selected destinations:

```powershell
./Invoke-OSWAPPush.ps1 'upload' 'twin=(4+3)/2' -Execute
```

The executing form displays the selected destinations and requires the operator to type `TWIN` before publication.

## What the current implementation does

Implemented in the current source tree:

- parses restricted OSWAP arithmetic without `Invoke-Expression`;
- resolves integer and fractional whole-copy replication factors;
- selects eligible publication destinations without replacement;
- previews publication before any remote write;
- requires explicit operator confirmation before publication;
- supports a configured `twin` Git remote for compatibility pushes;
- retrieves from multiple configured sources and refuses source disagreement;
- avoids destructive pull reconciliation and only fast-forwards clean local history;
- includes secret-screening and release/checksum helpers; and
- includes PowerShell syntax and documentation-semantic conformance tests.

Still experimental or requiring wider validation:

- cross-platform behavior beyond the available test environments;
- convergence of expression-addressing implementations behind one conformance suite;
- reproducible routing/provenance manifests for semi-random selection;
- non-Git archival or repository adapters; and
- broader OSWAPSACW policy surfaces such as `joker`.

Design documents describe future work explicitly and must not be read as proof that a feature is implemented.

## OSWAP language boundary

OSWAP is a domain-specific programming language (DSL), not merely a PowerShell wrapper, Git alias set, or collection of command names. PowerShell is a supported host, launcher, implementation environment, and prompt surface; PowerShell grammar does not redefine OSWAP grammar.

Within OSWAP arithmetic, `^` means exponentiation. The reference publication parser does not use `Invoke-Expression`, shell `eval`, or equivalent arbitrary-code evaluation.

The normative rules are in [OSWAP_STANDARD.md](OSWAP_STANDARD.md).

## Fractional replication

A positive non-integer `twin` value represents probabilistic selection of one additional complete destination, never a partial repository.

For example:

```text
twin=(4+3)/2
```

resolves to `3.5`: three complete destination publications are guaranteed and a fourth complete destination is selected with 50% probability, subject to the configured eligible pool.

## Consent and safety boundary

OSWAP publication is preview-first. A successful parse is not authorization, authorization is not proof of execution, and execution is not proof of success. Where a Y/N gate is used, `Y` authorizes only the stated attempt and `N` cancels; neither value is authentication material.

The project does not use a `twin` expression as permission to force-push, rewrite history, reset a working tree, disable endpoint security, or publish private plaintext. Sensitive records must be encrypted before remote replication and decryption secrets must remain separate from replicated ciphertext.

See [SECURITY.md](SECURITY.md) and [OSWAP_INTENT.md](OSWAP_INTENT.md).

## Documentation map

Start here:

- [OSWAP Standard](OSWAP_STANDARD.md) — normative language and safety rules.
- [OSWAP Intent](OSWAP_INTENT.md) — project goals and non-goals.
- [Twin Protocol](TWIN_PROTOCOL.md) — transport behavior and reconciliation boundaries.
- [Architecture Scope](ARCHITECTURE_SCOPE.md) — implemented versus proposed architecture.
- [Branding](BRANDING.md) — canonical component identity and hosting-name policy.
- [Glossary](GLOSSARY.md) — concise terminology with implementation-status labels.
- [Mirrors](MIRRORS.md) — public endpoints and equivalence checks.
- [Documentation index](docs/README.md) — deeper design and historical documents.
- [Changelog](CHANGELOG.md) — user-facing project history.

## Contributing and support

Bug reports, test cases, documentation corrections, portability fixes, and narrowly scoped feature proposals are welcome. Please read [CONTRIBUTING.md](CONTRIBUTING.md), [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md), and [SECURITY.md](SECURITY.md) before contributing.

For usage questions and support boundaries, see [SUPPORT.md](SUPPORT.md).

## License

OSWAP-authored code and documentation in this repository are licensed under the Apache License 2.0. See [LICENSE](LICENSE) and [NOTICE](NOTICE).
