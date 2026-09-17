---
name: aidev-code
description: General coding expertise for enterprise technology ecosystems. Provides coding conventions, leverages MCP tools for live framework documentation, and enforces security and testing practices. Adapts to available context — works with a pre-existing implementation plan, a workspace architecture file, or just a developer's prompt. Load this skill before writing production code. Triggers on "coding conventions", "code guidelines", "implement", "code this", "develop", or when about to write production code.
---

# aidev-code — General Coding Expertise

This skill is a knowledge container for writing production code within an organization's technology ecosystem. It can be invoked from an orchestrating agent (with a full implementation plan) or directly by a developer (with just a task description). It adapts to whatever context is available and can be re-entered iteratively.

## Context Awareness

Before writing code, assess what you already know. This determines how much discovery is needed:

| If this exists... | Then... | Why |
|---|---|---|
| `.aicontext/.sdd/{topic}/tech-plan.md` | Trust it as the definitive roadmap. Do not re-validate. | It was grounded against the codebase and validated with the user. Second-guessing wastes time and creates conflicting signals. |
| `.aicontext/.state/stack.md` | Skip stack detection. The project's identity, structure, and conventions are already captured. | Re-exploring persisted conclusions burns context tokens with no upside. |
| Neither | Explore the project to understand the stack, structure, and conventions of the area you'll modify. Use sub-agents for parallel exploration when multiple gaps exist. | You need enough understanding to make sound implementation decisions. But explore only what's missing — the goal is confidence, not exhaustiveness. |

## Input Resolution

Handle the input based on what you receive:

| Input type | What to do | Why |
|---|---|---|
| **Free text** | Proceed to implement the stated objective. | Direct execution without ceremony. The caller (developer or orchestrator) owns any progress tracking. |
| **GitHub issue reference** | Fetch the issue body and save it to `.aicontext/.sdd/{topic}/tech-plan.md`. Treat it as the implementation plan. | The issue body IS the technical plan. Downloading once avoids repeated API calls and context loss if connectivity fails on re-entries. |
| **Path to a .md file** | Copy it to `.aicontext/.sdd/{topic}/tech-plan.md` if not already there. Do NOT transcribe it. | The file is already prepared with full context and roadmap. Duplicating it wastes tokens and creates drift risk. |

Once input is resolved, the file at `.aicontext/.sdd/{topic}/tech-plan.md` (if it exists) or the referenced .md file becomes the definitive roadmap — trust it completely as described in Context Awareness above.

## Leveraging Skills/MCP Tools

The skills and/or MCP tools available in your session are your primary advantage over generic coding. They provide live, version-current knowledge about the organization's frameworks, libraries, patterns, APIs, security configurations, and testing setups.

**Before writing any production code**, discover and query the tools relevant to your task. This isn't optional ceremony — without it you'll produce code that looks correct but doesn't align with corporate conventions, causing code review rejections and maintenance burden.

