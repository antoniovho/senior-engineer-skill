# Branching Strategy: Gitflow vs Trunk Based Development

> Source of truth: `github-cicd.docs.inditex.dev`
> For migration steps or current workflow versions → query `geppetto-githubcicd_search`.

## Overview

Inditex supports two official branching strategies. The choice affects how deployments are triggered, how releases are created, and how `deployments.yml` is configured.

## Comparison

| Aspect | Gitflow | Trunk Based Development (TBD) |
|--------|---------|-------------------------------|
| **Primary branches** | `main` + `develop` | `main` only |
| **Default branch** | `develop` | `main` |
| **Feature branches target** | `develop` | `main` |
| **Release trigger** | PR merged `develop` → `main` | PR merged to `main` |
| **Release cadence** | Scheduled, team-controlled | Continuous, per merge |
| **Branch lifespan** | Longer-lived, larger features | Short-lived, small changes |
| **Post-release** | Auto-PR syncs `main` → `develop` | Not needed |
| **Repo variable** | `DEVELOPMENT_FLOW=gitflow` | `DEVELOPMENT_FLOW=tbd` |
| **Code in main** | Only released code | Always ready to deploy |

## When to Use Each

### Gitflow
- Scheduled release cycle with specific periodicity
- Long-lived branches with well-defined features
- Multiple features bundled in a single release version
- Team needs to control exactly what goes into each release

### TBD
- Continuous release cycle for every feature
- Short-lived branches with specific, small tasks
- Frequent integration with the main codebase
- Continuous delivery is the primary goal

## Impact on deployments.yml

### Gitflow

```yaml
# deployments.yml — Gitflow
supraenvironments:
  - name: des
    environments:
      - name: des
        platforms:
          - name: my-platform
            tenants:
              - name: my-tenant
                slots:
                  - name: my-slot
                    deploy_on:
                      merge_to:
                        - develop          # ← deploys on merge to develop
                      push_to_prs_with_autodeploy_label: true
```

### TBD

```yaml
# deployments.yml — TBD
supraenvironments:
  - name: des
    environments:
      - name: des
        platforms:
          - name: my-platform
            tenants:
              - name: my-tenant
                slots:
                  - name: my-slot
                    deploy_on:
                      merge_to:
                        - main             # ← deploys on merge to main
                      push_to_prs_with_autodeploy_label: true
```

## Release Flow

### Gitflow Release Flow

```
1. Feature branches → PR to develop → Merge
2. When ready for release: PR from develop → main
3. Merge to main triggers release workflow
4. Release workflow:
   a. Bumps version according to labels (feature, bug, breaking)
   b. Creates git tag + GitHub release
   c. Uploads artifact to Distribution Platform
   d. Bumps to next SNAPSHOT
   e. Opens sync PR: main → develop
5. Release artifact is deployed to des → promoted to pre → pro
```

### TBD Release Flow

```
1. Feature branches → PR to main → Merge
2. Every merge to main triggers release workflow
3. Release workflow:
   a. Bumps version according to labels
   b. Creates git tag + GitHub release
   c. Uploads artifact to Distribution Platform
   d. Bumps to next SNAPSHOT
4. Release artifact is deployed to des → promoted to pre → pro
```

## How to Determine the Project's Model

1. Check the `DEVELOPMENT_FLOW` repository variable in GitHub
2. Check which is the default branch (`develop` = Gitflow, `main` = TBD)
3. Check `deployments.yml` — `merge_to` target reveals the model

## Migration

Migrating between strategies is supported through DevHub:
- **Gitflow → TBD**: Sync `main` with `develop` first, then reconfigure in DevHub
- **TBD → Gitflow**: Close/merge all open PRs first, then reconfigure in DevHub

Both require workflow version `code@1.80.0` or later.

For step-by-step migration guides, query `geppetto-githubcicd_search` with "gitflow to tbd migration" or "tbd to gitflow migration".

## Key Principles

1. **The branching model is configured in DevHub**, not by editing workflow files.
2. **Both models use the same promotion chain** (des → pre → pro) — only the trigger differs.
3. **The `skip-release` label** can prevent a merge from triggering a release in either model.
4. **Version numbering** is automatic — driven by issue/PR labels (feature → minor, bug → patch, breaking → major).
