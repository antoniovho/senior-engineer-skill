---
name: application-security-analyzer
description: >
  Application security skill for structured threat modeling, full codebase security audits, and PR/branch
  vulnerability reviews. Use for any security-related task on a codebase: generating threat models,
  running security audits, or analyzing changes for newly introduced vulnerabilities.
  Trigger whenever the user mentions: threat model, security audit, security review, vulnerability scan,
  PR security review, branch analysis, AppSec, SAST, attack surface, STRIDE, OWASP, CVE, pentest,
  or asks "is this code secure?", "what vulnerabilities does this have?", "review this PR for security issues".
  Always use this skill even if the request is short (e.g., "analyze this diff" or "make a threat model").
---

# Application Security Analyzer

Reason about code like a skilled security researcher: trace data flows, build project-specific threat models, and surface high-confidence findings with proposed fixes.

## Three Modes of Operation

Read the user's request and determine which mode applies — or combine them if needed:

| Mode | When to use | Entry point |
|---|---|---|
| **1. Threat Model** | User wants a structured security overview of a project | [→ Threat Modeling](#mode-1-threat-modeling) |
| **2. Full Security Audit** | User wants vulnerabilities found across the whole codebase | [→ Full Audit](#mode-2-full-security-audit) |
| **3. Branch / PR / Diff Review** | User wants to review changes in a branch or PR | [→ Diff Review](#mode-3-branch--pr-diff-review) |
| **4. Discuss Finding** | User wants to discuss a finding and record it as false positive or accepted risk | [→ Discuss Finding](#mode-4-discuss-finding) |

---

## Before Starting Any Mode

### 1. Load Threat Intelligence

Always read the skill threat references before analyzing:

```
READ: references/threat-frameworks.md      ← STRIDE, OWASP, CWE categories and how to apply them
READ: references/vulnerability-patterns.md ← Concrete patterns to detect by language/type
```

Project-specific threat knowledge is in `.security/knowledge/` (loaded in Step 1 above).

---

### 2. Initialize and Load Project Security Context

**Step 1 — Check if `.security/` exists in the project root:**

```bash
ls .security/ 2>/dev/null && echo "EXISTS" || echo "MISSING"
```

If missing, initialize it:

```bash
mkdir -p .security/knowledge .security/reports
```

Then copy the knowledge template from the skill assets:

```
COPY: assets/security-folder-template/knowledge/security-compound.md → .security/knowledge/security-compound.md
```

Inform the user: "Created `.security/` folder. Edit `.security/knowledge/security-compound.md` to add project architecture context, confirmed false positives, and accepted risks."

**Step 2 — Load project knowledge (always):**

```bash
ls .security/knowledge/
```

Read every file found under `.security/knowledge/`. These are small and always relevant.

**Step 3 — Load prior reports only if relevant:**

Do NOT load reports automatically. Only read `.security/reports/` if:
- The user explicitly asks to review or continue a prior analysis
- The current task is an incremental audit that should reference previous findings
- The user asks "what did the last audit find?"

If loading is needed:
```bash
ls -lt .security/reports/   # list by date — read only the most recent relevant file
```

### 3. Gather Project Context

Projects in an organization may share common patterns regardless of their nature. Use repository-specific documentation and available tools to build context efficiently before analyzing.

#### Step 1 — Assess available tools and knowledge sources

Before reading anything, determine what is available. Work through this list in order:

**a) Check for a context guide**
```bash
ls .security/context-guide.md 2>/dev/null || ls .aicontext/ 2>/dev/null
```
If a context guide exists, read it first — it tells you exactly where relevant information lives for this project. Follow it.

**b) Check for GitNexus**
GitNexus is an indexed knowledge graph of the codebase. If available, it is the highest-value source for understanding code structure, flows, and dependencies without reading every file manually. Use `gitnexus_list_repos` to check what is indexed.

If GitNexus has the project indexed, use it as the primary source for:
- Understanding architecture and data flows
- Tracing entry points and trust boundaries
- Finding all usages of security-sensitive functions

If related projects or documentation are missing from the index, tell the user: "GitNexus does not have [X] indexed. Adding it would significantly improve this analysis."

**c) Check for framework documentation tools**
Available documentation tools may provide procedural knowledge about the project's frameworks. Use them to understand:
- How authentication and authorization work in that framework
- Which security controls the framework provides by default (so you don't flag them as missing)
- How configuration and secrets are handled

**d) Check for agents.md or project documentation**
```bash
ls agents.md AGENTS.md .agents/ 2>/dev/null
ls docs/ README.md 2>/dev/null
```
Read this for orientation, but **never prioritize it over reading the actual code**. Documentation may be outdated or incomplete.

**e) Check deployment configuration**
```bash
ls /paas/ 2>/dev/null
```
If `/paas/` exists, production environment configuration is there. Production config is what matters for vulnerability assessment — not local or staging defaults. Look for environment variables, secrets management, network policies, and service exposure.

