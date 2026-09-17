# Exploration Sub-agent Prompt

Use this template when spawning an explore sub-agent for each repository. Replace `{repo_path}`, `{repo_name}`, and `{detection_json}` before spawning.

`{detection_json}` is the JSON output from `detect-repo.sh` — the deterministic facts already resolved (stack, build system, tool versions, contracts). The sub-agent builds on this foundation without re-detecting what the script already covered. You ARE responsible for exploring the project's directory structure, modules, and layout — use `find`, `ls`, and file reading to understand what directories contain and how the project is organized.

```
Explore the repository at {repo_path} to identify its architecture, patterns, conventions, and gotchas.

## Already detected (do NOT re-detect)

{detection_json}

## What to produce

Return ONLY this structured markdown:

### Project Structure
- **Modules**: [what each top-level dir/module does — go beyond names, explain purpose]
- **Source layout**: [how prod code, tests, and resources are arranged]
- **Key directories**: [role of important dirs, not just a listing]
- **Configuration**: [where config lives, format, environment handling]
- **Module relationships**: [dependencies between parts, if applicable]

### Architecture & Patterns
- **Architectural style**: [style + evidence of how boundaries and dependencies flow]
- **Component wiring**: [framework mechanisms, DI, manual construction]
- **Error handling**: [how errors are represented, propagated, and surfaced]
- **Logging**: [library, format, conventions]
- **Contracts & Integrations**: for each contract in the detection JSON, determine:
  - **Direction**: does this repo produce (expose) or consume (call) the contract? Look for controllers/handlers (produce) vs client classes/feign/http clients (consume)
  - **Counterpart**: which system or API is on the other end? Check config files, client bean names, base URLs, topic names, or package naming conventions
  - If there are integrations NOT covered by detected contracts (e.g., direct SDK usage, database connections), list those too
- **Key patterns**: [other dominant patterns worth knowing]

### Conventions
- **Naming**: [conventions for files, types, functions — with examples]
- **Code organization**: [by layer, by feature, by domain, flat, etc.]
- **Code style**: [formatter config + observable rules]
- **Test conventions**: [where tests live, naming, framework, patterns]

### Constraints & Gotchas
- [Generated code that must not be modified manually]
- [Framework-specific lifecycle gotchas]
- [Non-obvious dependencies between parts]
- [Anything that would trip up someone writing code here for the first time]
```
