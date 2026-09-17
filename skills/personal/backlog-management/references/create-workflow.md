# Issue Creation Workflow

End-to-end workflow for creating a new GitHub issue and optionally adding it to a project.

## Tool Convention

All steps use **gh CLI scripts first**. If a script exits with code **127** (gh not installed), fall back to the MCP alternative in the same step. Other exit codes: **0** = success (parse stdout), **1** = error (show stderr to user).

## Step 1 — Setup

Collect all configuration in a **single round**. Present these questions together:

1. **Issue type**: User Story, Bug, or Spike
2. **Target repository**: `owner/repo` where the issue will be created
3. **GitHub Project**: project number to add the issue to
4. **Depth**: Guided (walk through the template step by step) or Quick (just title + description)

Mention briefly what each type is for so the user can choose:
- **User Story** — A new capability or enhancement from the user's perspective
- **Bug** — Something is broken and needs fixing
- **Spike** — A research task to reduce uncertainty before implementation

### Gate checklist — all required before proceeding to Step 2

- [ ] Issue type — explicit choice from the user
- [ ] Target repository — explicit `owner/repo` from the user
- [ ] GitHub Project number — explicit answer from the user (a number, or "none")
- [ ] Depth — explicit choice from the user

If any value is missing, ask again. Do not infer, assume, default, or skip any of these inputs under any circumstance.

**Type-to-metadata mapping** — once the type is confirmed, load the corresponding template from `assets/template-*.md`. Parse its YAML frontmatter to obtain the default `labels` and `type`. Apply them automatically.

## Step 2 — Content

### Guided mode

Load the appropriate template from `assets/`:

| Type | Template |
|------|----------|
| User Story | [assets/template-user-story.md](../assets/template-user-story.md) |
| Bug | [assets/template-bug.md](../assets/template-bug.md) |
| Spike | [assets/template-spike.md](../assets/template-spike.md) |

Walk through the template sections, **grouping related sections** rather than asking one at a time. For each group:

1. Explain briefly what the sections capture and why they matter
2. Ask the user to provide the content for all sections in the group
3. If the user says "skip" for a section, move on — but keep the section header in the body with the placeholder `_TBD_`
4. Help the user articulate their answers in clear, concise language. Rewrite or suggest improvements if their input is vague

### Quick mode

Collect just:
- **Title**: A clear, concise title for the issue
- **Description**: 1-3 sentences describing what needs to happen

The skill fills in the frontmatter (type, labels) automatically based on the issue type established in Step 1.

### Preserving uncovered sections

Every section defined in the template must appear in the final issue body, even if the user didn't provide content for it. For any section not covered — whether skipped in guided mode or omitted in quick mode — keep the section header and fill it with `_TBD_`. This ensures the issue retains its full structure and makes it obvious which parts still need attention.

## Step 3 — Preview, Metadata & Confirmation

Present a **preview** of the complete issue and, in the **same message**, ask the user to confirm or adjust the remaining metadata fields. Show each field with its current default so the user can approve everything at once or override what they need:

| Field | Default | Note |
|-------|---------|------|
| **Title** | From content phase | Confirm the final title |
| **Labels** | From type mapping (e.g., `kind/story`) | Any additional labels? |
| **Type** | From type mapping (e.g., `User Story`) | Already set |
| **Assignees** | None | Assign to someone? |
| **Milestone** | None | Link to a milestone? |
| **Project fields** | None | Only if a GitHub Project was specified — ask about fields like status, priority, sprint, size |

The user should be able to reply once with all their adjustments (or just "looks good") and move straight to creation.

## Step 4 — Create the Issue on GitHub

### 4a. Create the Issue — gh CLI via script (Preferred)

Run the bundled script [`scripts/gh-issue.sh`](../scripts/gh-issue.sh):

```bash
scripts/gh-issue.sh create \
  --repo "{target_repo}" \
  --title "{title}" \
  --body "{body}" \
  --label "{label1}" --label "{label2}" \
  --assignee "{assignee}" \
  --type "{type}"
```

Capture the **issue URL** from stdout. On exit 127, skip to **4b**.

The script handles `--type` failure gracefully — it retries without it and logs a note to stderr.

### 4b. Create the Issue — GitHub MCP (Fallback)

