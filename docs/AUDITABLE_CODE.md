# OSWAP Standards for Auditable Code — design direction

SPDX-License-Identifier: Apache-2.0

Status: experimental design document. This file does not supersede `OSWAP_STANDARD.md`.

## Purpose

The planned OSWAP Standards for Auditable Code define how software should preserve enough evidence for humans to reconstruct consequential development actions without requiring trust in one AI model, vendor, repository host, or proprietary interface.

The objective is not total surveillance. The objective is accountable, inspectable software change.

A conforming future profile should make it possible to answer:

- who or what requested a change;
- which human, persona, agent, model, or tool performed or mediated it;
- which files or artifacts changed;
- what authorization existed;
- what verification was performed; and
- where independent evidence of the resulting state can be checked.

## Model agnosticism

OSWAP compliance is intended to require model agnosticism for core semantics, execution policy, verification, and auditability, including when the surrounding application is proprietary.

A compliant implementation should therefore be capable of replacing one supported model/provider with another without changing the normative meaning of OSWAP commands or invalidating the audit trail.

An LLM may explain, propose, translate, or request an operation. It must not be the sole authority defining what a normative OSWAP token means.

For example, `twin=3` must resolve through deterministic OSWAP semantics, not through a model's interpretation of the phrase "three copies".

## Auditable state transitions

OSWAP distinguishes at least four states:

1. parsing — what operation was requested;
2. authorization — whether the principal permitted the stated attempt;
3. execution — what tool or runtime attempted to do; and
4. verification — what resulting state was independently observed.

These states should not be collapsed into one success flag.

## Human and AI attribution

AI assistance does not remove human responsibility, and human authorization does not erase machine participation.

Where technically feasible, provenance should distinguish the principal who authorized an action from the agent, model, tool, script, or developer process that executed or mediated it.

Attribution is evidence about participation. It is not, by itself, a finding of blame, intent, legal liability, or factual truth.

## Data sovereignty and privacy

Auditability does not require universal plaintext disclosure.

OSWAP should minimize collection of secrets and personal information, separate public provenance from protected payloads, and preserve user-controlled export and replication where the user has authority to move the data.

Public artifacts may be replicated openly when licensing and policy permit. Sensitive material must remain subject to the privacy, encryption, authorization, and jurisdictional rules defined by the applicable OSWAP profile.

## Policy and replication

`twin` and `joker` remain separate control dimensions:

- `twin` expresses cardinality: how many independently selected complete copies, sources, endpoints, or authorities participate;
- `joker` expresses policy: how eligible participants are selected or used.

A future `joker` profile should be machine-readable, versioned, inspectable, and deterministic. Models may help users understand or select policies but must not silently redefine them.

## Related open standards

OSWAP should integrate established primitives rather than invent replacement cryptography or transport protocols. Relevant adjacent work includes SLSA provenance, in-toto supply-chain attestations, Sigstore/Rekor transparency logging, Open Policy Agent policy-as-code, Git, and model/tool interoperability protocols such as MCP.

See `DIGITAL_ACCOUNTABILITY_BALLCHAIN.md` and `AGENTIC_TOOL_INTEGRATION.md` for the corresponding design layers.
