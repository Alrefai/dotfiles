# 📑 Pull Request Merge Strategy Guide

When merging pull requests on GitHub, you have three main strategies:

## 1. Merge Commit (Create a merge commit)

**What it does:**
- Leaves all feature-branch commits intact.
- Creates an explicit "merge" commit on the target branch.

```
…─A─B─C────M─
        \   /
         D─E─F
```

**Pros:**
- Preserves complete history of every commit as authored.
- Clearly marks the point of the merge with a single merge commit.

**Cons:**
- Introduces extra "noise" (merge commits) and non-linear history.
- Often unnecessary for small, self-contained PRs (e.g. docs or config tweaks).

## 2. Squash and Merge

**What it does:**
- Combines (squashes) all PR commits into a single new commit.
- Applies that single commit on top of the target branch.

```
…─A─B─C─S─
        ^
        | S = all D,E,F squashed into one
```

**Pros:**
- Keeps target-branch history linear and tidy.
- One PR → one commit; easy to review, revert, and read.
- Commits can still follow Conventional Commits style.

**Cons:**
- Loses the granular detail of intermediate "work-in-progress" commits.

## 3. Rebase and Merge

**What it does:**
- Replays the PR's commits one-by-one onto the tip of the target branch.
- No merge commit is created; history remains linear.

```
…─A─B─C─D'─E'─F'─
         (D,E,F rebased)
```

**Pros:**
- Preserves each individual commit while maintaining linear history.

**Cons:**
- Replays all commits including fixups or WIP commits unless cleaned up first.
- May clutter main history with very small or unpolished intermediate commits.

## Recommended Strategy for This Project

For a highly readable, linear history with one clear Conventional Commit per PR,
**Squash and Merge** is the preferred strategy for this repository.

This approach:
- Produces a single, self-describing commit per PR.
- Avoids merge-commit clutter and non-linear history.
- Keeps the git log concise and easy to navigate.