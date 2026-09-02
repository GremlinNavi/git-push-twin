# Git Push Twin v0.1.0-beta.1

Initial beta of the separate PowerShell/Git architecture for the deliberate paired
publication command `git push twin`.

## Included

- `installer.bat` to configure a selected target checkout;
- `Configure-TwinGitRemote.ps1`, which creates a local composite remote named `twin`;
- `Test-TwinGitRemote.ps1`, a read-only local configuration verifier;
- documentation of the two-host push boundary and recovery expectations; and
- an archive/checksum workflow for this repository.

The source archive retains its legacy `ps-twin` filename so its published checksum
and historical link remain valid.

## Explicit boundaries

The installer does not publish, fetch, pull, create a commit, or contact a network.
`git push twin` remains an explicit Git command. A two-host push is sequential, not
atomic; an accepted first push and rejected second push must be investigated rather
than force-fixed.
