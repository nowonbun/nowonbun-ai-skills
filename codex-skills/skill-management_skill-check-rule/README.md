# Skill Check Rule

이 스킬은 헌법 문서, 루트 저장소 지도, 수동 검토 프로필, 활성 스킬 규칙과 검증 문서의 구조·참조·인코딩·역할 일관성을 검사한다.

Codex 스킬 검증 문서는 저장소 루트 기준 `tests/codex/<skill-name>-test.md`에 있다. `tests/claude/`는 별도 Claude 스킬 검증 영역이며 두 테스트 영역 모두 활성 규칙 원본이 아니다.

`**/.claude/worktrees/**`, 백업 및 이력 복제본은 현재 작업 트리의 활성 규칙 검사에서 제외한다.
