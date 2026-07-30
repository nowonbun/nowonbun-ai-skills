# md-file-tdd-rule TDD Test Specification

## Target
- 스킬 규칙: ../../codex-skills/runtime-management_md-file-tdd-rule/SKILL.md
- 테스트 식별자: md-file-tdd-rule-test.md

## Preconditions
- 대상 파일과 이 테스트 파일은 UTF-8로 읽혀야 합니다.
- 대상 frontmatter의 name은 `md-file-tdd-rule`이어야 합니다.

## Test Cases
1. Given Markdown 또는 텍스트 문서 변경을 설계한다. When 변경 계약을 작성한다. Then 대상 독자, 사실 출처, 필수 구조·링크·용어 및 호환성 제약을 식별한다.
2. Given 문서 계약이 존재한다. When 테스트 사례를 설계한다. Then 성공 기준, 실패 또는 중지 조건, 검증 방법 및 예상 증거를 연결한다.
3. Given 링크·앵커·상대 경로를 변경한다. When 검증을 실행한다. Then 변경 전후 해석 대상과 끊어진 참조를 검사한다.
4. Given 한국어 문서를 수정한다. When 저장 후 검증한다. Then UTF-8 디코딩, 비정상적인 `?` 반복 및 대표 한국어 문장 보존을 확인한다.
5. Given 문서 계약 검증이 실패한다. When 병합 또는 배포를 판정한다. Then 변경을 격리하고 되돌리기 또는 재발 검증이 완료될 때까지 중지한다.
6. Given 동일 원인의 회귀가 두 번 발생한다. When 운영 개선을 결정한다. Then 자동 또는 정적 검증을 추가하는 개선 항목을 생성한다.

## Verification Command
~~~powershell
$target = Resolve-Path 'D:/work/nowonbun-ai-skills/codex-skills/runtime-management_md-file-tdd-rule/SKILL.md'
$test = Resolve-Path 'D:/work/nowonbun-ai-skills/tests/codex/md-file-tdd-rule-test.md'
$targetText = [Text.UTF8Encoding]::new($false, $true).GetString([IO.File]::ReadAllBytes($target))
$testText = [Text.UTF8Encoding]::new($false, $true).GetString([IO.File]::ReadAllBytes($test))
@('name: md-file-tdd-rule', '문서 계약', 'UTF-8 디코딩', '동일 원인의 회귀가 두 번 발생', '분기별 검토에서') | ForEach-Object { if (-not $targetText.Contains($_)) { throw "Missing target rule: $_" } }
if (-not $testText.Contains('md-file-tdd-rule-test.md')) { throw 'Missing test identifier' }
if ($targetText -match '\?{3,}' -or $testText -match '\?{3,}') { throw 'Possible text corruption' }
'PASS: md-file-tdd-rule specification is readable and covers required contracts.'
~~~

## Expected Evidence
- 대상과 테스트 파일이 UTF-8로 읽힙니다.
- 문서 계약, 링크·참조, UTF-8, 회귀 격리 및 성장 규칙을 확인하는 사례가 존재합니다.
- 검증 실패 시 중지·격리·재발 검증 조건을 확인할 수 있습니다.
