# OSWAP Twin Transport branding

## Canonical identity

- Display name: `OSWAP Twin Transport`
- GitHub repository slug: `OSWAP-twin` (current canonical hosting identifier; `PS-twin` is retained as a historical compatibility name)
- GitLab repository slug: `git-push-twin` (current hosting identifier)
- Primary implementation language: PowerShell
- Canonical user-facing command: `oswap upload twin=N`
- Compatibility Git transport command: `git push twin`
- Current Git remote name: `twin`

`OSWAP Twin Transport` is the component identity. `OSWAP-twin` is the current GitHub hosting identifier; `PS-twin` is a historical compatibility identifier, and `git-push-twin` remains the current GitLab hosting identifier. Git, GitHub, GitLab, self-hosted Git servers, and future repository providers are transport surfaces rather than the public identity of the component.

The name deliberately avoids privileging a particular repository provider. The current implementation uses standard Git transport because Git is broadly interoperable, but OSWAP architecture should remain free to add other repository or archival adapters without requiring another project rename.

## Open-Source World Access Project relationship

OSWAP Twin Transport is open-source publication and repository-redundancy infrastructure for the Open-Source World Access Project (OSWAP). It helps an operator configure, publish, compare, and verify approved repository destinations.

It is not the OSWAP software catalogue or database, and it does not replace or rename the separate OSWAP AI Demonstrator.

## Registered OSWAP domains — not yet online

OSWAP has registered the following domain names for planned future infrastructure:

- `oswap.ca`
- `oswap.jp`
- `oswap.us`

No OSWAP website, repository endpoint, API, or other public service on those domains is represented by this repository as currently deployed or online.

Planned repository-access namespace labels include:

- `repo.oswap.ca` — planned
- `repo.oswap.jp` — planned
- `repo.oswap.us` — planned

A planned hostname is not operational until DNS, TLS, routing, repository protocol behaviour, and relevant content/equivalence checks have been deployed and independently verified.

Documentation and tests that require a deliberately non-operational network hostname should use an IANA-reserved example or `.invalid` name instead of presenting a planned OSWAP hostname as a usable URL.

Order-of-Operations addressing may additionally reserve DNS-safe expression labels such as `9d3` for the canonical expression `9/3`. The mathematical expression remains metadata; the encoded label exists for transport surfaces that cannot represent the raw arithmetic form.

See [ORDER_OF_OPERATIONS_ADDRESSING_AND_BUILD_PROVENANCE.md](ORDER_OF_OPERATIONS_ADDRESSING_AND_BUILD_PROVENANCE.md).

## Current public repositories

The connected forge projects currently use different compatibility hosting slugs:

- GitHub: <https://github.com/GremlinNavi/OSWAP-twin>
- GitLab: <https://gitlab.com/GremlinNavi-group/git-push-twin>

Those are current, independently verifiable repository URLs. They should remain the user-facing network locations until any future OSWAP-owned endpoint is actually deployed and verified.

Those URLs are hosting identifiers, not the canonical component name. Avoid further repository renames during active development unless there is a concrete migration need; public documentation should use `OSWAP Twin Transport` and canonical OSWAP command syntax.

## Compatibility names

`PS-twin`, `Git Push Twin`, and `git-push-twin` are compatibility or hosting identifiers rather than current component branding. They may still appear where necessary to describe:

- the literal `git push twin` command;
- compatibility-facing script filenames such as `Invoke-GitPushTwin.ps1`;
- immutable historical archives, checksums, commits, or links; or
- historical forge paths and compatibility references.

Do not interpret those compatibility references as provider preference.

## Claims and tone

Be precise, calm, and candid. Multi-host publication improves resilience but does not guarantee permanent access, atomic distributed publication, authenticity, or backup completeness. Avoid unsupported claims of universal access, security, endorsement, website/service availability, or production deployment.
