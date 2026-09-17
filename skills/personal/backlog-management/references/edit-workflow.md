# Issue Editing Workflow

End-to-end workflow for modifying an existing GitHub issue — any combination of title, body, labels, assignees, milestone, issue type, and project fields.

## Tool Convention

All steps use **gh CLI scripts first**. If a script exits with code **127** (gh not installed), fall back to the MCP alternative in the same step. Other exit codes: **0** = success (parse stdout), **1** = error (show stderr to user).

## Step 1 — Identify the Issue

Collect the target in a **single round**:

1. **Target repository**: `owner/repo` (may already be clear from context)
2. **Issue number**: The `#number` of the issue to edit

If the user's message already contains this information (e.g., "edit issue #42 in org/repo"), extract it directly without asking.

## Step 2 — Fetch Current State

Retrieve the issue to confirm it exists and capture the current values of any fields that will change (needed for the diff preview in Step 3).

### 2a. Fetch issue properties — gh CLI via script (Preferred)

```bash
scripts/gh-issue.sh view --repo "{target_repo}" --number {issue_number}
```

stdout is JSON with title, body, labels, assignees, milestone, issueType. On exit 127, use MCP fallback below.

**2a fallback (MCP):** Look for an MCP tool that fetches a single issue by number (e.g., `get_issue`). Request its title, body, labels, assignees, milestone, and type.

### 2b. Fetch project field values (if applicable)

If the changes involve project fields, also fetch the current project field values.

#### Via gh CLI script (Preferred):

```bash
scripts/gh-project.sh list-fields --owner "{owner}" --project-number {project_number}
```

On exit 127, fall back to MCP below.

#### Via MCP (Fallback):

1. List the project's fields to get their IDs and names.
2. List the project items, **passing the field IDs from step 1** so the response includes field values. Without field IDs, most project tools only return titles.
3. Match the issue in the response and extract its current field values.

Save the **item ID** and **field IDs** — they are reused in Step 4c if project fields need updating.

### 2c. Determine what to change

How much interaction is needed depends on what the user already told you:

- **User already specified the changes** (e.g., "move #11 to sprint 2", "change priority to P0 on #7") — Skip presenting the full state. You already know what to change, and the fetched data gives you the current values for the diff. Go straight to Step 3.

- **User is vague or open-ended** (e.g., "I need to update issue #42", "edit the backlog item for auth") — Present a summary of the current state so they can decide what to change:
  - **Title**, **Body** (condensed), **Labels**, **Assignees**, **Milestone**, **Type**
  - **Project fields** (if linked to a project)

  Then ask what they'd like to modify.

## Step 3 — Preview & Confirmation

Present a summary of **only the changes** that will be applied, showing `current value → new value` for each field. Ask the user to confirm or adjust before applying.

This is the user's last chance to review, so make it easy to scan. Don't re-display unchanged fields — focus attention on what's actually changing.

## Step 4 — Apply Changes

### 4a. Apply issue property changes — gh CLI via script (Preferred)

```bash
scripts/gh-issue.sh edit --repo "{target_repo}" --number {issue_number} \
  --title "{new_title}" \
  --body "{new_body}" \
  --add-label "{label}" --remove-label "{label}" \
  --add-assignee "{user}" --remove-assignee "{user}" \
  --milestone "{milestone}" \
  --type "{new_type}"
```

Include only the flags for fields that changed. The script supports granular add/remove for labels and assignees.

On exit 127, skip to **4b**. The script handles `--type` failure gracefully — it retries without it and logs a note to stderr.

### 4b. Apply issue property changes — GitHub MCP (Fallback)

Look for an MCP tool that updates an issue (e.g., `update_issue`). Pass only the fields that changed — don't resend unchanged fields.

Typical parameters:
- **owner** and **repo**: parsed from `{target_repo}`
- **issue_number**: the issue number
- Plus whichever fields changed: `title`, `body`, `labels`, `assignees`, `milestone`, `type`

For **labels** and **assignees**, respect whether the user wants to *add*, *remove*, or *replace* the current set. If the MCP tool only supports a full replacement, compute the resulting set yourself (current + additions − removals) before calling.

### 4c. Update project fields (Optional)

If any project field changes were requested, update them on the project item.

#### Via gh CLI script (Preferred):

```bash
# List fields to get their IDs (if not already available from Step 2b)
scripts/gh-project.sh list-fields --owner "{owner}" --project-number {project_number}

# For each changed field, set the value
scripts/gh-project.sh set-field \
  --project-id "{project_id}" \
  --item-id "{item_id}" \
  --field-id "{field_id}" \
  --value "{value}" \
  --field-type "single-select"
```

Supported `--field-type` values: `text`, `number`, `single-select`, `date`, `iteration`.

On exit 127, fall back to MCP below. If a field or value doesn't exist in the project, log a note but don't treat it as an error.

#### Via MCP (Fallback):

Look for an MCP tool that updates project item fields. For each changed field, pass the `item_id` and `field_id` along with the new value. Match the value format to the field type — text, number, single-select option ID, date (YYYY-MM-DD), or iteration ID.

If a field or value doesn't exist in the project, log a note but don't treat it as an error.

## Step 5 — Report Result

Report to the user:

```
Issue updated: #<number> — <title>
<url>

Changes applied:
- <field>: <old value> → <new value>
- ...
```

If project fields were updated:
```
Project fields updated: Status → {value}, Priority → {value}, ...
```
