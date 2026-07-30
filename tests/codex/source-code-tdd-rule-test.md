# source-code-tdd-rule TDD Test Specification

## Target
- 스킬 규칙: ../../codex-skills/runtime-management_source-code-tdd-rule/SKILL.md
- 테스트 식별자: source-code-tdd-rule-test.md

## Preconditions
- 대상 파일과 이 테스트 파일은 UTF-8로 읽혀야 합니다.
- 대상 frontmatter의 name은 `source-code-tdd-rule`이어야 합니다.

## Test Cases
1. Given 소스 코드 변경을 설계한다. When 변경 계약을 작성한다. Then 입력, 출력, 오류, 상태 전이, 호환성 및 자원 예산을 식별한다.
2. Given 코드 계약이 존재한다. When 구현을 시작한다. Then 정상·경계·오류·이전 동작 보존을 포함하는 실패 테스트와 승인 기준이 먼저 존재한다.
3. Given 시간·난수·네트워크·파일 시스템 의존성이 있다. When 테스트를 작성한다. Then 의존성을 제어 가능한 대역으로 분리하여 결정성을 확보한다.
4. Given 모듈 경계를 넘는 변경이 있다. When 영향 검증을 선택한다. Then 소비자 관점 계약 테스트 또는 동등한 통합 검증을 포함한다.
5. Given 테스트 실패·불안정 또는 성능 예산 초과가 발생한다. When 병합 또는 배포를 판정한다. Then 재현 입력·환경·로그를 보존하고 수정 또는 되돌리기 전까지 중지한다.
6. Given 같은 회귀 원인이 두 번 발생한다. When 품질 제어를 강화한다. Then 해당 경계의 회귀 테스트와 예방 제어를 추가한다.
7. Given 테스트 실행 시간이 정의된 예산을 넘는다. When 개선 계획을 수립한다. Then 병렬화, 격리 또는 계층 분리 중 하나와 승인 기준을 기록한다.

## Verification Command
~~~powershell
$target = Resolve-Path 'D:/work/nowonbun-ai-skills/codex-skills/runtime-management_source-code-tdd-rule/SKILL.md'
$test = Resolve-Path 'D:/work/nowonbun-ai-skills/tests/codex/source-code-tdd-rule-test.md'
$targetText = [Text.UTF8Encoding]::new($false, $true).GetString([IO.File]::ReadAllBytes($target))
$testText = [Text.UTF8Encoding]::new($false, $true).GetString([IO.File]::ReadAllBytes($test))
@('name: source-code-tdd-rule', '먼저 실패하는 테스트', '결정적으로', '같은 회귀 원인이 두 번 발생', '테스트 실행 시간이 정의된 예산') | ForEach-Object { if (-not $targetText.Contains($_)) { throw "Missing target rule: $_" } }
if (-not $testText.Contains('source-code-tdd-rule-test.md')) { throw 'Missing test identifier' }
if ($targetText -match '\?{3,}' -or $testText -match '\?{3,}') { throw 'Possible text corruption' }
'PASS: source-code-tdd-rule specification is readable and covers required contracts.'
~~~

## Expected Evidence
- 대상과 테스트 파일이 UTF-8로 읽힙니다.
- 코드 계약, 실패 테스트, 결정성, 계층 검증, 회귀 및 성장 규칙을 확인하는 사례가 존재합니다.
- 실패·불안정·예산 초과 시 중지와 재현 증거 보존 조건을 확인할 수 있습니다.