**f) Identify the framework and language**
```bash
ls package.json pom.xml build.gradle go.mod requirements.txt Pipfile pyproject.toml 2>/dev/null
```
Frameworks may provide security defaults worth knowing. Use authoritative documentation if available rather than inferring from code alone.

#### Step 2 — Read the codebase with security focus

Prioritize reading code over documentation. When in doubt, trace the actual data flow.

**Secrets discipline**: Never read files that are clearly local secrets (`.env`, `*.key`, `*.pem`, `*secrets.yaml`, `credentials.json`, etc.). These are not needed for security analysis and must not be loaded into context.

#### Step 3 — Identify and communicate gaps

If after steps 1 and 2 there is information that would materially affect the analysis and is not available, tell the user before proceeding:

> "To complete this analysis I need: [specific information]. Options: [how the user could provide it — e.g., index the related service in GitNexus, share the infrastructure config, describe the auth flow]."

Do not proceed with a low-confidence analysis when a critical gap exists. A partial analysis that omits key attack surface is worse than a delayed analysis with complete context.

---

## Mode 1: Threat Modeling

Produce an **editable threat model** and save it to `.security/threat-model.md`. This is the structured security summary used as context for all future scans.

### Step 1 — Understand the System

Analyze the codebase or description to extract:
- **What the system does** (purpose, main flows)
- **Trust boundaries** (where does trust change? external ↔ internal, user ↔ admin, service ↔ service)
- **Attack surface** (entry points: HTTP endpoints, CLI args, file inputs, message queues, WebSockets, etc.)
- **Sensitive data** (credentials, PII, tokens, payment data, health data)
- **High-impact code paths** (auth, payments, admin actions, data deletion, crypto operations)
- **External dependencies** (third-party APIs, SDKs, OSS packages)
- **Deployment context** (cloud, on-prem, container, serverless)

### Step 2 — Apply STRIDE-LM per Component

For each major component (see `references/threat-frameworks.md` for STRIDE-LM details):

| Threat | Question to answer |
|---|---|
| **Spoofing** | Can an attacker impersonate a user, service, or component? |
| **Tampering** | Can data or code be modified in transit or at rest? |
| **Repudiation** | Can users deny actions? Is there adequate audit logging? |
| **Information Disclosure** | Can sensitive data leak (logs, errors, APIs, side channels)? |
| **Denial of Service** | Can the system be made unavailable? |
| **Elevation of Privilege** | Can a lower-privileged actor gain higher access? |
| **Lateral Movement** | If one component is compromised, what else is reachable? |

### Step 3 — Output the Threat Model

Save to `.security/threat-model.md` using this format:

