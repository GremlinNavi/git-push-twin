# Order of Operations twin identifiers and PowerShell integration

## Status

This document describes a proposed extension to PS-twin. It is a design concept, not a claim about current Git syntax or implemented behavior.

The proposal uses a deliberately restricted arithmetic expression language in PowerShell to give related Git repositories human-readable, machine-verifiable semantic identifiers while Git object IDs remain the authoritative identity of repository content.

## Core idea

Equivalent arithmetic expressions can be distinct strings while resolving to the same value:

```text
9/3  = 3
6/2  = 3
12/4 = 3
```

OSWAP / PS-twin can use that property to represent a repository family whose members are related but independently identifiable.

Example assignment:

```text
Canada        -> 9/3  -> family 3
Japan         -> 6/2  -> family 3
United States -> 12/4 -> family 3
```

The expression identifies the member. The evaluated value identifies the family.

This allows two ideas to coexist:

```text
different expression -> distinct member identity
same result           -> shared family relationship
```

The mathematics is therefore a semantic and provenance layer. It does not replace Git hashes, checksums, signatures, authentication, or repository permissions.

## Why PowerShell

PowerShell is a practical host for the proposed expression layer because it can orchestrate Git, inspect structured configuration, display preflight information, and perform explicit validation before invoking network-changing operations.

A production implementation should not pass user-controlled expressions to `Invoke-Expression`. The arithmetic language should have its own small parser or restricted AST supporting only explicitly approved syntax, initially something such as:

```text
numbers
+
-
*
/
%
(
)
```

The parser should preserve both the original expression and the parsed structure rather than immediately collapsing every input to one number.

## Git identity versus Order of Operations identity

The proposal deliberately separates several kinds of identity:

```text
Order of Operations expression -> human-readable twin/member identity
resolved value                 -> twin family identity
Git object ID                  -> exact source-content identity
signature                      -> authenticated human or publisher attribution
```

For example:

```text
Member:       CA
Expression:   9/3
Family:       3
Commit:       a41c92f...
```

A mathematically valid expression does not prove that two repositories contain the same code. Repository equivalence must still be checked using Git object IDs and, where appropriate, release checksums and signatures.

## Proposed push semantics

A future OSWAP-aware wrapper or Git extension could accept a concept equivalent to:

```powershell
git push twin=(9/3)
```

Native Git does not interpret this expression. A PowerShell layer would parse it before calling ordinary Git operations.

Conceptual flow:

```text
requested expression
        |
        v
      9/3
        |
        v
validate restricted arithmetic
        |
        v
resolve member -> CA
resolve family -> 3
        |
        v
verify configured remote and local Git object
        |
        v
show human-readable preflight
        |
        v
explicit publication
```

The human operator should be able to see the selected member, family, commit, and destination before a push changes any remote repository.

## Twin is broader than push

`twin` is intended as a repository relationship, not only as a push destination.

Potential operations include:

```text
git twin status
git twin verify
git twin fetch
git twin pull
git twin push
git twin compare
```

Exact command syntax remains design work. The important concept is that a twin member can be a publication target, retrieval source, verification peer, archival endpoint, or failover source.

## Pull subset selection

A key extension is using multiple member expressions to select only part of a twin family.

Given:

```text
Canada        -> 9/3
Japan         -> 6/2
United States -> 12/4
```

this conceptual command:

```powershell
git pull twin=(9/3)+12/4
```

means:

```text
include Canada
include United States
exclude Japan
```

At the Git-twin language layer, `+` therefore acts as composition of selected twin members. The parser must preserve the component expressions instead of reducing the complete text to the arithmetic result `6`.

Conceptually:

```text
        +
       / \
    9/3  12/4
     |     |
     CA    US
```

Each selected member can still be evaluated independently:

```text
9/3  -> 3
12/4 -> 3
```

which verifies that both selected members belong to family `3`.

The same model allows other subsets:

```text
(9/3)+(6/2)          -> Canada + Japan
(6/2)+(12/4)         -> Japan + United States
(9/3)+(6/2)+(12/4)   -> Canada + Japan + United States
```

## Pull and fetch oversight

Pulling from multiple twins requires more caution than pushing to multiple destinations because incoming histories may diverge.

A safe implementation should be fetch-first:

```text
resolve selected expressions
        |
        v
fetch selected twin refs
        |
        v
compare commits
        |
        v
show agreement or divergence
        |
        v
human selects integration action
```

Example preflight:

```text
Requested set:
  CA  9/3  -> family 3
  US 12/4  -> family 3

Excluded:
  JP  6/2

CA HEAD: a41c92f...
US HEAD: a41c92f...
Local:   88ab120...

Mathematical family check: PASS
Selected-twin Git agreement: PASS
No local branch modified yet.
```

If the selected twins disagree:

```text
CA HEAD: a41c92f...
US HEAD: f039bd1...
```

