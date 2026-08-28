---
name: init-workspace-skills
description: 스킬 세트를 다른 위치로 초기화하거나 갱신할 때 원본·대상 검증, 내부 참조 변환 및 복사 후 구조 검증을 수행합니다.
---

# Workspace Skill Initialization

# Must

## Scope
- Apply this skill when initializing or refreshing a workspace skill set.
- Apply this skill to source identification, target identification, copying, reference conversion, and verification.

## Source of Truth
- This document governs initialization scope, copy boundaries, and reference validation.
- skill-create-rule governs individual SKILL.md structure and writing rules.
- markdown-safe-writing governs UTF-8 preservation checks.

## Rules
- Verify source and target roots as single normalized real paths before copying.
- Record the source list, target list, and overwrite list before writing.
- Convert internal skill references to the target frontmatter name value.
- Verify each converted name resolves to exactly one target skill.
- Stop without writing if a source reference has no target mapping.
- Verify name, description, Must, Must NOT, Definition of Done, and Verification after copying.
- Verify every copied text file decodes as UTF-8.

## Error Handling
- Stop and report the failure if a source or target is missing or unreadable.
- Report the failed file and rerun verification after a conversion or UTF-8 failure.
- Stop if overwrite authorization is not confirmed.

# Must NOT

## Scope Violation
- Do not copy to an unverified source or target path.
- Do not convert an internal reference to a nonexistent skill name.
- Do not report partial initialization as complete after a reference validation failure.

## Data Safety
- Do not declare text files valid without UTF-8 verification.
- Do not modify configuration or user files outside the copy scope.

# Flow

1. Verify source, target, and overwrite scope.
2. Prepare the skill inventory and reference map.
3. Validate every mapping.
4. Copy approved files and convert references.
5. Verify structure, references, and UTF-8.
6. Report results and rerun requirements.

# Definition of Done

## Verification
- Source and target paths are normalized and readable.
- Copy scope and overwrites are confirmed.
- Every converted reference matches a target frontmatter name.
- Every target SKILL.md has the required structure.
- Every modified text file decodes as UTF-8.
