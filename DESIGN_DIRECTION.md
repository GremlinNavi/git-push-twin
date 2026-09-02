# PS-twin design direction

This document records planned extensions to PS-twin. Unless a feature is explicitly described as implemented in the README, treat it as design work rather than current behaviour.

## Expression-driven deployment policy

A future `twin=x` policy layer may allow a small arithmetic expression to resolve deployment parameters while leaving the underlying transport and PowerShell operations explicit and auditable.

Examples:

```text
twin=(2+1)        -> select 3 approved destinations
quorum=(6/2)+1    -> require 4 successful destination verifications
retries=(2+1)     -> allow 3 retry attempts
retain=(3*4)      -> retain 12 local verification records
```

The expression language should be deliberately tiny. It may support numeric literals, parentheses, and approved arithmetic operators such as `+`, `-`, `*`, `/`, and `%`. It must not evaluate arbitrary PowerShell and must not use `Invoke-Expression`.

Arithmetic is a policy input, not a replacement for the implementation. Transport adapters, loops, validation, sanitization, cryptography, retries, and error handling remain ordinary reviewed code.

## Dynamic repository allocation

`twin=x` may eventually select `x` destinations from a repository pool explicitly configured by the operator.

Selection may be semi-random and may prefer geographic diversity when the configuration contains operator-supplied location metadata. The tool must never discover arbitrary third-party repositories and attempt to publish to them. Every destination must be pre-approved and writable by the operator.

Multiple destinations improve resilience against provider outages, accidental deletion, and single-host failure. They do not guarantee permanent availability.

## Control-plane independence

PS-twin should preserve a strict boundary between the control surface used to request an operation and the transport that carries repository data.

Possible control surfaces include:

```text
PowerShell or another local shell
forge web interfaces
GitHub or GitLab APIs
IDE integrations
AI-agent connectors
CI/CD systems
future OSWAP frontends
```

None of these should become the sole authoritative path to repository state. A platform-specific API or connector can fail, lose write scope, become rate-limited, or be unavailable while the underlying repository transport remains reachable through normal credentials.

The implementation and documentation should therefore distinguish at least four independent conditions:

```text
control-surface/API availability
repository transport reachability
authentication/authorization
repository-content agreement
```

A failure in one condition must not be silently generalized into another. In particular:

```text
API failure != transport failure
transport success != authenticated content equivalence
successful publication != verified multi-destination agreement
```

Future status and verification commands should report these states separately where practical. Recovery logic should prefer direct transport inspection and content-ID comparison before destructive repair, forced publication, history rewriting, or manual reconstruction.

This boundary supports graceful degradation: if an IDE, AI connector, forge API, or other control plane becomes unusable, an operator can continue through a different interface as long as a configured repository transport and its credentials remain valid.

## Data sanitization and removal

The current scrub gate is intentionally non-destructive: it detects likely secrets and blocks publication rather than rewriting tracked source files.

Future sanitization work should preserve that safe default and, when automatic removal is explicitly requested, operate on a temporary staging copy rather than the developer's working tree.

Two operations must remain distinct:

- `sanitize`: prevent sensitive material from entering a newly distributed build;
- `purge`: intentionally remove previously committed material from repository history.

Deleting a file in a new commit does not necessarily remove it from older repository objects. History rewriting should therefore be a separate, explicit workflow with verification and no silent forced-publication behaviour.

## License and attribution preservation

Any future sanitization stage must protect mandatory legal and attribution material from accidental deletion or redaction.

At minimum, configured protected files may include:

```text
LICENSE
NOTICE
COPYING
AUTHORS
```

A sanitized staging build should fail validation if a required protected file is missing or unexpectedly modified.

## Cryptographic roles

The project should keep three different security properties separate:

- SHA-256: integrity evidence — whether bytes changed;
- digital signatures: authenticity — whether a release or manifest was signed by the expected publisher;
- encryption: confidentiality — whether private material is readable by unauthorized parties.

A checksum alone is not publisher authentication.

## Encryption use cases

Public open-source source code should remain public. Encryption is more useful for supporting private material, including:

- local pre-sanitization recovery snapshots;
- private configuration backups;
- internal deployment manifests;
- logs containing sensitive infrastructure metadata;
- disaster-recovery archives; and
- separately stored credential or key material when an external workflow requires it.

Encryption should use established authenticated-encryption implementations such as AES-GCM or ChaCha20-Poly1305 through mature libraries or operating-system tooling. The project should not invent a custom cipher.

A future policy layer could also resolve non-secret operational parameters such as backup-copy counts, key-rotation intervals, or threshold-recovery requirements. For example, a configured five-share recovery scheme could use a policy equivalent to `(5/2)+1` to require three shares. The arithmetic must never derive or expose encryption keys themselves.

## Verification and manifests

Future multi-destination deployment should continue to distinguish `publication succeeded` from `deployment verified`.

A deployment record may include:

```text
source revision
artifact SHA-256
resolved twin expression
selected approved destinations
successful destinations
failed destinations
timestamp
```

Remote verification should compare the expected content identifier with each destination independently. Multi-destination transports may not be atomic, so partial success must be reported rather than hidden.

## Non-goals

The expression layer is not intended to become a general-purpose scripting language, an arbitrary code-execution feature, or a mechanism for publishing into repositories the operator does not control.
