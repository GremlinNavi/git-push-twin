# PS-twin scope

PS-twin contains only the Windows batch entry point, PowerShell setup tool,
read-only verifier, documentation, and licensing material required to standardize the
`git push twin` convention for an Eternal Thread checkout.

It intentionally does not contain:

- Eternal Thread application source or model/runtime code;
- model weights, datasets, local data, credentials, secrets, or private keys;
- a cloud service, webhook, CI workflow, or hidden remote synchronization process;
- GitHub or GitLab credentials; or
- a server-side repository created without an explicit user decision on its name and
  visibility.

The architecture is portable because it uses Git and PowerShell behavior rather than
vendor-specific APIs. It is not a replacement for reviewing branch protection,
repository permissions, release signing, or checksum verification.
