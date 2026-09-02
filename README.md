# PS-twin

PS-twin is a standalone PowerShell safety, publication, and repository-redundancy layer for OSWAP.

The project name is intentionally repository-provider agnostic. Git is the current transport implementation; GitHub, GitLab, self-hosted Git servers, and future repository or archival providers are destinations rather than the identity of the project.

## Current Git workflow

PS-twin currently configures a normal Git remote named `twin` with one or more push URLs so that the explicit command:

```powershell
git push twin
```

publishes the selected commit to every configured Git destination.

The current implementation adds safety and verification around Git's native multi-push behaviour:

1. a pre-push scrub gate that refuses obvious secrets or private-key material;
2. a SHA-256 manifest for the clean tracked tree being pushed;
3. optional post-push verification that compares destination branch refs with the local commit; and
4. explicit failure semantics for partial multi-host publication.

## Why PS-twin exists

A repository host is a distribution surface, not an archival identity.

PS-twin is intended to let a project keep its publication policy independent of a single provider. Today that means standard Git remotes. The architecture is deliberately structured so future OSWAP adapters can support other repository or archival transports without renaming the project around a particular provider.

## Requirements

- PowerShell 5.1+ or PowerShell 7+
- Git for the current Git transport adapter
- an existing local repository checkout
- authenticated access to each selected destination

## Install the current Git adapter

From the repository you want to publish through the Git adapter:

```powershell
& "C:\path\to\ps-twin\Install-GitPushTwin.ps1" `
  -RepositoryUrl @(
    "https://github.com/OWNER/REPO.git",
    "https://gitlab.com/GROUP/REPO.git"
  )
```

The installer:

- refuses to run outside a Git working tree;
- preserves the first configured URL as the fetch URL for `twin`;
- configures supplied destinations as push URLs;
- pins `git push twin` to the branch selected at install time;
- installs the scrub/checksum `pre-push` hook locally in `.git/hooks`;
- refuses to overwrite an unexpected `twin` remote unless explicitly authorized; and
- never stores repository credentials.

Use SSH, Git Credential Manager, or another normal authentication mechanism. Do not place access tokens in project configuration.

## Publish

```powershell
git push twin
```

Before network transfer begins, the hook can:

- require tracked files to match the current commit;
- scan tracked text files for common credential/private-key patterns;
- write a SHA-256 manifest under `.git/ps-twin/checksums/` or the compatibility storage path used by the installed version; and
- abort publication if the safety gate fails.

For stronger post-push confirmation, keep the current directory in the target repository and run the verifier from the PS-twin checkout:

```powershell
& "C:\path\to\ps-twin\Invoke-GitPushTwin.ps1"
```

The verifier performs the current Git publication operation and checks configured remote refs against local `HEAD`.

## Pull and source selection

Git supports multiple push URLs for one remote, but ordinary `git pull twin` uses only the fetch URL. PS-twin therefore keeps multi-source pull behaviour in an explicit PowerShell dispatcher rather than pretending native Git performs a distributed pull.

See:

- `Enable-GitPullTwin.ps1`
- `Invoke-GitPullTwin.ps1`
- `ORDER_OF_OPERATIONS_TWIN_IDENTIFIERS.md`

## Data-scrubbing philosophy

The default scrub stage is deliberately non-destructive. It detects likely secrets and stops publication instead of silently rewriting source files.

If a secret was committed previously, rotate the credential and use an appropriate reviewed history-cleaning procedure. Removing it only from the newest working tree is not sufficient.

## Integrity evidence

For a clean tracked tree, the current Git adapter can compute SHA-256 digests without modifying the commit being published. Integrity metadata is evidence about content identity; it is not a substitute for signatures, access controls, or independent archival policy.

## Failure semantics

Multi-host publication is not an atomic distributed transaction.

One destination may accept a push while another rejects it. PS-twin reports divergence and expects the operator to inspect repository state rather than claiming rollback guarantees that the underlying transport does not provide.

## Provider and control-plane independence

Hosting-provider REST or GraphQL APIs, web interfaces, IDE integrations, and AI connectors are optional control surfaces. They are not the authoritative definition of repository availability.

For the current Git adapter:

```text
forge API or connector failure
!= Git transport failure
!= authentication failure
!= repository divergence
```

Verify the underlying transport directly before destructive recovery:

```powershell
git remote -v
git ls-remote twin
git push twin --dry-run
```

## OSWAP relationship

PS-twin is publication and repository-redundancy infrastructure for the Open-Source World Access Project (OSWAP). It is separate from the OSWAP catalogue/database and from the Sovereign AI Demonstrator.

OSWAP owns:

- `oswap.ca`
- `oswap.jp`
- `oswap.us`

Planned repository-access namespaces are:

- `repo.oswap.ca`
- `repo.oswap.jp`
- `repo.oswap.us`

These subdomains are roadmap infrastructure until DNS, TLS, routing, protocol behaviour, and repository equivalence are deployed and verified.

## Design documentation

Implemented behaviour and experimental design are intentionally separated.

- [BRANDING.md](BRANDING.md) — canonical PS-twin identity and compatibility naming.
- [DESIGN_DIRECTION.md](DESIGN_DIRECTION.md) — future allocation, sanitization, cryptographic, and control-plane directions.
- [ORDER_OF_OPERATIONS_TWIN_IDENTIFIERS.md](ORDER_OF_OPERATIONS_TWIN_IDENTIFIERS.md) — proposed mathematical repository-family identifiers and subset semantics.
- [ORDER_OF_OPERATIONS_ADDRESSING_AND_BUILD_PROVENANCE.md](ORDER_OF_OPERATIONS_ADDRESSING_AND_BUILD_PROVENANCE.md) — proposed OSWAP domain addressing and provenance models.
- `docs/expression-addressing/` — expression parsing, execution, provenance, and security design.

Experimental syntax is not represented as implemented transport behaviour.

## Current public forge paths

The connected public repositories currently retain their earlier `git-push-twin` hosting paths:

- GitHub: <https://github.com/GremlinNavi/git-push-twin>
- GitLab: <https://gitlab.com/GremlinNavi-group/git-push-twin>

The canonical project name is PS-twin. Those forge paths are transition identifiers and should move to a `ps-twin` form when renamed through the repository-host account settings.

## Community

Before contributing, read:

- [CONTRIBUTING.md](CONTRIBUTING.md)
- [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)
- [SECURITY.md](SECURITY.md)
- [SUPPORT.md](SUPPORT.md)

## License

Apache License 2.0. See `LICENSE` and `NOTICE`.
