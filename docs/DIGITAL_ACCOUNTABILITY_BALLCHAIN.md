# OSWAP Digital Accountability Ballchain

SPDX-License-Identifier: Apache-2.0

Status: experimental design document. The Ballchain is not normative in OSWAP Standard 0.2.1.

## Summary

The OSWAP Digital Accountability Ballchain is a proposed public, open-source, tamper-evident provenance journal for software development.

Its primary purpose is to make consequential file changes attributable to the humans, personas, AI systems, agents, tools, and development processes that participated in them.

The Ballchain is cryptocurrency-adjacent in some implementation primitives, such as hashes, signatures, linked records, replication, and public verification. It is not a cryptocurrency and does not inherently require tokens, mining, transaction fees, proof-of-work, or monetary consensus.

The name is inspired by the physical ball chain connecting military identity dog tags: a sequence of linked identity and accountability markers.

## Core question

For a consequential software change, an investigator should be able to ask:

> Who or what changed which file, under whose authority, and what evidence survives to verify that history?

The Ballchain is intended to preserve evidence needed to answer that question.

## Proposed record model

A Ballchain record may include:

- record identifier and prior-record digest;
- timestamp and repository or workspace identifier;
- accountable principal or pseudonymous/persona credential;
- participating developer, agent, model/runtime, and tool identifiers when available;
- operation type and affected file paths;
- before/after artifact digests;
- authorization evidence;
- execution result;
- verification/test result;
- `twin` cardinality and `joker` policy metadata when relevant;
- destination or witness receipts; and
- signatures or attestations sufficient for independent verification.

The exact schema, signature profile, key lifecycle, and witness model remain to be specified and tested.

## File-level accountability

The Ballchain should complement Git rather than replace it. Git already records content-addressed history and author/committer metadata; OSWAP aims to preserve additional context about AI mediation, authorization, policy, verification, and independent replication.

A future record should be able to distinguish, where known:

```text
human principal -> AI/agent -> tool -> file change -> verification
```

from a purely human or automated path without pretending that an AI system has the same legal or moral agency as a person.

## Public auditability and privacy

Public auditability does not mean publishing every input, prompt, secret, or personal datum.

The preferred design is to expose the minimum provenance needed for integrity and accountability while keeping protected payloads encrypted, omitted, or referenced by digest where disclosure would create privacy or safety risk.

Secrets such as passwords, API tokens, signing keys, decryption keys, and private plaintext must not be written into public Ballchain records.

## What the Ballchain can prove

A valid record may help establish integrity, provenance, ordering, attribution, authorization evidence, or verification history.

It cannot prove that every recorded factual assertion is true, that an attributed participant acted with a particular intent, or that legal liability follows from the record.

Accountability evidence must not be confused with automatic blame.

## Replication and policy

`twin` can express how many independent copies, witnesses, or custodians participate in preserving an eligible Ballchain artifact. `joker` can express the deterministic policy by which eligible participants are selected or used.

Replication does not create truth by majority vote. Its role is resilience, independent observation, and resistance to unilateral history loss or alteration.

## Adjacent standards and projects

OSWAP should reuse established mechanisms where practical:

- Git for content-addressed source history;
- SLSA for software provenance concepts and attestations;
- in-toto for signed evidence about authorized supply-chain steps and affected materials/products;
- Sigstore/Rekor for transparency-log and software-signing precedent; and
- established cryptographic libraries for hashing, signing, and encryption.

OSWAP should not invent bespoke cryptographic primitives merely to make the Ballchain distinctive.

## Sociotechnical objective

The desired precedent is cultural as well as technical: consequential AI-assisted and human software changes should leave enough trustworthy evidence that they can later be reconstructed, attributed, questioned, and independently audited.

The design must preserve the distinction between accountability and surveillance, attribution and blame, transparency and unnecessary disclosure, and tamper evidence and factual truth.
