# 만화책 리더 앱 - 제품 기획서

## 개요

Flutter로 개발하는 크로스플랫폼 만화책 뷰어 앱. WebDAV 원격 저장소와 로컬 파일을 지원하며, 읽기 진행 상황을 추적한다.

**대상 플랫폼:** iOS, Android

**주요 사용 시나리오:**
- 개인 WebDAV 서버(NAS, Nextcloud 등)에서 만화책 읽기
- 로컬에 저장된 만화 파일 읽기
- 마지막 읽던 위치에서 이어서 읽기
- 여러 기기에서 라이브러리 관리

---

## 핵심 기능

### 1. WebDAV 저장소 연동

**설명:** WebDAV 서버에 연결하여 원격으로 만화 파일을 탐색하고 읽는다.

**요구사항:**

| ID | 요구사항 | 우선순위 |
|----|----------|----------|
| WD-01 | 여러 WebDAV 서버 설정 지원 | 필수 |
| WD-02 | 서버 설정: URL, 사용자명, 비밀번호, 표시 이름 | 필수 |
| WD-03 | 폴더 탐색이 가능한 디렉토리 구조 브라우징 | 필수 |
| WD-04 | 파일 목록에 이름, 크기, 수정일 표시 | 필수 |
| WD-05 | 지원 형식(.zip, .cbz, .cbr, .rar)과 폴더만 필터링하여 표시 | 필수 |
| WD-06 | 진행률 표시와 함께 파일 다운로드 | 필수 |
| WD-07 | 다운로드한 파일을 오프라인 읽기용으로 캐싱 | 필수 |
| WD-08 | 연결 상태 표시 | 권장 |
| WD-09 | 네트워크 복구 시 자동 재연결 | 권장 |
| WD-10 | 암호화된 자격 증명 저장 | 필수 |
| WD-11 | 자체 서명 인증서 허용 옵션 | 선택 |

**사용자 흐름:**
1. 설정에서 WebDAV 서버 추가
2. 라이브러리 소스 목록에 서버 표시
3. 서버 디렉토리 탐색
4. 만화 파일 탭하여 다운로드 및 열기
5. 다운로드한 파일 로컬 캐시에 저장

---

### 2. 로컬 파일 지원

**설명:** 기기에 저장된 만화 파일을 가져와서 읽는다.

**요구사항:**

| ID | 요구사항 | 우선순위 |
|----|----------|----------|
| LF-01 | 시스템 파일 선택기로 파일 가져오기 | 필수 |
| LF-02 | 지원 형식: ZIP, CBZ | 필수 |
| LF-03 | 지원 형식: CBR, RAR | 권장 |
| LF-04 | 아카이브 내 이미지 형식: JPG, PNG, GIF, WebP | 필수 |
| LF-05 | 가져온 파일을 앱 문서 디렉토리에 저장 | 필수 |
| LF-06 | 라이브러리에서 가져온 파일 삭제 | 필수 |
| LF-07 | 파일 메타데이터 표시 (이름, 페이지 수, 파일 크기) | 필수 |
| LF-08 | iOS: Files 앱 연동 | 권장 |
| LF-09 | Android: SAF(Storage Access Framework) 지원 | 권장 |

---

### 3. 읽기 진행 및 기록

**설명:** 읽기 진행 상황을 추적하고 최근 읽은 책에 빠르게 접근할 수 있게 한다.

**요구사항:**

| ID | 요구사항 | 우선순위 |
|----|----------|----------|
| RP-01 | 리더 종료 시 현재 페이지 위치 저장 | 필수 |
| RP-02 | 책 열 때 마지막 읽은 페이지에서 재개 | 필수 |
| RP-03 | 홈 화면에 "이어서 읽기" 섹션 표시 | 필수 |
| RP-04 | 책 썸네일에 읽기 진행률 퍼센트 표시 | 필수 |
| RP-05 | 최근 읽은 목록을 마지막 읽은 시간 기준 정렬 | 필수 |
| RP-06 | 로컬 데이터베이스에 읽기 진행 저장 | 필수 |
| RP-07 | 책별 읽기 기록 추적 (소스 + 경로를 고유 식별자로 사용) | 필수 |
| RP-08 | 읽기 기록 삭제 옵션 | 권장 |
| RP-09 | 마지막 페이지 도달 시 "완료" 표시 | 권장 |
| RP-10 | 읽기 통계 (선택): 총 읽은 페이지, 읽기 시간 | 선택 |

---

### 4. 만화 리더 뷰

**설명:** 직관적인 내비게이션을 갖춘 전체 화면 만화 보기 경험.

**요구사항:**

