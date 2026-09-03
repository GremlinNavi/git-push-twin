# Changelog

SPDX-License-Identifier: Apache-2.0

This changelog summarizes user-visible project changes. Historical development notes remain available under `docs/development-history/`.

## Unreleased

### Added

- public mirror policy and verification guidance;
- concise OSWAP terminology glossary;
- documentation index for the expanding design surface;
- unified local test runner for syntax and semantic-documentation checks; and
- clearer public-facing explanation of Twin Transport status, safety boundaries, and mirror naming.

### Clarified

- `twin` is the cardinality dimension;
- `joker` is a distinct policy dimension in experimental OSWAPSACW documentation;
- the Accountability Ballchain metaphor is based on military dog-tag chains rather than cryptocurrency; and
- equivalent GitHub/GitLab source trees can have different commit SHAs when platform commits are created independently.

## 0.1.0-beta.1

Initial beta of the separate PowerShell/Git architecture for deliberate paired publication.

### Included

- explicit `git push twin` compatibility transport;
- local configuration and verification helpers;
- two-host publication and reconciliation documentation; and
- archived source/checksum material.

### Boundary

Publication is sequential rather than atomic. A successful publication to one destination and rejection by another must be investigated rather than hidden with destructive history rewriting.

See [RELEASE_NOTES_v0.1.0-beta.1.md](RELEASE_NOTES_v0.1.0-beta.1.md) for the original release note.
