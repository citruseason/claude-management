---
name: manage-skills
description: 세션 변경사항과 사용자 입력을 분석하여 verify-* 검증 스킬의 누락을 탐지합니다. 새 스킬을 생성하거나 기존 스킬을 업데이트한 뒤 CLAUDE.md를 관리합니다. 코딩 스탠다드/패턴을 스킬로 저장할 때 사용합니다.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash
argument-hint: "[선택사항: 코딩 스탠다드, 패턴, 또는 규칙]"
---

# Manage Skills

세션 기반 verify-* 스킬 유지보수. 코드 변경사항을 분석하여 검증 스킬 갭을 탐지하고 관리합니다.

**입력**: $ARGUMENTS

---

## Workflow Checklist

```
- [ ] Step 1: 입력 분석 (명시적 / 세션 분석 모드)
- [ ] Step 2: 세션 히스토리 분석 (변경 파일, 컨텍스트, 후보 추출)
- [ ] Step 3: verify-* 스킬 탐색 및 매핑
- [ ] Step 4: 커버리지 갭 분석
- [ ] Step 5: CREATE vs UPDATE 결정 → 사용자 확인
- [ ] Step 6: 기존 스킬 업데이트 (UPDATE 대상)
- [ ] Step 7: 새 스킬 생성 → skill-maker 위임 (CREATE 대상)
- [ ] Step 8: 검증 → authoring-skills 위임 및 리포트
```

---

### Step 1. 입력 분석

$ARGUMENTS 내용으로 입력 모드를 결정합니다.

- **명시적 입력**: 코딩 스탠다드, 패턴, 규칙이 있으면 주요 소스로 사용. 세션 분석도 추가 실행.
- **세션 분석**: $ARGUMENTS가 비어있거나 일반적 요청이면 Step 2로 진행하여 자동 추출.

---

### Step 2. 세션 히스토리 분석

#### 2a. 변경 파일 수집

`git diff --name-only`로 변경 파일 목록 수집.

#### 2b. 세션 컨텍스트 분석

대화 히스토리에서 추출:
- 새로 확립된 컨벤션 (코딩 규칙, 네이밍, 파일 구조)
- 반복된 교정 패턴
- 새로운 API 형태 / 데이터 모델
- 코드 패턴 (에러 처리, 상태 관리, 컴포넌트 구조)

#### 2c. 스킬 후보 추출

저장 기준: 반복된 패턴, 명시적 규칙, 프로젝트 전반 구조적 결정.
제외: 일회성 수정, 특정 파일 한정 변경.

추출 결과를 사용자에게 제시합니다.

---

### Step 3. verify-* 스킬 탐색 및 매핑

#### 3a. 기존 스킬 탐색

파일시스템이 레지스트리 역할. `.claude/skills/verify-*/SKILL.md` 우선 탐색, `skills/verify-*/SKILL.md` 폴백.

#### 3b. 변경 파일 매핑

변경 파일을 기존 verify-* 스킬의 파일 패턴에 매핑: `[파일] → [매핑된 스킬]` 또는 `[미매핑]`

---

### Step 4. 커버리지 갭 분석

미커버 파일과 패턴을 식별합니다.

갭 리포트: 미커버 파일 수, 미커버 패턴, 커버리지 요약을 출력합니다.

---

### Step 5. CREATE vs UPDATE 결정

| 조건 | 액션 |
|------|------|
| 기존 스킬이 해당 영역 커버하지만 확장 필요 | UPDATE |
| 커버하는 스킬 없음 | CREATE |
| 이미 완전 커버 | SKIP |

판단 기준: 파일 패턴 중첩도, 의미적 유사성, 범위 적정성.

액션 플랜을 사용자에게 제시하고 **확인 후** Step 6, 7 실행.

---

### Step 6. 기존 스킬 업데이트

UPDATE 대상 스킬의 SKILL.md를 Edit 도구로 최소 변경:
- 기존 Workflow 보존, 새 스텝은 필요 시 추가
- 검증 규칙 추가, 파일 패턴 확장, Exceptions 업데이트

---

### Step 7. 새 스킬 생성 (skill-maker 위임)

CREATE 대상에 대해 `skill-maker`를 호출하여 스킬을 생성합니다.

각 CREATE 항목마다 skill-maker에 전달할 컨텍스트:
- 스킬명: `verify-<name>`
- 아키타입: Verification
- 검증 대상 파일 패턴 (Step 4에서 식별된 미커버 패턴)
- 검증 규칙 (Step 2에서 추출된 패턴/컨벤션)

스킬 간 중복 검증 없이, 한 규칙은 하나의 스킬에서만 담당.

---

### Step 8. 검증 및 리포트 (authoring-skills 위임)

1. 생성/업데이트된 모든 스킬에 대해 `authoring-skills`를 호출하여 체크리스트 검증 실행
2. FAIL 항목이 있으면 수정 후 재검증
3. CLAUDE.md 스킬 테이블 업데이트
4. 결과 리포트 출력: 생성/업데이트 스킬, 검증 결과, 커버리지 변화, 잔여 갭

---

## Exceptions

- 본 스킬 (`manage-skills`)과 실행기 (`verify-implementation`)는 관리 대상 제외
