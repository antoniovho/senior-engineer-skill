# GitHub CI/CD Delivery Model

> Source of truth: `github-cicd.docs.inditex.dev`
> For current ChatBot syntax, workflow parameters, or trigger details → query `geppetto-githubcicd_search`.

## Table of Contents
1. [Deployment Triggers](#deployment-triggers)
2. [Snapshot vs Release](#snapshot-vs-release)
3. [Promotion Flow](#promotion-flow)
4. [Config-Ref (Version/Config Decoupling)](#config-ref)
5. [Key Principles](#key-principles)

---

## Deployment Triggers

The CI/CD platform provides several official mechanisms to trigger a PaaS deployment. Teams do not modify the underlying GitHub Actions workflows — they use the standardized triggers.

### Autodeploy Label

Add the `autodeploy` label to a PR. Combined with the `deploy_on.push_to_prs_with_autodeploy_label` configuration, this triggers an automatic snapshot deployment on every push to that PR.

**Use case:** Rapid iteration during development — every push deploys automatically to a dev slot.

### Merge-based Triggers

- `merge_to_develop` / `merge_to` — When a PR merges to the target branch, a deployment is triggered automatically.
- This is the standard flow for progressing from development to the release pipeline.

### ChatBot Commands

The ChatBot integrated into GitHub PRs and issues supports deployment commands:

- `/deploy-paas` — Deploy the application to PaaS.
  - Can target specific environments, slots, or configurations.
  - Exact flags and optional parameters must be verified in the current official docs before quoting them.
- `/deploy-pipe-topic` — Deploy PIPE topics.
- `/deploy-pipe-connect` — Deploy PIPE connectors.

For current command syntax and available flags, query `geppetto-githubcicd_search` with "ChatBot deploy-paas commands" or check the official docs.

### Manual / Workflow Dispatch

Some workflows support `workflow_dispatch` for manual triggering through the GitHub Actions UI, but this is not the primary deployment mechanism.

---

## Snapshot vs Release

### Snapshots

- Built from PR branches or pre-merge code.
- Deployed to development slots for testing.
- Identified by a snapshot version (e.g., `1.2.3-SNAPSHOT` or a commit-based identifier).
- Ephemeral — not promoted to production.

### Releases

- Built from merged code (typically the main/develop branch).
- Tagged with a semantic version.
- Candidates for promotion through supraenvironments.
- Follow the `des → pre → [preint →] pro` promotion chain.

---

## Promotion Flow

The standard promotion flow moves a **release artifact** through supraenvironments:

```
1. Code merges → Release is built (des)
2. Release deploys to des → Tested
3. Promote to pre → Tested
4. [Promote to preint → Tested] (if applicable)
5. Promote to pro → Production
```

At each stage:
- The **same artifact** (container image) is deployed.
- The **configuration** changes — each supraenvironment reads its own `configmap_<SUPRAENV>.yml`, `platform_<SUPRAENV>.yml`, and `secret_<SUPRAENV>.yml`.

Promotion is triggered through the platform (ChatBot or CI pipeline), not by manually re-building.

---

## Config-Ref

Official docs support a `config-ref` mechanism to decouple the configuration version from the application version.

**Why this matters:** Sometimes you need to deploy the same application version but with updated configuration (for example, changing a feature flag without rebuilding). The platform supports reading configuration from a different git ref than the application artifact.

For the current syntax and limitations, query `geppetto-githubcicd_search` with "config-ref deploy". Do not quote flags or examples from memory.

---

## Key Principles

1. **Workflows are standardized.** Teams do not modify `.github/workflows/` files. They are templated from DevHub archetypes and managed by the platform team.

2. **Configuration drives behavior.** The deployment topology and configuration files in the repo (`paas/`) are what teams control. The CI/CD system reads these files and acts accordingly.

3. **Snapshots are for testing, releases are for promotion.** Never try to promote a snapshot to production.

4. **Each supraenvironment has its own config overlay.** A single deployment to `pro` reads `configmap_pro.yml`, `platform_pro.yml`, and `secret_pro.yml` on top of the base files.

5. **ChatBot is the interactive interface.** For ad-hoc deployments, use ChatBot commands in GitHub PRs or issues rather than modifying workflow files.
