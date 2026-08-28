# skill-check-rule 검증 명세

## Target
- 스킬 규칙: ../../claude-skills/skill-check-rule/SKILL.md
- 테스트 식별자: skill-check-rule-test.md

## Checks
1. 대상 파일은 UTF-8로 읽을 수 있어야 한다.
2. frontmatter name은 skill-check-rule과 일치해야 한다.
3. Must, Must NOT, Definition of Done H1이 존재해야 한다.
4. U+FFFD 대체 문자가 없어야 한다.
5. 상대 SKILL.md 참조가 있으면 실제 파일로 확인되어야 한다.
6. 루트 저장소 지도와 수동 검토 프로필이 검사 범위에 포함되어야 한다.
7. `.claude/worktrees` 복제본이 활성 검사 대상에서 제외되어야 한다.

## Verification Command
~~~powershell
$target = Resolve-Path 'D:/work/nowonbun-ai-skills/claude-skills/skill-check-rule/SKILL.md'
$readme = Resolve-Path 'D:/work/nowonbun-ai-skills/README.md'
$manualReview = Resolve-Path 'D:/work/nowonbun-ai-skills/CLAUDE.md'
$test = Resolve-Path 'D:/work/nowonbun-ai-skills/tests/claude/skill-check-rule-test.md'
$text = Get-Content -LiteralPath $target -Raw -Encoding UTF8
$text.Length -gt 0 -and $text -match 'name:\s*skill-check-rule' -and $text.Contains('global_instructions.md') -and $text.Contains('README.md') -and $text.Contains('.claude/worktrees') -and (Get-Content -LiteralPath $readme -Raw -Encoding UTF8).Contains('CLAUDE.md') -and (Get-Content -LiteralPath $manualReview -Raw -Encoding UTF8).Contains('수동 검토 프로필') -and $text -match '# Must' -and $text -match '# Must NOT' -and $text -match '# Definition of Done' -and -not $text.Contains([char]0xFFFD) -and (Get-Content -LiteralPath $test -Raw -Encoding UTF8).Length -gt 0
~~~

## Expected Evidence
- 대상과 검증 문서는 UTF-8로 읽힌다.
- identity와 필수 구조를 실행 로그로 확인할 수 있다.
- 루트 저장소 지도, 수동 검토 프로필 및 worktree 제외 규칙이 확인된다.
