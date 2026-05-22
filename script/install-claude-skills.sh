#!/usr/bin/env bash

set -euo pipefail

# ===== Configuration =====
# - SOURCE_ROOT: repository root path
#   example) D:/work/nowonbun-harness
# - SKILL_SOURCE_DIR: skill source folder relative to SOURCE_ROOT (default: claude-skills)
#   example) claude-skills
# - Every .md file under nested folders is treated as a skill.
#   example) claude-skills/test1/test2/abc.md
#     -> .claude/skills/test1_test2_abc/SKILL.md
# - TARGET_DIR: parent root of the .claude directory
#   example) /Users/nowonbun

TARGET_DIR="${TARGET_DIR:-$HOME}"
SOURCE_ROOT="${SOURCE_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
SKILL_SOURCE_DIR="${SKILL_SOURCE_DIR:-claude-skills}"

if [[ "$SKILL_SOURCE_DIR" = /* ]] || [[ "$SKILL_SOURCE_DIR" =~ ^[A-Za-z]:[\\/].* ]]; then
    SKILL_SOURCE_ROOT="$SKILL_SOURCE_DIR"
else
    SKILL_SOURCE_ROOT="$SOURCE_ROOT/$SKILL_SOURCE_DIR"
fi

CLAUDE_ROOT="$TARGET_DIR/.claude"
SKILLS_ROOT="$CLAUDE_ROOT/skills"
MANIFEST_PATH="$CLAUDE_ROOT/install-claude-skills.manifest.txt"

test_skill_sheet() {
    local file_path="$1"

    awk '
        BEGIN { in_frontmatter=0; first_delim=0; has_name=0; has_desc=0 }
        NR == 1 && $0 ~ /^---[[:space:]]*$/ { in_frontmatter=1; first_delim=1; next }
        in_frontmatter && $0 ~ /^---[[:space:]]*$/ {
            exit(first_delim && has_name && has_desc ? 0 : 1)
        }
        in_frontmatter && $0 ~ /^[[:space:]]*name[[:space:]]*:/ { has_name=1 }
        in_frontmatter && $0 ~ /^[[:space:]]*description[[:space:]]*:/ { has_desc=1 }
        END {
            if (!(first_delim && has_name && has_desc)) {
                exit 1
            }
        }
    ' "$file_path"
}

normalize_skill_name() {
    local relative_path="$1"
    local normalized_input="$relative_path"
    local normalized

    if [[ "$(basename "$relative_path")" == 'SKILL.md' ]]; then
        normalized_input="$(dirname "$relative_path")"
    else
        normalized_input="${relative_path%.md}"
    fi

    normalized="$(printf '%s' "$normalized_input" | sed -E 's#[/\\]+#_#g; s#[[:space:]]+#_#g; s#^[_\.]+##; s#[_\.]+$##')"

    if [[ -z "$normalized" ]]; then
        echo "Cannot convert path to skill name. relativePath=$relative_path" >&2
        exit 1
    fi

    printf '%s\n' "$normalized"
}

load_previous_skill_names() {
    if [[ ! -f "$MANIFEST_PATH" ]]; then
        return 0
    fi

    sed '/^[[:space:]]*$/d' "$MANIFEST_PATH"
}

save_current_skill_names() {
    local tmp_manifest
    tmp_manifest="$(mktemp)"

    if ((${#SKILL_NAMES[@]} > 0)); then
        printf '%s\n' "${SKILL_NAMES[@]}" | sort -u > "$tmp_manifest"
    fi

    mkdir -p "$CLAUDE_ROOT"
    cp "$tmp_manifest" "$MANIFEST_PATH"
    rm -f "$tmp_manifest"
}

remove_stale_skill_dirs() {
    local -A current_skill_set=()
    local old_name stale_dir

    for old_name in "${SKILL_NAMES[@]}"; do
        current_skill_set["$old_name"]=1
    done

    while IFS= read -r old_name; do
        [[ -z "$old_name" ]] && continue
        if [[ -n "${current_skill_set[$old_name]:-}" ]]; then
            continue
        fi

        stale_dir="$SKILLS_ROOT/$old_name"
        if [[ -d "$stale_dir" ]]; then
            rm -rf "$stale_dir"
            echo "[DEL ] Removed previously managed skill: $stale_dir"
        fi
    done < <(load_previous_skill_names)
}

if [[ ! -d "$SKILL_SOURCE_ROOT" ]]; then
    echo "Skill source root not found. expected=$SKILL_SOURCE_ROOT" >&2
    exit 1
fi

mkdir -p "$SKILLS_ROOT"

declare -a SKILL_FILES=()
declare -a SKILL_NAMES=()
declare -A SKILL_NAME_SEEN=()

while IFS= read -r file_path; do
    if ! test_skill_sheet "$file_path"; then
        continue
    fi

    relative_path="${file_path#"$SKILL_SOURCE_ROOT"/}"
    skill_name="$(normalize_skill_name "$relative_path")"

    if [[ -n "${SKILL_NAME_SEEN[$skill_name]:-}" ]]; then
        echo "Duplicate skill name detected. $skill_name" >&2
        echo "- ${SKILL_NAME_SEEN[$skill_name]}" >&2
        echo "- $relative_path" >&2
        exit 1
    fi

    SKILL_NAME_SEEN["$skill_name"]="$relative_path"
    SKILL_FILES+=("$file_path")
    SKILL_NAMES+=("$skill_name")
done < <(find "$SKILL_SOURCE_ROOT" -type f -name '*.md' | sort)

if ((${#SKILL_FILES[@]} == 0)); then
    echo "No skill sheet with metadata (name, description) found. skillSourceRoot=$SKILL_SOURCE_ROOT" >&2
    exit 1
fi

remove_stale_skill_dirs

for i in "${!SKILL_FILES[@]}"; do
    file_path="${SKILL_FILES[$i]}"
    skill_name="${SKILL_NAMES[$i]}"
    relative_path="${file_path#"$SKILL_SOURCE_ROOT"/}"
    skill_dir="$SKILLS_ROOT/$skill_name"
    skill_target_path="$skill_dir/SKILL.md"

    mkdir -p "$skill_dir"
    cp "$file_path" "$skill_target_path"
    echo "[COPY] ${relative_path} -> ${skill_target_path}"
done

save_current_skill_names

echo
echo "Done:"
echo "- sourceRoot     : $SOURCE_ROOT"
echo "- skillSourceRoot: $SKILL_SOURCE_ROOT"
echo "- targetDir      : $TARGET_DIR"
echo "- skillsRoot     : $SKILLS_ROOT"
