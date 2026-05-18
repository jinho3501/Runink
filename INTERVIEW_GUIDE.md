# 🏃‍♀️ RunInk — 면접용 프로젝트 설명 & 코드 리뷰 가이드

> 진호(Jinho) — LG전자 DX School 1기 / Team. 바잇킹
> 실제 코드 기반 분석 (Flutter Dart ~8,094줄, 30개 화면)

---

## 1. 한 줄 / 30초 / 3분 자기소개

### 🎯 한 줄 (엘리베이터 피치)
> "RunInk는 **사진 한 장만 넣으면 사용자 현재 위치 기반으로 GPS 아트 러닝 경로를 자동 생성해주는** Flutter 기반 크로스플랫폼 러닝 앱입니다. LG DX School 팀 프로젝트로 30k 건의 SNS 데이터 분석부터 백엔드 운영(AWS EC2), Flutter 앱 30개 화면 구현까지 풀스택으로 진행했습니다."

### ⏱ 30초 버전
> "기존 러닝 앱(Strava, NRC, 런데이)이 단순 기록·인증에 머무는 한계를 데이터로 검증했습니다. 인스타그램·X·런갤러리 3만 건을 크롤링·토픽 모델링한 결과, 러너들이 **'재미'와 '개성 표현'** 을 원한다는 인사이트를 도출했고, 이를 해결하기 위해 **이미지 입력만으로 GPS 아트 경로를 자동 생성**하는 RunInk를 만들었습니다. Flutter로 30개 화면, FastAPI 백엔드를 AWS EC2에 배포해 실제 동작하는 MVP를 완성했습니다."

### 🎤 3분 발표 버전
1. **문제 정의 (40초)** — 한국 러닝 인구가 폭발적으로 늘고(`기록` 키워드 +250%, `트레일` +223%), '러닝스타그램', '러닝크루', '런린이'가 신규 키워드로 진입했습니다. 그러나 기존 앱은 페이스·거리 기록 중심이라 **재미와 개성 표현 욕구**를 충족시키지 못했습니다.
2. **솔루션 (40초)** — PCA + 계층 클러스터링으로 두 페르소나(도전형 초보 러너 71.6% / 개성형 숙련 러너 14.2%)를 도출하고, 공통 인사이트인 **"지루함 → 즐거움"** 을 해결하기 위해 GPS 아트 자동 생성을 핵심 차별점으로 잡았습니다.
3. **구현 (60초)** — Flutter 3.5로 5탭 메인 + 30개 화면을 구현했고, 갤러리 이미지를 FastAPI 백엔드(AWS EC2 `43.203.107.133:8000`)에 multipart 업로드하면 OSM 도로망에서 가장 유사한 경로를 자동 생성합니다. **Haversine 공식으로 거리, atan2 기반 Bearing으로 8방위 한국어 내비게이션, 20m tolerance 경로 이탈 감지** 알고리즘을 직접 구현했습니다.
4. **임팩트 (40초)** — Strava의 수작업 GPS 아트 / GPSArtify의 $7.99 유료 모델 대비 **'위치 기반 자동 생성 + 무료'** 라는 명확한 차별점을 갖췄고, 브랜드 콜라보·NFT·지역 연계 4가지 수익 모델을 제시했습니다.

---

## 2. 시스템 아키텍처

