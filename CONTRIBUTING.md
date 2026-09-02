# Contributing to Git Push Twin

Thank you for helping improve Git Push Twin. Participation is governed by
[CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

## Before changing code

- Search existing issues and merge or pull requests.
- Discuss broad behaviour, compatibility, or security changes before implementation.
- Keep each contribution focused and avoid unrelated formatting churn.
- Never include credentials, private repository URLs, or confidential test data.

## Development workflow

1. Fork the repository or create a topic branch from `main`.
2. Make the smallest complete change.
3. Run the relevant PowerShell tests and syntax checks documented by the repository.
4. Update documentation and examples when behaviour changes.
5. Open a merge or pull request with the motivation, test evidence, risks, and
   compatibility impact.

Use imperative, descriptive commit messages. Preserve Apache-2.0 notices and
attribution. Contributors remain responsible for submitted work, including material
created with automated assistance; review it, test it, and disclose substantial
automated generation when that context would help reviewers.

## Compatibility and naming

Use **Git Push Twin** as the display name, `git-push-twin` for repository and package
identifiers, and `git push twin` only for the literal Git command. Do not introduce
the retired `PS-twin` name except when accurately referencing an existing legacy
filename or historical artifact.

## Review expectations

Maintainers may request changes for safety, scope, tests, documentation, licensing, or
backward compatibility. A contribution may be declined without judging the
contributor. See [SUPPORT.md](SUPPORT.md) for support requests and
[SECURITY.md](SECURITY.md) for vulnerabilities.