| ID | 요구사항 | 우선순위 |
|----|----------|----------|
| RV-01 | 전체 화면 몰입형 읽기 모드 | 필수 |
| RV-02 | 가로 스와이프로 페이지 넘기기 | 필수 |
| RV-03 | 핀치 줌과 팬 지원 | 필수 |
| RV-04 | 더블 탭으로 줌 인/아웃 | 필수 |
| RV-05 | 화면 중앙 탭으로 컨트롤 오버레이 토글 | 필수 |
| RV-06 | 빠른 이동을 위한 페이지 슬라이더 | 필수 |
| RV-07 | 현재 페이지 / 전체 페이지 표시 | 필수 |
| RV-08 | 읽기 방향 옵션: 왼쪽→오른쪽, 오른쪽→왼쪽 | 권장 |
| RV-09 | 세로 스크롤 모드 (웹툰 스타일) | 권장 |
| RV-10 | 밝기 조절 오버레이 | 선택 |
| RV-11 | 배경색 옵션 (흰색, 검정, 세피아) | 선택 |
| RV-12 | 페이지 미리 로딩 (현재 ± 2페이지 메모리 유지) | 필수 |
| RV-13 | 메모리 관리: 멀리 있는 페이지 해제 | 필수 |
| RV-14 | 페이지 추출/로딩 중 로딩 표시 | 필수 |

**제스처:**
- 좌우 스와이프: 다음/이전 페이지
- 핀치: 줌
- 더블 탭: 줌 레벨 토글
- 중앙 싱글 탭: 컨트롤 표시/숨기기
- 가장자리 싱글 탭: 다음/이전 페이지 (선택)

---

### 5. 라이브러리 관리

**설명:** 만화 컬렉션을 정리하고 탐색한다.

**요구사항:**

| ID | 요구사항 | 우선순위 |
|----|----------|----------|
| LM-01 | 커버 썸네일이 있는 그리드 뷰 | 필수 |
| LM-02 | 리스트 뷰 옵션 | 권장 |
| LM-03 | 정렬 기준: 이름, 추가 날짜, 마지막 읽은 날짜 | 필수 |
| LM-04 | 제목으로 검색 | 권장 |
| LM-05 | WebDAV 소스에서 당겨서 새로고침 | 필수 |
| LM-06 | 빈 상태에 안내 메시지 표시 | 필수 |
| LM-07 | 로딩 상태에 스켈레톤/쉬머 효과 | 권장 |
| LM-08 | 첫 페이지에서 썸네일 생성 | 필수 |
| LM-09 | 썸네일 캐싱 | 필수 |

---

## 기술 아키텍처

### 기술 스택

| 구성요소 | 기술 |
|----------|------|
| 프레임워크 | Flutter 3.x |
| 상태 관리 | Riverpod |
| 로컬 데이터베이스 | SQLite (sqflite) |
| 키-값 저장소 | SharedPreferences |
| 보안 저장소 | flutter_secure_storage |
| 라우팅 | go_router |
| WebDAV 클라이언트 | webdav_client |
| 아카이브 처리 | archive (ZIP), unrar (RAR - 선택) |
| 이미지 뷰어 | photo_view |
| 파일 선택 | file_picker |

### 프로젝트 구조

```
lib/
├── main.dart
├── app.dart
│
├── core/
│   ├── constants/
│   │   ├── app_constants.dart
│   │   └── storage_keys.dart
│   ├── extensions/
│   │   └── string_extensions.dart
│   ├── utils/
│   │   ├── natural_sort.dart        # 자연 정렬 알고리즘
│   │   ├── file_utils.dart          # 파일 유틸리티
│   │   └── hash_utils.dart          # 해시 유틸리티
│   └── exceptions/
│       └── app_exceptions.dart
│
├── data/
│   ├── models/
│   │   ├── comic_book.dart          # 만화책 모델
│   │   ├── comic_page.dart          # 페이지 모델
│   │   ├── reading_progress.dart    # 읽기 진행 모델
│   │   ├── server_config.dart       # 서버 설정 모델
│   │   └── library_item.dart        # 라이브러리 아이템
│   │
│   ├── repositories/
│   │   ├── comic_repository.dart
│   │   ├── reading_progress_repository.dart
│   │   └── server_config_repository.dart
│   │
│   └── sources/
│       ├── local/
│       │   ├── database_helper.dart
│       │   ├── local_file_source.dart
│       │   └── archive_extractor.dart
│       └── remote/
│           └── webdav_source.dart
│
├── services/
│   ├── file_cache_service.dart      # 파일 캐시 서비스
│   ├── thumbnail_service.dart       # 썸네일 서비스
│   └── download_manager.dart        # 다운로드 관리자
│
├── providers/
│   ├── library_provider.dart
│   ├── reader_provider.dart
│   ├── webdav_provider.dart
│   ├── reading_progress_provider.dart
│   └── settings_provider.dart
│
└── ui/
    ├── screens/
    │   ├── home/
    │   │   ├── home_screen.dart
    │   │   └── widgets/
    │   │       ├── continue_reading_section.dart
    │   │       └── source_selector.dart
    │   │
    │   ├── library/
    │   │   ├── library_screen.dart
    │   │   └── widgets/
    │   │       ├── comic_grid_item.dart
    │   │       └── comic_list_item.dart
    │   │
    │   ├── reader/
    │   │   ├── reader_screen.dart
    │   │   └── widgets/
    │   │       ├── page_view_reader.dart
    │   │       ├── scroll_reader.dart
    │   │       ├── reader_controls.dart
    │   │       └── page_slider.dart
    │   │
    │   ├── webdav/
    │   │   ├── server_list_screen.dart
    │   │   ├── server_form_screen.dart
    │   │   └── browser_screen.dart
    │   │
    │   └── settings/
    │       └── settings_screen.dart
    │
    ├── widgets/
    │   ├── loading_indicator.dart
    │   ├── error_view.dart
    │   └── empty_state.dart
    │
    └── theme/
        ├── app_theme.dart
        └── app_colors.dart
```