```
┌─────────────────────────────────────────────────────────────┐
│                      User (Runner)                          │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│  📱 Flutter App (iOS / Android)                             │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ ConvexAppBar 5탭                                     │   │
│  │ ┌────┐ ┌────┐ ┌────────┐ ┌─────┐ ┌────┐             │   │
│  │ │Rank│ │Ink │ │Center  │ │Group│ │My  │             │   │
│  │ └────┘ └────┘ └────────┘ └─────┘ └────┘             │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                             │
│  • google_maps_flutter ─ 지도 렌더링 + Polyline             │
│  • location ─ 실시간 GPS 권한·추적 (1초 interval, 5m 필터)  │
│  • image_picker ─ 갤러리에서 GPS 아트 입력 이미지 선택      │
│  • firebase_auth + google_sign_in ─ 인증                    │
│  • shared_preferences ─ 자동 로그인 상태 유지               │
│  • share_plus + RepaintBoundary ─ 결과 캡쳐 → SNS 공유      │
└──────────────────────────┬──────────────────────────────────┘
                           │ HTTP / JSON / Multipart
                           ▼
┌─────────────────────────────────────────────────────────────┐
│  ☁️  Backend (AWS EC2 — http://43.203.107.133:8000)        │
│                                                             │
│  POST /signin       회원가입 + 프로필                        │
│  POST /login        로그인 (Firebase Auth 병행)             │
│  POST /user         사용자 정보 조회                         │
│  POST /center       메인 진입 위치 전송                      │
│  POST /message      위치 → Heart/Square/Star 자동 경로 생성  │
│  POST /upload_image 이미지 + 위치 + 거리 → GPS 아트 경로     │
│  GET  /load_image   Brand 이벤트 경로                       │
│  GET  /ann          Anniversary 이벤트 경로                 │
│  GET  /local        Local 이벤트 경로                       │
│  POST /rankings     랭킹 데이터                              │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│  🔥 Firebase (BaaS — byte-king 프로젝트)                    │
│     Auth / Firestore / Storage                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 3. 핵심 사용자 여정 (User Flow)

### 🎨 시나리오 A: 이미지로 GPS 아트 그리기 (메인 차별 기능)

```
[Ink 탭 진입]
   └─ Ink.dart (MapPage, 540줄)
      ├─ 현재 위치 자동 수신 (location 패키지)
      ├─ POST /message 호출 → Heart/Square/Star 사전 정의 경로 3종 자동 수신
      ├─ PageView로 캐러셀 UI (좌우 스와이프로 모양 선택)
      └─ 선택된 경로는 검은색 / 나머지는 회색 Polyline 렌더링

[+ 버튼 → 이미지로 경로 추가]
   └─ image_picker로 갤러리 이미지 선택
   └─ Image_route_page.dart (230줄)
      ├─ 선택 이미지 미리보기
      ├─ NumberPicker로 목표 거리 1~42km 설정
      └─ POST /upload_image (multipart) → 백엔드가 도로망 매칭

[경로 생성 완료]
   └─ SelectedRoutePage.dart (723줄, 가장 큰 파일)
      ├─ 안전 경고 다이얼로그 (인구밀집/횡단보도/골목길/경사로)
      ├─ 운동 시작 → Haversine 거리 계산 + Bearing 방향 안내
      ├─ 경로 이탈 감지 (20m tolerance)
      └─ 일시정지/재개/종료

[운동 종료]
   └─ workout_result_page.dart (469줄)
      ├─ 날짜·제목·거리·시간·페이스·칼로리 표시
      ├─ Google Maps 폴리라인으로 실주행 경로 시각화
      └─ RepaintBoundary로 전체 화면 캡쳐 → share_plus로 SNS 공유
```

### 🏃 시나리오 B: 자유 러닝 (목표 시간 설정 가능)

```
[Center 탭] → RunningTracker.dart (362줄)
   ├─ targetTimeInSeconds 선택적 입력 (목표 시간)
   ├─ 듀얼 타이머: 운동 시간 + 목표 카운트다운
   ├─ 목표 시간 도달 시 자동 일시정지 + "계속하기" 옵션
   └─ 종료 시 동일하게 WorkoutResultPage로 전환
