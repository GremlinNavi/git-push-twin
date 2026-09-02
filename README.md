# OSWAP Twin Transport (`git-push-twin`)

`git-push-twin` provides the Git/PowerShell transport component used by the Open-Source World Access Project for explicit multi-destination repository publication. The canonical user-facing publication form is `oswap upload twin=N`; `git push twin` remains a transport-level compatibility mechanism.

This repository adopts [OSWAP Standard 0.2.0](OSWAP_STANDARD.md) and its [intent documentation](OSWAP_INTENT.md). OSWAP-authored code and documentation here are Apache-2.0 licensed.

Development history: [September 2, 2026 OSWAP branding and Twin transport session](docs/development-history/2026-09-02-oswap-branding-and-twin-session.md).

## Command hierarchy

The canonical OSWAP publication path is `oswap upload twin=N`. This repository supplies its transport backend. `Invoke-GitPushTwin.ps1` and the literal `git push twin` command remain available for configured all-destination compatibility pushes.

The OSWAP DSL adds restricted arithmetic and semi-random destination selection:

```powershell
.\Invoke-OSWAPPush.ps1 'upload' 'twin=(4+3)/2'
.\Invoke-OSWAPPush.ps1 'upload' 'twin=(4+3)/2' -Execute
```

`(4+3)/2` resolves to a replication factor of `3.5`: three whole destination copies are guaranteed and a fourth whole destination is selected with 50% probability. There is never a partial repository copy.

The executing form shows the selected destinations and requires the operator to type `TWIN` before any remote write.

## OSWAP language boundary

OSWAP syntax is not PowerShell syntax. PowerShell is the host and prompt environment. The OSWAP parser defines `^` as exponentiation and applies OSWAP order of operations before Git execution.

The reference OSWAP push implementation never uses `Invoke-Expression`.

## Current implementation status

`Invoke-OSWAPPush.ps1` recognizes canonical `upload twin=<expression>` preview and execution while retaining `push twin=<expression>` as a compatibility alias. It implements fractional whole-copy replication, randomized destination selection without replacement, and explicit `TWIN` confirmation before publication.

`Invoke-GitPullTwin.ps1` implements multi-source retrieval independently of the expression-addressing draft: it fetches each configured twin source, compares commit IDs, refuses disagreement, and only fast-forwards a clean local branch when the twin sources agree.

The expression-addressing reference parser and the PowerShell publication parser are still being converged. Features not shared by both implementations must not be presented as portable OSWAP syntax until they have matching conformance coverage.

See [Repository-native execution model](docs/REPOSITORY_NATIVE_EXECUTION.md) for the lightweight shell/Git architecture, optional GUI boundary, capability-based hardware portability, and provenance model.

## Destination pools

The `twin` Git remote supplies the eligible push URL pool. A factor of `3.5` requires at least four configured push URLs because the fourth whole copy can be selected.

The OSWAP tool selects destinations without replacement, displays the resulting selection, and requires explicit confirmation.

## Sensitive records

Do not place plaintext domestic-violence evidence, whistleblower material, or other sensitive private records into a public or multi-host Git repository.

OSWAP Standard 0.2.0 requires sensitive material to be encrypted before remote replication, with descriptive metadata kept inside the protected package and decryption secrets kept separate. The Sovereign AI Framework repository contains the reference prompt-driven preservation workflow.

OSWAP does not promise invisibility from spyware and does not disable antivirus, logging, or endpoint security.

## Existing project documentation

The existing installer, pull/push helpers, expression-addressing documents, tests, and repository-map configuration remain part of this project. The OSWAP Standard is the normative rule set for new OSWAP code going forward.
