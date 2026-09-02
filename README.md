# Git Push Twin

`git-push-twin` is a small, standalone PowerShell safety and redundancy layer for Git.

It configures a normal Git remote named `twin` with any number of push URLs so that the literal command:

```powershell
git push twin
```

publishes the same commit to every configured mirror.

The project adds three things around Git's native multi-push behavior:

1. a pre-push scrub gate that refuses to publish obvious secrets or private-key material;
2. a SHA-256 manifest for the exact clean working tree being pushed;
3. an optional post-push verifier that checks every mirror's branch ref against the local commit.

## Why this exists

A single hosting provider is a convenient distribution point, not an archival strategy. Git Push Twin is intended for developers who want one local command to publish identical repository state to GitHub, GitLab, self-hosted Git servers, or any other Git remote.

Git itself supports multiple push URLs for one remote. Current Git documentation states that pushing to a remote affects all defined `pushurl` values. `git-push-twin` uses that native behavior rather than reimplementing the Git transport protocol.

## Requirements

- Git
- PowerShell 5.1+ or PowerShell 7+
- an existing local Git repository
- authenticated push access to each destination repository

## Install into a repository

Clone or download this project, then from the repository you want to mirror:

```powershell
& "C:\path\to\git-push-twin\Install-GitPushTwin.ps1" `
  -RepositoryUrl @(
    "https://github.com/OWNER/REPO.git",
    "https://gitlab.com/GROUP/REPO.git"
  )
```

The installer:

- refuses to run outside a Git working tree;
- preserves the first URL as the fetch URL for `twin`;
- configures every supplied URL as a push URL;
- pins `git push twin` to the branch selected at install time;
- installs the scrub/checksum `pre-push` hook locally in `.git/hooks`;
- refuses to overwrite a pre-existing `twin` remote unless it was previously managed by this tool or `-Force` is explicitly supplied;
- refuses to overwrite another tool's existing `pre-push` hook;
- never stores credentials in the repository.

Use SSH, Git Credential Manager, or another normal Git authentication mechanism. Do not place access tokens in this project's config files.

## Push

After configuration:

```powershell
git push twin
```

Before network transfer begins, the hook:

- requires tracked files to match the current commit;
- scans tracked text files for common credential/private-key patterns;
- writes a SHA-256 manifest under `.git/git-push-twin/checksums/`;
- aborts the push if the safety gate fails.

For stronger post-push confirmation, keep your current directory in the target repository and invoke the verifier from the cloned tool directory:

```powershell
& "C:\path\to\git-push-twin\Invoke-GitPushTwin.ps1"
```

That performs the same `git push twin`, then queries every configured push URL with `git ls-remote` and confirms that the remote branch equals the local `HEAD`.

## Add more mirrors

Re-run the installer with the complete destination list. The `twin` remote is rebuilt deterministically from the supplied URLs.

There is no hard-coded two-repository limit. "Twin" describes the mirrored workflow, not the number of destinations.

## Configuration

An optional `.git-push-twin.json` file can be placed in a target repository:

```json
{
  "excludePaths": [
    "docs/examples/*"
  ],
  "extraSecretPatterns": [
    "(?i)MY_INTERNAL_TOKEN\\s*[:=]\\s*\\S+"
  ],
  "maxScanFileBytes": 5242880
}
```

`excludePaths` only affects the scrub scan. It does not exclude files from Git or from the checksum manifest.

## Data scrubbing philosophy

The default scrub stage is deliberately non-destructive. It detects likely secrets and stops the push instead of silently rewriting source files.

Automatic redaction inside a Git working tree can corrupt source code or create a false sense that sensitive material was removed from history. If a secret was committed previously, rotate the credential and rewrite Git history using an appropriate history-cleaning tool before publishing.

## SHA-256 evidence

For tracked files that match the current commit, the pre-push hook computes a SHA-256 digest for every tracked regular file and stores a manifest outside the tracked tree:

```text
.git/git-push-twin/checksums/<commit-sha>.sha256
```

This avoids modifying the commit during the integrity check.

## Failure semantics

Multi-host publication is not an atomic distributed transaction.

One server can accept a push while a later server fails. `git-push-twin` therefore treats verification as a first-class step and reports mismatched/unreachable mirrors rather than claiming rollback guarantees Git does not provide.

## Project identity

- Human-facing name: Git Push Twin
- Technical/project slug: `git-push-twin`
- Literal Git command: `git push twin`

Git Push Twin is a standalone open-source Git utility and publication infrastructure for the Open-Source World Access Project (OSWAP). It is not the OSWAP software catalogue or database, and it does not replace or rename the separate Sovereign AI Demonstrator.

Canonical public repositories:

- GitHub: <https://github.com/GremlinNavi/git-push-twin>
- GitLab: <https://gitlab.com/GremlinNavi-group/git-push-twin>

See [BRANDING.md](BRANDING.md) for the complete naming boundary.

## Community

Before participating, read [CONTRIBUTING.md](CONTRIBUTING.md), [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md), [SECURITY.md](SECURITY.md), and [SUPPORT.md](SUPPORT.md).

## License

Apache License 2.0. See `LICENSE` and `NOTICE`.
