# OSWAP Twin Transport scope

OSWAP Twin Transport contains the Windows batch entry point, PowerShell setup and
verification tools, documentation, tests, and licensing material required to support
the `twin` repository-transport convention for an approved application checkout.

It intentionally does not contain:

- Sovereign AI Demonstrator or other application source/model runtime code;
- model weights, datasets, local data, credentials, secrets, or private keys;
- a hosted synchronization service, webhook daemon, or hidden background publication process;
- GitHub or GitLab credentials; or
- a server-side repository created without an explicit user decision on its name and
  visibility.

The architecture is portable because it uses Git and PowerShell behavior rather than
vendor-specific APIs. It is not a replacement for reviewing branch protection,
repository permissions, release signing, or checksum verification.
