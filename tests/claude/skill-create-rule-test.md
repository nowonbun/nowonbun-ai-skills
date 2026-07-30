# skill-create-rule TDD Test Specification

## Target
- 스킬 규칙: ../claude-skills/skill-create-rule/SKILL.md

## Test Cases
1. Given 실행 작업. When TDD를 적용. Then 설계 → 테스트 사례 설계 → 계획 검토 → 실행 → 결과 검토 → 결과 보고순서를 지킨다.
2. Given 테스트 사례. When 실행 시작. Then 성공 기준과 중지 조건이 문서화된다.
3. Given 검토 요청. When Claude 교차 검토가 명시됐다. Then 전용 런타임을 사용한다.
4. Given 결과. When 검토. Then 실행 로그 또는 파일 증거를 기록한다.
5. Given 본문에는 `# Must`, `# Must NOT`, and `# Definition of Done`이 반드시 포함되어야 합니다. When 조건이 충족된다. Then 해당 행동을 위반하지 않는다.

## Verification Command
~~~powershell
$target = Resolve-Path 'D:/work/nowonbun-ai-skills/claude-skills/skill-create-rule/SKILL.md'
$test = Resolve-Path 'D:/work/nowonbun-ai-skills/tests/claude/skill-create-rule-test.md'
(Get-Content $target -Raw -Encoding UTF8).Length -gt 0 -and (Get-Content $test -Raw -Encoding UTF8) -match [regex]::Escape('skill-create-rule')
~~~
