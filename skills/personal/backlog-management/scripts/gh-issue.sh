#!/bin/bash
set -euo pipefail

# gh-issue.sh — Create, view, and edit GitHub issues via gh api.
#
# Exit codes:
#   0   — Success (JSON on stdout)
#   1   — Operation failed (error on stderr)
#   127 — Missing dependency (gh, jq)
#
# Usage:
#   gh-issue.sh create --repo OWNER/REPO --title TITLE --body BODY [--label LABEL]... [--type TYPE] [--assignee USER]...
#   gh-issue.sh view   --repo OWNER/REPO --number NUMBER
#   gh-issue.sh edit   --repo OWNER/REPO --number NUMBER [--title TITLE] [--body BODY] [--add-label L]... [--remove-label L]... [--add-assignee U]... [--remove-assignee U]... [--milestone M] [--type TYPE]

# --- dependency checks ---
command -v gh  &>/dev/null || { echo "gh CLI not found in PATH" >&2; exit 127; }
gh auth status &>/dev/null || { echo "gh CLI not authenticated — run 'gh auth login' first" >&2; exit 127; }
command -v jq  &>/dev/null || { echo "jq not found in PATH" >&2; exit 127; }

# --- helpers ---
usage() { sed -n '3,14p' "$0" | sed 's/^# \?//' >&2; exit 1; }
die()   { echo "ERROR: $*" >&2; exit 1; }

split_repo() {
  OWNER="${1%%/*}"; REPO_NAME="${1#*/}"
  if [[ "$OWNER" == "$REPO_NAME" ]]; then
    die "Invalid repo format: $1 (expected owner/repo)"
  fi
}

# Ensure a label exists; create it if missing.
ensure_label() {
  local encoded
  encoded=$(jq -rn --arg l "$1" '$l | @uri')
  gh api "repos/$OWNER/$REPO_NAME/labels/$encoded" --silent > /dev/null 2>&1 \
    || gh api "repos/$OWNER/$REPO_NAME/labels" -X POST -f "name=$1" --silent > /dev/null 2>&1 \
    || echo "Warning: could not ensure label '$1'" >&2
}

# --- subcommand routing ---
[[ $# -lt 1 ]] && usage
SUBCMD="$1"; shift

case "$SUBCMD" in

# =============================================================================
# CREATE — single REST call (POST /repos/{owner}/{repo}/issues)
# =============================================================================
create)
  REPO="" TITLE="" BODY="" TYPE=""
  declare -a LABELS=() ASSIGNEES=()

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --repo)      REPO="$2"; shift 2 ;;
      --title)     TITLE="$2"; shift 2 ;;
      --body)      BODY="$2"; shift 2 ;;
      --label)     LABELS+=("$2"); shift 2 ;;
      --type)      TYPE="$2"; shift 2 ;;
      --assignee)  ASSIGNEES+=("$2"); shift 2 ;;
      *) die "Unknown flag: $1" ;;
    esac
  done

  [[ -z "$REPO" ]]  && die "--repo is required"
  [[ -z "$TITLE" ]] && die "--title is required"
  [[ -z "$BODY" ]]  && die "--body is required"

  split_repo "$REPO"

  for l in "${LABELS[@]+"${LABELS[@]}"}"; do ensure_label "$l"; done

  API_ARGS=(gh api "repos/$OWNER/$REPO_NAME/issues" -X POST
    -f "title=$TITLE" -f "body=$BODY"
  )
  for l in "${LABELS[@]+"${LABELS[@]}"}"; do API_ARGS+=(-f "labels[]=$l"); done
  for a in "${ASSIGNEES[@]+"${ASSIGNEES[@]}"}"; do API_ARGS+=(-f "assignees[]=$a"); done
  [[ -n "$TYPE" ]] && API_ARGS+=(-f "type=$TYPE")

  RESPONSE=$("${API_ARGS[@]}") || die "Failed to create issue"

  echo "$RESPONSE" | jq '{
    number:  .number,
    url:     .html_url,
    node_id: .node_id,
    type:    (.type.name // null),
    labels:  [.labels[].name]
  }'
  ;;

