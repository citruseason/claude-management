# Korean Prompt Fragments

## Common Responses

### task-started
작업을 시작합니다. 계획에 따라 단계별로 진행하겠습니다.

### task-completed
구현이 완료되었습니다. 변경 사항 요약:

### verification-passed
모든 검증을 통과했습니다. 구현이 검증되었으며 리뷰 준비가 되었습니다.

### verification-failed
검증에서 해결이 필요한 문제가 발견되었습니다:

### plan-ready
구현 계획이 검토 준비가 되었습니다:

### review-summary
코드 리뷰가 완료되었습니다. 평가 결과:

## Error Messages

### blocked-force-push
안전 정책에 의해 강제 푸시가 차단되었습니다. 일반 푸시를 사용하거나 팀과 상의하세요.

### blocked-destructive
이 작업은 돌이킬 수 없는 데이터 손실을 초래할 수 있어 차단되었습니다.

### missing-plan
구현 계획을 찾을 수 없습니다. 먼저 /plan을 실행하여 계획을 생성하세요.

### missing-tests
이 변경에 대한 테스트를 찾을 수 없습니다. 테스트 커버리지 추가를 고려하세요.

## Workflow Prompts

### before-implementation
시작하기 전에 확인합니다:
1. 계획이 명확하고 완전한지
2. 기존 코드 패턴을 이해했는지
3. 변경 사항을 검증하는 방법을 알고 있는지

### after-implementation
변경이 완료되었습니다. 다음 단계:
1. /verify를 실행하여 구현을 검증
2. /review를 실행하여 코드 품질 확인
3. 준비가 되면 /ship으로 커밋

### lesson-recorded
교훈이 .work/lessons.md에 기록되었습니다. 향후 작업에서 이 패턴을 주시합니다.

## Init Prompts

### init-complete
프로젝트가 성공적으로 초기화되었습니다. 워크플로우 디렉토리, 규칙, .gitignore가 설정되었습니다.

### init-already-configured
프로젝트가 이미 완전히 설정되어 있습니다. 변경이 필요하지 않습니다.

### init-rules-skipped
CLAUDE.md에 워크플로우 규칙이 이미 존재합니다 — 추가를 건너뛰었습니다.

### init-gitignore-skipped
.gitignore에 .work/가 이미 등록되어 있습니다 — 건너뛰었습니다.

## External Skill Prompts

### skills-discovered
.claude/skills/에서 외부 스킬이 감지되었습니다:

### skills-none-found
외부 스킬이 감지되지 않았습니다. skills.sh에서 스킬을 설치하여 파이프라인을 확장하세요.

### skills-wrapper-exists
이 스킬에 대한 검증 래퍼가 이미 존재합니다.

### skills-wrapper-suggest
/manage-skills를 실행하여 외부 스킬에 대한 verify-* 래퍼를 생성하세요.

### skills-not-executed
외부 스킬이 목록에 표시되지만 자동 실행되지 않습니다. verify-* 래퍼를 생성하여 통합하세요.

### skills-registry-updated
스킬 레지스트리가 .work/skill-registry.md에 업데이트되었습니다.
