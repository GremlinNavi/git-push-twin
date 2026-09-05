# OSWAP Intent: Resilient, Survivor-Controlled Information Infrastructure

SPDX-License-Identifier: Apache-2.0

This document records the design intent behind the OSWAP Standard. It is explanatory rather than a substitute for the normative requirements in `OSWAP_STANDARD.md`.

## Why this exists

OSWAP is designed around a simple observation: real-world information can be lost or suppressed before any institution has an opportunity to evaluate it.

Repository loss, account takeover, device destruction, platform removal, coercive deletion, institutional capture, and ordinary hardware failure can all erase records. A preservation system therefore has value even when no lawsuit, police report, journalistic publication, or other formal process occurs.

OSWAP treats preservation as a user-controlled capability.

## Historical design context

OSWAP Twin Transport was designed in part with the 1933 destruction of Magnus Hirschfeld's Institute for Sexual Science (`Institut für Sexualwissenschaft`) in mind.

On May 6, 1933, pro-Nazi students and members of the SA plundered the institute in Berlin. Books and documents taken from the institute were subsequently among the material targeted in the Nazi book burnings. On May 10, approximately 20,000 volumes were burned at Berlin's Opernplatz, including material confiscated from Hirschfeld's institute.

The engineering lesson OSWAP draws from this history is limited and concrete: unique or centrally controlled archives are vulnerable to deliberate erasure when physical, administrative, or institutional control is captured.

Twin therefore treats independent custody as a preservation property rather than merely a convenience. A project or archive should not depend for its continued existence on one repository host, one account, one provider, one institution, or ultimately one jurisdiction.

This is historical design context, not a claim that contemporary repository failures are equivalent to Nazi persecution or the 1933 book burnings.

See [`docs/PRESERVATION_THREAT_MODEL.md`](docs/PRESERVATION_THREAT_MODEL.md) for sources, claim boundaries, and the resulting preservation threat model.

## Information should survive coercion

For sensitive records, the primary question is not only:

> How can this later be proved to an authority?

It is also:

> How can the person prevent what happened from becoming erasable?

Accordingly, OSWAP preservation is intended to support:

- personal incident records;
- domestic-violence and coercive-control documentation;
- whistleblower source preservation;
- human-rights documentation;
- community and minority-history archiving;
- ordinary private records that a user cannot safely afford to lose.

No category above authorizes access to somebody else's systems. OSWAP only handles material the user is entitled to possess and preserve.

## Preservation is not publication

Public open-source knowledge and sensitive personal evidence have different threat models.

OSWAP therefore follows an asymmetric principle:

```text
public knowledge -> replicate openly when appropriate
private identity/evidence -> minimize exposure and replicate protected ciphertext
```

A sensitive preservation package should remain under the user's control until that user deliberately chooses disclosure.

The preservation goal is therefore not simply "make more copies." It is to preserve knowledge without needlessly increasing risk to the people represented by that knowledge.

## Safety model

OSWAP assumes that a device may be observable.

It does not promise stealth against spyware or privileged monitoring. If a device may be compromised, the safer action is to stop and move to a trusted device.

The software should minimize unnecessary traces, but it must not weaken operating-system security controls or use malware-like evasion techniques.

## Human-facing design

Safety-sensitive OSWAP workflows are intentionally prompt-driven in PowerShell-compatible terminals.

The goal is to keep dangerous or sensitive values out of command-line history and process arguments while presenting each side effect in plain language.

A user should be able to understand:

- what will be copied;
- what will be hashed;
- what will be encrypted;
- what will be committed;
- where ciphertext may be pushed;
- what remains local;
- what cancellation will leave behind.

## Distributed custody

OSWAP's `twin` model treats repository hosts as participating custodians rather than as the ontology of the project.

A project or archive should be capable of existing across independent infrastructure. Copy count matters, but independence matters too: multiple copies under one correlated administrative point of control do not provide the same preservation properties as copies held across genuinely independent infrastructure.

Fractional twin factors provide a compact way to express replication intensity while preserving whole-copy semantics.

For example:

```text
oswap push twin=(4+3)/2
```

means a replication factor of `3.5`: three whole destination copies are guaranteed and a fourth is selected with 50% probability.

The current Twin implementation also treats source disagreement conservatively rather than silently choosing one copy and overwriting the others. This supports the broader preservation objective of surfacing possible corruption or divergence before reconciliation.

## Autonomy

Coercive control is fundamentally a problem of concentrated control. OSWAP should not answer that problem by transferring control to a developer, platform, maintainer, police service, or other authority.

The user retains the decision to preserve, replicate, decrypt, disclose, delete local material, or seek outside assistance.

## Engineering discipline

This intent should be implemented through:

- restricted parsing rather than arbitrary evaluation;
- SHA-256 integrity manifests;
- encryption before remote replication of sensitive material;
- generic external package identifiers;
- explicit confirmation before remote writes;
- independent destination support;
- multi-source verification and visible disagreement handling;
- auditability and open licensing;
- tests that fail closed when safety invariants are violated.

OSWAP-authored code and documentation implementing this intent are licensed under Apache-2.0 when included in an OSWAP repository carrying that license.