# =============================================================================
# VIEW — single REST call (GET /repos/{owner}/{repo}/issues/{number})
# =============================================================================
view)
  REPO="" NUMBER=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --repo)   REPO="$2"; shift 2 ;;
      --number) NUMBER="$2"; shift 2 ;;
      *) die "Unknown flag: $1" ;;
    esac
  done

  [[ -z "$REPO" ]]   && die "--repo is required"
  [[ -z "$NUMBER" ]] && die "--number is required"

  split_repo "$REPO"

  gh api "repos/$OWNER/$REPO_NAME/issues/$NUMBER" \
  | jq '{
      number:    .number,
      title:     .title,
      body:      .body,
      url:       .html_url,
      state:     .state,
      type:      (.type.name // null),
      labels:    [.labels[].name],
      assignees: [.assignees[].login],
      milestone: (.milestone.title // null)
    }'
  ;;

# =============================================================================
# EDIT — single REST call for core fields; extra calls only for add/remove ops
# =============================================================================
edit)
  REPO="" NUMBER="" TITLE="" BODY="" MILESTONE="" TYPE=""
  declare -a ADD_LABELS=() REMOVE_LABELS=() ADD_ASSIGNEES=() REMOVE_ASSIGNEES=()

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --repo)             REPO="$2"; shift 2 ;;
      --number)           NUMBER="$2"; shift 2 ;;
      --title)            TITLE="$2"; shift 2 ;;
      --body)             BODY="$2"; shift 2 ;;
      --add-label)        ADD_LABELS+=("$2"); shift 2 ;;
      --remove-label)     REMOVE_LABELS+=("$2"); shift 2 ;;
      --add-assignee)     ADD_ASSIGNEES+=("$2"); shift 2 ;;
      --remove-assignee)  REMOVE_ASSIGNEES+=("$2"); shift 2 ;;
      --milestone)        MILESTONE="$2"; shift 2 ;;
      --type)             TYPE="$2"; shift 2 ;;
      *) die "Unknown flag: $1" ;;
    esac
  done

  [[ -z "$REPO" ]]   && die "--repo is required"
  [[ -z "$NUMBER" ]] && die "--number is required"

  split_repo "$REPO"

  # --- Core fields via PATCH (single call) ---
  HAS_PATCH=false
  PATCH_ARGS=(gh api "repos/$OWNER/$REPO_NAME/issues/$NUMBER" -X PATCH)
  [[ -n "$TITLE" ]] && { PATCH_ARGS+=(-f "title=$TITLE"); HAS_PATCH=true; }
  [[ -n "$BODY" ]]  && { PATCH_ARGS+=(-f "body=$BODY");   HAS_PATCH=true; }
  [[ -n "$TYPE" ]]  && { PATCH_ARGS+=(-f "type=$TYPE");    HAS_PATCH=true; }

  if [[ -n "$MILESTONE" ]]; then
    MS_NUMBER=$(gh api "repos/$OWNER/$REPO_NAME/milestones" --paginate \
      --jq ".[] | select(.title == \"$MILESTONE\") | .number" 2>/dev/null || true)
    if [[ -n "$MS_NUMBER" ]]; then
      PATCH_ARGS+=(-F "milestone=$MS_NUMBER"); HAS_PATCH=true
    else
      echo "Warning: milestone '$MILESTONE' not found" >&2
    fi
  fi

  [[ "$HAS_PATCH" == true ]] && { "${PATCH_ARGS[@]}" --silent > /dev/null || die "Failed to update issue"; }

  # --- Labels: add/remove ---
  for l in "${ADD_LABELS[@]+"${ADD_LABELS[@]}"}"; do
    ensure_label "$l"
    gh api "repos/$OWNER/$REPO_NAME/issues/$NUMBER/labels" \
      -X POST -f "labels[]=$l" --silent > /dev/null 2>&1 \
      || echo "Warning: failed to add label '$l'" >&2
  done

  for l in "${REMOVE_LABELS[@]+"${REMOVE_LABELS[@]}"}"; do
    encoded=$(jq -rn --arg l "$l" '$l | @uri')
    gh api "repos/$OWNER/$REPO_NAME/issues/$NUMBER/labels/$encoded" \
      -X DELETE --silent > /dev/null 2>&1 \
      || echo "Warning: failed to remove label '$l'" >&2
  done

  # --- Assignees: add/remove ---
  if [[ ${#ADD_ASSIGNEES[@]} -gt 0 ]]; then
    AA_ARGS=(gh api "repos/$OWNER/$REPO_NAME/issues/$NUMBER/assignees" -X POST)
    for a in "${ADD_ASSIGNEES[@]}"; do AA_ARGS+=(-f "assignees[]=$a"); done
    "${AA_ARGS[@]}" --silent > /dev/null 2>&1 || echo "Warning: failed to add assignees" >&2
  fi

  if [[ ${#REMOVE_ASSIGNEES[@]} -gt 0 ]]; then
    RA_ARGS=(gh api "repos/$OWNER/$REPO_NAME/issues/$NUMBER/assignees" -X DELETE)
    for a in "${REMOVE_ASSIGNEES[@]}"; do RA_ARGS+=(-f "assignees[]=$a"); done
    "${RA_ARGS[@]}" --silent > /dev/null 2>&1 || echo "Warning: failed to remove assignees" >&2
  fi

  echo "https://github.com/$OWNER/$REPO_NAME/issues/$NUMBER"
  ;;

*)
  die "Unknown subcommand: $SUBCMD (expected: create, view, edit)"
  ;;
esac
