#!/usr/bin/env bash
set -euo pipefail

# Deterministic repository detection script.
# Usage: detect-repo.sh <repo_path>
# Output: JSON to stdout with stack, AMIGA, build system, tool versions,
#         contracts, and directory structure.
#
# Searches for build files in the repo root first, then one level deep.
# Stops at the first match found.

REPO_PATH="${1:?Usage: detect-repo.sh <repo_path>}"
REPO_PATH="$(cd "$REPO_PATH" && pwd)"
REPO_NAME="$(basename "$REPO_PATH")"

BUILD_FILE_CANDIDATES=(pom.xml build.gradle.kts build.gradle pyproject.toml package.json go.mod Cargo.toml)

# --- Find the first build file (root, then one level deep) ---

find_first_build_file() {
  # Check root first
  for candidate in "${BUILD_FILE_CANDIDATES[@]}"; do
    if [[ -f "$REPO_PATH/$candidate" ]]; then
      echo "$REPO_PATH/$candidate"
      return
    fi
  done

  # Check immediate subdirectories
  for subdir in "$REPO_PATH"/*/; do
    [[ ! -d "$subdir" ]] && continue
    local dirname
    dirname="$(basename "$subdir")"
    [[ "$dirname" == .* || "$dirname" == "node_modules" || "$dirname" == "target" || \
       "$dirname" == "build" || "$dirname" == "dist" || "$dirname" == "__pycache__" || \
       "$dirname" == "vendor" ]] && continue

    for candidate in "${BUILD_FILE_CANDIDATES[@]}"; do
      if [[ -f "$subdir$candidate" ]]; then
        echo "$subdir$candidate"
        return
      fi
    done
  done
}

# --- Classify a build file ---

classify_build_file() {
  local filepath="$1"
  local filename
  filename="$(basename "$filepath")"
  local dirpath
  dirpath="$(dirname "$filepath")"
  local relative_path="${filepath#"$REPO_PATH"/}"
  local stack="unknown"
  local build_system="unknown"
  local amiga="false"

  case "$filename" in
    pom.xml)
      build_system="Maven"
      if grep -q "amiga-framework" "$filepath" 2>/dev/null; then
        stack="AMIGA Java"
        amiga="true"
      else
        stack="generic Java/Maven"
      fi
      ;;
    build.gradle.kts|build.gradle)
      build_system="Gradle"
      stack="Java/Gradle"
      ;;
    pyproject.toml)
      if grep -q "fwk-amigapython" "$filepath" 2>/dev/null; then
        stack="AMIGA Python"
        amiga="true"
        build_system="uv"
      else
        stack="generic Python"
        if grep -q '\[tool\.poetry\]' "$filepath" 2>/dev/null; then
          build_system="poetry"
        elif grep -q '\[tool\.uv\]' "$filepath" 2>/dev/null || [[ -f "$dirpath/uv.lock" ]]; then
          build_system="uv"
        else
          build_system="pip"
        fi
      fi
      ;;
    package.json)
      if grep -q "@amiga-fwk-nodejs" "$filepath" 2>/dev/null; then
        stack="AMIGA Node"
        amiga="true"
      elif grep -q "@amiga-fwk-web" "$filepath" 2>/dev/null; then
        stack="AMIGA Web"
        amiga="true"
      else
        stack="generic Node.js/Web"
      fi
      if [[ -f "$dirpath/pnpm-lock.yaml" ]]; then
        build_system="pnpm"
      elif [[ -f "$dirpath/yarn.lock" ]]; then
        build_system="yarn"
      else
        build_system="npm"
      fi
      ;;
    go.mod)
      build_system="go"
      if grep -q "fwk-amigagolang" "$filepath" 2>/dev/null; then
        stack="AMIGA Go"
        amiga="true"
      else
        stack="generic Go"
      fi
      ;;
    Cargo.toml)
      build_system="cargo"
      if grep -q "amiga" "$filepath" 2>/dev/null; then
        stack="AMIGA Rust"
        amiga="true"
      else
        stack="generic Rust"
      fi
      ;;
  esac

  printf '{"build_file":"%s","stack":"%s","build_system":"%s","amiga":%s}' \
    "$relative_path" "$stack" "$build_system" "$amiga"
}

# --- Tool Versions Detection ---
# Searches repo root AND the directory where the build file was found

detect_tool_versions() {
  local build_dir="${1:-}"
  local tool_versions_file=""

  # Check repo root first
  if [[ -f "$REPO_PATH/.tool-versions" ]]; then
    tool_versions_file="$REPO_PATH/.tool-versions"
  # Then check build file directory (if different from root)
  elif [[ -n "$build_dir" && "$build_dir" != "$REPO_PATH" && -f "$build_dir/.tool-versions" ]]; then
    tool_versions_file="$build_dir/.tool-versions"
  fi

  if [[ -n "$tool_versions_file" ]]; then
    local tools=""
    while IFS= read -r line; do
      [[ -z "$line" || "$line" == \#* ]] && continue
      local tool="${line%% *}"
      local version="${line#* }"
      tools="${tools:+$tools, }\"$tool\": \"$version\""
    done < "$tool_versions_file"
    printf '{%s}' "$tools"
  else
    printf 'null'
  fi
}

# --- Contracts Detection ---
# Searches ALL build files (root + one level deep) for dependency suffixes

detect_contracts() {
  local paradigms=""

  # Collect all build files to scan
  local build_files=()
  for candidate in "${BUILD_FILE_CANDIDATES[@]}"; do
    [[ -f "$REPO_PATH/$candidate" ]] && build_files+=("$REPO_PATH/$candidate")
  done
  for subdir in "$REPO_PATH"/*/; do
    [[ ! -d "$subdir" ]] && continue
    local dirname
    dirname="$(basename "$subdir")"
    [[ "$dirname" == .* || "$dirname" == "node_modules" || "$dirname" == "target" || \
       "$dirname" == "build" || "$dirname" == "dist" || "$dirname" == "__pycache__" || \
       "$dirname" == "vendor" ]] && continue
    for candidate in "${BUILD_FILE_CANDIDATES[@]}"; do
      [[ -f "$subdir$candidate" ]] && build_files+=("$subdir$candidate")
    done
  done

  [[ ${#build_files[@]} -eq 0 ]] && { printf '[]'; return; }

  # Track which paradigms were already detected to avoid duplicates
  local found_rest=false
  local found_grpc=false
  local found_event=false
  local found_graphql=false

  for bf in "${build_files[@]}"; do
    local relative_path="${bf#"$REPO_PATH"/}"

    if [[ "$found_rest" == false ]] && grep -qE "rest-stable|rest-unstable" "$bf" 2>/dev/null; then
      paradigms="${paradigms:+$paradigms, }{\"type\": \"REST API\", \"source\": \"$relative_path\"}"
      found_rest=true
    fi

    if [[ "$found_grpc" == false ]] && grep -qE "grpc-stable|grpc-unstable" "$bf" 2>/dev/null; then
      paradigms="${paradigms:+$paradigms, }{\"type\": \"gRPC API\", \"source\": \"$relative_path\"}"
      found_grpc=true
    fi

    if [[ "$found_event" == false ]] && grep -qE "event-stable|event-unstable" "$bf" 2>/dev/null; then
      paradigms="${paradigms:+$paradigms, }{\"type\": \"Async API\", \"source\": \"$relative_path\"}"
      found_event=true
    fi

    if [[ "$found_graphql" == false ]] && grep -qE "graphql-stable|graphql-unstable" "$bf" 2>/dev/null; then
      paradigms="${paradigms:+$paradigms, }{\"type\": \"GraphQL API\", \"source\": \"$relative_path\"}"
      found_graphql=true
    fi
  done

  printf '[%s]' "$paradigms"
}

# --- Assemble output ---

BUILD_FILE_PATH="$(find_first_build_file)"

if [[ -n "$BUILD_FILE_PATH" ]]; then
  STACK_JSON="$(classify_build_file "$BUILD_FILE_PATH")"
  BUILD_DIR="$(dirname "$BUILD_FILE_PATH")"
else
  STACK_JSON='{"build_file":"","stack":"unknown","build_system":"unknown","amiga":false}'
  BUILD_DIR=""
fi

TOOL_VERSIONS="$(detect_tool_versions "$BUILD_DIR")"
CONTRACTS="$(detect_contracts)"

cat <<EOF
{
  "repo_name": "$REPO_NAME",
  "repo_path": "$REPO_PATH",
  "stack": $STACK_JSON,
  "tool_versions": $TOOL_VERSIONS,
  "contracts": $CONTRACTS
}
EOF