```markdown
## Threat Model: [Nombre del Proyecto]
**Versión**: 1.0 (editable)
**Fecha**: [fecha]
**Clasificación**: [Web API / SPA / Mobile Backend / CLI / Microservicio / LLM App]
**Scope**: [qué está incluido y qué explícitamente excluido]

---

### Q1 — ¿Qué estamos construyendo?

#### Assumptions

Estas suposiciones son la base del modelo. Si alguna es falsa, las amenazas derivadas
son incorrectas y el modelo debe revisarse.

- El servicio corre en [entorno: AWS ECS / on-prem / serverless]
- Los usuarios están autenticados antes de acceder a [recurso]
- La red interna entre servicios se considera de confianza
- [assumption N]

#### Data Flow Diagram (DFD)

Elementos usados:
[E] Entidad externa
[P] Proceso
[D] Data store
[F] Data flow
[B] Trust boundary (línea discontinua)

Ejemplo de estructura:

[E] Usuario web
|
[F] HTTPS request (credentials, JSON)
|
[B]--- Trust boundary: Internet -> DMZ ---[B]
|
[P] API Gateway / Load Balancer
|
[F] Internal HTTP (forwarded request)
|
[B]--- Trust boundary: DMZ -> Internal services ---[B]
|
+-- [P] Auth Service --[F] JWT verify --[D] Sessions DB
|
+-- [P] App Server
|
+-- [F] SQL queries --[D] PostgreSQL
+-- [F] S3 API calls --[D] S3 Bucket

[E] Admin CLI --[F] SSH / internal API --[B] Admin boundary --[P] App Server

> El DFD es el artefacto central. Sin él, STRIDE no tiene elementos a los que aplicarse.
> Actualizar cuando cambien los flujos, no solo cuando haya vulnerabilidades.

#### Entry Points (superficie de ataque)

| ID    | Entry point             | Protocolo | Autenticación       | Trust level      |
|-------|-------------------------|-----------|---------------------|------------------|
| EP-01 | POST /api/login         | HTTPS     | Ninguna             | Sin autenticar   |
| EP-02 | GET /api/documents/:id  | HTTPS     | JWT                 | Autenticado      |
| EP-03 | Admin CLI               | SSH       | mTLS + IP allowlist | Alta confianza   |

#### Sensitive Data Inventory

| Tipo              | Dónde se almacena        | Dónde se transmite | Protección actual      |
|-------------------|--------------------------|--------------------|------------------------|
| Passwords         | PostgreSQL (hashed)      | HTTPS              | bcrypt rounds=12       |
| JWT tokens        | Cliente (cookie/header)  | HTTPS              | HS256, exp=1h          |
| PII (email, nombre) | PostgreSQL             | HTTPS              | Sin cifrar en reposo   |

---

### Q2 — ¿Qué puede salir mal?

#### STRIDE per element

Aplicar a cada elemento del DFD según su tipo.

Regla por tipo de elemento:
- Entidad externa [E]: puede ser Spoofed, puede Repudiate
- Proceso [P]: puede sufrir todos (S, T, R, I, D, E)
- Data flow [F]: puede ser Tampered, Information Disclosed
- Data store [D]: puede ser Tampered, Information Disclosed, DoS

---

**[P] Auth Service**

| Threat ID | STRIDE             | Descripción                                                              | Likelihood | Impact   | Riesgo   |
|-----------|--------------------|--------------------------------------------------------------------------|------------|----------|----------|
| T-001     | Spoofing           | Atacante impersona usuario con JWT forjado si se acepta alg:none         | HIGH       | CRITICAL | CRITICAL |
| T-002     | Tampering          | Modificación del payload JWT para escalar rol a admin                    | HIGH       | CRITICAL | CRITICAL |
| T-003     | Repudiation        | Sin audit log de login fallidos ni cambios de contraseña                 | MEDIUM     | HIGH     | HIGH     |
| T-004     | Info Disclosure    | Error diferente para "usuario no existe" vs "contraseña incorrecta"      | HIGH       | MEDIUM   | HIGH     |
| T-005     | Elevation of Priv. | Escalada de rol vía mass assignment en PATCH /user                       | MEDIUM     | CRITICAL | HIGH     |

[Continuar por cada elemento del DFD]

#### Threat Inventory (todas las amenazas, priorizadas por riesgo)

| Threat ID | Componente   | Categoría STRIDE   | Riesgo   | Estado |
|-----------|--------------|--------------------|----------|--------|
| T-001     | Auth Service | Spoofing           | CRITICAL | Abierto |
| T-002     | Auth Service | Tampering          | CRITICAL | Abierto |
| T-008     | PostgreSQL   | Tampering          | HIGH     | Abierto |
| T-007     | HTTPS flow   | Info Disclosure    | HIGH     | Abierto |
| T-005     | Auth Service | Elevation of Priv. | HIGH     | Abierto |
| T-003     | Auth Service | Repudiation        | HIGH     | Abierto |
| T-004     | Auth Service | Info Disclosure    | HIGH     | Abierto |
| T-009     | PostgreSQL   | Info Disclosure    | HIGH     | Abierto |
| T-006     | HTTPS flow   | Tampering          | MEDIUM   | Abierto |
| T-010     | PostgreSQL   | DoS                | MEDIUM   | Abierto |

---

### Q3 — ¿Qué hacemos al respecto?

Cada amenaza tiene una respuesta explícita.

Respuestas posibles:
- Mitigate: añadir un control
- Eliminate: rediseñar para que la amenaza no exista
- Transfer: SLA, seguro, delegar a tercero
- Accept: riesgo residual documentado y aprobado por owner

| Threat ID | Respuesta  | Mitigación concreta                                                          | Owner     | Sprint |
|-----------|------------|------------------------------------------------------------------------------|-----------|--------|
| T-001     | Mitigate   | Fijar algorithms=['HS256'] en jwt.decode(), rechazar alg:none                | Backend   | S-12   |
| T-002     | Mitigate   | Validar firma server-side en cada request                                    | Backend   | S-12   |
| T-003     | Mitigate   | Structured audit log (user_id, action, timestamp, IP) en todas las auth ops  | Backend   | S-13   |
| T-004     | Mitigate   | Unificar mensaje de error a "credenciales inválidas" en todos los casos       | Backend   | S-12   |
| T-005     | Mitigate   | Whitelist de campos editables en PATCH /user, nunca actualizar campo role     | Backend   | S-12   |
| T-007     | Eliminate  | Bloquear credentials en query params via Semgrep rule en CI                  | DevSecOps | S-11   |
| T-008     | Mitigate   | Parametrizar todas las queries, revisión de ORM raw() calls                  | Backend   | S-12   |
| T-009     | Accept     | Credenciales rotadas en Vault; riesgo residual aceptado por [owner]          | SRE       | —      |
| T-010     | Transfer   | Monitorizado en Datadog; SLA de respuesta 4h por parte de SRE                | SRE       | —      |

---

### Q4 — ¿Lo hemos hecho bien?

#### Coverage check

- [ ] Se aplicó STRIDE a cada elemento del DFD
- [ ] Cada trust boundary tiene al menos una amenaza asociada
- [ ] Cada amenaza CRITICAL o HIGH tiene owner y sprint asignado
- [ ] Las assumptions han sido revisadas con el equipo
- [ ] El DFD refleja el estado actual del sistema, no el diseño original

#### Riesgo residual

[Lista de amenazas en estado Accept con justificación y nombre del owner que aprueba]

#### Trigger para próxima iteración

Este modelo debe revisarse cuando:
- Se añade un nuevo entry point o data store
- Cambia un trust boundary
- Se descubre una vulnerabilidad relacionada en producción
- Han pasado más de [N] sprints sin revisión
```

