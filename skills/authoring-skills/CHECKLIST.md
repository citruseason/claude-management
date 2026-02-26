# Skill Validation Checklist

모범사례 문서에서 추출한 검증 규칙. SKILL.md 검증 시 참조됩니다.

---

## 1. Frontmatter (F)

| # | Rule | Severity | Check Method |
|---|------|----------|-------------|
| F-01 | `name` 필드 존재 | FAIL | frontmatter 파싱 |
| F-02 | `name` 64자 이하 | FAIL | `len(name) <= 64` |
| F-03 | `name` 소문자/숫자/하이픈만 | FAIL | `/^[a-z0-9-]+$/` |
| F-04 | `name`에 예약어 없음 | FAIL | "anthropic", "claude" 미포함 |
| F-05 | `name`에 XML 태그 없음 | FAIL | `<`, `>` 미포함 |
| F-06 | `description` 필드 존재 (비어있지 않음) | FAIL | `len(description) > 0` |
| F-07 | `description` 1024자 이하 | FAIL | `len(description) <= 1024` |
| F-08 | `description`에 XML 태그 없음 | FAIL | `<`, `>` 미포함 |
| F-09 | `description` 3인칭 작성 | WARN | 동사가 3인칭 형태 |
| F-10 | `description`에 what + when 포함 | WARN | 기능 설명 + 활성화 조건 모두 존재 |

### F-09 판별 가이드

**올바른 3인칭**:
- "Reviews UI code for..." (영어: -s/-es 형태)
- "Creates distinctive..."
- "Provides React..."
- "~을 분석하여 ~을 탐지합니다" (한국어: ~합니다 형태)

**잘못된 예**:
- "Review UI code for..." (명령형)
- "Use this to..." (2인칭)
- "I will help you..." (1인칭)

### F-10 판별 가이드

- **what**: 스킬이 하는 일 (핵심 동사 + 대상)
- **when**: 활성화 조건 ("Activates when...", "~할 때 사용", "~시 활성화")

---

## 2. Structure (S)

| # | Rule | Severity | Check Method |
|---|------|----------|-------------|
| S-01 | SKILL.md 본문 500줄 이하 | WARN | `wc -l` (frontmatter 제외) |
| S-02 | 참조 파일 한 수준 깊이 | FAIL | 참조 파일 내 링크가 다른 참조 파일을 가리키지 않음 |
| S-03 | 100줄+ 참조 파일에 목차 존재 | WARN | 상단에 섹션 네비게이션 존재 |
| S-04 | 파일명 설명적 | WARN | doc1.md, file2.md 등 비설명적 이름 없음 |
| S-05 | Unix 스타일 경로만 사용 | FAIL | `\` (백슬래시) 미사용 |
| S-06 | 점진적 공개 활용 | WARN | 500줄 초과 시 별도 파일 분리 |

---

## 3. Content Quality (C)

| # | Rule | Severity | Check Method |
|---|------|----------|-------------|
| C-01 | 시간에 민감한 정보 없음 | WARN | 날짜 조건문 없음 ("YYYY년 이전/이후" 등) |
| C-02 | 일관된 용어 | WARN | 같은 개념에 여러 용어 혼용 없음 |
| C-03 | 과도한 설명 없음 | WARN | Claude가 이미 아는 기본 개념 설명 불포함 |
| C-04 | 옵션 과다 제시 없음 | WARN | 기본값 제공, 대안은 필요 시만 |
| C-05 | 구체적 예시 사용 | WARN | 추상적이 아닌 실제 코드/명령 예시 |

### C-03 판별 가이드

**과도한 설명 (제거 대상)**:
- "PDF(Portable Document Format)는 텍스트, 이미지를 포함하는 파일 형식입니다..."
- "마크다운은 경량 마크업 언어로..."
- 동일 포맷 템플릿이 3회 이상 반복

**적절한 설명 (유지)**:
- 프로젝트 고유 컨텍스트 (내부 API, 커스텀 패턴)
- 비자명적 결정 사항 (왜 이 도구/접근법을 쓰는지)
- Claude가 모를 수 있는 도메인 지식

---

## 4. Workflow Quality (W)

| # | Rule | Severity | Check Method |
|---|------|----------|-------------|
| W-01 | 5+ 스텝 워크플로우에 체크리스트 | WARN | 체크리스트 코드 블록 존재 |
| W-02 | 품질 중요 작업에 피드백 루프 | WARN | 검증 → 수정 → 재검증 패턴 존재 |
| W-03 | 조건부 워크플로우 분기 명확 | WARN | IF/THEN 또는 테이블로 분기 명시 |
| W-04 | 워크플로우 단계 순서 명확 | OK | 번호/순서 매겨진 스텝 |
| W-05 | 자유도 수준 적절 | WARN | 작업 취약도에 맞는 지시 구체성 |

### W-05 자유도 판별 가이드

| 자유도 | 적합한 경우 | 지시 형태 |
|--------|-------------|-----------|
| Low | 취약한 작업, 오류 위험 높음, 순서 중요 | 정확한 스크립트/명령, "정확히 이것을 실행" |
| Medium | 선호 패턴 존재, 일부 변형 허용 | 의사코드, 매개변수 있는 템플릿 |
| High | 여러 접근법 유효, 컨텍스트 의존 | 텍스트 지침, 휴리스틱 |

---

## 5. Naming (N)

| # | Rule | Severity | Check Method |
|---|------|----------|-------------|
| N-01 | 동명사 형태 권장 | INFO | verb-ing (processing-pdfs, reviewing-code) |
| N-02 | 모호한 이름 없음 | WARN | helper, utils, tools 등 단독 사용 안 함 |
| N-03 | 과도하게 일반적 없음 | WARN | documents, data, files 등 단독 사용 안 함 |

---

## Severity Definitions

| Severity | 의미 | 조치 |
|----------|------|------|
| **FAIL** | 스킬 작동 또는 발견성에 직접 영향 | 반드시 수정 |
| **WARN** | 품질/발견성 저하 가능 | 수정 권장 |
| **INFO** | 모범사례 권장 사항 | 선택적 개선 |
| **OK** | 문제 없음 (확인용) | 조치 불필요 |
