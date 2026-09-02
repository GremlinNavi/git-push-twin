# Twin Git protocol

## Local names

| Name | Function |
| --- | --- |
| `origin` | Individual GitHub remote for the target application checkout. |
| `gitlab` | Individual GitLab remote for the target application checkout. |
| `twin` | Composite remote: fetches GitHub; pushes first to GitHub, then GitLab. |

The configuration lives only in the target checkout's `.git/config`. It does not
create a server-side mirror rule, a webhook, a scheduled job, or a secret.

## Setup contract

`installer.bat` calls `tools/Configure-TwinGitRemote.ps1` in a non-profile child
PowerShell process. Its execution-policy override applies to that child process only;
it does not alter a saved user or system policy. The helper:

1. checks that the target is an existing Git checkout and is not this architecture
   repository;
2. confirms that existing `origin`, `gitlab`, and `twin` URLs match the explicitly
   selected pair, or creates missing individual remotes;
3. sets the `twin` fetch URL to GitHub;
4. sets exactly two `twin` push URLs, GitHub followed by GitLab;
5. records `twin` as the current branch's remote and the matching branch ref; and
6. records `push.default=simple` in the target repository only.

It never reaches a network endpoint. Re-running it refreshes the approved local
configuration and does not publish anything.

## Publication contract

For the configured current branch, Git's standard command is:

```powershell
git push twin --dry-run
git push twin
```

The dry run contacts both servers but changes neither. The real command sends the same
branch ref to both configured `pushurl` values. It uses no force flag. A rejected
non-fast-forward update is a protective failure to resolve deliberately.

Git cannot atomically commit an update to two unrelated servers. The second push can
fail after the first succeeds. In that event:

1. retain the exact local commit and read both remote ref IDs;
2. identify the actual cause (permissions, protected branch, divergent history, or
   network failure);
3. correct only that cause; and
4. rerun the explicit preflight and paired push when both are ready.

Do not call `git push --force`, `git reset`, `git clean`, or an automatic merge as a
recovery shortcut.

## Boundaries

The protocol proves only that a named ref was requested for both URLs. It does not
prove full-history equality, asset equality, release signature validity, host account
ownership, or a successful end-to-end release. Check the exact commit, ZIP checksum,
release metadata, and access rules on each host independently.
