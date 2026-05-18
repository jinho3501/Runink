# 🏃‍♀️ RunInk (런잉크)

> **러닝, 운동을 넘어 문화가 되다.**
> 사진 한 장으로 내 위치 기반 **GPS 아트 러닝 경로**를 자동 생성하는 — 개성과 재미 중심의 러닝 앱

<p align="left">
  <img src="https://img.shields.io/badge/Flutter-3.5%2B-02569B?logo=flutter&logoColor=white" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white" alt="Dart"/>
  <img src="https://img.shields.io/badge/Firebase-Auth-FFCA28?logo=firebase&logoColor=black" alt="Firebase"/>
  <img src="https://img.shields.io/badge/Google%20Maps-API-4285F4?logo=googlemaps&logoColor=white" alt="Google Maps"/>
  <img src="https://img.shields.io/badge/AWS-EC2%20backend-FF9900?logo=amazonec2&logoColor=white" alt="AWS"/>
  <img src="https://img.shields.io/badge/Platform-iOS%20%7C%20Android-lightgrey" alt="Platform"/>
  <img src="https://img.shields.io/badge/LG%20DX%20School-1기%20바잇킹-A50034" alt="LG DX School"/>
</p>

---

## ✨ 핵심 차별점

**"사진을 넣기만 하면, 사용자 현재 위치 기반으로 GPS 아트 경로를 자동 생성!"**

| | GPSArtify | Strava | **RunInk** |
|---|:---:|:---:|:---:|
| 사용 요금 | $7.99/월 | 무료 | **무료** |
| GPS 아트 자동 생성 | 업로드 이미지 한정 | 없음 (수작업) | **원하는 모양 자유 지원** |
| 사용자 위치 기반 | ✗ | ✗ | **○** |
| 러닝 앱 내비게이션 | ✗ | ○ | **○** |
| 공유 / 자랑 | ✗ | ○ | **○** |

---

## 🎯 주요 기능

### 1. 🎨 GPS 아트 자동 생성 ([`Event/Ink/Ink.dart`](lib/RunInk/Event/Ink/Ink.dart))
- 갤러리에서 이미지 선택 → 백엔드가 OSM 도로망에 매칭 → 가장 유사한 러닝 경로 생성
- 사전 정의 모양(`Heart`·`Square`·`Star`)을 캐러셀 UI로 즉시 선택
- `NumberPicker`로 목표 거리 1~42km 설정

### 2. 🧭 실시간 내비게이션 ([`selected_route_page.dart`](lib/RunInk/selected_route_page.dart))
- **Haversine 공식**으로 GPS 좌표 간 거리 계산 (오프라인 동작)
- **atan2 Bearing**으로 다음 지점 방향 산출 → 8방위 한국어 안내
- 30m 이내 진입 시 "잠시 후 좌/우회전" 사전 안내
- 경로 이탈 감지(20m tolerance) + 인덱스 ±5 탐색 최적화

### 3. ⚠️ 안전 경고 시스템
출발 직전 다이얼로그로 경로상 위험 요소 사전 고지:
- 인구 밀집지역 · 횡단보도 · 골목길 교차로 · 경사로

### 4. 📸 결과 공유 ([`workout_result_page.dart`](lib/RunInk/workout_result_page.dart))
- `RepaintBoundary` + `share_plus`로 결과 화면 전체를 PNG 캡쳐 → 인스타·X 등 SNS 공유
- 페이스/칼로리 자동 계산, 다크 모드 맵 스타일

### 5. 👥 러닝 크루 & 이벤트
- `Group` — 크루 검색·생성·게시글 (`image_picker` 사진 업로드)
- `Event` — Ink(GPS 아트), Brand(브랜드 콜라보), Anniversary(기념일), Local(지역 연계) 4종 이벤트
- `Rank` — 크루 / 개인 랭킹 + 수집 갤러리(3×4 그리드)

### 6. 📊 마이페이지 ([`MyPage/MyPage.dart`](lib/RunInk/MyPage/MyPage.dart))
- `fl_chart`로 일/월/년 단위 누적 거리 그래프 시각화
- 프로필·랭킹·보상 상점(`carousel_slider`)

---

## 🏗 시스템 아키텍처