```

---

## 4. 직접 구현한 기술적 도전 (면접 어필 포인트)

### 💡 ① Haversine 공식으로 GPS 좌표 간 거리 계산
**위치**: `lib/RunInk/selected_route_page.dart:244-251`, `RunningTracker.dart:216-223`, `workout_result_page.dart:329-336`

```dart
double _calculateDistance(LatLng point1, LatLng point2) {
  var p = 0.017453292519943295;  // π/180
  var c = math.cos;
  var a = 0.5 - c((point2.latitude - point1.latitude) * p) / 2 +
      c(point1.latitude * p) * c(point2.latitude * p) *
          (1 - c((point2.longitude - point1.longitude) * p)) / 2;
  return 12742 * math.asin(math.sqrt(a)) * 1000;  // 지구 반지름 6371km × 2
}
```

**면접 포인트**:
- Google Maps Distance API를 쓰면 비용·네트워크 지연 발생 → **수학적 직접 계산으로 오프라인·실시간 동작 보장**
- 미터 단위 반환으로 즉시 비교 가능
- 1초마다 GPS 콜백에서 호출되므로 `radians` 변환 상수를 미리 계산해 성능 최적화

### 💡 ② Bearing (방위각) 계산 + 8방위 한국어 내비
**위치**: `lib/RunInk/selected_route_page.dart:253-264, 233-242`

```dart
double _calculateBearing(LatLng start, LatLng end) {
  // ... atan2(y, x) * 180/π
  return (bearing + 360) % 360;
}

String _getNavigationInstruction(double bearing) {
  if (bearing >= 337.5 || bearing < 22.5) return '북쪽으로 이동';
  if (bearing >= 22.5  && bearing < 67.5)  return '북동쪽으로 이동';
  // ... 8방위 모두 처리
}
```

**면접 포인트**:
- 다음 경로 지점까지의 방위각을 atan2로 계산 → **사용자에게 직관적인 방향 안내**
- 30m 이내 진입 시 "잠시 후 우회전/좌회전" 으로 사전 안내 UX

### 💡 ③ 경로 이탈 감지 + 인덱스 탐색 최적화
**위치**: `lib/RunInk/selected_route_page.dart:178-231`

```dart
int searchRange = 5;   // 현재 인덱스 ±5 범위만 탐색
int startIndex = math.max(0, _currentRouteIndex - searchRange);
int endIndex = math.min(routePoints.length - 1, _currentRouteIndex + searchRange);

for (int i = startIndex; i <= endIndex; i++) {
  double distance = _calculateDistance(currentLatLng, routePoints[i]);
  if (distance < minDistance) { ... }
}

if (minDistance > _toleranceDistance) {  // 20m
  _navigationInstruction = '경로를 이탈했습니다. 경로로 돌아와주세요.';
}
```

**면접 포인트**:
- 전체 경로 점이 수백~수천 개여도 **인접 인덱스 ±5만 비교**해 O(N)→O(1)에 가까운 성능
- 20m tolerance로 GPS 노이즈 흡수 + 실제 이탈 구분

### 💡 ④ 위젯 캡쳐 + SNS 공유 (인증 욕구 충족)
**위치**: `lib/RunInk/workout_result_page.dart:63-88`

```dart
RenderRepaintBoundary boundary = _globalKey.currentContext!
    .findRenderObject() as RenderRepaintBoundary;
