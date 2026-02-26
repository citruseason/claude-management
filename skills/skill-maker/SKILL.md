---
name: skill-maker
description: 모범사례 기반으로 새 스킬을 설계하고 생성합니다. 새 스킬 생성, 도메인 스킬화, 워크플로우 SKILL화 시 활성화됩니다.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash
argument-hint: "<도메인 또는 작업 설명>"
---

# Skill Maker

모범사례 기반 스킬 설계 및 생성. 도메인 분석부터 SKILL.md 파일 생성까지 가이드합니다.

**입력**: $ARGUMENTS

---

## Workflow Checklist

```
- [ ] Step 1: 도메인 분석
- [ ] Step 2: 아키타입 선택
- [ ] Step 3: 구조 설계
- [ ] Step 4: 콘텐츠 작성
- [ ] Step 5: 파일 생성
- [ ] Step 6: 검증 (authoring-skills 체크리스트)
```

---

### Step 1. 도메인 분석

- **목적**: 스킬이 해결하는 문제와 대상 사용자
- **취약도 평가**: 작업이 깨지기 쉬운가(low freedom) vs 유연한가(high freedom)
- **기존 스킬 확인**: 프로젝트의 스킬 디렉토리를 탐색하여 중복/겹침 확인

### Step 2. 아키타입 선택

| 아키타입 | 특성 | 자유도 | 예시 |
|----------|------|--------|------|
| Pipeline | Phase 기반 오케스트레이션, 게이트 | Low | deploying-releases |
| Verification | 규칙 검사, pass/fail 리포트 | Low | validating-api-contracts |
| Procedural | 순차적 단계, 조건 분기 | Medium | processing-pdfs |
| Reference | 가이드라인, 규칙 목록, 체크리스트 | High | react-best-practices |
| Review | 기준 대비 분석, 결과 리포트 | Medium | reviewing-accessibility |

### Step 3. 구조 설계

**Frontmatter**:
- `name`: 동명사 형태 권장 (`reviewing-code`), 소문자/숫자/하이픈만, 64자 이하
- `description`: 3인칭 ("Reviews...", "~합니다"), what + when, 핵심 키워드, 1024자 이하
- `allowed-tools`: 필요한 도구만

**본문 설계 원칙**:
- 500줄 이하 목표
- 5+ 스텝 워크플로우 → 체크리스트 추가
- 품질 중요 작업 → 피드백 루프 (검증→수정→재검증) 추가
- 500줄 초과 예상 → 참조 파일 분리 (한 수준 깊이만)

**간결함 원칙**:
- Claude가 이미 아는 것은 생략
- 인라인 포맷 템플릿 최소화 (Claude가 생성 가능)
- 프로젝트 고유 컨텍스트만 기술

### Step 4. 콘텐츠 작성

아키타입에 따라 SKILL.md 작성:

1. YAML frontmatter
2. 타이틀 및 한 줄 설명
3. Workflow Checklist (5+ 스텝인 경우)
4. 워크플로우 스텝
5. Exceptions (해당 시)

**콘텐츠 규칙**:
- 시간에 민감한 정보 금지 ("2025년 이후에는..." 등)
- 일관된 용어 (하나의 개념에 하나의 용어)
- Unix 경로만 (`/`, 백슬래시 금지)
- 기본값 제공 + 필요 시 대안 (옵션 과다 금지)
- 구체적 예시 우선 (추상적 설명 지양)

### Step 5. 파일 생성

- **표준 위치**: `.claude/skills/<name>/SKILL.md`
- **참조 파일**: 같은 디렉토리에 설명적 이름으로 (`REFERENCE.md`, `CHECKLIST.md` 등)
- 환경에 따라 다른 스킬 디렉토리가 사용될 수 있음 — 프로젝트 규칙을 따를 것

### Step 6. 검증

생성된 SKILL.md에 대해 `authoring-skills`의 체크리스트를 실행합니다:

1. Frontmatter 유효성 (F-01~F-10)
2. 구조 규칙 (S-01~S-06)
3. 콘텐츠 품질 (C-01~C-05)
4. 워크플로우 품질 (W-01~W-05)
5. 명명 규칙 (N-01~N-03)

FAIL 항목이 있으면 수정 후 재검증합니다.

---

## Exceptions

- 스킬 업데이트(기존 SKILL.md 수정)는 본 스킬의 범위가 아님 — 직접 Edit 도구 사용
- 서드파티 플러그인 스킬은 자체 관리 체계를 따름
