# stock-mcp TDD Test Specification

## Target
- 스킬 규칙: ../codex-skills/tool-usage-management_stock-mcp/SKILL.md
- 테스트 식별자: stock-mcp-test.md

## Preconditions
- 대상 파일이 존재하고 UTF-8로 읽힌다.
- stock-mcp은 대상 SKILL.md의 frontmatter name과 일치한다.

## Test Cases
1. Given 실행 작업의 설계가 필요하다. When 공유 TDD 실행 순서를 적용한다. Then 순서는 설계 → 테스트 사례 설계 → 계획 검토 → 실행 → 결과 검토 → 결과 보고이다.
2. Given 테스트 사례를 설계한다. When 실행 시작 조건을 판정한다. Then 테스트 사례는 성공 기준, 실패 또는 중지 조건, 검증 방법을 포함한다.
3. Given 계획 검토나 결과 검토가 요청되었다. When Claude 교차 검토가 명시적으로 요청되었다. Then claude-review-runtime과 claude-cross-review-protocol을 적용한다.
4. Given 실행이 완료되었다. When 결과 검토를 수행한다. Then 검증 결과는 실행 로그 또는 파일 검사 증거로 기록한다.

5. Given `market`과 `as_of` 매개변수 없이 `predict_rows`를 호출해서는 안 됩니다. When 해당 규칙의 적용 조건이 충족된다. Then 대상 스킬은 해당 행동을 위반하지 않는다.

## Verification Command
~~~powershell
$target = Resolve-Path 'D:/work/nowonbun-ai-skills/codex-skills/tool-usage-management_stock-mcp/SKILL.md'
$test = Resolve-Path 'D:/work/nowonbun-ai-skills/tests/stock-mcp-test.md'
(Get-Content $target -Raw -Encoding UTF8).Length -gt 0 -and (Get-Content $test -Raw -Encoding UTF8) -match [regex]::Escape('stock-mcp')
~~~

## Expected Evidence
- 스킬 및 테스트 파일은 UTF-8로 읽힌다.
- 대상 경로, 테스트 식별자, TDD 게이트, 검증 명령이 존재한다.
