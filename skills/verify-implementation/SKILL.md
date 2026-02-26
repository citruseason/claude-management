---
name: verify-implementation
description: 발견된 모든 verify-* 스킬을 병렬로 실행하여 통합 검증 보고서를 생성합니다. 기능 구현 후, PR 전, 코드 리뷰 시 사용.
disable-model-invocation: true
argument-hint: "[선택사항: 특정 verify 스킬 이름]"
allowed-tools: Read, Write, Edit, Grep, Glob, Bash, Task
---

# Verify Implementation (병렬 실행)

모든 verify-* 스킬을 병렬 에이전트로 동시 실행하여 통합 검증 보고서를 생성합니다.

---

## Workflow Checklist

```
- [ ] Step 1: verify-* 스킬 탐색
- [ ] Step 2: 병렬 실행 (Task 동시 spawn)
- [ ] Step 3: 결과 수집
- [ ] Step 4: 통합 리포트
- [ ] Step 5: 수정 옵션 (FAIL/WARN 시)
- [ ] Step 6: 수정 및 재검증
```

---

### Step 1: verify-* 스킬 탐색

1. `.claude/skills/verify-*/` 탐색 (primary), `skills/verify-*/` 폴백
2. $ARGUMENTS가 있으면 해당 스킬만 필터링
3. 스킬이 없으면 `manage-skills` 실행을 안내하고 종료

### Step 2: 병렬 실행

Task 도구로 각 스킬을 **하나의 응답에서 모두 동시에** spawn:

각 에이전트 프롬프트:
> `[스킬 경로]/SKILL.md`의 검증 스킬을 실행하세요. Workflow 단계를 순서대로 실행하고, Exceptions는 건너뜁니다.
> 결과: skill, checks, pass/fail/warn 수, details.

### Step 3: 결과 수집

에이전트 완료 대기 후 결과 수집. 개별 실패는 다른 에이전트에 영향 없음:
- 에러 종료 → `ERROR`, 타임아웃 → `TIMEOUT`, 정상 → pass/fail/warn 집계

### Step 4: 통합 리포트

스킬별 상태 테이블과 FAIL/WARN/ERROR 상세 항목을 출력합니다.

전체 상태 결정:
- **PASS**: 모든 스킬 pass (fail=0, error=0)
- **WARN**: fail=0, warn>0 또는 error>0
- **FAIL**: fail>0인 스킬 존재

### Step 5: 수정 옵션

FAIL/WARN 시 사용자에게 옵션 제시:
1. **전체 수정** — 모든 FAIL/WARN 일괄 수정
2. **개별 수정** — 항목별 수정/건너뛰기 선택
3. **건너뛰기** — 현재 결과 확정

모든 PASS이면 이 단계 건너뜀. **자동 수정 금지** — 사용자 선택 후 진행.

### Step 6: 수정 및 재검증

수정 적용 후 **영향받은 스킬만** 병렬 재검증. 재검증 통과 시 상태 갱신, 실패 시 Step 5 반복 (최대 2회).

---

## Exceptions

- reference/guidance 스킬은 실행 대상 제외
- `verify-implementation` 자신은 실행 목록에 미포함
- 모든 에이전트 ERROR/TIMEOUT 시 전체 상태 ERROR
