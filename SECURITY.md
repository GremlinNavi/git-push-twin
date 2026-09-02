# Security

## Credential handling

PS-twin does not require or store repository-hosting credentials.

Use the authentication mechanism provided by Git and the selected hosting service, such as SSH keys, Git Credential Manager, or a credential helper. Do not place personal access tokens, passwords, private keys, or other secrets in `.ps-twin.json`, repository URLs, source files, examples, or commit messages.

The legacy `.git-push-twin.json` configuration filename remains readable during migration. New configuration should use `.ps-twin.json`; if both files exist, the safety hook fails closed rather than guessing which policy is authoritative.

The installer refuses HTTP/SSH-style URLs that appear to contain inline username/password-style credentials.

## Scrub gate

The pre-push hook performs heuristic secret detection against tracked text files and blocks a push when it finds likely private keys, common GitHub token formats, AWS access-key IDs, or generic secret assignments.

This is a safety layer, not a complete secret-scanning product. False negatives and false positives are possible.

For new installations, PS-twin stores generated checksum manifests under `.git/ps-twin/checksums/`. Older `.git/git-push-twin/` support data may remain in an existing checkout until the operator deliberately removes it after migration.

If a secret was already committed:

1. revoke or rotate it;
2. remove it from Git history using an appropriate history-rewriting procedure;
3. verify the rewritten repository before publishing it again.

Simply deleting the secret in a later commit does not remove it from earlier Git objects.

## Reporting a vulnerability

Do not open a public issue containing exploit details, real credentials, or sensitive repository content. Use the hosting provider's private vulnerability-reporting feature when available. If no private feature is available, contact the maintainer through a private method listed on their hosting profile and request a confidential channel before sharing details.

Include affected versions, impact, reproduction conditions, and suggested mitigation without including real secrets. Acknowledgement and remediation are best-effort; no response-time guarantee is made.
