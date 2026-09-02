# Security

## Supported work

Security fixes target the current default branch. Pre-release artifacts may change
without backward-compatibility guarantees.

## Credential handling

Git Push Twin does not require or store Git hosting credentials. Use Git or hosting
provider credential stores. Never place tokens, passwords, private keys, or secrets in
configuration, repository URLs, source files, examples, issues, or commit messages.

The scrub gate is heuristic defense-in-depth, not a complete secret-scanning product.
False positives and false negatives are possible.

If a secret was committed, revoke or rotate it first, then remove it from history with
an appropriate reviewed procedure. Deleting it in a later commit is insufficient.

## Reporting a vulnerability

Do not open a public issue containing exploit details, credentials, or sensitive
repository content. Use the hosting provider's private vulnerability-reporting
feature when available. If no private feature is available, contact the maintainer
through a private method listed on their hosting profile and request a confidential
channel before sharing details.

Include affected versions, impact, reproduction conditions, and suggested mitigation
without including real secrets. Acknowledgement and remediation are best-effort; no
response-time guarantee is made.
