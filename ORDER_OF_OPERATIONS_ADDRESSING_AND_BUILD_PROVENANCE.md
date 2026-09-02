# Order of Operations addressing and build provenance

## Status

This document extends the proposed Order of Operations identifier model described in `ORDER_OF_OPERATIONS_TWIN_IDENTIFIERS.md`.

It is design documentation. Examples in this file describe intended wrapper or protocol behavior and must not be presented as native Git syntax unless and until the required PowerShell/Git integration is implemented and tested.

## Owned OSWAP domain namespace

OSWAP currently controls the following public domains:

- `oswap.ca`
- `oswap.jp`
- `oswap.us`

Domain ownership provides stable OSWAP-controlled namespaces. It does not by itself mean that every example subdomain in this document is already deployed, reachable, or backed by a Git service. Individual services remain planned until DNS, TLS, routing, and Git protocol behavior are configured and verified.

The three domains may expose peer repository identities without designating one country domain as the universal primary copy.

## Canonical expression and transport-safe identifier

Order of Operations expressions are useful as human-readable identifiers, but raw arithmetic operators are not always valid in DNS labels, Git refs, filenames, or other transport surfaces.

The protocol should therefore preserve two equivalent representations:

```text
canonical expression: 9/3
transport-safe ID:     9d3
```

A minimal reversible encoding can use:

```text
/ -> d
* -> x
+ -> p
- -> m
```

The canonical arithmetic expression remains authoritative metadata. The encoded form exists only where a transport-safe representation is required.

For example:

```text
9/3  <-> 9d3
6/2  <-> 6d2
12/4 <-> 12d4
3+3  <-> 3p3
3*2  <-> 3x2
9-6  <-> 9m6
```

The parser must reject ambiguous or malformed encodings rather than guessing.

## Expression-addressed OSWAP repository subdomains

A planned public naming convention is:

```text
repo<transport-safe-expression>.<oswap-domain>
```

Examples include:

```text
repo9d3.oswap.ca
repo9d3.oswap.jp
repo9d3.oswap.us

repo6d2.oswap.ca
repo6d2.oswap.jp
repo6d2.oswap.us
```

The equation identity and country domain are separate dimensions unless an explicit registry assigns a particular expression to a particular member or jurisdiction.

That separation allows the same Order of Operations identity to be represented through more than one owned OSWAP domain while retaining independently addressable endpoints.

A resolver can therefore interpret:

```text
repo9d3.oswap.ca
```

as metadata equivalent to:

```text
Domain:               oswap.ca
Canonical expression: 9/3
Transport-safe ID:    9d3
Resolved value:       3
```

The resolved value may identify a family while the complete expression continues to identify a member, review context, build, or other protocol object defined by policy.

## Human-readable wrapper syntax

A PowerShell/Git integration may accept an expressive form that cannot itself be sent directly to DNS.

Conceptual example:

```powershell
git pull repo(9/3).oswap.ca
```

The integration would intercept and normalize the expression before ordinary Git/network resolution:

```text
repo(9/3).oswap.ca
        |
        v
extract canonical expression: 9/3
        |
        v
validate restricted arithmetic
        |
        v
transport-safe ID: 9d3
        |
        v
network hostname: repo9d3.oswap.ca
        |
        v
ordinary Git transport
```

Accordingly, these may represent the same logical endpoint to the OSWAP wrapper:

```text
repo(9/3).oswap.ca
repo9d3.oswap.ca
```

Only the second form is the DNS-safe hostname. The first is proposed human-facing syntax handled before Git attempts network resolution.

## Relationship to twin subset selection

Expression-addressed endpoints complement the existing proposed subset syntax.

For example:

```powershell
git pull twin=(9/3)+12/4
```

can select two expression identities while omitting other registered members.

The implementation should preserve each component expression instead of reducing the complete selection to one arithmetic result.

A resolver can then map each selected identity to one or more approved OSWAP endpoints, forge remotes, or archival locations according to explicit configuration.

This keeps three questions separate:

```text
Which expressions were selected?
Which family does each expression resolve to?
Which approved network endpoints currently represent those expressions?
```

## Build dates as provenance, not replacement identifiers

Build dates can be incorporated into the same model as an additional provenance dimension.

The canonical build date should remain an ordinary unambiguous date, preferably ISO 8601:

```text
2026-09-02
```

An Order of Operations expression may accompany the date as a symbolic or derived build identifier:

```text
Build date:            2026-09-02
Build-date expression: 2026+9+2
Build-date value:      2037
```

The arithmetic value must not replace the actual date. The literal date answers when the build was produced; the expression provides an additional inspectable identity or policy input.

## Proposed build file structure

A readable archival structure can make the date, family, and expression identity visible without requiring a user to decode a Git hash first.

Example:

```text
builds/
  2026-09-02/
    f3/
      repo9d3/
        manifest.json
        SHA256SUMS.txt
        source.zip
      repo6d2/
        manifest.json
        SHA256SUMS.txt
        source.zip
      repo12d4/
        manifest.json
        SHA256SUMS.txt
        source.zip
```

This expresses different forms of provenance independently:

```text
2026-09-02 -> when the build was produced
f3         -> resolved family value
repo9d3    -> transport-safe expression identity
Git SHA    -> exact source-content identity
SHA-256    -> artifact integrity evidence
signature  -> authenticated publisher/reviewer attribution when used
```

The Git commit and artifact checksums remain the authoritative technical evidence for exact content. A directory name or arithmetic expression is not cryptographic proof.

## Proposed build metadata

A machine-readable build manifest can preserve the literal and derived values together:

```json
{
  "buildDate": "2026-09-02",
  "buildDateExpression": "2026+9+2",
  "buildDateValue": 2037,
  "family": 3,
  "equation": "9/3",
  "equationSafe": "9d3",
  "oswapDomain": "oswap.ca",
  "repositoryHost": "repo9d3.oswap.ca",
  "expectedCommit": "a41c92f..."
}
```

A production manifest may add artifact hashes, signatures, reviewer decisions, tool versions, and other reproducibility fields.

## Conceptual build command

A future wrapper may expose a command equivalent to:

```powershell
git push twin=(9/3) date=(2026+9+2)
```

The wrapper could resolve and display:

```text
Order of Operations expression: 9/3
Transport-safe ID:             9d3
Family:                        3
Build date:                    2026-09-02
Build-date expression:         2026+9+2
Build-date value:              2037
Commit:                        <Git object ID>
Destinations:                  <approved endpoints>
```

The displayed date must come from an explicit build-date source or recorded build metadata. The tool should not infer an historical build date solely from an arithmetic result.

## Human oversight and audit records

Expression-addressed repositories and date-addressed builds can strengthen human-readable audit trails when combined with actual authentication and source identity.

A review record could contain:

```text
OSWAP domain:            oswap.ca
Repository hostname:     repo9d3.oswap.ca
Canonical expression:    9/3
Family:                  3
Build date:              2026-09-02
Git commit:              a41c92f...
Reviewer:                <human identity>
Decision:                APPROVE / REJECT
Authorized action:       pull / integrate / publish
Signature:               <cryptographic signature, when used>
Timestamp:               <review timestamp>
```

The Order of Operations identifier locates the oversight context. The Git object identifies the code. A signature or authenticated forge identity attributes the human decision. These roles should not be conflated.

## Domain and deployment safety boundary

Documentation may state that OSWAP owns `oswap.ca`, `oswap.jp`, and `oswap.us`.

Documentation must still distinguish ownership from deployed capability:

```text
Domain ownership:      established OSWAP namespace
Example subdomain:     proposed until created
DNS/TLS routing:       unverified until tested
Git Smart HTTP:        unverified until tested
Repository equivalence: verified only through Git/content checks
```

This keeps public claims accurate while allowing the owned domains to be used freely in architecture and protocol examples.

## Summary

The extended addressing model separates human notation from transport syntax and adds time as another provenance dimension:

```text
9/3
  -> canonical mathematical identity

9d3
  -> transport-safe expression ID

repo9d3.oswap.ca
  -> OSWAP-controlled network identity

2026-09-02
  -> canonical build date

2026+9+2 -> 2037
  -> optional derived build expression/value

Git commit
  -> exact source identity

SHA-256 / signature
  -> integrity and authenticated attribution where applicable
```

This preserves the central design principle: human-readable mathematical structure can organize repository relationships and provenance, while ordinary Git objects, cryptographic evidence, explicit configuration, and human authorization remain responsible for technical integrity and consequential actions.
