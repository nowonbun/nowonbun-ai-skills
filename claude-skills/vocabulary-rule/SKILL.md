---
name: vocabulary-rule
description: 규칙 문서의 용어가 실행 결정을 바꿀 만큼 모호하거나 충돌할 때 표준 의미를 확인합니다.
---

# Vocabulary Rule

# Must

## Scope
- 이 스킬은 구성·스킬 규칙을 작성하거나 검토할 때, 또는 용어 해석이 실행·중지·승인 결정을 바꿀 때 적용해야 합니다.
- 일반적인 코드 작성, 파일 조회, 설명 또는 보고에는 자동으로 적용해서는 안 됩니다.

## Registry
- 활성 용어 정의는 저장소 루트 기준 상대 경로 `codex-skills/vocabulary-management/vocabulary-registry.md`에서 관리해야 합니다.
- 레지스트리 항목은 용어, 범주, 표준 의미, 결정 규칙, 허용 값, 금지된 해석 및 증거 출처를 포함해야 합니다.
- 같은 용어를 여러 문서에서 다른 의미로 사용할 경우 레지스트리 정의를 우선하고 충돌을 보고해야 합니다.

## Strength
- must와 always는 필수로, should와 recommended는 근거를 남기고 생략할 수 있는 권고로 해석해야 합니다.
- must not과 do not use는 금지로, should not은 수행 시 근거가 필요한 권고적 금지로 해석해야 합니다.
- 상대 날짜가 결과에 영향을 주면 실행 시점의 시간대를 기준으로 절대 날짜로 변환해야 합니다.
- 증거가 없는 주장은 검증되지 않음으로 표시해야 합니다.

# Must NOT

## Overreach
- 의미가 명확하고 실행 결정에 영향이 없는 일반 작업을 어휘 검토로 지연시켜서는 안 됩니다.
- 동일한 용어 정의를 다른 규칙 문서에 복제해서는 안 됩니다.
- 기준 없이 appropriately, when needed, if possible 또는 important 같은 표현을 규범적 규칙에 사용해서는 안 됩니다.
- 용어 변경마다 별도 이력 파일이나 정기 검토를 의무화해서는 안 됩니다.

# Flow

1. 결정에 영향을 주는 용어만 추출합니다.
2. 레지스트리 정의와 비교합니다.
3. 충돌이나 미정의 용어가 있으면 영향과 대안을 확인합니다.
4. 해결된 의미로 실행하거나 해결 불가능한 고위험 모호성을 보고합니다.

# Definition of Done

## Verification
- 적용 여부가 작업 유형과 결정 영향으로 제한됩니다.
- 규칙 강도와 핵심 용어가 일관되게 해석됩니다.
- 일반 작업에 불필요한 어휘 게이트가 생기지 않습니다.

## Monitoring
- 사용자가 직접 수행하는 용어 점검에서는 `codex-skills/vocabulary-management/vocabulary-terminology-conflict-checklist.md`를 참고 점검표로 사용할 수 있습니다.
- 이 점검표 갱신은 정기 실행 의무가 아니며 필요할 때만 수행합니다.