---

## 데이터 모델

### ComicBook (만화책)

```dart
enum ComicSource { local, webdav }

class ComicBook {
  final String id;              // 생성된 해시 (source + serverId + path)
  final String title;           // 표시 이름 (확장자 제외한 파일명)
  final String path;            // 파일 경로 (로컬) 또는 원격 경로 (WebDAV)
  final ComicSource source;     // local | webdav
  final String? serverId;       // WebDAV 서버 ID (로컬은 null)
  final String? localCachePath; // WebDAV 파일의 캐시된 파일 경로
  final String? coverPath;      // 썸네일 이미지 경로
  final int pageCount;          // 총 페이지 수 (미추출 시 0)
  final int fileSize;           // 파일 크기 (바이트)
  final DateTime addedAt;       // 라이브러리 추가 시점
}
```

### ReadingProgress (읽기 진행)

```dart
class ReadingProgress {
  final String id;              // UUID
  final String bookId;          // ComicBook.id 참조
  final String title;           // 책 제목 (표시용 비정규화)
  final String? coverPath;      // 썸네일 경로 (비정규화)
  final ComicSource source;     // local | webdav
  final String? serverId;       // WebDAV 서버 ID
  final String filePath;        // 원본 파일 경로
  final int currentPage;        // 0부터 시작하는 현재 페이지
  final int totalPages;         // 총 페이지 수
  final bool isFinished;        // 마지막 페이지 도달 시 true
  final DateTime lastReadAt;    // 마지막 읽은 시간
  final DateTime createdAt;     // 처음 연 시간
}
```

### ServerConfig (서버 설정)

```dart
class ServerConfig {
  final String id;              // UUID
  final String name;            // 표시 이름
  final String url;             // WebDAV 서버 URL
  final String username;        // 인증 사용자명
  final String password;        // 인증 비밀번호 (암호화 저장)
  final String rootPath;        // 시작 탐색 경로 (기본값: "/")
  final bool allowSelfSigned;   // 자체 서명 SSL 인증서 허용
  final DateTime createdAt;     // 설정 생성 시간
}
```

### ComicPage (만화 페이지)

```dart
class ComicPage {
  final int index;              // 0부터 시작하는 페이지 번호
  final String path;            // 추출된 이미지 파일 경로
  final String originalName;    // 아카이브 내 원본 파일명
}
```

---

## 데이터베이스 스키마

### SQLite 테이블

```sql
-- 읽기 진행 추적
CREATE TABLE reading_progress (
  id TEXT PRIMARY KEY,
  book_id TEXT NOT NULL UNIQUE,
  title TEXT NOT NULL,
  cover_path TEXT,
  source TEXT NOT NULL,
  server_id TEXT,
  file_path TEXT NOT NULL,
  current_page INTEGER NOT NULL DEFAULT 0,
  total_pages INTEGER NOT NULL DEFAULT 0,
  is_finished INTEGER NOT NULL DEFAULT 0,
  last_read_at INTEGER NOT NULL,
  created_at INTEGER NOT NULL
);

CREATE INDEX idx_reading_progress_last_read ON reading_progress(last_read_at DESC);
CREATE INDEX idx_reading_progress_book_id ON reading_progress(book_id);

-- WebDAV 서버 설정
CREATE TABLE server_configs (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  url TEXT NOT NULL,
  username TEXT NOT NULL,
  password_encrypted TEXT NOT NULL,
  root_path TEXT NOT NULL DEFAULT '/',
  allow_self_signed INTEGER NOT NULL DEFAULT 0,
  created_at INTEGER NOT NULL
);

-- 썸네일 캐시 메타데이터
CREATE TABLE thumbnails (
  book_id TEXT PRIMARY KEY,
  path TEXT NOT NULL,
  created_at INTEGER NOT NULL
);

-- 다운로드 파일 캐시 메타데이터
CREATE TABLE file_cache (
  id TEXT PRIMARY KEY,
  book_id TEXT NOT NULL,
  remote_path TEXT NOT NULL,
  local_path TEXT NOT NULL,
  file_size INTEGER NOT NULL,
  downloaded_at INTEGER NOT NULL
);

CREATE INDEX idx_file_cache_book_id ON file_cache(book_id);
```

