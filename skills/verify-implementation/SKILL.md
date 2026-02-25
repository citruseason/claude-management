---
name: verify-implementation
description: 발견된 모든 verify-* 스킬을 **병렬**로 실행하여 통합 검증 보고서를 생성합니다. 기능 구현 후, PR 전, 코드 리뷰 시 사용.
disable-model-invocation: true
argument-hint: "[선택사항: 특정 verify 스킬 이름]"
allowed-tools: Read, Write, Edit, Grep, Glob, Bash, Task
---

# Verify Implementation (병렬 실행)

발견된 모든 verify-* 스킬을 **병렬**로 실행하여 통합 검증 보고서를 생성합니다.
각 verify-* 스킬은 독립적인 백그라운드 에이전트로 동시에 실행되어, 순차 실행 대비 검증 시간을 크게 단축합니다.

**사용 시점**: 기능 구현 후 / PR 생성 전 / 코드 리뷰 시 / 수동 검증이 필요할 때

---

## Workflow

### Step 1: verify-* 스킬 동적 탐색

1. glob 패턴으로 verify-* 스킬을 동적으로 탐색합니다:
   ```bash
   # Primary: 소비 프로젝트
   ls -d .claude/skills/verify-*/ 2>/dev/null

   # Fallback: 플러그인 내부
   ls -d skills/verify-*/ 2>/dev/null
   ```
2. 인자($ARGUMENTS)가 주어진 경우, 해당 스킬 이름만 필터링합니다.
   - 예: `/verify-implementation verify-api` -> `verify-api` 스킬만 실행
3. 실행 목록을 구성합니다:
   ```
   발견된 verify-* 스킬:
   1. verify-api (.claude/skills/verify-api/SKILL.md)
   2. verify-types (.claude/skills/verify-types/SKILL.md)
   3. ...
   ```
4. verify-* 스킬이 하나도 없으면 아래 메시지를 출력하고 종료합니다:
   ```
   발견된 verify-* 스킬이 없습니다.
   manage-skills를 실행하여 검증 스킬을 먼저 생성하세요.
   ```

### Step 2: 병렬 실행

**Task 도구**를 사용하여 각 verify-* 스킬을 독립적인 백그라운드 에이전트로 **동시에** 실행합니다.

각 스킬마다 아래와 같이 Task를 생성합니다:

```
Task tool 호출 (스킬당 1개씩, 모두 동시에 spawn):

Task 1 - verify-api:
  prompt: |
    `skills/verify-api/SKILL.md`의 검증 스킬을 실행하세요.
    1. 해당 SKILL.md를 읽고 Workflow 단계를 순서대로 실행합니다.
    2. Exceptions 섹션에 해당하는 검사는 건너뜁니다.
    3. 결과를 아래 형식으로 반환합니다:
       - skill: "verify-api"
       - checks: [실행한 검사 목록]
       - pass: N
       - fail: N
       - warn: N
       - details: [각 검사의 상세 결과]

Task 2 - verify-types:
  prompt: |
    `skills/verify-types/SKILL.md`의 검증 스킬을 실행하세요.
    (위와 동일한 형식)

... (발견된 모든 verify-* 스킬에 대해 동시 spawn)
```

**핵심**: 모든 Task를 순차가 아닌 **병렬로** spawn합니다. 하나의 응답에서 모든 Task 도구 호출을 동시에 수행하여 병렬성을 확보합니다.

### Step 3: 에이전트 완료 대기 및 결과 수집

1. 모든 백그라운드 에이전트의 완료를 대기합니다.
2. 각 에이전트의 결과를 수집합니다.
3. 에이전트 실패 시 **개별 처리** (다른 에이전트에 영향을 주지 않음):
   - 에이전트가 에러로 종료 -> 해당 스킬을 `ERROR` 상태로 기록
   - 에이전트가 타임아웃 -> 해당 스킬을 `TIMEOUT` 상태로 기록
   - 정상 완료 -> 결과를 파싱하여 pass/fail/warn 집계

```
결과 수집 완료:
- verify-api: 5 checks (4 pass, 1 fail)
- verify-types: 3 checks (3 pass, 0 fail)
- verify-contracts: ERROR (에이전트 실패)
```

### Step 4: 통합 리포트 생성

수집된 결과를 하나의 통합 보고서로 집계합니다.

