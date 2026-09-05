# Documentation index

SPDX-License-Identifier: Apache-2.0

This index separates normative rules, current implementation documentation, experimental design work, and historical records.

## Normative project documents

- [OSWAP Standard](../OSWAP_STANDARD.md) — current normative language and safety rules.
- [OSWAP Intent](../OSWAP_INTENT.md) — project goals, historical preservation context, autonomy principles, and non-goals.
- [Security policy](../SECURITY.md) — vulnerability-reporting and security boundaries.
- [Contribution guide](../CONTRIBUTING.md) — contributor workflow and expectations.

## Preservation and threat-model context

- [Preservation Threat Model](PRESERVATION_THREAT_MODEL.md) — historical design context for deliberate archive destruction, including the 1933 destruction of Magnus Hirschfeld's Institute for Sexual Science; explains how that history informs independent custody, multi-destination replication, integrity checking, and privacy-aware preservation.

This material is explanatory rather than normative. Historical examples motivate engineering requirements without asserting equivalence between contemporary infrastructure failures and the events used as case studies.

## Current component documentation

- [Twin Protocol](../TWIN_PROTOCOL.md) — Git transport and reconciliation behavior.
- [Architecture Scope](../ARCHITECTURE_SCOPE.md) — implemented versus proposed scope.
- [Branding](../BRANDING.md) — canonical component identity and compatibility names.
- [Glossary](../GLOSSARY.md) — concise terminology and implementation-status labels.
- [Public mirror policy](../MIRRORS.md) — GitHub/GitLab equivalence guidance.
- [Repository-native execution model](REPOSITORY_NATIVE_EXECUTION.md) — shell/Git architecture and capability boundaries.
- [Twin history reconciliation](TWIN_HISTORY_RECONCILIATION.md) — divergence and fast-forward rules.
- [OSWAP installer integration](OSWAP_INSTALLER_INTEGRATION.md) — installer-facing integration guidance.

## Accountability and agentic design

- [Standards for Auditable Code](AUDITABLE_CODE.md) — planned model-agnostic accountability and provenance requirements.
- [Digital Accountability Ballchain](DIGITAL_ACCOUNTABILITY_BALLCHAIN.md) — public, tamper-evident file-change accountability design.
- [Agentic Tool Integration](AGENTIC_TOOL_INTEGRATION.md) — agent/tool policy, authorization, and accountability receipts.

These files are experimental design documents unless a later OSWAP Standard incorporates their requirements.

## Expression-addressing design

The files under `expression-addressing/` describe the evolving restricted arithmetic and provenance model:

- [Overview](expression-addressing/README.md)
- [Expression specification](expression-addressing/EXPRESSION_SPEC.md)
- [Execution model](expression-addressing/EXECUTION_MODEL.md)
- [Git integration](expression-addressing/GIT_INTEGRATION.md)
- [Provenance model](expression-addressing/PROVENANCE_MODEL.md)
- [Security model](expression-addressing/SECURITY_MODEL.md)

Treat experimental design documents as proposals unless their behavior is also implemented and covered by conformance tests.

## OSWAPSACW plugin documentation

The files under `oswapsacw-chatgpt-plugin/` contain experimental semantic and conformance documentation for model-assisted OSWAP workflows.

- [Testing and semantic contract](oswapsacw-chatgpt-plugin/OSWAPSACW_CHATGPT_PLUGIN_TESTING.md)
- `OSWAPSACW_CHATGPT_PLUGIN_TEST_VECTORS.txt`

These documents distinguish `twin = cardinality` from `joker = policy`. They do not grant arbitrary shell authority and do not override provider permissions.

## Development history

Historical records live under `development-history/` and `archive/`. They are retained for provenance and context, not as the normative definition of current behavior.

When historical text conflicts with the current standard or implementation, use the current normative documents and tested source.
