# Git Push Twin scope

Git Push Twin contains only the Windows batch entry point, PowerShell setup tool,
read-only verifier, documentation, and licensing material required to standardize the
`git push twin` convention for an approved checkout.

It intentionally does not contain:

- Sovereign AI Demonstrator source or model/runtime code;
- the OSWAP catalogue, database, ingestion pipeline, or discovery service;
- model weights, datasets, local data, credentials, secrets, or private keys;
- a cloud service, webhook, CI workflow, or hidden remote synchronization process;
- GitHub or GitLab credentials; or
- credentials or authority to create, rename, or change the visibility of a remote
  repository.

The architecture is portable because it uses Git and PowerShell behavior rather than
vendor-specific APIs. It is not a replacement for reviewing branch protection,
repository permissions, release signing, or checksum verification.
