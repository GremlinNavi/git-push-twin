# OSWAP Twin Transport glossary

SPDX-License-Identifier: Apache-2.0

This glossary is descriptive unless a term is explicitly defined by [OSWAP_STANDARD.md](OSWAP_STANDARD.md). The current normative OSWAP Standard version is 0.2.1.

## OSWAP

Open-Source World Access Project. In this repository, OSWAP refers to the project-level domain-specific language, publication rules, provenance concepts, and related open-source infrastructure.

## Twin

Cardinality: how many independently selected complete copies, destinations, sources, endpoints, or authorities participate in an operation.

For publication under OSWAP Standard 0.2.1, `twin=<expression>` resolves a replication factor. A fractional result can probabilistically select one additional complete destination; it never means a partial file or partial repository.

Status: normative for publication behavior in OSWAP Standard 0.2.1.

## Joker

Policy: how eligible copies, sources, endpoints, or authorities are selected or used.

`twin` and `joker` are independent dimensions. A conforming implementation must not silently reinterpret `joker` as `twin`, or vice versa.

Status: defined in the experimental OSWAPSACW semantic documentation. It is not currently a general-purpose policy engine in the Twin Transport implementation.

## OR/AND logic gate (`|&`)

An ordered OSWAP semantic token. `|&` is named the OR/AND logic gate; the symbol and word order are significant. It is not synonymous with AND/OR or `&|`.

Host-language parsing does not redefine the token. In particular, PowerShell's separate meanings for `|` and `&` do not define OSWAP `|&`.

Status: token name and ordering are normative in OSWAP Standard 0.2.1; the detailed execution truth table remains experimental.

## Accountability Ballchain

OSWAP terminology for a tamper-evident accountability/provenance journal in which records can be linked across authorization, execution, verification, and attribution events.

The symbolism is based on the physical chain connecting military identity dog tags: linked identity and accountability markers. Cryptographic hash-linking can be used as an implementation mechanism, but the metaphor is not derived from cryptocurrency.

The Accountability Ballchain is not Bitcoin. It does not inherently require a token, mining, transaction fees, proof-of-work, double-spend prevention, or decentralized monetary consensus.

Status: project-level accountability/provenance concept; non-normative in OSWAP Standard 0.2.1 unless incorporated by a later standard revision.

## Model agnosticism

The OSWAP design requirement that normative semantics, execution policy, verification, and auditability must not depend on one AI model or provider. Provider-specific adapters may exist, but replacing a supported model must not redefine OSWAP commands or destroy the audit trail.

Status: planned requirement for the Standards for Auditable Code; not yet normative in OSWAP Standard 0.2.1.

## Accountable principal

The human, organization, or accredited persona/pseudonym under whose authority a consequential operation is requested. The principal may be distinct from the agent, model, tool, script, or developer process that executes or mediates the action.

## AI-assisted change

A file or artifact modification in which an AI model or agent materially participates in proposing, generating, selecting, applying, or verifying the change. Recording AI participation does not by itself assign blame or legal responsibility.

## Provenance

Information sufficient to understand where an artifact or event came from and how it relates to earlier states. Depending on the implementation, provenance can include source identifiers, artifact hashes, timestamps, authorization records, selected destinations, execution results, and verification results.

## Preview

A non-publishing phase that resolves and displays the operation before a remote write. Preview is not authorization and is not proof that a later execution will succeed.

## Authorization

An explicit decision permitting a state-changing operation. Provider permissions still apply; OSWAP authorization cannot grant rights that the underlying Git host or operating system does not provide.

## Y/N authorization gate

A human authorization input in which `Y` permits an attempt to perform the explicitly described action and `N` declines it. Y/N is not an authentication mechanism, credential exchange, identity proof, or proof of successful execution. Credentials remain inside the designated authentication boundary.

## Execution

The attempt to perform an authorized operation. Execution is recorded separately from authorization because permission to act does not prove that the action completed.

## Verification

A post-execution check that evaluates the resulting state. Verification is distinct from parsing, authorization, and execution.

## Mirror

An independently hosted copy of project content. Mirrors improve availability and resilience but do not imply atomic distributed publication or identical commit hashes.

## Compatibility transport

The lower-level Git-facing behavior retained for interoperability, such as `git push twin`. The canonical OSWAP user-facing publication form is `oswap upload twin=N`.
