# Preservation Threat Model: Deliberate Archive Destruction

SPDX-License-Identifier: Apache-2.0

Status: explanatory design context; not a normative protocol specification.

This document records a historical motivation for OSWAP Twin Transport's preservation architecture. Twin was designed in part with the destruction of Magnus Hirschfeld's Institute for Sexual Science (`Institut für Sexualwissenschaft`) in Berlin in 1933 in mind.

The point of this history is not rhetorical comparison. It is a concrete preservation lesson: information that exists under concentrated custody can be destroyed, suppressed, or made inaccessible when control of that custody is captured.

## Historical case study: the Institute for Sexual Science

On May 6, 1933, pro-Nazi students and members of the SA plundered Magnus Hirschfeld's Institute for Sexual Science in Berlin. Books and documents taken from the institute were subsequently among material targeted in the Nazi book burnings.

On May 10, 1933, approximately 20,000 volumes were burned at Berlin's Opernplatz. The United States Holocaust Memorial Museum specifically identifies material confiscated from Hirschfeld's institute among the material burned there.

Primary historical references used for this design note:

- United States Holocaust Memorial Museum, "Plundering of the Institute for Sexual Science": <https://encyclopedia.ushmm.org/content/en/photo/plundering-of-the-institute-for-sexual-science>
- United States Holocaust Memorial Museum, "Nazi Book Burnings": <https://encyclopedia.ushmm.org/content/en/article/book-burning>

## Engineering lesson

The relevant failure mode can be expressed abstractly as:

```text
valuable knowledge
      ↓
concentrated custody
      ↓
correlated administrative / physical control
      ↓
hostile capture, destruction, suppression, or loss
      ↓
unique material becomes unavailable
```

Twin's preservation response is to avoid treating one repository host, institution, account, provider, or jurisdiction as the ontology of an archive.

Conceptually:

```text
                     ┌─ independent copy / custodian A
source material ─────┼─ independent copy / custodian B
                     └─ independent copy / custodian C
                              ↓
                  integrity / provenance checks
```

This design principle motivates:

- independently selected publication destinations;
- support for more than one repository host;
- multi-source retrieval;
- refusal to silently reconcile disagreeing sources;
- integrity and checksum verification;
- preservation of provenance information; and
- future non-Git archival adapters that do not depend on one provider.

Redundancy alone is not sufficient if one administrator, provider, credential set, or infrastructure layer can destroy every copy simultaneously. Administrative and infrastructural independence therefore matter alongside copy count.

## Relationship to established digital-preservation practice

OSWAP did not invent the principle that preservation benefits from independently controlled copies.

The LOCKSS Program ("Lots of Copies Keep Stuff Safe") explicitly treats malicious attack, human error, and organizational failure as preservation threats. Its preservation principles also warn that a canonical integrity store can itself become a central point of failure or attack, and emphasize independent peers and local custody.

Reference:

- LOCKSS Program, "Preservation Principles": <https://www.lockss.org/about/preservation-principles>

Twin's implementation is not a LOCKSS implementation and should not be represented as one. The relevance is architectural precedent: durable preservation should minimize correlated failure and avoid unnecessary dependence on a single custodian.

## Preservation is not indiscriminate publication

The same historical context also demonstrates why preservation and disclosure must remain separate concepts.

Archives concerning sexuality, gender, health, identity, abuse, whistleblowing, or other sensitive subjects can contain information whose exposure could endanger people. A system that maximizes persistence by publishing sensitive plaintext everywhere would solve one threat while creating another.

OSWAP therefore uses an asymmetric preservation principle:

```text
public knowledge
    -> replicate openly when appropriate

sensitive personal records
    -> minimize exposure
    -> encrypt before remote replication
    -> keep decryption secrets separate from replicated ciphertext
    -> preserve user control over disclosure
```

The preservation objective is therefore twofold:

```text
preserve knowledge
protect people
```

Neither goal should erase the other.

## Threat-model implications for Twin

The historical design lesson informs the following Twin requirements and directions:

1. No single forge is conceptually authoritative merely because it currently hosts a copy.
2. Multiple copies should, where practical, cross administrative and infrastructure boundaries.
3. Retrieval disagreement should be surfaced rather than automatically overwritten.
4. Preservation workflows should retain enough provenance to investigate divergence.
5. Sensitive material should be protected before replication, not after exposure.
6. Replication authority must remain explicit; preservation intent is not authorization to access or copy material the operator is not entitled to possess.
7. Future adapters should make it possible to preserve content outside a single Git ecosystem.

## Claim boundary

This historical motivation does not imply that:

- OSWAP can guarantee that information will survive every attack or disaster;
- contemporary repository failures are historically equivalent to Nazi persecution or the 1933 book burnings;
- replication by itself provides confidentiality, authenticity, or legal admissibility;
- every record should be replicated publicly; or
- preservation intent overrides privacy, consent, copyright, access control, or other applicable obligations.

The 1933 destruction of the Institute for Sexual Science is included here because it materially informed the project's threat model: concentrated custody can make knowledge vulnerable to deliberate erasure. Twin's technical response is to investigate auditable, independently controlled, privacy-aware replication rather than dependence on one copy or one custodian.
