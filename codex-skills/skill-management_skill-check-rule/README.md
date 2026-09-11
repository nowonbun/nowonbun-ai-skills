# Skill Check Rule

이 스킬은 대상 스킬과 관련 문서를 기본 검사하고, 명시적 전체 감사 또는 공통 규칙 변경 시 검사 범위를 확장한다. 수동 외부 모델 검토 프로필은 명시적 요청 없이는 수집하지 않는다.

Codex 스킬 검증 문서는 저장소 루트 기준 `tests/codex/<skill-name>-test.md`에 있다. `tests/claude/`는 별도 Claude 스킬 검증 영역이며 두 테스트 영역 모두 활성 규칙 원본이 아니다.

`**/.claude/worktrees/**`, 백업 및 이력 복제본은 현재 작업 트리의 활성 규칙 검사에서 제외한다.

## 정형 검사 실행

스킬 폴더에서 PowerShell로 실행한다. 경로 입력은 호출 위치 기준이며, 대상은 이 저장소의 codex-skills 안에 있는 Markdown 파일로 한정한다.

```powershell
& ./scripts/validate-skills.ps1 -Paths ./SKILL.md,./README.md
& ./scripts/validate-skills.ps1 -All
& ./scripts/validate-skills.ps1 -SelfTest
```

- 읽기 전용이며 UTF-8, 대체 문자, SKILL.md의 제한된 frontmatter 형식·필수 H1, 코드 펜스 및 명시적 상대 파일 참조를 검사한다.
- 상대 참조는 백틱 안의 `./`·`../` 경로와 인라인 Markdown 링크만 검사한다. 웹 URL·앵커·템플릿·참조형 링크·일반 문장 속 경로 및 저장소 밖 참조는 의미 검토에서 따로 확인한다.
- 경로 이탈과 심볼릭 링크·junction은 접근 전에 거부한다. 전체 모드는 백업·이력·테스트·worktree 폴더를 제외한다.
- 출력은 파일 수·검사 집합 해시와 실패 위치만 포함한다. 종료 코드 0은 정형 검사 통과, 1은 실패다. 정형 검사 통과는 의미·정책 정합성이나 한국어 본문 보존의 증명이 아니다.
- 자동 캐시는 만들지 않는다. 동일 실행의 증거를 재사용할지는 work-runtime 기준으로 판단한다.