**How to discover:**
1. Review the list of available skills and MCP tools in your session (they're listed in your system context).
2. Identify which ones are relevant to the detected stack and the specific task (documentation tools, framework-specific skills, API references, among others).
3. Query those specifically for the aspects below — targeted queries produce better results than broad "tell me everything" requests.

**What to look for:**
- Naming conventions and project structure patterns
- Error handling and logging approaches
- API and messaging patterns
- Framework components that solve the problem at hand (prefer these over custom or third-party solutions — framework components get maintained, upgraded, and comply with corporate policies automatically)
- Security configurations specific to the stack
- Any other topic relevant to the task that the tools cover.

**Example**: for a Java/Maven project with AMIGA, you'd look for documentation tools that cover AMIGA Java patterns, query them for the specific concern you're implementing (e.g., "data access layer conventions", "REST error response format"), and apply what they return over generic Spring patterns.

If no skills or MCP tools are available, fall back to codebase patterns exclusively. Never block on missing tools.

## Coding Priorities

When making implementation decisions, follow this hierarchy:

1. **Existing codebase patterns** — match the style, structure, and layering of the code around you. Consistency within a project is more valuable than abstract "best practice."
2. **Skills/MCP-sourced conventions** — the stack's canonical way of doing things, as reported by documentation tools.
3. **General best practices** — only when neither of the above provides guidance.

This order exists because code review and maintenance happen in context. A perfectly "correct" implementation that diverges from the surrounding code creates cognitive load for every future reader.

## Organization Ecosystem First

When a capability exists in the organization's technology ecosystem — internal frameworks, libraries, corporate APIs, or shared platform services — evaluate it before introducing an external alternative.

Internal solutions may encode the organization's security model, compliance requirements, infrastructure, and operational patterns. External alternatives can still be appropriate when they are better supported or fit the requirements more closely; document that decision.

**Practical implication**: before reaching for an external library or framework feature, query available skills/MCP tools to check whether the organization provides a supported solution. Compare support, security, compatibility, and maintenance before choosing.

## Implementation Cycle

For each unit of work: write code, review security, write tests (if required). Complete one cycle before starting the next unit.

**Before writing code:**
- If `.tool-versions` exists, ensure correct versions are active. Wrong tool versions cause subtle bugs that waste hours to diagnose.
- If the project uses contract-first design (OpenAPI, GraphQL schemas, messaging contracts), verify generated sources are up to date. Hand-writing types that belong to the generator creates conflicts on the next generation run.

**Security** — Load [references/security.md](references/security.md) and evaluate your code against all applicable practices. Record findings explicitly — even "N/A with justification." Silent skipping creates a false sense of completeness; vulnerabilities ship unreviewed.

**Testing** — Load [references/testing.md](references/testing.md). Write tests for every new behavior. Use the definition of done (from the plan, issue, or task description) to guide what to cover. Tests verify behavior, not implementation details.

 ## Success Criteria
 
 Before signaling completeness, verify that all applicable criteria are met:
 
 | Criterion | Evidence |
 |---|---|
 | ✅ Implementation scope completed | All planned units are implemented or explicitly marked blocked |
 | ✅ Code follows local patterns | Reused nearby conventions, helpers, naming, and architecture |
 | ✅ Skills/MCP guidance checked | Consulted available relevant tools, or recorded that none were available |
 | ✅ Security reviewed | Findings recorded, or N/A justified with concrete reason |
 | ✅ Tests added or updated | New behavior is covered, or non-applicability is explained |
 | ✅ Organization ecosystem checked | Internal alternatives evaluated before adding external dependencies |
 | ✅ No git operations performed | Commit/PR remains caller-owned |

## Output Contract

When this skill signals completeness, the caller (orchestrator or developer) can expect:

| Deliverable | State |
|---|---|
| Production code | Compiles, follows local patterns and corporate conventions |
| Tests | Written for new behavior (if required) |
| Security | Evaluated explicitly — findings resolved or N/A justified |
| Implementation Report | Returned as structured output to the caller (not persisted to disk) |
| Git state | Working tree modified, nothing committed — caller owns git lifecycle |

The **Implementation Report** is the structured output this skill returns when signaling completeness. It enables the caller (orchestrator or developer) to aggregate progress across invocations. Contents:

| Section | What it contains |
|---|---|
| Tasks completed | List of implemented units of work |
| Key decisions | Non-obvious choices with rationale and alternatives considered |
| Blockers | Anything preventing full completion, with remaining work described |
| Security findings | Finding, area, status, and resolution for each evaluated concern |

If anything prevents full completion (blocker, ambiguity, pre-existing failure), the report's Blockers section documents what remains and why.

## Boundaries

- **No git operations** (commit, push, branch creation). Whether invoked by an orchestrator or by a developer directly, the git lifecycle is not this skill's responsibility. Signal completeness; let the caller decide when to commit.
- **No re-validating the tech-plan**. If one exists, it's the definitive roadmap. Implement it following the execution order.
- **No custom implementations when a framework component exists**. Use skills and/or query MCP first. Custom code for problems the organization already solves creates maintenance burden and diverges from supported upgrade paths.

## Anti-patterns

| Anti-pattern | Why it's harmful | Correct behavior |
|---|---|---|
| 🚫 Re-exploring what existing artifacts provide | Burns context budget rediscovering known conclusions | Check artifacts first. Explore only genuine gaps. |
| 🚫 Skipping skills/MCP queries when tools are available | Hardcoded assumptions go stale. The ecosystem evolves; skills/MCP stays current. | Always query available skills/MCP tools. Fall back to codebase patterns only if no tools exist. |
| 🚫 Writing code before prerequisites pass | Wrong tool versions or missing generated sources cause subtle breakage | Verify prerequisites before touching production code. |
| 🚫 Silently skipping security evaluation | Vulnerabilities ship unreviewed | Evaluate explicitly. Record findings or justify N/A. |
| 🚫 Writing all tests after all code is done | Failures harder to diagnose when covering many changes at once | Per-unit cycle: code, security, tests. |
| 🚫 Sequential inline exploration when sub-agents would be faster | Blocks the main agent and fills context with exploration noise | Spawn targeted sub-agents for parallel exploration of gaps. |
| 🚫 Using external libraries without evaluating internal equivalents | Can create maintenance, compliance, or upgrade risks | Query skills/MCP tools first and document the choice. |

## Resources

| Reference | Path | Purpose |
|-----------|------|---------|
| Security practices | [references/security.md](references/security.md) | Universal security principles — input validation, injection prevention, auth, secrets |
| Testing conventions | [references/testing.md](references/testing.md) | Naming, 3A pattern, coverage, mocking, Object Mother, deterministic time |
