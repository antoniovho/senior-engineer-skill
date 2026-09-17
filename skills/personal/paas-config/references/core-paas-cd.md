# PaaS CD Core Configuration

> Source of truth: `paas-cd.docs.inditex.dev`
> For specific property names, allowed values, or restrictions → always query `geppetto-generic_search`.

## Table of Contents

1. [File Responsibilities](#file-responsibilities)
2. [Deployment Topology](#deployment-topology)
3. [Configuration Hierarchy and Precedence](#configuration-hierarchy-and-precedence)
4. [Sentinel Rules and Final Rendered Configuration](#sentinel-rules-and-final-rendered-configuration)
5. [Advanced Features](#advanced-features)

---

## File Responsibilities

Every PaaS application follows a **configuration-as-code** model. The canonical files live in the repository and are consumed by the CI/CD pipeline at deploy time.

Important nuance: those repository files are the **input**, not always the exact final deployed configuration. During `paas-cli prepare`, Sentinel Rules can inject defaults, copy metadata, derive values, and overwrite some fields before the manifests are rendered.

### `code/image.yml`

Defines how the container image is built. Typical contents:

- Base image (from the approved Container Hub catalog)
- Build arguments
- Image metadata

```yaml
# code/image.yml
image:
  name: my-app
  from: registry.example.com/base-image:tag
```

When to touch this file: changing the runtime base image, build-time args, or image naming strategy.

### `paas/deployments.yml`

Defines **where** the application deploys: which supraenvironments, environments, platforms, tenants, and slots.

```yaml
# paas/deployments.yml
supraenvironments:
  - name: des
    environments:
      - name: des
        platforms:
          - name: platform-name
            tenants:
              - name: tenant-name
                slots:
                  - name: slot-name
                    deploy_on:
                      merge_to:
                        - develop
                      push_to_prs_with_autodeploy_label: true
```

When to touch this file: adding a new deployment target, changing tenant or slot assignments, or configuring deployment triggers such as `merge_to` or `push_to_prs_with_autodeploy_label`.

### `paas/config_paas/configmap*.yml`

Non-sensitive application configuration. This is where feature flags, endpoint URLs, cache TTLs, client IDs (non-secret), and behavioral parameters go.

```yaml
# paas/config_paas/configmap.yml (base — applies to all environments)
app:
  feature-x: true
  cache-ttl: 300
  external-api-url: https://api.example.com
```

### `paas/config_paas/platform*.yml`

Template selection and operational platform configuration. This file is **template-driven**: do not assume every property lives at the same level for every Sentinel template.

Stable mental model:

- `app.openshift_template` selects the Sentinel application template.
- App-level platform behavior usually lives under `app.*` (for example route publication or ConfigNow enablement).
- Marketplace service blocks live at the root level as siblings of `app:`.
- Scaling, resources, probes, routes, and runtime integrations belong to `platform*.yml`, but the exact property path should be verified against the selected template when quoting it.

```yaml
# paas/config_paas/platform.yml
app:
  openshift_template: com.inditex.sentinel:senttapp-springboot:<VERSION>
  services:
    http:
      route:
        enabled: true
  amiga_config:
    enabled: true

redis:
  template: com.inditex.sentinel:senttpl-redis:<VERSION>
  enabled: true
  slot: cache
```

When to touch this file: changing the selected application template, app-level runtime/publication behavior, Marketplace service declarations, or operational platform settings such as scaling, resources, probes, and routes.

### `paas/config_paas/secret*.yml`

Sensitive configuration: passwords, tokens, API keys, certificates. Same hierarchy as configmap files, but values are managed securely.

**Important:** Never commit real secret values to the repository. The actual values are managed through the platform's secret management system. The files in the repo define the structure and key names.

---

## Deployment Topology

The PaaS deployment model uses a five-level hierarchy:

```
supraenvironment
  └── environment
        └── platform
              └── tenant
                    └── slot
```

### Supraenvironments

The standard supraenvironments are:

- `des` — Development
- `pre` — Pre-production
- `preint` — Pre-integration (not all apps use this)
- `pro` — Production

### Promotion Flow

Applications promote through supraenvironments:

```
des → pre → [preint →] pro
```

Each promotion step deploys the same artifact (image) with the configuration for that supraenvironment.

---

## Configuration Hierarchy and Precedence

Files follow a naming convention that determines their scope:

### Base files (apply everywhere)

```
configmap.yml
platform.yml
secret.yml
```

### Supraenvironment-specific overrides

```
configmap_<SUPRAENV>.yml      (e.g., configmap_pro.yml)
platform_<SUPRAENV>.yml
secret_<SUPRAENV>.yml
```

### Granular overrides (advanced)

For specific combinations of tenant, slot, supraenvironment, environment, and platform:

```
configmap_<TENANT>_<SLOT>_<SUPRAENV>_<ENV>_<PLATFORM>.yml
platform_<TENANT>_<SLOT>_<SUPRAENV>_<ENV>_<PLATFORM>.yml
secret_<TENANT>_<SLOT>_<SUPRAENV>_<ENV>_<PLATFORM>.yml
```

Not all segments are required — you can use partial combinations. The more specific the filename, the higher its precedence.

### Precedence rule

**More specific files override less specific ones.** If `configmap.yml` sets `cache-ttl: 300` and `configmap_pro.yml` sets `cache-ttl: 60`, production uses 60.

---

## Sentinel Rules and Final Rendered Configuration

The final configuration deployed to the platform is not obtained only by merging the project's `configmap*.yml`, `platform*.yml`, `secret*.yml`, and `image*.yml` files.

It is also transformed by **Sentinel Rules**, implemented in the `inditex/cac-sentvalid` repository and executed during `paas-cli prepare`.

### What `cac-sentvalid` does

According to the Sentinel Rules tutorial and repository README, Sentvalid rules can:

- **transform** developer-authored properties,
- **inject defaults**,
- **force/overwrite** values,
- **copy** platform values into other namespaces,
- **expand** arrays,
- **compute** derived values with templates or `jq`,
- and **deny deployments** through OPA policies.

The relevant rule files are:

- `image*.yml` for image-building rules,
- `validations*.yml` for deployment-time transformations,
- `imp_*.yml` for imported rule packs,
- `opa_infoyml/`, `opa_infoyml_before/`, and `opa_image_infoyml_before/` for policy checks.

### Why this matters for project configuration

When a developer edits repository YAML, they are only defining the **starting point**. Sentvalid may then enrich or change the final values used by the deployment.

Typical examples visible in `cac-sentvalid`:

- **Metadata injection**: `metadata.environment`, `metadata.platform`, `metadata.platformid`, `metadata.domain`, `metadata.service`, `metadata.tenant`, `metadata.build`, and `metadata.version` are copied or forced into the final configuration.
- **Derived route and URL generation**: route hostnames, paths, and public/private URLs can be calculated from slot, context path, platform group, tenant, and domain.
- **Config file mounting defaults**: `app.configmap.mount_path`, `app.configmap.file_name`, `app.secret.mount_path`, and `app.secret.file_name` are derived from the selected template and load mode.
- **ConfigNow / AMIGA Config integration**: when `app.amiga_config.enabled` is active, Sentvalid derives mount path, slot, generated file name, and configmap channel keys for the runtime configuration file.
- **Framework-specific values**: OAuth and client-gateway values can be defaulted or derived depending on the selected Sentinel template and supraenvironment.

### Rule commands you should recognize

The most important commands are:

- `default` — set a value only if the developer did not set it,
- `force` — overwrite even if the developer set a value,
- `copyto` — propagate a value to another namespace or key,
- `jq` — build or transform structured values programmatically,
- `if` / `else` — make transformations conditional,
- `import` — pull additional rule files into the merge sequence.

This is why a property may exist in the deployed output even if the team never wrote it explicitly in the project repository.

### How to debug “where did this value come from?”

Use this mental model:

1. **Project YAML** = developer-authored input
2. **`paas-cli prepare` + Sentvalid** = merge + transform + validate
3. **Final rendered config** = what deployment actually consumes

The repository itself documents two especially useful artifacts:

- `info.before_check.yml` / `info.before_check.golden.yml` — the values before Sentinel Rules finish their work
- `info.after_check.yml` / `info.after_check.golden.yml` — the values after Sentinel Rules have injected and transformed configuration

If a value appears only in `info.after_check`, it was injected or derived during prepare time.

### Practical guidance for this skill

When helping a user:

- Do not assume every deployed value must be authored manually in project YAML.
- If the user cannot find a deployed property in the repo, consider Sentvalid before concluding the config is missing.
- Distinguish clearly between:
  - **what the team writes** in `configmap*.yml`, `platform*.yml`, `secret*.yml`, `deployments.yml`, or `image.yml`,
  - and **what the platform derives or injects** during `paas-cli prepare`.
- For exact current behavior, inspect `inditex/cac-sentvalid` because rule implementation can evolve independently of project code.

---

## Advanced Features

### `configfiles/` and `ymlconfigfiles/`

For applications that need to mount additional config files (not just key-value YAML), PaaS CD supports:

- `paas/config_paas/configfiles/` — raw files mounted into the container
- `paas/config_paas/ymlconfigfiles/` — YAML files with environment stratification

These follow the same supraenvironment override pattern.

### Import Directive

YAML config files support an `import` feature for reusing shared configuration blocks:

```yaml
# In a configmap file
imports:
  - shared/common-config.yml
app:
  custom-value: foo
```

This reduces duplication across environments. For current syntax details and restrictions, query Geppetto (`geppetto-generic_search` with "paas cd import configmap ymlconfigfiles").

### ConfigNow / config-now

Some technology stacks support a `config-now.yml` or ConfigNow mechanism for runtime configuration that can be refreshed without redeployment. Consult the technology-specific reference for details.
