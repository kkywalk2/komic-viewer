# Komic Viewer - 개발 진행 상황

## 프로젝트 개요
Flutter 기반 만화책 뷰어 앱. 상세 스펙은 `comic_reader_spec_ko.md` 참조.

## 완료된 단계

### 1단계: 핵심 기반 (완료)
- [x] pubspec.yaml 패키지 추가 (riverpod, go_router, sqflite, archive, photo_view 등)
- [x] 데이터 모델: ComicBook, ComicPage, ReadingProgress, ServerConfig
- [x] 유틸리티: 자연 정렬, 해시, 파일 유틸
- [x] SQLite 데이터베이스 설정
- [x] ZIP/CBZ 아카이브 추출기
- [x] 리포지토리 계층
- [x] Riverpod 프로바이더
- [x] 라우팅 (go_router)
- [x] 홈 화면 (라이브러리 그리드, 이어서 읽기 섹션)
- [x] 리더 화면 (전체화면, 핀치 줌, 페이지 슬라이더)

**주의:** `flutter pub get` 실행 필요

## 남은 단계

### 2단계: 라이브러리 & UI 다듬기 (완료)
- [x] 리스트 뷰 옵션 (그리드/리스트 전환)
- [x] 정렬 기능 (제목, 추가일, 크기 - 오름차순/내림차순)
- [x] 로딩/빈 상태 UI 개선
- [x] 스켈레톤/쉬머 효과
- [ ] 썸네일 생성 및 캐싱 (자동 커버 추출은 3단계에서 개선 예정)

### 3단계: WebDAV 연동
- [ ] 서버 설정 CRUD
- [ ] 보안 자격 증명 저장
- [ ] WebDAV 클라이언트 연동
- [ ] 디렉토리 브라우저 화면
- [ ] 파일 다운로드 및 캐싱

### 4단계: 설정 & 다듬기
- [ ] 설정 화면
- [ ] 읽기 방향 옵션
- [ ] 캐시 관리
- [ ] 앱 아이콘/스플래시

## 현재 파일 구조
```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/app_constants.dart
│   └── utils/
│       ├── natural_sort.dart
│       ├── hash_utils.dart
│       └── file_utils.dart
├── data/
│   ├── models/
│   │   ├── comic_book.dart
│   │   ├── comic_page.dart
│   │   ├── reading_progress.dart
│   │   └── server_config.dart
│   ├── repositories/
│   │   ├── comic_repository.dart
│   │   └── reading_progress_repository.dart
│   └── sources/local/
│       ├── database_helper.dart
│       ├── archive_extractor.dart
│       └── local_file_source.dart
├── providers/
│   ├── library_provider.dart
│   ├── preferences_provider.dart    # NEW: 뷰 모드/정렬 설정
│   ├── reader_provider.dart
│   └── reading_progress_provider.dart
└── ui/
    ├── screens/
    │   ├── home/
    │   │   ├── home_screen.dart
    │   │   └── widgets/
    │   │       ├── comic_list_item.dart        # NEW: 리스트 뷰 아이템
    │   │       ├── continue_reading_section.dart
    │   │       ├── empty_library_state.dart    # NEW: 빈 상태 UI
    │   │       └── library_header.dart         # NEW: 헤더 (정렬/뷰 토글)
    │   └── reader/
    │       ├── reader_screen.dart
    │       └── widgets/
    │           ├── page_view_reader.dart
    │           └── reader_controls.dart
    ├── widgets/shimmer/                        # NEW: 쉬머 위젯
    │   ├── library_shimmer.dart
    │   ├── shimmer_continue_reading.dart
    │   ├── shimmer_grid_item.dart
    │   └── shimmer_list_item.dart
    └── theme/app_theme.dart
```
