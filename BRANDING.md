# OSWAP Twin Transport branding

## Canonical identity

- Display name: `OSWAP Twin Transport`
- GitHub repository slug: `git-push-twin` (current hosting identifier)
- GitLab repository slug: `git-push-twin` (current hosting identifier)
- Primary implementation language: PowerShell
- Canonical user-facing command: `oswap upload twin=N`
- Compatibility Git transport command: `git push twin`
- Current Git remote name: `twin`

`OSWAP Twin Transport` is the component identity. `PS-twin` and `git-push-twin` are compatibility/hosting identifiers; Git, GitHub, GitLab, self-hosted Git servers, and future repository providers are transport surfaces rather than the public identity of the component.

The name deliberately avoids privileging a particular repository provider. The current implementation uses standard Git transport because Git is broadly interoperable, but OSWAP architecture should remain free to add other repository or archival adapters without requiring another project rename.

## Open-Source World Access Project relationship

OSWAP Twin Transport is open-source publication and repository-redundancy infrastructure for the Open-Source World Access Project (OSWAP). It helps an operator configure, publish, compare, and verify approved repository destinations.

It is not the OSWAP software catalogue or database, and it does not replace or rename the separate Sovereign AI Demonstrator.

## OSWAP-owned domains

OSWAP owns the following public domain names:

- `oswap.ca`
- `oswap.jp`
- `oswap.us`

Planned repository-access namespaces include:

- `repo.oswap.ca`
- `repo.oswap.jp`
- `repo.oswap.us`

Domain ownership must not be confused with deployment status. A planned subdomain is not operational until its DNS, TLS, routing, repository protocol behaviour, and equivalence rules are deployed and verified.

Order-of-Operations addressing may additionally use DNS-safe expression labels such as `9d3` for the canonical expression `9/3`. The mathematical expression remains metadata; the encoded label exists for transport surfaces that cannot represent the raw arithmetic form.

See [ORDER_OF_OPERATIONS_ADDRESSING_AND_BUILD_PROVENANCE.md](ORDER_OF_OPERATIONS_ADDRESSING_AND_BUILD_PROVENANCE.md).

## Current public repositories

The connected forge projects currently use the same compatibility hosting slug on both providers:

- GitHub: <https://github.com/GremlinNavi/git-push-twin>
- GitLab: <https://gitlab.com/GremlinNavi-group/git-push-twin>

Those URLs are hosting identifiers, not the canonical component name. Avoid further repository renames during active development unless there is a concrete migration need; public documentation should use `OSWAP Twin Transport` and canonical OSWAP command syntax.

## Compatibility names

`PS-twin`, `Git Push Twin`, and `git-push-twin` are compatibility or hosting identifiers rather than current component branding. They may still appear where necessary to describe:

- the literal `git push twin` command;
- compatibility-facing script filenames such as `Invoke-GitPushTwin.ps1`;
- immutable historical archives, checksums, commits, or links; or
- current forge paths that have not yet been renamed.

Do not interpret those compatibility references as provider preference.

## Claims and tone

Be precise, calm, and candid. Multi-host publication improves resilience but does not guarantee permanent access, atomic distributed publication, authenticity, or backup completeness. Avoid unsupported claims of universal access, security, endorsement, or availability.
