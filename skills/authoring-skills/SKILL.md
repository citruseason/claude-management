---
name: authoring-skills
description: 기존 스킬을 모범사례 체크리스트 기반으로 검증하고 품질 개선을 제안합니다. 스킬 리뷰, 품질 감사, 모범사례 준수 확인 시 활성화됩니다.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash
argument-hint: "<스킬 경로 또는 'all'>"
---

# Authoring Skills

모범사례 기반 스킬 검증. 기존 스킬의 품질을 체크리스트로 검증하고 개선점을 제안합니다.

**입력**: $ARGUMENTS

---

## Workflow Checklist

```
- [ ] Step 1: 대상 탐색
- [ ] Step 2: 체크리스트 실행
- [ ] Step 3: 리포트
- [ ] Step 4: 수정 (선택)
- [ ] Step 5: 최종 검증
```

---

### Step 1. 대상 탐색

- 특정 경로 → 해당 스킬
- `all` → 프로젝트의 스킬 디렉토리에서 `*/SKILL.md` 패턴으로 전체 탐색
- 서드파티 플러그인 스킬은 제외 (별도 관리 체계를 따름)

### Step 2. 체크리스트 실행

각 스킬에 대해 [CHECKLIST.md](CHECKLIST.md)의 모든 규칙을 실행합니다.

**자동 검증** (Grep/Read/Bash로 확인):
- Frontmatter 필드 존재 및 형식 (F-01~F-08)
- 줄 수 확인 (S-01)
- 경로 형식 (S-05)
- 참조 파일 존재 (S-02)

**수동 판단** (내용 분석):
- 3인칭 여부 (F-09)
- what+when 포함 (F-10)
- 용어 일관성 (C-02)
- 간결함 수준 (C-03)
- 자유도 적절성 (W-05)

### Step 3. 리포트

스킬별 결과를 출력합니다:

```
| 스킬 | FAIL | WARN | INFO | 상태 |
|------|------|------|------|------|
```

FAIL 항목에는 수정 제안을 포함합니다.

### Step 4. 수정 (선택)

FAIL 항목 발견 시 사용자에게 옵션 제시:
1. **전체 수정** — 모든 FAIL 일괄 수정
2. **개별 수정** — 항목별 선택
3. **건너뛰기** — 리포트만 출력

**자동 수정 금지** — 사용자 확인 후 진행.

### Step 5. 최종 검증

수정된 파일에 대해:

1. YAML frontmatter 파싱 유효성
2. 참조 파일 존재 확인
3. 줄 수 500 이하 확인
4. FAIL 항목 0건 확인

---

## Exceptions

- `authoring-skills` (본 스킬) 자체는 셀프 리포트만 수행
- frontmatter의 비표준 필드 (`allowed-tools`, `argument-hint` 등)는 검증하지 않음
- 서드파티 플러그인 스킬은 자체 관리 체계를 따르므로 검증 대상에서 제외