---

## 화면 명세

### 홈 화면

**목적:** 읽기 진행 상황과 라이브러리 접근을 보여주는 메인 진입점.

**레이아웃:**
```
┌─────────────────────────────────┐
│  만화 리더                  [⚙]  │  <- 앱 바 + 설정 버튼
├─────────────────────────────────┤
│  이어서 읽기                     │
│  ┌─────┐ ┌─────┐ ┌─────┐       │  <- 가로 스크롤
│  │ 75% │ │ 30% │ │ 10% │  ...  │
│  └─────┘ └─────┘ └─────┘       │
├─────────────────────────────────┤
│  [로컬] [서버1] [서버2]          │  <- 소스 탭
├─────────────────────────────────┤
│  ┌─────┐ ┌─────┐ ┌─────┐       │
│  │     │ │     │ │     │       │  <- 라이브러리 그리드
│  │     │ │     │ │     │       │
│  └─────┘ └─────┘ └─────┘       │
│  ┌─────┐ ┌─────┐ ┌─────┐       │
│  │     │ │     │ │     │       │
│  └─────┘ └─────┘ └─────┘       │
├─────────────────────────────────┤
│                           [+]   │  <- FAB: 파일 추가 (로컬만)
└─────────────────────────────────┘
```

**구성요소:**

1. **이어서 읽기 섹션**
   - 최근 읽은 책의 가로 스크롤 목록
   - lastReadAt 내림차순으로 최근 10개 표시
   - 각 아이템: 커버 썸네일, 제목 (말줄임), 진행률 바
   - 탭하면 마지막 위치에서 리더 열기
   - 읽기 기록 없으면 숨김

2. **소스 탭**
   - "로컬" 탭 항상 표시
   - 설정된 WebDAV 서버마다 탭 하나씩
   - 서버 탭 길게 누르면 편집/삭제

3. **라이브러리 그리드**
   - 폰에서 3열, 태블릿에서 4-5열
   - 각 아이템: 커버 썸네일, 제목, 진행률 표시 (시작한 경우)
   - 탭하면 리더 열기
   - 길게 누르면 컨텍스트 메뉴 (삭제, 정보)

4. **FAB (플로팅 액션 버튼)**
   - "로컬" 탭 선택 시에만 표시
   - 시스템 파일 선택기 열기

**상태:**
- 로딩: 스켈레톤 그리드
- 비어있음 (로컬): "아직 만화가 없습니다. +를 눌러 파일을 추가하세요."
- 비어있음 (WebDAV): "만화를 찾을 수 없습니다. 만화 파일이 있는 폴더로 이동하세요."
- 오류: 오류 메시지와 재시도 버튼

---

### WebDAV 브라우저 화면

**목적:** WebDAV 서버 디렉토리를 탐색하고 파일을 선택한다.

**레이아웃:**
```
┌─────────────────────────────────┐
│  [←]  /Comics/Manga             │  <- 뒤로 버튼 + 현재 경로
├─────────────────────────────────┤
│  📁 원피스                       │
│  📁 나루토                       │
│  📁 드래곤볼                     │
│  ──────────────────────────────│
│  📖 특별편.cbz           45 MB   │
│  📖 단편.zip             12 MB   │
│                                 │
│                                 │
└─────────────────────────────────┘
```

**구성요소:**

1. **앱 바**
   - 뒤로 버튼 (상위 디렉토리로 이동, 루트면 닫기)
   - 현재 경로 표시 (길면 왼쪽부터 말줄임)
   - 새로고침 버튼

2. **파일 목록**
   - 폴더 먼저, 그 다음 파일
   - 폴더 아이템: 폴더 아이콘, 이름
   - 파일 아이템: 책 아이콘, 이름, 파일 크기
   - 모든 아이템 자연 정렬

