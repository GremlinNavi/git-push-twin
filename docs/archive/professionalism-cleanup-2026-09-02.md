# Public-surface cleanup archival record — 2026-09-02

## Purpose

This record preserves rollback coordinates for the public-facing professionalism cleanup performed on 2026-09-02. The cleanup was intentionally non-destructive and a pre-cleanup archive branch was created before the branding/community merge.

## Pre-cleanup checkpoint

GitLab archive branch:

`archive/pre-professionalism-cleanup-2026-09-02`

Pre-cleanup GitLab commit:

`9df42338df1cadba93d4b0d3896aab5766afafa9`

GitHub pre-cleanup main commit observed during the audit:

`afaf5649df87ec8be393183c5ff9e851787e30d4`

The connected GitHub integration returned HTTP 403 for branch/content writes to `GremlinNavi/git-push-twin`, so no GitHub repository files or refs were changed by this cleanup pass. The GitHub commit above remains the observed rollback coordinate for that public state.

## Cleanup actions

- Merged GitLab !1, adding canonical Git Push Twin / OSWAP branding boundaries, community participation files, issue / merge-request templates, and clearer security-reporting guidance.
- Retained the source branch rather than deleting it.
- Left PowerShell implementation code unchanged.
- Preserved the pre-cleanup GitLab state on `archive/pre-professionalism-cleanup-2026-09-02`.

## Recovery procedure

Do not erase history to undo this cleanup.

1. Compare current `main` against `archive/pre-professionalism-cleanup-2026-09-02`.
2. Revert only the documentation/community merge or later cleanup commit that caused the problem.
3. Retain source branches and use normal Git comparison/revert operations.
4. Avoid force-pushing `main` as a recovery shortcut.

The archive branch is a rollback reference, not a new canonical repository or release.