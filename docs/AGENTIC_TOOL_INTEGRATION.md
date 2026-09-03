# OSWAP agentic tool integration

SPDX-License-Identifier: Apache-2.0

Status: experimental design document. This file describes intended integration boundaries, not implemented authority.

## Role of OSWAP

OSWAP is not intended to replace general agent/tool protocols, Git, repository hosts, or identity providers.

Its proposed role is to provide a model-agnostic policy, authorization, provenance, replication, and verification layer around those systems.

A typical architecture may look like:

```text
human principal
    -> agent/model
    -> OSWAP policy and authorization
    -> tool adapter / MCP / API / Git
    -> external side effect
    -> verification
    -> accountability record
```

The agent may request or explain an action. OSWAP semantics and policy enforcement must remain independently inspectable.

## Model and provider agnosticism

An OSWAP workflow should be portable across compatible human-operated scripts, local models, hosted models, and future agents.

A provider-specific adapter may be necessary for transport or authentication, but the normative meaning of OSWAP commands must not depend on one provider's private interpretation.

A proprietary application may implement OSWAP, but a future OSWAP compliance profile should require that core semantics, audit records, and verification remain inspectable and replaceable across supported model providers.

## Least authority

Agentic integrations should receive only the permissions required for the stated operation.

Where practical, authentication secrets should remain in the provider, operating-system credential store, wallet, browser, or other designated authentication boundary rather than entering model context.

OSWAP authorization cannot grant permissions that the underlying service does not grant.

A human authorization input permits only the stated attempt. It is not a credential and is not proof that the attempt succeeded.

## Twin and Joker

`twin` answers how many independently selected complete participants are required.

`joker` answers which policy governs eligibility, selection, or use of those participants.

A future `joker` profile should be declarative, versioned, machine-readable, and reviewable before execution. An LLM must not silently invent policy semantics at runtime.

## Accountability receipt

After a consequential tool action, an OSWAP-capable integration should be able to produce a receipt containing enough non-secret evidence to reconstruct the operation, such as:

- principal or accountable persona/pseudonym;
- participating agent/model/runtime when available;
- tool or adapter used;
- requested action;
- affected artifact digests or paths;
- authorization state;
- execution result;
- verification result;
- `twin` and `joker` values or resolved policies; and
- independent destination/witness receipts when applicable.

These receipts are candidate inputs to the Digital Accountability Ballchain.

## Interoperability direction

MCP and similar open protocols can provide tool connectivity; Git and forge APIs can provide repository transport; SLSA, in-toto, and Sigstore provide useful provenance and attestation precedents; OSWAP should focus on the auditable policy connecting these layers.

No protocol named here is required merely because it is referenced. Adapters should remain replaceable, and conformance should be based on observable OSWAP behavior rather than vendor branding.
