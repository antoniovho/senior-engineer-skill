# PIPE Integration

> Source of truth: `pipe.docs.inditex.dev`, `github-cicd.docs.inditex.dev`, and ChatBot docs
> For current schema, allowed values, workflow versions, or command flags → query `geppetto-generic_search` and `geppetto-githubcicd_search`.

## What PIPE Owns

PIPE is its **own configuration-as-code surface** for topics and connectors. Do not mix it with:

- `/paas/` application deployment configuration
- local framework config (`application-configmap.yml`, `config.amg`, etc.)
- Marketplace infrastructure provisioning

If the user is enabling Kafka topics or connectors, load this reference first and only then combine it with the relevant technology reference for the application-side consumer or producer config.

## Repository Structure

### Topic management

Official docs describe a `pipe/` folder with:

```text
pipe/
  pipe.yml
  config/
    des/**/topics.yml
    pre/**/topics.yml
    pro/**/topics.yml
```

Key points from official docs:

- `pipe.yml` lives at the first level under `pipe/`.
- `topics.yml` files live under `pipe/config/<supraenv>/`.
- Teams can organize multiple `topics.yml` files under nested folders.
- Official docs mention up to five nested levels under each supraenvironment folder.

### Connector management

Official docs describe connectors as a separate PIPE surface that uses:

```text
pipe/
  pipe.yml
  connect.yml
  connect_definitions/
```

Use live lookup before quoting exact connector file layout or plugin-specific configuration, because connector guidance evolves independently.

## What Each File Does

| File / folder | Role |
|---------------|------|
| `pipe.yml` | Declares PIPE scope such as platformgroups, tenants, and environments in use |
| `topics.yml` | Declares topics for a given supraenvironment subtree |
| `connect.yml` | Declares connector configuration |
| `connect_definitions/` | Holds connector definitions and related assets |

## Delivery Model

PIPE has its own automation and ChatBot entry points.

- To deploy topics, use `/deploy-pipe-topic`.
- To deploy connectors, use `/deploy-pipe-connect`.
- Official ChatBot docs currently document `/deploy-pipe-topic` with a required supraenvironment selector, but verify the exact syntax before quoting it.
- Exact flags such as `--dry-run` depend on workflow version; verify them via official docs before quoting them.

From the official GitHub CI/CD docs:

- Teams work through changes in the `/pipe/` folder.
- A PR with `/pipe/` changes can be paired with the relevant ChatBot command.
- After merge to `main`, teams can also trigger the deployment from an issue with the same ChatBot commands.

## How to Answer PIPE Questions

1. **Separate PIPE from application config.** If the user asks about Kafka topics and local Go or Java config in the same prompt, explain PIPE first, then handle application config separately.
2. **Start from `/pipe/`.** If the repository does not yet have PIPE configured, the first concrete step is creating the `pipe/` folder and the required files by asking the user to provision them in Devhub first and then pulling the changes from GitHub.
3. **Use live lookup for moving details.** Exact topic schema options, ACLs, environment identifiers, connector plugins, and command flags can evolve.
4. **Keep deployment guidance official.** Do not tell teams to edit workflow YAML manually; PIPE delivery is integrated into the official GitHub/ChatBot flow.

## Live Lookup Triggers

Always query Geppetto when the user asks about:

- allowed values for platformgroups, tenants, environments, or regions
- topic configuration fields such as retention, partitions, replication, cleanup policy, or ACL variants
- connector plugins, connector property catalogs, or connector deployment prerequisites
- current ChatBot flags for `/deploy-pipe-topic` or `/deploy-pipe-connect`
- workflow-version-dependent behavior such as `--dry-run`
