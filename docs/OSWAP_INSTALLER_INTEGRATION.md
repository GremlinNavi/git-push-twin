# PS-twin integration with the OSWAP install wizard

This document defines how PS-twin should participate in the planned Open-Source World Access Project (OSWAP) PowerShell installation workflow.

## Status

The intended package command is:

```powershell
oswap install twin
```

The recommended full-environment command is:

```powershell
oswap install
```

These are planned OSWAP installer interfaces. This repository does not currently register a global `oswap` command.

The implemented PS-twin installer is `Install-GitPushTwin.ps1`.

## Current acquisition primitive

The first OSWAP wizard implementation may obtain this repository with GitHub CLI:

```powershell
gh repo clone GremlinNavi/git-push-twin
```

The equivalent GitLab twin is:

```text
https://gitlab.com/GremlinNavi-group/git-push-twin.git
```

GitHub and GitLab are distribution surfaces. The wizard should retain both repository coordinates in package metadata and must not describe either host as the permanent canonical source of truth.

## Current manual integration

PS-twin configures the repository in the current working directory. From the target repository:

```powershell
& "C:\path\to\git-push-twin\Install-GitPushTwin.ps1" `
  -RepositoryUrl @(
    "https://github.com/GremlinNavi/sovereign-ai-framework.git",
    "https://gitlab.com/GremlinNavi-group/sovereign-ai-framework.git"
  )
```

The installer requires at least one repository URL and configures a local Git remote named `twin`. It can also install the local pre-push safety hook.

The installer does not need to publish anything during OSWAP setup. Installation and publication must remain separate actions.

## OSWAP package role

Within the planned package map, PS-twin should be identified as the `twin` package.

Its responsibilities are:

- configure explicit multi-destination Git publication;
- preserve provider-independent repository transport semantics;
- provide non-destructive pre-push secret detection;
- generate integrity evidence for the tracked tree;
- support explicit post-push verification;
- report partial multi-host publication instead of pretending publication is atomic.

It should not become responsible for:

- installing AI inference runtimes or models;
- owning the OSWAP syntax grammar;
- silently publishing a repository during setup;
- storing forge credentials;
- force-reconciling divergent repository history;
- choosing a permanent primary forge.

## Wizard integration contract

When `oswap install twin` is implemented, the OSWAP installer should perform the following sequence.

1. Resolve the PS-twin package from a declarative package manifest.
2. Show the selected source and destination path before cloning or updating.
3. Acquire the repository through a verified GitHub, GitLab, or other Git-compatible twin.
4. Verify the checkout identity before invoking any local script from it.
5. Ask which target repository, if any, should receive PS-twin configuration.
6. Preview the target repository and proposed push URLs.
7. Invoke `Install-GitPushTwin.ps1` only after the user has approved that local Git configuration change.
8. Verify the resulting `twin` remote with read-only Git commands.
9. Do not run `git push twin` as part of installation.

## Required safety properties

The OSWAP wizard must preserve PS-twin's existing safety boundaries.

- Never embed access tokens in repository URLs.
- Never overwrite an unexpected existing `twin` remote without an explicit recovery decision.
- Never overwrite another tool's pre-push hook silently.
- Never weaken PowerShell execution policy persistently to make installation succeed.
- Never force-push, reset, clean, or rewrite history as an installer repair operation.
- Never treat a forge API failure as proof that the Git repository itself is unavailable.
- Keep publication operator-initiated and visible.

## Idempotency

Repeated `oswap install twin` runs should be safe.

The wizard should distinguish at least these states:

```text
not installed
checkout present and verified
checkout present but unexpected remote identity
PS-twin installed but target not configured
target configured correctly
target configuration differs from requested state
```

An unexpected state should produce a diagnostic rather than an automatic destructive repair.

## Command vocabulary

The planned OSWAP command layer may expose:

```text
oswap install twin
oswap update twin
oswap repair twin
oswap doctor twin
oswap remove twin
```

The underlying Git transport command remains explicit:

```powershell
git push twin
```

OSWAP should not obscure that publication is a Git operation performed against configured destinations.

## Relationship to `gh repo clone`

`gh repo clone` is an acquisition adapter, not the identity of PS-twin.

A package resolver may translate:

```text
twin
```

into:

```powershell
gh repo clone GremlinNavi/git-push-twin
```

when GitHub CLI is selected and available. The same package ID should be resolvable from the GitLab twin through standard Git transport when required.

## Documentation rule

Documentation must distinguish:

- current implemented PS-twin behaviour;
- current manual OSWAP bootstrap steps;
- future `oswap install` command surfaces.

Do not document `oswap install twin` as executable until the OSWAP global command layer actually implements it.

See also:

- [README.md](../README.md)
- [DESIGN_DIRECTION.md](../DESIGN_DIRECTION.md)
- [TWIN_HISTORY_RECONCILIATION.md](TWIN_HISTORY_RECONCILIATION.md)
- `Install-GitPushTwin.ps1`