```markdown
# 검증 결과 보고서

실행 시간: YYYY-MM-DD HH:mm
실행 방식: 병렬 (N개 에이전트 동시 실행)

## 전체 상태: FAIL

| 스킬 | 검사 수 | Pass | Fail | Warn | 상태 |
|------|---------|------|------|------|------|
| verify-api | 5 | 4 | 1 | 0 | FAIL |
| verify-types | 3 | 3 | 0 | 0 | PASS |
| verify-contracts | - | - | - | - | ERROR |

## FAIL 항목
- [verify-api] API 응답 스키마 불일치: `GET /users` 응답에 `email` 필드 누락
  - 위치: `src/api/users.ts:42`
  - 제안: contract에 정의된 `email` 필드를 응답에 추가

## WARN 항목
(없음)

## ERROR 항목
- [verify-contracts] 에이전트 실행 중 에러 발생: [에러 메시지]

## PASS 항목
- [verify-types] 모든 타입 검사 통과 (3/3)
```

전체 상태 결정 기준:
- **PASS**: 모든 스킬이 PASS (fail=0, error=0)
- **WARN**: fail=0 이지만 warn>0 또는 error>0
- **FAIL**: 하나 이상의 스킬에 fail>0

### Step 5: 수정 옵션 제시

FAIL 또는 WARN 항목이 있을 경우, 사용자에게 세 가지 수정 옵션을 제시합니다.

```
검증 결과 수정이 필요한 항목이 있습니다.

수정 옵션을 선택하세요:

1. **전체 수정** - 모든 FAIL/WARN 항목을 일괄 수정합니다
   수정 대상:
   - [verify-api] API 응답 스키마 불일치 -> email 필드 추가
   - [verify-styles] 미사용 CSS 클래스 -> 해당 클래스 제거

2. **개별 수정** - 수정할 항목을 개별 선택합니다
   각 항목에 대해 수정/건너뛰기를 선택할 수 있습니다.

3. **건너뛰기** - 수정 없이 현재 결과를 최종 보고서로 확정합니다
```

모든 스킬이 PASS인 경우 이 단계를 건너뛰고 바로 최종 보고서를 출력합니다.

**중요**: 사용자가 선택하기 전에 자동으로 수정을 적용하지 않습니다.

### Step 6: 수정 적용 및 재검증

사용자가 전체 수정 또는 개별 수정을 선택한 경우:

1. 선택된 수정 사항을 코드에 적용합니다.
2. **영향받은 스킬만** 재검증합니다 (전체 재실행 아님):
   ```
   재검증 대상: verify-api (1개 스킬)
   (verify-types는 이미 PASS이므로 재실행하지 않음)
   ```
3. 재검증도 Task 도구를 사용하여 **병렬로** 실행합니다 (여러 스킬이 대상인 경우).
4. 재검증 결과로 보고서를 업데이트합니다:
   - 재검증 통과 -> 해당 스킬 상태를 PASS로 변경
   - 여전히 실패 -> 남은 이슈를 사용자에게 다시 제시
5. 모든 재검증이 통과하면 전체 상태를 PASS로 갱신합니다.
6. 여전히 실패 항목이 있으면 Step 5로 돌아가 다시 수정 옵션을 제시합니다 (최대 2회 반복).

---

## Exceptions

- `reference` 또는 `guidance` 타입 스킬은 실행 대상에서 제외합니다.
- `verify-implementation` 자기 자신은 실행 목록에 포함하지 않습니다.
- 프로젝트에 verify-* 스킬이 하나도 없으면 스킬 생성을 안내하고 종료합니다.
- 특정 스킬 이름이 인자로 전달되었으나 해당 스킬이 존재하지 않으면 에러 메시지를 출력합니다.
- 모든 에이전트가 ERROR/TIMEOUT인 경우 전체 상태를 ERROR로 보고합니다.

---

## Related Files

- `skills/manage-skills/SKILL.md` - verify-* 스킬 생성/관리 도구
- `.claude/skills/verify-*/SKILL.md` - 개별 검증 스킬 파일 (소비 프로젝트)
- `skills/verify-*/SKILL.md` - 개별 검증 스킬 파일 (플러그인 내부, 폴백)
- `CLAUDE.md` - 프로젝트 규칙 및 스킬 문서