> This model is editable and serves as context for all future scans.

---

## Mode 2: Full Security Audit

Scan the entire codebase reasoning like a human security researcher. Do NOT just pattern-match — trace data flows, understand business logic, follow trust across files.

### Step 1 — Build Scan Context

If `.security/threat-model.md` exists, read it. If not, do a rapid threat model first (abbreviated) and use it as context for the audit.

### Step 2 — Systematic Code Analysis

Work through these categories (read `references/vulnerability-patterns.md` for concrete patterns):

**Tier 1 — Almost Always Worth Reporting (High Confidence)**
- Injection: SQL, command, LDAP, XPath, NoSQL, XXE, SSTI
- Authentication bypass / broken auth logic
- Privilege escalation / IDOR (Insecure Direct Object Reference)
- Hardcoded secrets, credentials, API keys
- Insecure cryptography (weak algos, bad IV, hardcoded keys)
- Remote Code Execution: deserialization, eval injection, pickle
- Stored/Reflected/DOM XSS with proven execution path
- SSRF (Server-Side Request Forgery)
- Path traversal / directory traversal
- Race conditions on security-critical resources (TOCTOU)

**Tier 2 — Report if Proven Impact**
- Missing input validation WITH clear exploit path
- Session management flaws
- Insecure session storage / token handling
- CSRF on state-changing endpoints
- Sensitive data in logs / error messages
- Supply chain: vulnerable dependency versions with known CVEs
- Missing security headers (only if meaningful for the app type)

**Tier 3 — Skip (False Positive Prone)**
- Generic DoS / resource exhaustion without exploit path
- Rate limiting missing (unless business-critical endpoint)
- Open redirects (unless used for OAuth/SAML flows)
- Theoretical timing attacks without realistic setup
- Missing security headers on non-browser-facing APIs

### Step 3 — Adversarial Verification

Before surfacing a finding, challenge it:
- Can I trace the actual data path from input to vulnerable sink?
- Is there an existing defense I missed (framework sanitization, WAF, type checking)?
- Is this exploitable in a realistic attack scenario?
- Is this a false positive that would waste the team's time?

