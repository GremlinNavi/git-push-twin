# Security

## Credential handling

`git-push-twin` does not require or store Git hosting credentials.

Use the authentication mechanism provided by Git and your hosting service, such as SSH keys, Git Credential Manager, or a credential helper. Do not place personal access tokens, passwords, private keys, or other secrets in `.git-push-twin.json`, repository URLs, source files, examples, or commit messages.

The installer refuses HTTP/SSH-style URLs that appear to contain inline username/password-style credentials.

## Scrub gate

The pre-push hook performs heuristic secret detection against tracked text files and blocks a push when it finds likely private keys, common GitHub token formats, AWS access-key IDs, or generic secret assignments.

This is a safety layer, not a complete secret-scanning product. False negatives and false positives are possible.

If a secret was already committed:

1. revoke or rotate it;
2. remove it from Git history using an appropriate history-rewriting procedure;
3. verify the rewritten repository before publishing it again.

Simply deleting the secret in a later commit does not remove it from earlier Git objects.

## Reporting

Please avoid filing public issues containing real credentials or sensitive repository content.
