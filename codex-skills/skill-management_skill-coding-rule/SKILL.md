---
name: skill-coding-rule
description: Java·Python·TypeScript·Bash·Vimscript·Common Lisp 코드와 JSON API·Markdown 문서를 작성하거나 검토할 때 해당 Google 스타일 가이드를 적용합니다.
---

# Coding Rule

## Must

### Scope
- 작성·수정·검토 대상의 언어 또는 문서 형식에 해당하는 아래 가이드만 선택해야 합니다. 한 작업에 여러 형식이 있으면 파일별로 선택합니다.
- 이 스킬은 규약의 선택과 적용 경계를 소유합니다. 세부 규칙과 예외의 원본은 링크된 Google 스타일 가이드입니다.
- 파일 확장자만으로 적용 대상을 단정하지 말고 실제 언어와 용도를 확인해야 합니다. 특히 JSON 가이드는 일반 설정 파일의 서식 규칙이 아니라 JSON API 요청·응답 설계 가이드입니다.
- 사용자가 제공한 `lispguide.md`의 "Common"은 공통 규약을 뜻하지 않습니다. 이 가이드는 Common Lisp 코드에만 적용해야 합니다.
- 기존 파일의 코드베이스 관례 또는 상위 규칙과 충돌하는 항목은 임의의 일괄 변경으로 해결하지 말고, 적용 범위와 충돌을 식별해야 합니다.

### Sources and Application

#### Java
- [Google Java Style Guide](https://google.github.io/styleguide/javaguide.html)를 Java 소스에 적용합니다.
- UTF-8, 파일 구조와 import, 2칸 블록 들여쓰기, 최소 4칸 이어쓰기, 예외가 있는 100자 열 제한, 중괄호, 식별자 명명, `@Override`, Javadoc의 적용 대상과 예외를 확인해야 합니다.

#### JSON API
- [Google JSON Style Guide](https://google.github.io/styleguide/jsoncguide.html)를 JSON API의 요청·응답 및 속성 설계에 적용합니다.
- 실제 JSON에는 주석을 넣지 않고, 키와 문자열 값은 큰따옴표로 작성하며, 속성 이름은 의미 있는 camelCase로 정합니다. 맵의 임의 키에는 속성 명명 규칙을 강제하지 않습니다.
- 날짜·기간·열거형 및 예약 속성은 해당 절을 확인해야 합니다. 가이드의 예시 구조나 예약 속성을 모든 JSON 문서에 의무적으로 삽입해서는 안 됩니다.

#### Markdown
- [Google Markdown Style Guide](https://google.github.io/styleguide/docguide/style.html)를 Markdown 문서에 적용합니다.
- 원본 텍스트의 가독성을 유지하고, H1은 하나만 사용하며, 설명적인 제목, 후행 공백 없는 줄, 언어가 표시된 fenced code block을 사용합니다.
- 일반 본문의 80자 줄 제한에는 링크·표·제목·코드 블록 등의 예외가 있습니다. `[TOC]` 같은 호스팅 의존 문법은 실제 렌더러가 지원할 때만 사용합니다.

#### Python
- [Google Python Style Guide](https://google.github.io/styleguide/pyguide.html)를 Python 소스에 적용합니다.
- 4칸 들여쓰기와 탭 금지, 예외가 있는 80자 줄 제한, import·명명·docstring 규칙을 확인해야 합니다. 공개 API를 추가·수정할 때는 타입 주석과 프로젝트의 타입 검사 가능 여부를 확인합니다.

#### Shell
- [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)를 Bash 스크립트에 적용합니다. PowerShell 또는 다른 셸의 문법 규칙으로 확장해서는 안 됩니다.
- 실행 파일의 인터프리터, 인용과 변수 확장, 명령 치환, 오류·반환값 처리, 함수 및 파일 명명을 확인합니다. 사용 가능하면 ShellCheck로 검사합니다.

#### TypeScript
- [Google TypeScript Style Guide](https://google.github.io/styleguide/tsguide.html)를 TypeScript 소스에 적용합니다.
- ES 모듈, `const` 우선·재할당 시 `let`, `var` 금지, 일반 문자열의 작은따옴표, 명시적 세미콜론, 명명 및 타입 사용 규칙을 확인합니다. 예시의 선택적 서식을 유일한 허용 형식으로 강제하지 않습니다.

#### Vimscript
- [Google Vimscript Style Guide](https://google.github.io/styleguide/vimscriptguide.html)를 Vimscript에 적용합니다. Vim 설정·플러그인에만 사용하고 다른 언어의 설정 파일에 적용해서는 안 됩니다.
- 이식성을 위해 문자열 인용, 명시적인 대소문자 매칭, 로컬 설정 변경을 확인하고, 2칸 들여쓰기·탭 금지·후행 공백 금지를 적용합니다.

#### Common Lisp
- [Google Common Lisp Style Guide](https://google.github.io/styleguide/lispguide.html)를 Common Lisp 코드에만 적용합니다.
- 해당 프로젝트의 관례를 확인하고, 원문의 함수형 스타일·상태 변경·패키지·명명·문서화 지침 중 변경 대상에 관련된 절을 선택합니다. 다른 언어의 공통 기본값으로 사용하지 않습니다.

### Verification
- 변경 파일별로 적용한 가이드와 확인한 절을 식별하고, 원문 요약에 없는 예외가 판단을 바꾸면 원문의 해당 절을 확인해야 합니다.
- 프로젝트에 있는 포매터·린터·파서·테스트 중 변경 위험에 맞는 검사를 실행하고 diff를 확인해야 합니다. 포매터 통과만으로 모든 명명·API 설계·문서화 규칙의 준수를 단정해서는 안 됩니다.
- 원문이나 도구로 확인하지 못한 준수 항목은 검증되지 않은 항목으로 구분해야 합니다.

## Must NOT

### Boundaries
- 규약 적용을 명분으로 요청받지 않은 파일을 일괄 재포맷하거나 의미 변경을 섞어서는 안 됩니다.
- 한 언어의 들여쓰기·줄 길이·명명 규칙을 다른 언어 또는 문서 형식에 전파해서는 안 됩니다.
- 원문이 허용하는 대안과 예외를 단일 선호 형식으로 축소해서는 안 됩니다.

## Definition of Done

### Completion checks
- 각 변경 파일에 적합한 원본 가이드가 선택되고 적용 범위 밖의 변경이 없습니다.
- 실행한 검사, 수동으로 확인한 규칙 및 미검증 항목이 구분됩니다.
