---
name: api-rest
description: >
  Comprehensive guide for designing REST APIs (OpenAPI 3.0.x only, never 3.1)
    following configurable enterprise API standards. Use this skill to generate API structure,
  create openapi-rest.yml, enforce design/security/error conventions,
  and certify the API with A+ rating.
---

# REST API Skill - OpenAPI Rules
## Execution Contract

- For API creation and API edits, execute Workflow 1 in strict order: Step 1 -> Step 2 -> Step 3.
- Before generating content, read this file and then load only relevant `references/` files.
- For new and existing APIs, source of truth is: user inputs + current API files + this skill + selected references.
- Never copy or adapt repository APIs/specs as template baseline.
- Complete all required questions in a single structured ask-questions tool call before writing files.
- If required input is missing, stop and ask; do not infer.
- Run certification only after Step 1 and Step 2 are complete.
- For any edit on an existing API, re-evaluate Step 1 and Step 2 and execute all required actions before certification.
- Any update to endpoints/operations (path, verb, params, request/response, schemas, status codes, or security) must re-run Step 3 certification in the same request.
- After certification, NEVER apply fixes or start an improvement loop without explicit user confirmation. Always stop and ask first.

## Global Compliance Rules

- OpenAPI must be `3.0.3` (never `3.1.x`).
- Main spec file must be `openapi-rest.yml`; `api-spec-type` must be `rest`.
- Semver format is `MAJOR.MINOR.PATCH` (no `v`) and must match spec + metadata.
- Every operation requires `operationId`, `summary`, `description`, `tags`.
- `operationId` format: camelCase `verbNoun` (for example `listUsers`).
- Every parameter and schema property must include `example`.
- Schemas require `additionalProperties: false` and explicit `required` arrays.
- All 4xx/5xx must use the configured shared error contract with `application/problem+json`.
- Enforce security constraints (`maxLength`, `maxItems`, HTTPS, valid schemes).
- Remove unused/unreferenced components before closing.

## Workflow 1 - End-to-End REST API Delivery

### Ordered Execution Rule (Critical)

- Always run Step 1 -> Step 2 -> Step 3.
- Do not start a step before previous one is fully complete.
- Do not write files before Step 1 Q&A is complete and user confirms.
- When editing an existing API, always re-check Step 1 and Step 2; execute whichever updates are needed based on the requested change.
- Endpoint-level edits are never Step 2-only: after applying changes, Step 3 must be executed.
- For existing APIs, Step 3 certification is mandatory after every applied modification.

### Step 1 - Define API Structure

1. Read mandatory references:
    - [general-principles.md](references/general-principles.md)
    - [structure-and-organization.md](references/structure-and-organization.md)
    - [domain-mapping-table.md](references/domain-mapping-table.md)
    - [readme-documentation.md](references/readme-documentation.md)
2. Resolve `locations[].domain` with this algorithm:
    1. Inspect root `application.yml`; read `domain` (trim + lowercase + non-empty).
    2. Map value with [domain-mapping-table.md](references/domain-mapping-table.md):
        - If matches key, use that key.
        - If matches value inside a key list, use parent key.
        - If multiple matches, stop for ambiguity.
    3. If unresolved, ask user in same Q&A interaction (allowed list only).
    4. Strict rules: exact match only, no free text, no fuzzy match, no silent defaults.
3. Ask required questions in a single structured interaction:
    - `api.name` (single-word domain name).
    - `api.version` (label: `Version (format: 1.0.0)`).
    - `api.type` (`kernel`, `shell`, or `application`; default `application`).
    - `api.visibility` (`PUBLIC` or `TEAM`; default `PUBLIC`).
    - `contact.name`, `contact.email`.
    - `locations[].domain` only if unresolved; restrict to allowed values only, no free text, no multi-select.
4. Normalize `api.name` to lowercase slug (`[a-z0-9-]`) and use `apis/<api.name>/`.
5. Wait for explicit user confirmation.
6. Ensure `apis/` exists and enforce two README files:
    - **Base README:** `apis/README.md` (global API catalog readme).
    - **API README:** `apis/<api.name>/README.md` (API-specific readme).
