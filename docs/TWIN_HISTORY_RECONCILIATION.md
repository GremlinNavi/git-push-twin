# Twin history reconciliation

PS-twin treats repository-provider copies as peer publication endpoints. If two twins were created or developed with unrelated Git histories, matching filenames or working trees do not make them safe to overwrite.

This procedure records both histories in one shared commit graph without force-pushing or deleting either lineage.

## Safety properties

A reconciliation must preserve these invariants:

- fetch both current branch tips before changing either host;
- preserve both existing tips as parents of the reconciliation commit;
- do not use `--force`, `--force-with-lease`, `reset --hard`, or history rewriting;
- explicitly choose and review the working tree that the reconciliation commit will publish;
- verify that the resulting commit is a descendant of both pre-reconciliation tips; and
- publish the exact same reconciliation commit to every twin.

## Why a two-parent merge works

Suppose two hosts contain unrelated current tips:

```text
Host A: A
Host B: B
```

Create one merge commit `R` with both as parents:

```text
A ---\
      R
B ---/
```

Because `R` descends from both `A` and `B`, moving each host from its existing tip to `R` is a fast-forward. No existing history is removed.

## Reviewed-tree reconciliation

When one working tree has already been reviewed as the intended current PS-twin state, Git's `ours` merge strategy can join the histories while keeping that reviewed tree unchanged.

Example using two explicitly configured remotes named `host-a` and `host-b`:

```powershell
git status --short
git fetch host-a main
git fetch host-b main

git switch -C reconcile-twins host-b/main
git merge --strategy=ours --no-ff --allow-unrelated-histories host-a/main `
  -m "Reconcile PS-twin repository histories"
```

`--strategy=ours` here does not mean that one provider is permanently authoritative. It means the operator has explicitly selected the currently reviewed tree for this one reconciliation commit while retaining both historical lineages.

Before publishing, verify both ancestry relationships:

```powershell
git merge-base --is-ancestor host-a/main HEAD
if ($LASTEXITCODE -ne 0) { throw 'Reconciliation commit does not contain host-a history.' }

git merge-base --is-ancestor host-b/main HEAD
if ($LASTEXITCODE -ne 0) { throw 'Reconciliation commit does not contain host-b history.' }

git log --graph --decorate --oneline -n 20
```

Then publish the exact reconciliation commit to both branch refs using ordinary non-force pushes:

```powershell
git push host-a HEAD:main
git push host-b HEAD:main
```

If either push is rejected, stop. Do not force the rejected host to match. Re-fetch both tips, identify the changed protection/permission/history condition, and reassess the plan.

## After reconciliation

Fetch both hosts again and verify that their branch refs equal the reconciliation commit:

```powershell
git fetch host-a main
git fetch host-b main

git rev-parse HEAD
git rev-parse host-a/main
git rev-parse host-b/main
```

Once both refs agree, future PS-twin publication can operate from one shared history. Repository protections should then prevent force-pushes and branch deletion so the reconciled lineage remains durable.

## Non-goals

This procedure does not prove release-asset equality, tag equality, signature validity, account ownership, or full repository-host configuration equivalence. Those surfaces require separate verification.
