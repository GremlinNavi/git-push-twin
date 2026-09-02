# Git Push Twin

Git Push Twin is a small, separate publication-infrastructure repository for the
Open-Source World Access Project (OSWAP). It configures a selected Git checkout with
a standard remote named `twin`. It is not the OSWAP software catalogue or database,
and it does not replace or rename the separate Sovereign AI Demonstrator.

Once configured, the deliberate paired-publication command is:

```powershell
git push twin --dry-run
git push twin
```

`twin` is native Git configuration, not a hidden PowerShell alias. It has GitHub as
its fetch URL and GitHub plus GitLab as ordered push URLs. The command stays visible
and requires an explicit operator action every time.

## Install the twin command architecture

Clone or otherwise obtain Git Push Twin. From the checkout to configure, run this
repository's installer by path:

```powershell
C:\path\to\git-push-twin\installer.bat
```

Or pass the target checkout explicitly:

```powershell
C:\path\to\git-push-twin\installer.bat C:\path\to\sovereign-ai-framework
```

The installer makes **local Git configuration changes only**. It does not access a
network, download software, modify the application files, create a commit, or push to
either host. It verifies or creates the target checkout's individual `origin` and
`gitlab` remotes, then configures the composite `twin` remote. On Windows it starts
one non-profile PowerShell process with a process-only execution-policy override so a
normal local script policy does not prevent setup; it does not persistently change the
device policy. A Group Policy restriction can still block it.

## Verify the local setup

```powershell
.\tools\Test-TwinGitRemote.ps1 -RepositoryPath C:\path\to\sovereign-ai-framework
```

The validation is read-only. It confirms the expected remote URLs, the ordered twin
push URLs, the current branch's tracking preference, and the repository-local safe
push policy.

## Publish deliberately

From the configured application checkout:

```powershell
git status
git push twin --dry-run
git push twin
```

Make an initial local commit with a configured Git identity before attempting to push
an unborn branch. A twin push is not atomic across GitHub and GitLab: if one host
accepts it and the other rejects it, stop and inspect the two refs. Do not force-push,
reset, or fabricate a merge merely to conceal the difference.

## Default paired repositories

- GitHub: `https://github.com/GremlinNavi/sovereign-ai-framework.git`
- GitLab: `https://gitlab.com/GremlinNavi-group/sovereign-ai-framework.git`

The setup tool accepts a deliberate alternate pair through explicit parameters. It
refuses an unexpected existing remote URL rather than overwriting it.

Git Push Twin is maintained publicly at
[GitHub](https://github.com/GremlinNavi/git-push-twin) and
[GitLab](https://gitlab.com/GremlinNavi-group/git-push-twin). See
[BRANDING.md](BRANDING.md), [TWIN_PROTOCOL.md](TWIN_PROTOCOL.md), and
[ARCHITECTURE_SCOPE.md](ARCHITECTURE_SCOPE.md).

## Archive

Git Push Twin v0.1.0-beta.1 is packaged as a source archive with a matching SHA-256
manifest under `releases/v0.1.0-beta.1/`. The existing verification script and archive
retain legacy `PS-twin`/`ps-twin` filenames; changing implementation filenames is
outside this documentation-only update. Verify the archive before extraction:

```powershell
.\tools\Test-PS-twinRelease.ps1 `
  -ChecksumFile .\releases\v0.1.0-beta.1\SHA256SUMS.txt `
  -ReleaseAsset .\releases\v0.1.0-beta.1\ps-twin-0.1.0-beta.1-source.zip
```

## Community

Before participating, read [CONTRIBUTING.md](CONTRIBUTING.md),
[CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md), [SECURITY.md](SECURITY.md), and
[SUPPORT.md](SUPPORT.md).