**인터랙션:**
- 폴더 탭: 해당 폴더로 이동
- 파일 탭: 다운로드 시작 후 리더 열기
- 당겨서 새로고침: 현재 디렉토리 다시 로드
- 스와이프 백 (iOS): 상위로 이동

**상태:**
- 로딩: 중앙 스피너 또는 스켈레톤 목록
- 비어있음: "이 폴더는 비어있습니다"
- 오류: 오류 메시지와 재시도
- 다운로드 중: 진행률 바와 취소 버튼이 있는 모달 오버레이

---

### 리더 화면

**목적:** 전체 화면 만화 읽기 경험.

**레이아웃 (컨트롤 숨김):**
```
┌─────────────────────────────────┐
│                                 │
│                                 │
│                                 │
│         [만화 페이지]            │
│                                 │
│                                 │
│                                 │
└─────────────────────────────────┘
```

**레이아웃 (컨트롤 표시):**
```
┌─────────────────────────────────┐
│ [←]  원피스 1권            [⋮]  │  <- 상단 바
│                                 │
│                                 │
│         [만화 페이지]            │
│                                 │
│                                 │
│ ○────────────●──────────────○   │  <- 페이지 슬라이더
│          15 / 120 페이지         │  <- 페이지 표시
└─────────────────────────────────┘
```

**구성요소:**

1. **페이지 뷰**
   - 줌 지원되는 가로 PageView
   - 각 페이지: 핀치 줌 가능한 PhotoView
   - 배경: 검정

2. **상단 바 (표시 시)**
   - 뒤로 버튼: 진행 저장 후 나가기
   - 제목: 책 제목 (말줄임)
   - 메뉴 버튼: 읽기 설정

3. **하단 바 (표시 시)**
   - 페이지 슬라이더: 드래그로 페이지 점프
   - 페이지 표시: "X / Y 페이지"

**제스처:**

| 제스처 | 동작 |
|--------|------|
| 왼쪽 스와이프 | 다음 페이지 |
| 오른쪽 스와이프 | 이전 페이지 |
| 중앙 탭 | 컨트롤 토글 |
| 왼쪽 가장자리 탭 | 이전 페이지 |
| 오른쪽 가장자리 탭 | 다음 페이지 |
| 핀치 | 줌 인/아웃 |
| 더블 탭 | 줌 토글 (맞춤/채움) |

**동작:**
- 진입: 시스템 UI 숨김 (상태 바, 내비게이션 바)
- 종료: 시스템 UI 복원, 현재 페이지 데이터베이스에 저장
- 페이지 변경: 메모리에서 읽기 진행 업데이트 (디바운스 저장)

---

### 설정 화면

**목적:** 앱 설정과 서버 관리.

**레이아웃:**
```
┌─────────────────────────────────┐
│  [←]  설정                      │
├─────────────────────────────────┤
│  읽기                           │
│  ──────────────────────────────│
│  읽기 방향                 [→]   │  <- 왼→오 / 오→왼
│  읽기 모드              [페이지] │  <- 페이지 / 스크롤
│  화면 켜짐 유지            [✓]   │
├─────────────────────────────────┤
│  WEBDAV 서버                    │
│  ──────────────────────────────│
│  🖥 내 NAS                  [>]  │
│  🖥 Nextcloud               [>]  │
│  + 서버 추가                     │
├─────────────────────────────────┤
│  저장소                         │
│  ──────────────────────────────│
│  캐시 크기              256 MB   │
│  캐시 비우기                     │
│  읽기 기록 삭제                  │
├─────────────────────────────────┤
│  정보                           │
│  ──────────────────────────────│
│  버전                    1.0.0   │
│  오픈소스 라이선스               │
└─────────────────────────────────┘
```

**섹션:**
- **읽기:** 읽기 방향, 모드, 화면 타임아웃
- **WebDAV 서버:** 서버 목록, 추가/편집/삭제
- **저장소:** 캐시 관리
- **정보:** 앱 정보

---

### 서버 폼 화면

**목적:** WebDAV 서버 설정 추가 또는 편집.

**레이아웃:**
```
┌─────────────────────────────────┐
│  [×]  서버 추가          [저장]  │
├─────────────────────────────────┤
│                                 │
│  표시 이름                       │
│  ┌─────────────────────────────┐│
│  │ 내 NAS                      ││
│  └─────────────────────────────┘│
│                                 │
│  서버 URL                       │
│  ┌─────────────────────────────┐│
│  │ https://nas.example.com     ││
│  └─────────────────────────────┘│
│                                 │
│  사용자명                        │
│  ┌─────────────────────────────┐│
│  │ admin                       ││
│  └─────────────────────────────┘│
│                                 │
│  비밀번호                        │
│  ┌─────────────────────────────┐│
│  │ ••••••••              [👁]  ││
│  └─────────────────────────────┘│
│                                 │
│  루트 경로 (선택)                │
│  ┌─────────────────────────────┐│
│  │ /Comics                     ││
│  └─────────────────────────────┘│
│                                 │
│  [ ] 자체 서명 인증서 허용       │
│                                 │
│  [연결 테스트]                   │
│                                 │
└─────────────────────────────────┘
```