```
┌─────────────────────────────────────────────────────────────┐
│  📱 Flutter App (iOS / Android) — 30 screens, ~8K LOC      │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  ConvexAppBar 5탭                                     │  │
│  │  Rank │ Ink │ CenterPage │ Group │ My                 │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                             │
│  google_maps_flutter · location · http · image_picker      │
│  firebase_auth · google_sign_in · share_plus · fl_chart    │
└──────────────────────────┬──────────────────────────────────┘
                           │ HTTP / JSON / Multipart
                           ▼
┌─────────────────────────────────────────────────────────────┐
│  ☁️  Backend API (AWS EC2 — FastAPI)                       │
│                                                             │
│  POST /signin · /login · /user · /rankings                  │
│  POST /center · /message · /upload_image                    │
│  GET  /load_image · /ann · /local                           │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│  🔥 Firebase — Auth / Firestore / Storage                   │
└─────────────────────────────────────────────────────────────┘
```

---

## 🗂 프로젝트 구조

```
lib/
├── main.dart                       # 엔트리포인트 (Firebase init + 로그인 라우팅)
├── Bottom_Bar.dart                 # 5탭 ConvexAppBar (Rank/Ink/Center/Group/My)
├── Loading.dart                    # 스플래시
├── Image_route_page.dart           # 이미지 → GPS 아트 변환 화면
├── firebase_options.dart           # ⚠️ git ignored (SETUP.md 참고)
│
├── Member/                         # 인증 & 온보딩 (8 files, ~1K LOC)
│   ├── Start.dart                  # 온보딩 시작
│   ├── LoginScreen.dart            # 로그인 (Firebase + 자체 API)
│   ├── SignUpScreen.dart           # 회원가입 (비밀번호 강도 검증)
│   ├── Introduce.dart              # 프로필(이름·생일·성별)
│   ├── Information.dart            # 약관 동의
│   ├── Watch.dart / Watch_Sign.dart  # 웨어러블 기기 연동
│   └── SLButton.dart               # 공용 SNS 로그인 버튼
│
├── Run/                            # 러닝 결과 관련
│   ├── Run_Result.dart             # 운동 결과
│   └── Image_Edit.dart             # 결과 이미지 편집(스티커·캡쳐)
│
└── RunInk/                         # 메인 도메인 (~6K LOC)
    ├── selected_route_page.dart    # 🌟 GPS 아트 따라 러닝 + 내비 (723 LOC)
    ├── workout_result_page.dart    # 결과 + 공유 (469 LOC)
    │
    ├── CenterPage/
    │   ├── CenterPage.dart         # 메인 피드 (442 LOC)
    │   └── RunningTracker.dart     # 자유 러닝 + 목표 시간 (362 LOC)
    │
    ├── Event/                      # 4종 이벤트
    │   ├── Event.dart              # 이벤트 허브
    │   ├── Ink/Ink.dart            # 🌟 GPS 아트 메인 (540 LOC)
    │   ├── Brand/Brand.dart        # 브랜드 콜라보
    │   ├── Anniversary/            # 기념일 이벤트
    │   └── Local/Local.dart        # 지역 연계
    │
    ├── Group/                      # 러닝 크루
    │   ├── Group.dart              # 크루 메인 (TabController)
    │   ├── Crew.dart / Crew1.dart  # 크루 상세
    │   ├── Group_Edit.dart         # 글쓰기
    │   └── Group_Search.dart       # 검색·필터
    │
    ├── MyPage/                     # 마이페이지
    │   ├── MyPage.dart             # 메인 (fl_chart)
    │   ├── MyPage_setting.dart     # 사용자 정보·랭크
    │   ├── Store.dart              # 보상 상점 (carousel_slider)
    │   └── Settings.dart           # 설정 (shared_preferences)
    │
    └── Rank/
        ├── Rank.dart               # 크루/개인 랭킹 (558 LOC)
        └── Individual.dart         # 수집 갤러리

assets/
├── images/, Ink/, Brand/, Ann/, Local/, ...   # 화면별 리소스
├── silim_heart.json                # 신림 하트 경로 좌표 샘플
├── yongsan_heart.json              # 용산 하트 경로 좌표 샘플
└── tracking_sample.json            # GPS 트래킹 테스트 데이터
```

---

## 🛠 기술 스택

