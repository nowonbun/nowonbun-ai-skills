# skill-governance-rule 검증 명세

## Target
- 스킬 규칙: ../../claude-skills/skill-governance-rule/SKILL.md
- 테스트 식별자: skill-governance-rule-test.md

## Checks
1. 대상 파일은 UTF-8로 읽을 수 있어야 한다.
2. frontmatter name은 skill-governance-rule과 일치해야 한다.
3. Must, Must NOT, Definition of Done H1이 존재해야 한다.
4. U+FFFD 대체 문자가 없어야 한다.
5. 상대 SKILL.md 참조가 있으면 실제 파일로 확인되어야 한다.

## Verification Command
~~~powershell
$target = Resolve-Path 'D:/work/nowonbun-ai-skills/claude-skills/skill-governance-rule/SKILL.md'
$test = Resolve-Path 'D:/work/nowonbun-ai-skills/tests/claude/skill-governance-rule-test.md'
$text = Get-Content -LiteralPath $target -Raw -Encoding UTF8
$text.Length -gt 0 -and $text -match 'name:\s*skill-governance-rule' -and $text -match '# Must' -and $text -match '# Must NOT' -and $text -match '# Definition of Done' -and -not $text.Contains([char]0xFFFD) -and (Get-Content -LiteralPath $test -Raw -Encoding UTF8).Length -gt 0
~~~

## Expected Evidence
- 대상과 검증 문서는 UTF-8로 읽힌다.
- identity와 필수 구조를 실행 로그로 확인할 수 있다.