**유효성 검사:**
- 표시 이름: 필수, 최대 50자
- 서버 URL: 필수, 유효한 URL 형식
- 사용자명: 필수
- 비밀번호: 필수
- 루트 경로: 선택, "/"로 시작해야 함

**연결 테스트:** 연결 시도 후 루트 디렉토리 목록 조회.

---

## 파일 처리

### 지원 아카이브 형식

| 형식 | 확장자 | 라이브러리 | 우선순위 |
|------|--------|------------|----------|
| ZIP | .zip, .cbz | archive | 필수 |
| RAR | .rar, .cbr | unrar_file | 권장 |

### 지원 이미지 형식

| 형식 | 확장자 |
|------|--------|
| JPEG | .jpg, .jpeg |
| PNG | .png |
| GIF | .gif |
| WebP | .webp |

### 아카이브 추출 프로세스

```
1. 아카이브 파일 열기
2. 모든 항목 나열
3. 이미지 확장자로 항목 필터링
4. 숨김 파일 필터링 ("."으로 시작하거나 __MACOSX 폴더)
5. 자연 정렬 알고리즘으로 항목 정렬
6. 캐시 디렉토리에 추출: {cache}/comics/{bookId}/
7. 파일명을 순차적으로 변경: 0000.jpg, 0001.png 등
8. ComicPage 객체 목록 반환
```

### 자연 정렬 알고리즘

파일명의 숫자 부분을 숫자로 비교하여 정렬:

```
입력:  page1.jpg, page10.jpg, page2.jpg, page20.jpg
출력: page1.jpg, page2.jpg, page10.jpg, page20.jpg
```

구현 방법:
1. 파일명을 숫자와 비숫자 세그먼트로 분리
2. 세그먼트를 쌍으로 비교
3. 숫자 세그먼트는 정수로 비교
4. 비숫자 세그먼트는 소문자 문자열로 비교

### 캐시 디렉토리 구조

```
{앱_캐시_디렉토리}/
├── comics/                      # 추출된 만화 페이지
│   ├── {bookId1}/
│   │   ├── 0000.jpg
│   │   ├── 0001.jpg
│   │   └── ...
│   └── {bookId2}/
│       └── ...
│
├── downloads/                   # 다운로드한 WebDAV 파일
│   ├── {hash1}.cbz
│   └── {hash2}.zip
│
└── thumbnails/                  # 커버 썸네일
    ├── {bookId1}.jpg
    └── {bookId2}.jpg
```

### 캐시 관리

**전략:**
- LRU (Least Recently Used) 제거
- 기본 최대 캐시 크기: 1 GB
- 설정에서 사용자 구성 가능
- 다운로드와 추출 페이지 별도 한도

**제거 우선순위:**
1. 읽기 기록에 없는 책의 추출 페이지
2. 가장 오래 전에 읽은 책의 추출 페이지
3. 읽기 기록에 없는 책의 다운로드 파일
4. 가장 오래 전에 읽은 책의 다운로드 파일

**삭제 금지:**
- 썸네일 (작고 라이브러리에 유용)
- 현재 읽고 있는 파일

---

## 오류 처리

### 오류 유형 및 사용자 메시지

| 오류 유형 | 조건 | 사용자 메시지 | 동작 |
|-----------|------|---------------|------|
| NetworkError | 인터넷 없음 | "인터넷 연결이 없습니다" | 재시도 버튼 |
| AuthError | 잘못된 자격 증명 | "인증에 실패했습니다. 자격 증명을 확인하세요." | 서버 편집 |
| NotFoundError | 파일/폴더 없음 | "이 항목이 더 이상 존재하지 않습니다" | 목록에서 제거 |
| CorruptArchiveError | 아카이브 읽기 불가 | "이 파일이 손상된 것 같습니다" | 오류 표시, 삭제 제안 |
| UnsupportedFormatError | 알 수 없는 형식 | "이 파일 형식은 지원되지 않습니다" | 지원 형식 표시 |
| StorageFullError | 디스크 꽉 참 | "저장 공간이 부족합니다" | 캐시 비우기 옵션 |
| TimeoutError | 요청 타임아웃 | "연결 시간이 초과되었습니다" | 재시도 버튼 |
| SSLError | 인증서 문제 | "SSL 인증서 오류" | 자체 서명 허용 제안 |

