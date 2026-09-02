# Contributing to PS-twin

Thank you for helping improve PS-twin. Participation is governed by [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

## Before changing code

- Search existing issues and merge or pull requests.
- Discuss broad behaviour, compatibility, transport, or security changes before implementation.
- Keep each contribution focused and avoid unrelated formatting churn.
- Never include credentials, private repository URLs, or confidential test data.

## Development workflow

1. Fork the repository or create a topic branch from `main`.
2. Make the smallest complete change.
3. Run the relevant PowerShell tests and syntax checks documented by the repository.
4. Update documentation and examples when behaviour changes.
5. Open a merge or pull request with motivation, validation evidence, risks, and compatibility impact.

Use imperative, descriptive commit messages. Preserve Apache-2.0 notices and attribution. Contributors remain responsible for submitted work, including material created with automated assistance; review it, test it, and disclose substantial automated generation when that context would help reviewers.

## Compatibility and naming

Use `PS-twin` as the canonical project name and `ps-twin` as the intended repository/package identifier.

The literal command `git push twin` describes the current Git transport workflow; it is not the project name. Existing `git-push-twin`, `GitPushTwin`, or similar text may remain only where needed for compatibility-facing filenames, historical artifacts, checksums, published links, or forge paths that have not yet been renamed.

Do not frame GitHub, GitLab, or another provider as the authoritative identity of PS-twin. Provider-specific integrations should be adapters or control surfaces around the provider-agnostic project architecture.

## Review expectations

Maintainers may request changes for safety, scope, tests, documentation, licensing, portability, or backward compatibility. A contribution may be declined without judging the contributor. See [SUPPORT.md](SUPPORT.md) for support requests and [SECURITY.md](SECURITY.md) for vulnerabilities.