| 영역 | 패키지·버전 | 활용 |
|---|---|---|
| **Core** | Flutter ^3.5.3, Dart 3.x | Material Design 3 |
| **지도** | google_maps_flutter ^2.9.0 | 지도·Polyline·카메라 제어 |
| **위치** | location ^7.0.1 | GPS 권한·실시간 추적 (1초 interval, 5m 필터) |
| **HTTP** | http ^1.2.2 | REST + multipart 업로드 |
| **인증** | firebase_core ^3.6.0, firebase_auth ^5.3.1, google_sign_in ^6.2.2 | Firebase + 자체 백엔드 하이브리드 |
| **UI** | convex_bottom_bar, carousel_slider, fl_chart, numberpicker | 하단 바·캐러셀·차트·휠 피커 |
| **미디어** | image_picker, share_plus | 갤러리 선택·OS 공유 |
| **저장** | shared_preferences | 자동 로그인 |
| **유틸** | intl ^0.19.0 | 날짜 포맷 |

---

## 🚀 시작하기

> ⚠️ 본 저장소에는 **Firebase 설정 파일과 Google Maps API 키가 포함되어 있지 않습니다.**
> 자세한 셋업은 [SETUP.md](./SETUP.md)를 참고하세요.

빠른 요약:
```bash
git clone https://github.com/<your-username>/Runink.git
cd Runink
flutter pub get
cd ios && pod install && cd ..

# 1) Firebase 설정 (SETUP.md 1단계)
# 2) Google Maps API 키 입력 (SETUP.md 2단계)
# 3) 백엔드 URL 변경 (SETUP.md 3단계)

flutter run
```

---

## 🎓 기획 배경 (요약)

### 데이터 분석 기반 의사결정
- SNS 5개 채널 약 **3만 건 크롤링** (X·Instagram·휴먼레이스·DC런갤·브런치, 2022~2024)
- 키워드 빈도·증감률 분석 → `기록` +250%, `트레일` +223%, `러닝크루`·`러닝스타그램`·`런린이` 신규 진입
- 장소: `헬스장` -12%, 외부 러닝(`거리`·`트레일`·`동네`) 폭증

### 페르소나 도출 (PCA + Hierarchical Clustering, n=2)
| | 🟠 도전형 초보 러너 (71.6%) | 🟢 개성형 숙련 러너 (14.2%) |
|---|---|---|
| Keywords | #뛰다 #재미 #시작 #싶다 | #다양하다 #SNS #브랜드 #슈즈 |
| Pain Point | 지루함, 동기부여 부족 | 비슷한 인증 콘텐츠, 개성 표현 부재 |
| Insight | 쉽고 재미있는 진입 | 차별화된 자기 표현 수단 |

→ 두 페르소나의 공통점: **"지루함 → 즐거움"**
→ 솔루션: **GPS 아트로 러닝 자체를 재미있게 + 공유 가능한 결과물로 개성 표현**

---

## 💰 수익 모델

- 🏷 **브랜드 콜라보** — NIKE 강남 본사 등 한정판 GPS 아트 경로·굿즈
- 🎟 **NFT 마켓 플레이스** — 완주한 GPS 아트를 NFT 발행·거래
- 📍 **지역 연계 프로모션** — 지자체·로컬 상권 연계 (예: 대전 빵집 할인 쿠폰)
- 🌸 **축제 광고** — 한강 벚꽃축제 등 시즌 이벤트 매칭

---

## 👥 팀 — 바잇킹 (LG전자 DX School 1기)

| 영역 | 주요 활동 |
|---|---|
| BX (Brand Experience) | 러닝 트렌드 정성·정량 분석, 브랜드 포지셔닝 |
| CX (Customer Experience) | 페르소나 도출, 니즈·페인 포인트 정의 |
| Service | 핵심 기능 설계, 경쟁사 비교 |
| Development | Flutter 앱 30화면 구현, FastAPI 백엔드 + AWS EC2 운영 |

---

## 📄 추가 문서

- [SETUP.md](./SETUP.md) — Firebase·Google Maps·백엔드 설정 가이드
- [INTERVIEW_GUIDE.md](./INTERVIEW_GUIDE.md) — 상세 코드 리뷰 & 기술 deep-dive

---

## 📜 라이선스

본 프로젝트는 LG전자 DX School 1기 교육 과정의 산출물입니다.
교육·포트폴리오 목적의 참고용으로 자유롭게 열람하실 수 있습니다.

---

<p align="center">
  <b>Let's RunInk 🖋️</b><br/>
  <i>당신의 발자국이 곧 작품이 됩니다.</i>
</p>