### 오프라인 동작

**오프라인 시:**
- 로컬 라이브러리: 완전히 작동
- WebDAV 브라우저: "오프라인입니다" 메시지 표시
- 다운로드한 책: 캐시에서 접근 가능
- 이어서 읽기: 로컬 캐시가 있는 모든 항목 표시
- 진행 동기화: 나중을 위해 대기열에 추가 (클라우드 동기화 구현 시)

**오프라인 표시:**
- 오프라인 시 화면 상단 배너
- 회색으로 표시된 WebDAV 서버 탭
- 캐시된 WebDAV 책에 "다운로드됨" 배지

---

## 성능 요구사항

### 목표

| 지표 | 목표 | 비고 |
|------|------|------|
| 콜드 스타트 | < 2초 | 앱 실행부터 홈 화면까지 |
| 페이지 넘김 | 60 fps | 부드러운 애니메이션 |
| 페이지 로드 | < 300ms | 페이지 이미지 표시 시간 |
| 썸네일 생성 | < 500ms | 책당 |
| 아카이브 추출 | < 5초 | 100페이지 만화 기준 |
| 메모리 (읽기 중) | < 200 MB | 활성 읽기 중 |
| 메모리 (유휴) | < 50 MB | 홈 화면에서 |

### 최적화 전략

**이미지 로딩:**
- 현재 페이지 ± 2페이지 미리 로드
- 현재 ± 4 이상의 페이지 해제
- 디스플레이 해상도로 이미지 디코딩, 원본 해상도 아님
- 메모리와 디스크 계층의 이미지 캐싱 사용

**아카이브 처리:**
- 첫 읽기 시 온디맨드로 페이지 추출
- 이후 읽기를 위해 백그라운드에서 캐시 추출
- 대용량 아카이브는 스트림 추출

**썸네일:**
- 아카이브 첫 페이지에서 생성
- 최대 200x300으로 리사이즈
- 무기한 캐시 (크기 작음)

**메모리 관리:**
```
// 페이지 메모리 관리 의사 코드
const PRELOAD_AHEAD = 2;
const PRELOAD_BEHIND = 2;
const KEEP_IN_MEMORY = 4;

void onPageChanged(int newPage) {
  // 범위 내 페이지 로드
  for (int i = newPage - PRELOAD_BEHIND; i <= newPage + PRELOAD_AHEAD; i++) {
    loadPage(i);
  }
  
  // 먼 페이지 언로드
  for (int i in loadedPages) {
    if ((i - newPage).abs() > KEEP_IN_MEMORY) {
      unloadPage(i);
    }
  }
}
```

---

## 보안 고려사항

### 자격 증명 저장

- `flutter_secure_storage`를 사용하여 WebDAV 비밀번호 저장
- iOS: Keychain
- Android: EncryptedSharedPreferences / Keystore

### 데이터 보호

- 로그나 디버그 출력에 평문 비밀번호 없음
- 앱 제거 시 민감한 데이터 삭제
- 선택: 생체 인증으로 앱 잠금 (향후 개선)

### 네트워크 보안

- 기본: 유효한 SSL 인증서 필요
- 선택: 서버별 자체 서명 인증서 허용 (사용자가 명시적으로 활성화해야 함)
- 프로덕션에서 HTTP(비HTTPS) 연결 없음

---

## 의존성

### pubspec.yaml

```yaml
name: comic_reader
description: WebDAV를 지원하는 만화책 리더
version: 1.0.0

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # 상태 관리
  flutter_riverpod: ^2.4.9
  
  # 네비게이션
  go_router: ^13.1.0
  
  # 로컬 저장소
  sqflite: ^2.3.2
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0
  path_provider: ^2.1.2
  
  # WebDAV
  webdav_client: ^2.1.1
  
  # 파일 처리
  archive: ^3.4.10
  file_picker: ^6.1.1
  path: ^1.8.3
  mime: ^1.0.5
  
  # 이미지 뷰어
  photo_view: ^0.14.0
  
  # UI 컴포넌트
  shimmer: ^3.0.0
  
  # 유틸리티
  uuid: ^4.3.1
  collection: ^1.18.0
  crypto: ^3.0.3
  connectivity_plus: ^5.0.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
```

---

## 개발 단계

### 1단계: 핵심 기반 (1-2주차)

**목표:** 로컬 파일로 기본 읽기 기능

**작업:**
- [ ] 폴더 구조로 프로젝트 설정
- [ ] 기본 테마와 앱 셸
- [ ] 로컬 파일 선택기 연동
- [ ] ZIP/CBZ 추출
- [ ] PageView가 있는 기본 리더 화면
- [ ] 핀치 줌 기능
- [ ] SQLite 데이터베이스 설정
- [ ] 읽기 진행 저장/복원

