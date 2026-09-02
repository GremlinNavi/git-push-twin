# Repository-native execution model

OSWAP is designed so its core rules, metadata, documentation, and transport instructions remain inspectable as ordinary repository content.

The core does not require a dedicated graphical application. A supported shell and Git-compatible environment can operate directly on the repository, while richer interfaces remain optional adapters.

## Core stack

```text
hardware
  -> operating system
  -> Git + supported shell
  -> OSWAP files, schemas, commands, and scripts
  -> optional database / GUI / AI layers
```

PowerShell is the current reference host for publication workflows. It is not the definition of OSWAP syntax.

OSWAP command definitions, policies, provenance records, and portable knowledge should prefer durable text-oriented formats such as Markdown, UTF-8 text, JSON, and JSONL where practical.

## Capability-based portability

OSWAP compatibility is a capability spectrum rather than a single application compatibility test.

A lower-power host may support repository inspection, clone, pull, verification, and text search without supporting local AI inference. A more capable host may add indexing, embeddings, local models, GPU acceleration, or an accessible GUI.
## Optional interface boundary

A web or desktop GUI SHOULD remain a view and control surface over OSWAP state rather than becoming the only place that state exists.

Information required to inspect, preserve, verify, or reconstruct an OSWAP resource should remain available outside the GUI through repository files, Git state, documented commands, or portable exports.

This permits multiple interfaces to coexist, including terminals, screen readers, IDEs, web frontends, local AI interfaces, and future accessibility clients.

## Twin publication and retrieval

`oswap push twin=<expression>` resolves a restricted arithmetic replication factor and selects approved destinations without replacement. Publication remains preview-first and requires explicit operator confirmation.

`Invoke-GitPullTwin.ps1` implements the complementary retrieval safety model: each configured twin source is fetched independently, the resulting commit IDs are compared, and local integration occurs only when all selected twins agree and a fast-forward is possible.

A successful network operation is not equivalent to verified twin state. Implementations should distinguish transport success from content equivalence.

## Provenance and epistemic audit

Replicas are evidence of preservation, not independent corroboration. Multiple forge copies of one repository should be represented as replicas of the same source state rather than counted as multiple independent sources.

OSWAP can support auditable relevance workflows by retaining source identity, commit IDs, hashes, timestamps, retrieval policy, and contradictory records while keeping AI interpretation downstream from evidence collection.

The objective is not to claim an unbiased machine judge. The objective is to make retrieval and relevance decisions inspectable, reproducible, challengeable, and attributable.