7. Create or update API package `apis/<api.name>/` with:
    - `openapi-rest.yml`, `metadata.yml`, `README.md`, `SUMMARY.md`.
8. Create/update `apis/metadata.yml` entry with:
    - `name`, `api-spec-type: rest`, `definition-path: <api.name>`.
9. Create/validate `apis/api-portal.yml` with required non-empty keys:
    - `service`, `contact.name`, `contact.email`, `locations`.
10. Do not continue to Step 2 until Step 1 artifacts are complete.

### Step 2 - Write REST OpenAPI Spec

1. Load only relevant references from the table below.
2. Build spec from scratch using user inputs + this skill.
3. Write/update `openapi-rest.yml` in `3.0.3`.
4. Validate info/tags/version/operation metadata.
5. Validate paths, verbs, params, schemas, examples, and security.
6. If list responses are paginated, enforce `data` + `pagination` using `pagination-structure.md`.
7. If polymorphism exists, enforce discriminator rules using `inheritance-polymorphism.md`.
8. Validate 4xx/5xx shared errors with `application/problem+json`.
9. Remove unreferenced components.

### Step 3 - Certify API (A+)

Mandatory trigger: run this step for all new APIs and after every applied edit on existing APIs.

1. Ensure API `name` equals entry in `apis/metadata.yml`.
2. Read `metadata.project_key` from root `application.yml`.
3. Use `mcp_api-certifica_certify_api` to certify the API with:
    - `repo_path`: absolute path to the repository root.
    - `api_names`: list of API names matching entries in `apis/metadata.yml`.
    - `project_key`: value from `apis/api-portal.yml` (`service` field) or `application.yml` (`metadata.project_key`).
    - `user_agent` *(optional)*: name of the AI model running the call.
    - If the tool is not available or the call fails, stop immediately and tell the user: "Certification cannot run because the `api-certifica` MCP server is not installed. Add it to `.vscode/mcp.json` using server identifier `api-certifica`." End Step 3 here.
4. Poll status by calling `mcp_api-certifica_get_certification_status` (NOT `get_certification_status`) with the `execution_id` returned by `mcp_api-certifica_certify_api`, repeating until status is `FINISHED` (other states: `ACCEPTED`, `RUNNING`, `FAILED`).
5. Output a concise certification summary including final status, score, and rating.
6. **STOP. MANDATORY CONFIRMATION REQUIRED.** Ask the user whether to start an improvement loop to reach `A+`. Do NOT make any changes, do NOT fix anything, do NOT run any loop until the user explicitly confirms.
7. Only if user explicitly confirms, run iterative loop: review gaps -> fix -> re-certify until `A+` or user stops.
8. If user does not confirm, end the workflow completely. No fixes, no re-certification.

## Reference Files

Load only files relevant to the current task.

- [general-principles.md](references/general-principles.md): base REST design.
- [structure-and-organization.md](references/structure-and-organization.md): structure and metadata.
- [readme-documentation.md](references/readme-documentation.md): README/SUMMARY rules.
- [domain-mapping-table.md](references/domain-mapping-table.md): domain mapping + allowed values.
- [commons-metadata.md](references/commons-metadata.md): operation metadata and contact.
- [example-enforcement.md](references/example-enforcement.md): examples.
- [http-verb-mapping.md](references/http-verb-mapping.md): verb/path mapping.
- [path-parameter-naming.md](references/path-parameter-naming.md): parameter naming.
- [schema-property-naming.md](references/schema-property-naming.md): schema conventions.
- [security-rules.md](references/security-rules.md): security constraints.
- [http-status-codes.md](references/http-status-codes.md): response status usage.
- [shared-error-definitions.md](references/shared-error-definitions.md): shared error references.
- [semantic-versioning.md](references/semantic-versioning.md): semver alignment.
- [tags-usage.md](references/tags-usage.md): tag conventions.
- [pagination-structure.md](references/pagination-structure.md): only for paginated collections.
- [inheritance-polymorphism.md](references/inheritance-polymorphism.md): only for polymorphism.