Only surface findings that pass this check.

### Step 4 — Output the Audit Report

Save to `.security/reports/audit-YYYY-MM-DD.md` using this format:

```markdown
## Security Audit Report: [Project Name]
**Date**: [date]
**Scope**: Full codebase
**Files analyzed**: [N]

### Executive Summary
[2-3 sentences on overall posture]

**Risk Distribution**: [X] Critical | [Y] High | [Z] Medium | [W] Low

---

### Finding #[N]: [Title]
**Severity**: CRITICAL / HIGH / MEDIUM / LOW
**CWE**: CWE-[number] — [name]
**OWASP**: [category if applicable]
**File(s)**: `path/to/file.py`, line [N]

**Description**:
[What the vulnerability is]

**Exploit Path**:
[Step-by-step how an attacker would exploit this]

**Evidence**:
```[language]
[Relevant code snippet]
```

**Impact**:
[What an attacker can achieve]

**Proposed Fix**:
```[language]
[Fixed code or patch diff]
```

**References**: [CVE/CWE/OWASP link]

---
[Repeat for each finding]

### Not Reported (Intentional)
[Brief list of things considered but excluded and why — shows reasoning]

### Recommended Remediation Priority
1. [Finding #N — reason]
2. ...
```

---

## Mode 3: Branch / PR / Diff Review

Analyze ONLY the changes introduced by a branch or diff. Focus on vulnerabilities **introduced** by the changes, not pre-existing issues.

### Step 1 — Get the Diff

If in a git repo, get the diff:
```bash
# Compare branch to main
git diff main...HEAD

# Or for a specific set of files
git diff main...HEAD -- path/to/files

# For staged changes
git diff --staged
```

If the user provides a diff directly, work from that.

### Step 2 — Understand Change Intent

Before looking for bugs:
- What was the developer trying to do? (new feature, bugfix, refactor?)
- What components does the change touch?
- Does it touch any security-sensitive areas? (auth, crypto, data access, input handling, file ops)

### Step 3 — Diff-Specific Analysis

Focus on what the change **introduces or modifies**:

**High-priority signals in diffs:**
- New endpoints / routes added (check auth, input validation, output encoding)
- Changes to authentication or session logic
- New database queries or ORM calls (injection risk)
- New file operations (path traversal risk)
- Changes to cryptographic operations
- New third-party packages added (supply chain risk)
- Changes to CORS, CSP, or security headers
- New use of `eval`, `exec`, `subprocess`, `pickle`, `deserialize`
- Removed security checks (auth guards, validation, rate limits)
- New environment variables or config (secrets exposure?)
- Changes to permission checks or role validation

**Pattern: Security check removed?**
The most dangerous PRs remove security controls. Look for:
- Lines starting with `-` (removals) near auth/validation/permission code

### Step 4 — Output the Diff Review

Save to `.security/reports/pr-review-[branch-name]-YYYY-MM-DD.md` using this format:

```markdown
## PR / Branch Security Review
**Branch**: [branch name]
**Base**: [main/master/etc.]
**Changed files**: [N]
**Review scope**: Changes only (not pre-existing issues)

### Risk Assessment: [LOW / MEDIUM / HIGH / CRITICAL]

### Security Findings in This Diff

#### Finding #[N]: [Title]
**Severity**: HIGH / MEDIUM / LOW
**File**: `path/to/file` line [N]
**Change type**: Added / Modified / Removed security control

[Description, evidence from diff, proposed fix]

---

### Security-Sensitive Changes (No Issue Found, But Worth Human Review)
- `path/to/file`: [what changed and why it deserves review]

### Approved Changes (Security-neutral or improved security)
- [Brief list of changes that look good from a security perspective]

### Summary
[Overall verdict: safe to merge / merge with fixes / needs significant rework]
```

---

## Mode 4: Discuss Finding

The user wants to discuss a finding — to challenge it, explain context the agent lacked, or argue it is a false positive or an accepted risk.

This mode is a **structured technical debate**, not a passive recording. The agent defends its finding with security reasoning and only updates the knowledge files when the developer provides technically sound arguments. The goal is twofold: the developer gains a deeper understanding of the risk, and the agent gains project context that improves future analyses.

**No file is modified without explicit user approval.**