**산출물:** 진행 추적과 함께 로컬 ZIP/CBZ 파일을 가져오고 읽을 수 있음

---

### 2단계: 라이브러리 & UI 다듬기 (3주차)

**목표:** 홈 화면과 라이브러리 관리 완성

**작업:**
- [ ] 소스 탭이 있는 홈 화면
- [ ] 이어서 읽기 섹션
- [ ] 라이브러리 그리드 뷰
- [ ] 썸네일 생성 및 캐싱
- [ ] 아이템에 진행률 표시
- [ ] 빈 상태와 로딩 상태
- [ ] 리더 컨트롤 오버레이
- [ ] 페이지 슬라이더 내비게이션

**산출물:** 썸네일이 있는 로컬 라이브러리의 다듬어진 UI

---

### 3단계: WebDAV 연동 (4-5주차)

**목표:** 전체 WebDAV 지원

**작업:**
- [ ] 서버 설정 CRUD
- [ ] 보안 자격 증명 저장
- [ ] WebDAV 클라이언트 연동
- [ ] 디렉토리 브라우저 화면
- [ ] 진행률이 있는 파일 다운로드
- [ ] 다운로드 캐싱
- [ ] 다운로드한 파일의 오프라인 지원
- [ ] 네트워크 문제 오류 처리

**산출물:** WebDAV 서버에서 탐색하고 읽을 수 있음

---

### 4단계: 설정 & 다듬기 (6주차)

**목표:** 전체 기능 세트와 다듬기

**작업:**
- [ ] 설정 화면
- [ ] 읽기 방향 옵션
- [ ] 캐시 관리
- [ ] 기록 삭제 기능
- [ ] 앱 아이콘과 스플래시 화면
- [ ] 성능 최적화
- [ ] 버그 수정과 엣지 케이스
- [ ] 여러 기기에서 테스트

**산출물:** 출시 준비된 애플리케이션

---

### 향후 개선 (MVP 이후)

- [ ] CBR/RAR 지원
- [ ] 세로 스크롤 읽기 모드
- [ ] 라이브러리 검색
- [ ] 컬렉션/폴더
- [ ] 진행 클라우드 동기화
- [ ] 태블릿 레이아웃 (양면 보기)
- [ ] 데스크톱 지원
- [ ] OPDS 카탈로그 지원
- [ ] PDF 지원

---

## 부록

### A. Book ID 생성

소스, 서버, 경로에서 고유 ID 생성:

```dart
String generateBookId(ComicSource source, String? serverId, String path) {
  final input = '${source.name}:${serverId ?? 'local'}:$path';
  final bytes = utf8.encode(input);
  final digest = sha256.convert(bytes);
  return digest.toString().substring(0, 16);
}
```

### B. 자연 정렬 구현

```dart
int naturalCompare(String a, String b) {
  final regex = RegExp(r'(\d+)|(\D+)');
  final partsA = regex.allMatches(a).map((m) => m.group(0)!).toList();
  final partsB = regex.allMatches(b).map((m) => m.group(0)!).toList();

  for (var i = 0; i < partsA.length && i < partsB.length; i++) {
    final partA = partsA[i];
    final partB = partsB[i];

    final numA = int.tryParse(partA);
    final numB = int.tryParse(partB);

    int cmp;
    if (numA != null && numB != null) {
      cmp = numA.compareTo(numB);
    } else {
      cmp = partA.toLowerCase().compareTo(partB.toLowerCase());
    }

    if (cmp != 0) return cmp;
  }

  return partsA.length.compareTo(partsB.length);
}

extension NaturalSort<T> on List<T> {
  void sortNatural(String Function(T) keyExtractor) {
    sort((a, b) => naturalCompare(keyExtractor(a), keyExtractor(b)));
  }
}
```

### C. 아카이브용 이미지 필터

```dart
bool isImageFile(String filename) {
  // 숨김 파일과 macOS 리소스 포크 건너뛰기
  if (filename.startsWith('.') || filename.contains('__MACOSX')) {
    return false;
  }
  
  final ext = path.extension(filename).toLowerCase();
  return const {'.jpg', '.jpeg', '.png', '.gif', '.webp'}.contains(ext);
}
```

### D. WebDAV URL 검증

```dart
bool isValidWebDavUrl(String url) {
  try {
    final uri = Uri.parse(url);
    return uri.hasScheme && 
           (uri.scheme == 'http' || uri.scheme == 'https') &&
           uri.host.isNotEmpty;
  } catch (e) {
    return false;
  }
}
```
