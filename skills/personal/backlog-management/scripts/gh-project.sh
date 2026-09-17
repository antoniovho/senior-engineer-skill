#!/bin/bash
set -euo pipefail

# gh-project.sh — Add issues to GitHub Projects and manage project fields via gh CLI.
#
# Exit codes:
#   0   — Success (result on stdout)
#   1   — Operation failed (error on stderr)
#   127 — gh CLI not available
#
# Usage:
#   gh-project.sh add-item     --owner OWNER --project-number NUM --issue-url URL
#   gh-project.sh list-fields  --owner OWNER --project-number NUM
#   gh-project.sh set-field    --project-id ID --item-id ID --field-id ID --value VALUE --field-type TYPE
#
# Field types for set-field: text, number, single-select, date, iteration

# --- gh availability check ---
if ! command -v gh &>/dev/null; then
  echo "gh CLI not found in PATH" >&2
  exit 127
fi

if ! gh auth status &>/dev/null; then
  echo "gh CLI not authenticated — run 'gh auth login' first" >&2
  exit 127
fi

# --- Helpers ---
usage() {
  sed -n '3,16p' "$0" | sed 's/^# \?//' >&2
  exit 1
}

die() { echo "ERROR: $*" >&2; exit 1; }

# --- Subcommand routing ---
[[ $# -lt 1 ]] && usage
SUBCMD="$1"; shift

case "$SUBCMD" in

# =============================================================================
# ADD-ITEM
# =============================================================================
add-item)
  OWNER="" PROJECT_NUMBER="" ISSUE_URL=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --owner)          OWNER="$2"; shift 2 ;;
      --project-number) PROJECT_NUMBER="$2"; shift 2 ;;
      --issue-url)      ISSUE_URL="$2"; shift 2 ;;
      *) die "Unknown flag: $1" ;;
    esac
  done

  [[ -z "$OWNER" ]]          && die "--owner is required"
  [[ -z "$PROJECT_NUMBER" ]] && die "--project-number is required"
  [[ -z "$ISSUE_URL" ]]      && die "--issue-url is required"

  gh project item-add "$PROJECT_NUMBER" --owner "$OWNER" --url "$ISSUE_URL" --format json
  ;;

# =============================================================================
# LIST-FIELDS
# =============================================================================
list-fields)
  OWNER="" PROJECT_NUMBER=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --owner)          OWNER="$2"; shift 2 ;;
      --project-number) PROJECT_NUMBER="$2"; shift 2 ;;
      *) die "Unknown flag: $1" ;;
    esac
  done

  [[ -z "$OWNER" ]]          && die "--owner is required"
  [[ -z "$PROJECT_NUMBER" ]] && die "--project-number is required"

  gh project field-list "$PROJECT_NUMBER" --owner "$OWNER" --format json
  ;;

# =============================================================================
# SET-FIELD
# =============================================================================
set-field)
  PROJECT_ID="" ITEM_ID="" FIELD_ID="" VALUE="" FIELD_TYPE=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --project-id) PROJECT_ID="$2"; shift 2 ;;
      --item-id)    ITEM_ID="$2"; shift 2 ;;
      --field-id)   FIELD_ID="$2"; shift 2 ;;
      --value)      VALUE="$2"; shift 2 ;;
      --field-type) FIELD_TYPE="$2"; shift 2 ;;
      *) die "Unknown flag: $1" ;;
    esac
  done

  [[ -z "$PROJECT_ID" ]] && die "--project-id is required"
  [[ -z "$ITEM_ID" ]]    && die "--item-id is required"
  [[ -z "$FIELD_ID" ]]   && die "--field-id is required"
  [[ -z "$VALUE" ]]      && die "--value is required"
  [[ -z "$FIELD_TYPE" ]] && die "--field-type is required"

  CMD=(gh project item-edit --project-id "$PROJECT_ID" --id "$ITEM_ID" --field-id "$FIELD_ID")

  case "$FIELD_TYPE" in
    text)          CMD+=(--text "$VALUE") ;;
    number)        CMD+=(--number "$VALUE") ;;
    single-select) CMD+=(--single-select-option-id "$VALUE") ;;
    date)          CMD+=(--date "$VALUE") ;;
    iteration)     CMD+=(--iteration-id "$VALUE") ;;
    *) die "Unknown field type: $FIELD_TYPE (expected: text, number, single-select, date, iteration)" ;;
  esac

  "${CMD[@]}"
  ;;

*)
  die "Unknown subcommand: $SUBCMD (expected: add-item, list-fields, set-field)"
  ;;
esac