ui.Image image = await boundary.toImage(pixelRatio: 3.0);
ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
// ... 임시 디렉토리 저장 → Share.shareXFiles
```

**면접 포인트**:
- `RepaintBoundary` + `GlobalKey`로 **Flutter 위젯 트리를 PNG로 캡쳐**
- `pixelRatio: 3.0`으로 레티나 디스플레이 대응
- 페르소나 분석에서 도출한 **"SNS 인증 욕구"** 를 코드로 직접 풀어냄

### 💡 ⑤ Firebase + 자체 백엔드 하이브리드 인증
**위치**: `lib/main.dart:11-20`, `lib/Member/LoginScreen.dart` (241줄)

```dart
final prefs = await SharedPreferences.getInstance();
final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
runApp(MyApp(isLoggedIn: isLoggedIn));
```

**면접 포인트**:
- **Firebase Auth로 보안·소셜 로그인 위임**, 자체 백엔드는 비즈니스 데이터만 관리하는 BaaS 패턴
- `shared_preferences`로 자동 로그인 → 첫 진입 UX 향상

### 💡 ⑥ 백엔드 API 설계 + AWS EC2 운영 경험
**활용 엔드포인트**: 10개 (POST 8 / GET 2)

- 단순 CRUD가 아니라 **`/upload_image`처럼 multipart + JSON 응답이 중첩된 복합 API**를 다룸
- 응답 JSON 구조 (`route.routes[0]`, `distance.route_distance` 등) 파싱 로직 직접 구현
- 실제 운영 중인 EC2에 배포해 **mock이 아닌 실제 데이터로 검증** 완료

---

## 5. 프로젝트 구조 한눈에

| 모듈 | 파일 수 | 라인 수 | 주요 화면 |
|---|:---:|:---:|---|
| **앱 진입** | 3 | 255 | `main.dart`, `Loading.dart`, `Bottom_Bar.dart` (5탭 ConvexAppBar) |
| **Member** (인증·온보딩) | 8 | 1,024 | LoginScreen, SignUpScreen, Introduce(생년월일·성별), Information(약관), Watch (웨어러블) |
| **RunInk/CenterPage** | 2 | 804 | 메인 피드 + RunningTracker (자유 러닝·목표 시간) |
| **RunInk/Event** | 5 | 1,903 | Event 허브, Ink (GPS 아트 핵심·540줄), Brand·Anniversary·Local |
| **RunInk/Group** | 5 | 904 | 크루 메인·크루 상세 v1/v2·글쓰기·검색 |
| **RunInk/MyPage** | 4 | 859 | 마이페이지 (fl_chart 그래프), 설정, Store(carousel_slider 광고), 앱 설정 |
| **RunInk/Rank** | 2 | 725 | 크루/개인 랭킹 + 개인 수집 갤러리 (3×4 그리드) |
| **Run** (러닝 결과) | 2 | 423 | 러닝 결과 + 이미지 편집(스티커) |
| **GPS 아트 핵심** | 2 | 953 | Image_route_page, selected_route_page (가장 큰 723줄) |
| **결과 & 공유** | 1 | 469 | workout_result_page |
| **Firebase 설정** | 1 | 69 | firebase_options.dart |
| **총합** | **35** | **~8,094** | StatefulWidget 18 + StatelessWidget 12+ |

---

## 6. 기술 스택 (의존성 기준)

| 카테고리 | 패키지 | 버전 | 활용 |
|---|---|---|---|
| **Core** | flutter | 3.5.3 | Material Design 3 |
| **지도/위치** | google_maps_flutter | ^2.9.0 | 지도·Polyline·카메라 |
| | location | ^7.0.1 | GPS 권한·실시간 추적 (1초 interval) |
| **HTTP** | http | ^1.2.2 | REST + multipart |
| **인증** | firebase_core | ^3.6.0 | Firebase 초기화 |
| | firebase_auth | ^5.3.1 | 이메일/비밀번호 인증 |
| | google_sign_in | ^6.2.2 | 구글 소셜 로그인 |
| **UI** | convex_bottom_bar | ^3.2.0 | 5탭 메인 하단 바 |
| | carousel_slider | ^5.0.0 | Store 광고 캐러셀 |
| | fl_chart | ^0.69.0 | MyPage 거리 그래프 |
| | numberpicker | ^2.1.2 | 목표 거리 선택 휠 |
| **미디어** | image_picker | ^1.1.2 | 갤러리에서 이미지 선택 |
| | share_plus | ^10.1.2 | OS 공유 시트 |
| **로컬 저장** | shared_preferences | ^2.3.3 | 자동 로그인 상태 |
| **유틸** | intl | ^0.19.0 | 날짜 포맷팅 |
| | icons_launcher | ^3.0.0 | 앱 아이콘 자동 생성 |

---

## 7. 예상 면접 질문 & 답변 가이드

### 🔧 기술 질문

**Q1. "GPS 아트 경로 생성은 어떻게 동작하나요? 알고리즘을 설명해주세요."**
> "프론트에서 갤러리 이미지를 `image_picker`로 받고, 사용자 현재 위치(`location` 패키지)와 목표 거리(`NumberPicker` 1~42km)를 함께 multipart로 백엔드에 전송합니다. 백엔드는 이미지의 윤곽선을 추출한 뒤, 사용자 위치 주변의 OSM 도로망 그래프와 매칭해 가장 유사한 경로를 반환합니다. 프론트는 응답 좌표를 `LatLng` 리스트로 변환해 `google_maps_flutter`의 `Polyline`으로 렌더링합니다."

**Q2. "왜 Provider나 Riverpod 같은 상태관리 라이브러리를 쓰지 않았나요?"**
> "MVP 단계에서 빠른 검증을 위해 StatefulWidget + setState로 시작했습니다. 화면 수가 30개를 넘으면서 Bottom_Bar의 `_selectedIndex` 같은 전역 상태는 `IndexedStack`으로 처리하고 있지만, **사용자 정보·러닝 기록 등은 화면 간 prop drilling이 발생하는 게 사실**입니다. 다음 단계로 Provider 도입을 계획하고 있고, 특히 인증 상태와 러닝 세션 데이터는 ChangeNotifier로 분리할 계획입니다."

**Q3. "GPS 위치를 1초마다 받는데 배터리 이슈는 어떻게 해결했나요?"**
> "`location.changeSettings()`로 `distanceFilter: 5` 미터를 설정했습니다. 1초 interval로 콜백이 호출되더라도 5m 이상 이동하지 않으면 onLocationChanged가 발화하지 않아 배터리·CPU를 절약합니다. 또한 일시정지 상태에서는 좌표를 `_recordedRoute` 리스트에 추가하지 않아 처리 비용을 줄였습니다."

**Q4. "Haversine 공식을 직접 구현한 이유는?"**
> "Google Maps Distance Matrix API는 호출당 비용이 발생하고 네트워크 지연이 있습니다. 러닝 중 1초마다 거리 갱신이 필요한데, API 호출은 비현실적입니다. Haversine은 구 면적 위 두 점의 대원거리를 삼각함수로 계산하므로 오프라인에서도 즉시 동작하며, 도시 단위에서는 1m 이내 오차로 충분히 정확합니다."

**Q5. "경로 이탈 감지는 어떻게 구현했나요?"**
> "전체 경로 점을 매번 순회하면 O(N)이라 비효율적이라, **현재 위치 인덱스 ±5 범위만 탐색**합니다. 사용자가 정상적으로 경로를 따라간다면 가장 가까운 점은 직전 인덱스 근처에 있을 확률이 높기 때문입니다. 최소 거리가 20m(tolerance)를 초과하면 이탈로 판단해 안내 메시지를 표시합니다."

**Q6. "Firebase Auth와 자체 백엔드를 둘 다 쓴 이유는?"**
> "Firebase Auth는 OAuth, 토큰 관리, 비밀번호 해싱 등 보안에 검증된 솔루션이라 인증은 위임했습니다. 단, 사용자별 러닝 기록·크루 정보·랭킹 등 **도메인 데이터는 자체 FastAPI 백엔드(AWS EC2)에서 관리**해 비즈니스 로직 자유도를 확보했습니다. 일종의 BaaS + IaaS 하이브리드 패턴입니다."

### 🎨 기획 / 협업 질문

**Q7. "왜 이 아이템을 골랐고, 시장 검증은 어떻게 했나요?"**
> "X·인스타그램·DC갤·브런치 등 5개 채널에서 2022~2024년 '러닝/달리기' 키워드 약 3만 건을 크롤링했습니다. 전처리(이모지·숫자·광고·10자 이하 제거) 후 연도별 키워드 빈도와 증감률을 분석했더니, '기록'이 +250%, '트레일'이 +223%, '러닝크루'·'러닝스타그램'이 신규 등장했고, '헬스장'은 -12% 감소했습니다. PCA + 계층 클러스터링으로 도전형 초보(71.6%)와 개성형 숙련자(14.2%) 두 페르소나가 명확히 분리됐고, 공통 인사이트가 '재미와 개성 표현'이라 GPS 아트로 풀어냈습니다."

**Q8. "기존 앱(Strava, NRC, 런데이)과 차별점은?"**
> "Strava는 정확한 GPS·숙련자 기록용이지만 GPS 아트는 수작업이고, GPSArtify는 자동 생성이 되지만 월 $7.99에 업로드된 이미지로 한정됩니다. RunInk는 **사용자 현재 위치 기반 자동 생성 + 무료**라는 두 가지를 동시에 충족하는 유일한 서비스입니다."

**Q9. "팀 협업은 어떻게 진행했나요?"**
> "Team. 바잇킹은 BX(브랜드)·CX(고객)·Service·Development 4영역으로 역할을 나눴습니다. 저는 Flutter 앱과 백엔드 API 연동을 담당했고, 데이터 분석 결과를 받아 '재미·개성 표현'이라는 인사이트를 **GPS 아트 자동 생성 + SNS 공유 가능한 결과 페이지**로 구현했습니다. Git 협업은 진호의_공간, 라미의_공간, 성일의_공간 폴더로 작업 영역을 분리했습니다."

### 🚨 트러블슈팅 질문

**Q10. "프로젝트하면서 가장 어려웠던 점은?"**
> "GPS 노이즈와 경로 이탈 감지 사이의 균형이었습니다. tolerance를 작게 잡으면 GPS 부정확성으로 정상 주행도 이탈로 오인하고, 크게 잡으면 진짜 이탈을 놓칩니다. 20m로 결정한 근거는 도시 환경에서 일반적인 GPS 정확도가 5~15m 범위라는 점을 고려했고, `distanceFilter: 5`로 노이즈를 1차 필터링 후 ±5 인덱스 범위만 탐색해 부드러운 추적을 만들었습니다."

**Q11. "Brand·Anniversary·Local 화면이 거의 동일한 구조던데, 왜 분리했나요?"**
> "코드 리뷰 관점에서 명백한 중복이고, 추상화가 필요한 부분입니다. MVP 단계에서는 각 이벤트별 디자인·API 응답 구조가 달라질 가능성을 열어두기 위해 의도적으로 분리했지만, 다음 리팩토링에서 공통 `EventRoutePage<T extends EventConfig>` 형태로 추상 위젯을 도입할 계획입니다."

---

## 8. 자체 코드 리뷰 (강점 & 개선 포인트)

### ✅ 강점

| 항목 | 평가 |
|---|---|
| **알고리즘 직접 구현** | Haversine, Bearing, 경로 매칭 등 라이브러리에 의존하지 않고 수학으로 해결 |
| **실제 백엔드 운영** | AWS EC2에 배포된 10개 API와 통신하는 살아있는 시스템 |
| **사용자 흐름 완결성** | 회원가입 → 로그인 → 경로 생성 → 러닝 → 결과 공유 전 과정이 끊김 없이 연결 |
| **다양한 기술 통합** | Firebase, Google Maps, Image Picker, RepaintBoundary, fl_chart 등 폭넓은 패키지 활용 |
| **권한·예외 처리** | 위치 서비스/권한 활성화 체크, 권한 거부 시 fallback, try-catch 적용 |
| **UX 디테일** | 안전 경고 다이얼로그(인구밀집/횡단보도), 진행 중 카메라 자동 추적, 캡쳐용 다크 맵 스타일 |

### ⚠️ 개선 포인트 (성장 의지 어필 카드)

| 항목 | 현재 | 개선 방향 |
|---|---|---|
| **상태관리** | setState 18개 화면 | Provider/Riverpod 도입으로 prop drilling 제거 |
| **테스트** | widget_test.dart 기본만 | 거리 계산·Bearing 같은 순수 함수부터 unit test |
| **로깅** | `print()` 다수 | `logger` 패키지로 레벨 분리 (debug/info/error) |
| **하드코딩** | API URL, 기본 좌표(`37.491914, 127.026912`) | `.env` + `flutter_dotenv` 분리 |
| **에러 핸들링** | SnackBar 위주 | 통합 에러 바운더리 + Sentry 같은 모니터링 |
| **코드 중복** | Brand/Anniversary/Local 거의 동일 | Generic `EventRoutePage<T>` 추상화 |
| **인증 보안** | shared_preferences 평문 `isLoggedIn` 플래그 | JWT + flutter_secure_storage |
| **CI/CD** | 수동 빌드 | GitHub Actions + Codemagic 등 자동화 |
| **이미지 캐싱** | Image.network 그대로 | cached_network_image로 비용·속도 개선 |
| **i18n** | 한국어 하드코딩 | intl + arb 파일로 다국어 대응 |

---

## 9. 회사·직무별 어필 포인트

| 지원 직무 | 강조할 부분 |
|---|---|
| **모바일/Flutter 개발자** | 30개 화면, 8천 줄 코드, 권한·생명주기·캡쳐 등 Flutter 깊이 |
| **백엔드 개발자** | FastAPI 추정·EC2 배포·10개 엔드포인트·multipart 처리 |
| **데이터/AI 엔지니어** | 3만 건 크롤링·NLP 전처리·PCA·계층 클러스터링·BERTopic 풀과정 |
| **PM/기획자** | 데이터 기반 페르소나 도출 → 핵심 기능 도출의 논리 흐름 |
| **UX 디자이너** | 페르소나별 Pain Point → UI/UX 매핑(안전 경고·캐러셀·캡쳐 공유) |
| **LG전자/제조사** | LG DX School 1기 / LG 슈스타일러·슈케이스와 연계한 BX 사고 |

---

## 10. 마지막 한마디 (면접 클로징)

> "RunInk는 단순한 학습용 토이 프로젝트가 아니라, **데이터로 가설을 검증하고 → 실제 동작하는 시스템으로 풀어내고 → 비즈니스 모델까지 설계**한 풀사이클 경험이었습니다. 30개 화면을 직접 구현하면서 Flutter의 한계와 가능성을 체감했고, Provider 마이그레이션·테스트 코드 작성·CI/CD 구축이 다음 단계의 숙제임을 분명히 알게 됐습니다. 이 경험을 바탕으로 입사 후에는 **사용자 가치를 코드로 빠르게 검증하는 엔지니어**가 되겠습니다."

---

## 📎 부록: 빠른 참조

### 핵심 파일 라인 수 TOP 10
1. `selected_route_page.dart` — 723줄 (GPS 아트 따라 뛰기 + 내비)
2. `Rank/Rank.dart` — 558줄 (랭킹 시스템)
3. `Event/Ink/Ink.dart` — 540줄 (GPS 아트 메인 화면)
4. `workout_result_page.dart` — 469줄 (결과 + 공유)
5. `CenterPage/CenterPage.dart` — 442줄 (메인 피드)
6. `Event/Local/Local.dart` — 411줄
7. `Event/Brand/Brand.dart` / `Event/Anniversary/Anniversary.dart` — 각 397줄
8. `CenterPage/RunningTracker.dart` — 362줄
9. `MyPage/MyPage_setting.dart` — 345줄
10. `MyPage/MyPage.dart` — 338줄

### 자주 받을 후속 질문 대비
- **"왜 Flutter를 골랐나요?"** → 1 코드베이스로 iOS+Android, 빠른 hot reload, 풍부한 패키지 생태계
- **"백엔드 코드 보여줄 수 있나요?"** → 팀원이 담당했지만, FastAPI 기반이고 OSM 도로망 매칭 로직이 핵심
- **"앱스토어 출시했나요?"** → MVP 단계로 미출시. 다음 단계로 출시 준비 중
- **"수익화 모델은 검증됐나요?"** → 배민 장보기 오픈런(24년 6월) 4만 명 1분 컷 사례로 시장 가능성 증명

---

*Last updated: 2026-05-18*
*Project repo (local): `/Users/imjinho/StudioProjects/RunInk/`*