### Step 1 — Identify and Reload the Finding

Ask the user which finding they want to discuss (report file, finding ID, or description). Read the referenced report if needed:

```bash
ls -lt .security/reports/
```

Restate the finding clearly: what the vulnerability is, why it was flagged, what the exploit path is, and what the severity assessment was. This ensures both parties are discussing the same thing.

### Step 2 — Listen and Challenge

The user presents their argument. Before accepting it, the agent must actively evaluate it against its security knowledge:

**If the argument is weak or incomplete, push back. Examples:**

- "You say this endpoint is internal-only, but I see no network-level control in the codebase. What enforces that boundary — infrastructure, not code?"
- "You say the input is pre-validated, but the validation happens in a different service. What guarantees the data reaching this function has passed through it?"
- "Accepting this risk requires a compensating control. What is it, and where is it documented?"

**The agent should only change its position when the developer provides:**
- Concrete evidence (file paths, infrastructure config, architecture docs)
- A verifiable compensating control
- A clear explanation of why the specific exploit path does not apply in this environment

Vague assertions ("trust me, it's fine", "we handle that elsewhere") are not sufficient. The agent must ask follow-up questions until the argument is specific and verifiable, or the developer acknowledges the risk.

**If the developer cannot provide a convincing argument**, the agent closes the discussion without updating any file:

> "I understand your position, but based on what you've described, I still consider this a valid finding. The risk remains open. If new evidence surfaces, we can revisit it."

### Step 3 — Classify the Outcome

Once the agent is genuinely convinced, determine where the information belongs:

| Outcome | Target file |
|---|---|
| Pattern is safe in this codebase — specific, verifiable reason | `.security/knowledge/security-compound.md` → Section 2 (Confirmed False Positives) |
| Risk is real but knowingly accepted with documented rationale and owner | `.security/knowledge/security-compound.md` → Section 3 (Accepted Risks) |
| Architecture context changes how threats should be modeled | `.security/threat-model.md` → relevant assumption or trust boundary |
| Context prevents a class of future false positives | `.security/knowledge/security-compound.md` → Section 1 (Project Architecture Context) |

### Step 4 — Draft and Propose the Entry

Write the proposed entry following the format in the target file. Include the specific argument the developer provided — vague entries are useless for future analyses.

Show the draft to the user:

```
Based on our discussion, I propose adding the following to [file] → [section]:

---
[proposed entry]
---

This will be incorporated in all future analyses. Approve? (yes / edit / discard)
```

Do NOT write to any file until the user explicitly approves.

### Step 5 — Apply After Approval

Only after explicit approval:
1. Append the entry to the correct section.
2. Update the Changelog at the bottom of `security-compound.md` if modified.
3. Confirm: "Updated [file]. Future analyses will use this context."

If the user edits the proposed text, show the revised version and ask for approval again before writing.

---

## Output Standards

- **Never report theoretical vulnerabilities** — every finding needs a traceable exploit path or solid evidence
- **Never report low-confidence guesses** — if unsure, say so and explain what additional info is needed
- **Always propose a fix** — findings without remediation guidance are incomplete
- **Severity definitions:**
  - **CRITICAL**: Direct, easily exploitable, high impact (RCE, auth bypass, data exfiltration)
  - **HIGH**: Exploitable with moderate effort, significant impact
  - **MEDIUM**: Exploitable in specific conditions, moderate impact
  - **LOW**: Hard to exploit, limited impact, or defense-in-depth issue
- **CWE and OWASP references**: Always include when applicable
- **False positive discipline**: When in doubt, leave it out (or flag as "needs human validation")

---

## Project `.security/` Folder

```
.security/
  knowledge/
    security-compound.md ← architecture context, false positives, accepted risks (edit this)
  reports/            ← All analysis outputs (loaded on demand)
    audit-YYYY-MM-DD.md
    pr-review-[branch]-YYYY-MM-DD.md
  threat-model.md
```

> To document project architecture context, confirmed false positives, or accepted risks,
> edit `.security/knowledge/security-compound.md`. The skill incorporates this file in every analysis.

---

## Reference Files

- `references/threat-frameworks.md` — STRIDE-LM, OWASP Top 10, OWASP API Top 10, LINDDUN, CWE mapping
- `references/vulnerability-patterns.md` — Concrete code patterns by language (Python, JS/TS, Java, Go, etc.)