then mathematical membership may still pass while content equivalence fails. The system should report the divergence and require human review rather than silently selecting a winner.

## Human accountability and oversight

Unique expressions can also anchor human-readable oversight records.

The expression should identify the repository or review context, not serve as a password or proof of a person's identity.

Example:

```text
Twin member:            CA
Order of Operations ID: 9/3
Family:                 3
Commit:                 a41c92f...
Reviewer:               <human identity>
Decision:               APPROVE
Action:                 publish
Signature:              <cryptographic signature, when used>
Timestamp:              <time>
```

This creates a useful separation:

```text
Order of Operations ID -> which oversight context
Git hash               -> which code
signature              -> which authenticated reviewer/publisher
decision               -> what the human authorized
```

The model can preserve disagreement rather than flattening review into one opaque boolean. For example:

```text
9/3  CA -> APPROVE
6/2  JP -> REJECT
12/4 US -> APPROVE
```

Each review remains attributable to a distinct twin context.

## Build and release naming

Raw mathematical expressions are not always suitable for Git refs, filenames, or URLs. The canonical expression can remain in metadata while a safe encoding is used in names.

Example:

```text
canonical expression: 9/3
safe expression ID:    9d3
```

Possible release names:

```text
oswap-v0.4.0-ca-f3-eq9d3
oswap-v0.4.0-jp-f3-eq6d2
oswap-v0.4.0-us-f3-eq12d4
```

Where:

```text
v0.4.0 -> software release
ca      -> twin member
f3      -> evaluated family value
eq9d3   -> encoded member expression
```

The original equation should still be stored in machine-readable metadata so the safe name does not become the only record of the expression.

## Machine-readable metadata

A future configuration or manifest could contain fields such as:

```json
{
  "release": "0.4.0",
  "family": 3,
  "member": "CA",
  "equation": "9/3",
  "equationSafe": "9d3",
  "expectedCommit": "a41c92f..."
}
```

Verification can then ask separate questions:

1. Is the expression valid under the restricted grammar?
2. Does it evaluate to the declared family value?
3. Is that expression assigned to the declared member?
4. Does the repository contain the expected Git object?
5. Do selected twins agree on the relevant ref?
6. Has a human explicitly authorized the consequential operation?

## Quantum-inspired representation concept

The identifier model is partly inspired by quantum-information concepts in which a system can have a defined dimension while individual states remain distinguishable.

In this software model, equivalent expressions provide distinct symbolic representations within a shared numerical family:

```text
9/3  -> 3
6/2  -> 3
12/4 -> 3
```

The practical implementation remains classical PowerShell and Git code. No claim is made that evaluating these equations performs quantum computation. The relevance is architectural: a quantum-inspired distinction between individual representation and shared dimensional/family structure is given a practical software use in repository addressing, grouping, verification, and provenance.

The same restricted expression engine could later be reused for other domains where a derived numerical value configures a system, including compute allocation, AI parameters, or quantum-simulator configuration, while each domain adapter defines what the value means.

## Human-readable failure semantics

A central goal is explainable failure.

If a member assigned to family `3` resolves incorrectly:

```text
CA -> 9/3  -> 3 PASS
JP -> 6/2  -> 3 PASS
US -> 16/4 -> 4 FAIL
```

then the tool should stop before publication or integration and explain the mismatch directly.

Likewise, mathematical validation and Git validation remain independent:

```text
Mathematical family check: PASS
Git content check:         FAIL
Operation:                 HALTED
```

This supports meaningful human oversight rather than hiding consequential decisions behind opaque automation.

## Design principles

A production implementation should preserve the following principles:

1. Expressions are metadata and policy inputs, not authentication secrets.
2. Git object IDs remain authoritative for exact content identity.
3. The original expression and parsed structure are preserved.
4. The arithmetic parser cannot execute arbitrary PowerShell.
5. Multi-member selections are explicit and inspectable.
6. Fetch precedes integration when pulling from twins.
7. Divergence is reported, not silently repaired.
8. Force push, destructive reset, automatic merge, or automatic rebase are never used as hidden recovery shortcuts.
9. Human approval remains explicit for consequential push/pull integration actions.
10. Cryptographic signatures may attribute approval, but Order of Operations identifiers themselves do not authenticate people.

## Summary

The proposed Order of Operations layer gives `twin` three related capabilities:

```text
unique expression -> identify a twin member
shared result      -> identify a twin family
expression set     -> select a subset of twin members
```

Combined with Git:

```text
Order of Operations -> semantic relationship and human-readable provenance
Git                 -> exact source identity and transport
Human               -> consequential approval and accountable oversight
```

The resulting concept is broader than `git push twin`. It is a proposed mathematical addressing and provenance layer for publishing to, retrieving from, comparing, and auditing independently identifiable members of a distributed Git repository family.
