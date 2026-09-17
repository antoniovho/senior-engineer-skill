# PaaS Marketplace — Infrastructure Services

> Source of truth: `paasmarketplace.docs.inditex.dev`
> For specific service properties, template versions, or configuration details → **always query Geppetto** with `"<service_name> sentinel template quickstart"`.

## Overview

The PaaS Marketplace is the catalog of infrastructure services that can be provisioned alongside an application. These are managed platform services: the platform handles provisioning, lifecycle, and most credential injection concerns.

Do **not** freeze the catalog inside this skill. During research, official docs included services such as Redis, RabbitMQ, Apache Flink, and Sentijobs, but availability and versions can change. Query Geppetto for the current catalog whenever service availability matters.

If the user asks about messaging brokers, verify current official guidance via Geppetto before quoting template names or deprecation status.

## The Universal Provisioning Pattern

Every Marketplace service follows the same pattern in `platform.yml`:

```yaml
# paas/config_paas/platform.yml
#
# Application config goes under app:
app:
  openshift_template: com.inditex.sentinel:senttapp-<technology>:<VERSION>
  # ... app properties

# Infrastructure services go at ROOT LEVEL (sibling to app:)
<service_name>:
  template: com.inditex.sentinel:senttpl-<service>:<VERSION>
  enabled: true
  slot: <unique-slot-name>
  # ... service-specific properties
```

### Key rules:
1. **Root level, not under `app:`** — infrastructure services are siblings to the `app:` block
2. **Each service has its own Sentinel template** — `senttpl-redis`, `senttpl-rabbitmq`, `senttpl-flink`, etc.
3. **`enabled: true`** is required to provision the service
4. **`slot`** uniquely identifies the service instance within the namespace
5. **`force: true`** is typically needed to apply changes to an already-deployed service instance

## Environment Overrides

Infrastructure service configuration follows the same supraenvironment override pattern as the rest of PaaS CD:

```yaml
# platform.yml — base (all environments)
redis:
  template: com.inditex.sentinel:senttpl-redis:<VERSION>
  enabled: true
  slot: my-cache
  ephemeral_cache: true

# platform_des.yml — dev: small
redis:
  node:
    size: XXXXS

# platform_pro.yml — production: larger
redis:
  node:
    size: M
  replicas: 3
```

## Credential Management

Infrastructure services that require authentication use **CyberArk** integration. Credentials are declared in `platform.yml` using `password_coordinates` — the platform resolves these at deploy time:

```yaml
# platform.yml — credentials managed by CyberArk, NEVER hardcoded
<service_name>:
  users:
    <user_role>:
      password_coordinates: cyberark.<SAFE>.<OBJECT>-<user_role>
```

The actual passwords never appear in the repository. The platform resolves the CyberArk coordinates and injects the credentials into the running environment.

## How to Answer a Service-Specific Question

Because each service has unique properties, sizes, plugins, and configuration options that evolve independently:

1. **Read this reference** for the universal pattern (root level, template, slot, enabled, force)
2. **Query Geppetto** for the specific service:
   - `geppetto-generic_search` with `"redis sentinel template quickstart properties"` for Redis
   - `geppetto-generic_search` with `"rabbitmq sentinel template quickstart properties"` for RabbitMQ
   - `geppetto-generic_search` with `"flink sentinel template quickstart"` for Flink
3. **Propose concrete YAML** based on what Geppetto returns, following the universal pattern
4. **Keep app connection settings separate** — hostnames, ports, usernames, and application-level toggles belong in `configmap*.yml` or `secret*.yml`, not in the Marketplace service block unless the docs say otherwise

## Metadata Section

All applications have a `metadata:` section in `platform.yml` that provides organizational context:

```yaml
metadata:
  layer: core                    # application layer
  developModel: CORPORATE        # or CONTRIBUTOR
  platformgroup: my-group        # platform group assignment
  namespace_id: my-namespace     # namespace identifier
```

The `metadata` values are often used by infrastructure services for connection URL resolution and naming, but the exact final hostnames and derived values may still be influenced by Sentinel Rules.

## Connection Patterns

Infrastructure services run within the Kubernetes namespace and are accessible via internal DNS. The connection URL pattern typically follows:

```
<service>[-<slot>].${metadata.tenant}-${metadata.domain}-${metadata.environment}.svc.cluster.local
```

Application-level connection configuration (host, port, credentials) goes in `configmap.yml` and `secret.yml`, not in `platform.yml`. For technology-specific connection setup, load the relevant local config reference (Java, Node, Go, Python, Web).

## Important Notes

- Each supraenvironment gets its **own service instance** with its own credentials — you never share a production database with development.
- Removing a service from `platform.yml` may not immediately destroy the running instance — deprovisioning has its own lifecycle.
- Service availability and property catalogs vary by platform and environment — query Geppetto if unsure.