Look among your available MCP tools for a tool that creates issues in a GitHub repository. Common tool names include `create_issue` or similar. Use it with:

- **owner** and **repo**: parsed from `{target_repo}` (split on `/`)
- **title**: the confirmed title
- **body**: the composed markdown body
- **labels**: as an array
- **type**: e.g., `User Story`, `Bug`, `Spike`
- **assignees**: as an array (omit if empty)

After creation, capture the **issue number**, **issue URL**, and **node ID** (needed for project integration).

If setting the type fails (the repo may not have issue types enabled), log a note but don't treat it as an error.

## Step 5 — Add to GitHub Project (Optional)

If no project number was specified, skip to Step 6.

### 5a. Add the issue to the project — gh CLI via script (Preferred)

```bash
scripts/gh-project.sh add-item \
  --owner "{owner}" \
  --project-number {project_number} \
  --issue-url "{issue_url}"
```

Capture the **project item ID** from stdout JSON. On exit 127, skip to **5b**.

### 5b. Add the issue to the project — GitHub MCP (Fallback)

Look for an MCP tool that adds an issue to a project.

Capture the **project item ID** from the response — it's needed to set field values.

### 5c. Set project fields

If the user specified project field values (e.g., Status, Priority, Sprint, Size), set each field on the project item. Project fields are properties that exist within the project board — they are separate from the issue's own metadata.

#### Via gh CLI script (Preferred):

```bash
# First, list the project fields to get their IDs
scripts/gh-project.sh list-fields \
  --owner "{owner}" \
  --project-number {project_number}

# Then, for each field, set the value
scripts/gh-project.sh set-field \
  --project-id "{project_id}" \
  --item-id "{item_id}" \
  --field-id "{field_id}" \
  --value "{value}" \
  --field-type "single-select"
```

Supported `--field-type` values: `text`, `number`, `single-select`, `date`, `iteration`.

On exit 127, fall back to MCP below.

#### Via MCP (Fallback):

Look for an MCP tool that updates project item fields (often requires the project item ID and field ID).

Field types vary — match the correct value format to the field type. If a field or value doesn't exist in the project, log a note but don't treat it as an error.

## Step 6 — Report Result

Report to the user:
```
Issue created: #<number> — <title>
<url>
```

If the issue was added to a project:
```
Added to Project #<project_number>
```

---

## Publish Path (File-based Issue Creation)

Use this path when the caller provides a **file path** to a markdown file that contains a fully-written issue. The file follows the same format as the templates under `assets/` — YAML frontmatter with metadata, followed by the issue body.

### Input

| Field | Description |
|-------|-------------|
| `file_path` | Path to a markdown file containing the issue (frontmatter + body) |
| `target_repo` | Target repository in `owner/repo` format |

Optional overrides (take precedence over frontmatter values):

| Field | Description |
|-------|-------------|
| `project_number` | GitHub Project number to add the issue to |
| `project_fields` | Map of field name → value for the project item |

### Workflow

1. **Read the file** at `file_path`.

2. **Parse the YAML frontmatter** (between `---` delimiters). Extract these fields:
   - `title` — if present and not a placeholder (e.g., not `<insert_title_here>`)
   - `labels` — default labels for the issue
   - `type` — GitHub Issue Type (`User Story`, `Bug`, `Spike`)
   - `assignees` — GitHub usernames (may be empty)

3. **Extract title from body** — if `title` is missing or is a placeholder in the frontmatter, scan the markdown body for the first `#` heading and use its text as the title.

4. **Compose the issue body** — everything after the closing `---` of the frontmatter is the body. Use it as-is — do NOT modify, reformat, or truncate.

5. **Create** — Execute **Step 4** (create the issue via MCP or gh CLI) with the resolved title, body, labels, type, and assignees.

6. **Project** — If `project_number` is provided, execute **Step 5** (add to project and set fields).

7. **Report** — Execute **Step 6** (report the result).

### Constraints

- Do NOT present a preview or ask for confirmation — the content is already finalized.
- Do NOT modify the body content — pass it through exactly as read from the file.
- Do NOT prompt for missing optional fields — use what's in the frontmatter or omit.
- If creation fails, return the error to the caller rather than entering an interactive recovery loop.
