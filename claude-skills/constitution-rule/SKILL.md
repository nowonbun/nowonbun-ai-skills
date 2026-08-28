---
name: constitution-rule
description: global_instructions.md와 AGENTS.md의 책임 경계, 우선순위 및 중복 여부를 검증합니다.
---

# Constitution Rule

# Must

## Scope
- 이 스킬은 global_instructions.md 또는 AGENTS.md를 생성·수정·감사할 때 적용해야 합니다.
- 전역 안전 규칙의 구체적인 내용은 global_instructions.md가, 폴더별 트리거와 워크플로는 AGENTS.md가 소유해야 합니다.

## Layer Boundaries
- 구성 계층은 global_instructions.md와 AGENTS.md 두 개로 유지해야 합니다.
- global_instructions.md에는 시스템 정체성, 전역 원칙, 안전 경계 및 우선순위 모델을 배치해야 합니다.
- AGENTS.md에는 폴더 역할, 정확한 실행 트리거, 워크플로 단계, 중지 조건 및 재실행 조건을 배치해야 합니다.
- 같은 규칙 문장을 두 계층에 복제하지 말고 하위 계층은 필요한 상위 규칙을 참조해야 합니다.

## Priority and Change Control
- 충돌 시 global_instructions.md가 AGENTS.md보다 우선해야 합니다.
- 하위 문서는 상위 문서가 명시적으로 위임한 범위만 구체화해야 합니다.
- 수정 전에는 대상 문서와 요청 범위를 확인하고, 수정 후에는 두 계층의 충돌과 깨진 참조를 다시 검사해야 합니다.
- 이미 요청 상태와 일치하면 파일을 다시 쓰지 않고 no-op으로 보고해야 합니다.

## Source of Truth
- 이 문서는 global_instructions.md 및 AGENTS.md에 대한 헌법 문서 내용 경계, 계층 할당 및 우선순위 규칙을 규정합니다. 스킬 문서 작성 형식이나 거버넌스 계층은 규정하지 않습니다.
- `skill-create-rule`는 스킬 문서의 구조 및 작성 형식 제약 조건에 대한 유일한 기준 문서입니다. 헌법 계층 우선순위 관련 질문은 이 문서를 참조하지 마십시오.
- `skill-governance-rule`는 거버넌스 계층 정의 및 엄격 트리거 제어에 대한 유일한 기준 문서입니다. 헌법 작성 관련 질문은 이 문서를 참조하지 마십시오.

# Must NOT

## Boundary Violations
- AGENTS.md에 시스템 정체성이나 전역 안전 정책을 새로 정의해서는 안 됩니다.
- global_instructions.md에 저장소별 세부 실행 순서를 배치해서는 안 됩니다.
- 문서 언어, 보고 형식 또는 안전 경계를 다른 스킬에서 재정의해서는 안 됩니다.
- 규칙 수정에 외부 AI 검토나 별도 이력 파일을 일률적으로 요구해서는 안 됩니다.
- 요청 범위 밖의 사용자 콘텐츠를 덮어써서는 안 됩니다.

# Flow

1. 두 문서의 존재, 정규 경로 및 읽기 가능성을 확인합니다.
2. 변경 대상 규칙의 소유 계층을 결정합니다.
3. 중복 없이 최소 범위로 수정합니다.
4. 우선순위, 참조, UTF-8 및 실행 가능성을 검증합니다.
5. 변경과 검증 결과를 보고합니다.

# Definition of Done

## Verification
- 두 계층의 책임이 분리됩니다.
- 동일 규칙의 중복과 해결되지 않은 충돌이 없습니다.
- 수정 범위와 검증 증거를 확인할 수 있습니다.
