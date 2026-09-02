# Git Integration Plan

## Existing behavior remains native Git

The current `git-push-twin` architecture configures a normal Git remote named `twin` with ordered push URLs.

That behavior should remain usable without the expression layer.

## Proposed expression wrapper

Expression-aware syntax is a wrapper concern, not a change to Git itself.

Conceptually:

```text
git push twin=(9/3)
```

means:

```text
extract expression
 -> parse 9/3
 -> resolve namespace `twin`
 -> produce approved remote plan
 -> show preflight
 -> invoke ordinary Git operations
 -> record provenance
```

Until an actual wrapper implements and tests that behavior, documentation must label the syntax as proposed.

## Separation of responsibilities

```text
expression engine -> mathematics and AST
resolver          -> expression value to logical repository target(s)
policy            -> permitted operation
Git adapter       -> ordinary Git commands
provenance        -> record of expression, mapping, commit and outcome
```

Git object IDs remain the authoritative identity of source content.

## Repository mapping

Mappings should live in version-controlled configuration rather than parser code.

Example logical mapping:

```text
namespace: twin
selector 1 -> one approved endpoint
selector 2 -> two approved endpoints
selector 3 -> three approved endpoints
```

The exact endpoint list belongs in configuration.

## Dry run

A future expression-aware preflight should display at minimum:

```text
raw expression
canonical expression
resolved exact value
namespace
mapping version/hash
selected remotes
current branch
current commit
planned Git commands
```

No remote change occurs in dry-run mode.

## Pull/fetch safety

Expression-aware retrieval should be fetch-first.

Selected twin members should be fetched and compared before any merge, rebase, reset, or branch modification.

Mathematical family agreement does not prove Git history agreement.

## Provenance

After execution, record:

```text
expression
canonical form
semantic value
resolver mapping identity
remote targets
branch/ref
commit ID
operation
result per remote
timestamp
```

The raw expression should never be discarded merely because its evaluated result is known.
