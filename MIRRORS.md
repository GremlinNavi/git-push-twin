# Public mirror policy

SPDX-License-Identifier: Apache-2.0

OSWAP Twin Transport is intentionally published through independent public forges.

## Current public endpoints

| Forge | Repository |
| --- | --- |
| GitHub | <https://github.com/GremlinNavi/OSWAP-twin> |
| GitLab | <https://gitlab.com/GremlinNavi-group/git-push-twin> |

The different slugs are compatibility hosting identifiers. The canonical component name is `OSWAP Twin Transport`.

## What mirror equivalence means

Mirror equivalence means that the intended source tree, documentation, version marker, and release/checksum material represent the same project state.

Equivalent mirror snapshots do not need to have the same Git commit SHA. If equivalent content is committed independently on GitHub and GitLab, commit metadata and parent history can differ, producing different commit IDs even when file contents match.

## Recommended verification order

For a public snapshot:

1. compare the `VERSION` file;
2. compare the expected file tree;
3. compare important source and documentation file contents;
4. compare published release checksums when using an archived release artifact; and
5. investigate any unexplained divergence before treating one mirror as authoritative.

For release archives, prefer the recorded SHA-256 checksum material under `releases/` rather than assuming a forge-generated archive is byte-identical across providers.

## Publication boundary

Multi-host publication is sequential, not atomic. One destination can accept a publication while another rejects it.

A partial multi-host result must be surfaced for investigation. The project must not hide the condition by force-pushing, rewriting unrelated history, or pretending that the destinations converged.

## Source-of-truth hierarchy

For language semantics, [OSWAP_STANDARD.md](OSWAP_STANDARD.md) is normative.

For component identity and forge naming, [BRANDING.md](BRANDING.md) is authoritative.

For a release artifact, the versioned release notes and SHA-256 checksum material define the expected archived payload.

## Reporting divergence

If the public mirrors unexpectedly disagree, open an issue on either forge and include:

- the two repository URLs;
- the branch, tag, or version compared;
- the affected paths;
- the observed hashes or commit IDs; and
- whether the difference appears to be content, metadata, or history only.

Do not include credentials, private repository URLs, access tokens, or sensitive plaintext in a public issue.
