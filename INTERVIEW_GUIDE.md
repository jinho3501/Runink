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
- **"백엔드 코드 보여줄 수 있나요?"** → FastAPI + OSMnx + OpenCV 기반. `Part 2`에서 상세 설명
- **"앱스토어 출시했나요?"** → MVP 단계로 미출시. 다음 단계로 출시 준비 중
- **"수익화 모델은 검증됐나요?"** → 배민 장보기 오픈런(24년 6월) 4만 명 1분 컷 사례로 시장 가능성 증명

---

# 🐍 Part 2 — 백엔드 알고리즘 Deep Dive

> Flutter 앱이 화려한 UI 레이어라면, 백엔드는 **"이미지를 GPS 경로로 바꾸는"** RunInk의 진짜 두뇌입니다.
> 풀스택으로 어필할 수 있는 가장 강력한 카드입니다.

## 📐 11. 시스템 풀스택 데이터 플로우

`POST /upload_image` 한 번의 요청이 백엔드에서 일으키는 일:

```
[Flutter 앱]
사용자 갤러리에서 이미지 선택
    │
    │ HTTP multipart/form-data
    │ (file + lat + lng + content)
    ▼
┌──────────────────────────────────────────────────┐
│ FastAPI @app.post("/upload_image")               │
│ main.py:316~388                                  │
└──────────────────────────────────────────────────┘
    │
    │ ① UUID + 타임스탬프로 파일명 생성
    │    img_20241119_141554_b92e3b3d.png
    ▼
┌──────────────────────────────────────────────────┐
│ AWS S3 업로드 (boto3)                            │
│ s3_connector.py:upload_img()                     │
│ → bucket: runink-bucket / region: ap-northeast-2 │
└──────────────────────────────────────────────────┘
    │
    │ ② 업로드된 S3 URL 생성
    ▼
┌──────────────────────────────────────────────────┐
│ img_load_s3.read_image_from_url(url)             │
│ → requests로 다운로드                            │
│ → np.asarray + cv2.imdecode로 OpenCV 이미지화    │
└──────────────────────────────────────────────────┘
    │
    │ ③ OpenCV NumPy 배열 (HxWx3 BGR)
    ▼
┌──────────────────────────────────────────────────┐
│ image2course.draw_contour_on_map(image, lat, lon)│
│ → cv2.Canny(100, 200): 외곽선 추출               │
│ → cv2.findContours(RETR_EXTERNAL): 윤곽선        │
│ → max(contours, key=cv2.contourArea): 최대 윤곽  │
│ → cv2.approxPolyDP(ε=1%): 점 단순화 (수십~수백)  │
│ → 픽셀 → 위경도 변환                             │
│   km_per_pixel = size_km(2.5) / max(w,h)         │
│   lat_step = km_per_pixel / 111                  │
│   lon_step = km_per_pixel / (111 × cos(lat))     │
└──────────────────────────────────────────────────┘
    │
    │ ④ List[(lat, lon)] — 이미지 외곽 좌표
    ▼
┌──────────────────────────────────────────────────┐
│ rotate_points.rotate_coordinates(coords, 12°)    │
│ → 기준점(첫 좌표) 기준 12도 시계방향 회전        │
│ → 위경도 → km 변환 → 2D 회전행렬 → 위경도 환원   │
│ (도로 방향과 그림 방향 정합)                     │
└──────────────────────────────────────────────────┘
    │
    │ ⑤ 회전된 좌표 리스트
    ▼
┌──────────────────────────────────────────────────┐
│ course_search.get_full_route(coords)             │
│ → OSMnx로 서울 보행 도로망 graphml 로드          │
│   data/서울특별시_대한민국_walk.graphml          │
│ → 각 점 쌍 → ox.distance.nearest_nodes로 매핑    │
│ → nx.shortest_path(weight='length'): Dijkstra    │
│ → 마지막 점 → 첫 점 연결 (closed loop)           │
└──────────────────────────────────────────────────┘
    │
    │ ⑥ 실제 도로를 따라가는 전체 경로 + 총 거리(m)
    ▼
[Flutter 앱]
JSON 응답: {"routes":[[{"lat":..,"lng":..}]], "distance":...}
→ google_maps_flutter Polyline으로 시각화
→ 사용자가 "운동 시작" 누르면 SelectedRoutePage에서 내비게이션 시작
```

## 🧠 12. 백엔드 핵심 알고리즘 (코드 인용)

### 🎨 ① 이미지 → 위경도 좌표 변환 (`image2course.py`)

**핵심 아이디어**: OpenCV의 Canny edge + 외곽선 단순화 + 픽셀↔위경도 선형 변환

```python
# image2course.py:10~62
def draw_contour_on_map(image, lat_start, lon_start, size_km=2.5, epsilon_factor=0.01):
    # 1) Canny edge로 외곽선만 추출
    edges = cv2.Canny(image, 100, 200)
    contours, _ = cv2.findContours(edges, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

    # 2) 가장 큰 윤곽 (배경 노이즈 무시)
    main_contour = max(contours, key=cv2.contourArea)

    # 3) Douglas-Peucker 알고리즘으로 점 단순화 (수천 점 → 수십 점)
    epsilon = epsilon_factor * cv2.arcLength(main_contour, True)
    simplified_contour = cv2.approxPolyDP(main_contour, epsilon, True)

    # 4) 픽셀 → km → 위경도 변환
    x, y, w, h = cv2.boundingRect(simplified_contour)
    km_per_pixel = size_km / max(w, h)
    lat_step = km_per_pixel / 111                              # 위도 1° ≈ 111km
    lon_step = km_per_pixel / (111 * np.cos(np.radians(lat_start)))  # 경도는 위도 보정

    # 5) 좌표 변환 (y축 반전 — 이미지 좌표계는 위가 0, 지리는 위가 큰 위도)
    coordinates = []
    for point in simplified_contour:
        px, py = point[0]
        lat = lat_start + ((h - (py - y)) * lat_step)
        lon = lon_start + ((px - x) * lon_step)
        coordinates.append((lat, lon))
    return coordinates
```

**면접 어필 포인트**:
- **Canny edge detection** + **Douglas-Peucker 단순화** (`cv2.approxPolyDP`) — 수천 픽셀 컨투어를 수십 개로 압축해 다운스트림 그래프 탐색 비용 절감
- **경도 보정** (`cos(lat)`) — 적도와 극지방의 경도 1°가 다르기 때문에 위도에 따라 보정. 한국(위도 37°)에서는 경도 1°가 약 88km
- **y축 반전** — OpenCV의 이미지 좌표계(위가 0)와 지리 좌표계(위가 큰 위도)의 방향 차이를 `h - rel_y`로 보정

### 🔄 ② 좌표 회전 변환 (`rotate_points.py`)

**왜 회전이 필요?** → 이미지를 그대로 매핑하면 그림이 정북향(↑)으로 고정. 도로망에 맞춰 회전해야 자연스러운 러닝 경로가 됨.

```python
# rotate_points.py:3~52
def rotate_coordinates(coordinates, angle_degrees):
    base_lat, base_lon = coordinates[0]  # 첫 점이 회전 중심
    angle_rad = np.radians(angle_degrees)

    # 2D 회전 행렬
    rotation_matrix = np.array([
        [np.cos(angle_rad), -np.sin(angle_rad)],
        [np.sin(angle_rad),  np.cos(angle_rad)]
    ])

    for lat, lon in coordinates[1:]:
        # 위경도 → km로 변환 (cos(위도) 보정)
        lat_diff_km = (lat - base_lat) * 111
        lon_diff_km = (lon - base_lon) * 111 * np.cos(np.radians(base_lat))

        # 회전행렬 적용
        rotated = rotation_matrix @ np.array([lon_diff_km, lat_diff_km])

        # km → 위경도 환원
        new_lat = base_lat + (rotated[1] / 111)
        new_lon = base_lon + (rotated[0] / (111 * np.cos(np.radians(base_lat))))
```

**면접 어필 포인트**: 위경도 좌표는 직접 회전하면 안 됨(위도/경도 단위가 다름). **반드시 km 좌표계로 변환 후 회전 → 다시 위경도로 환원**.

### 🗺 ③ 도로망 매칭 + 최단 경로 (`course_search.py`)

**핵심 라이브러리**: OSMnx (OpenStreetMap NetworkX) + NetworkX

```python
# course_search.py
import osmnx as ox
import networkx as nx

# 서울 보행 도로망 그래프 사전 다운로드 (graphml 파일)
G = ox.load_graphml("data/서울특별시_대한민국_walk.graphml")

def short_route_osm(start_point, end_point):
    # 위경도 → 가장 가까운 그래프 노드 찾기
    start_node = ox.distance.nearest_nodes(G, start_lon, start_lat)
    end_node   = ox.distance.nearest_nodes(G, end_lon, end_lat)

    # Dijkstra 최단 경로 (weight='length' = 미터)
    route = nx.shortest_path(G, start_node, end_node, weight='length')
    distance = nx.shortest_path_length(G, start_node, end_node, weight='length')

    route_coords = [(G.nodes[n]['x'], G.nodes[n]['y']) for n in route]
    return route_coords, distance

def get_full_route(star_points):
    full_route = []
    total_distance = 0
    for i in range(len(star_points) - 1):  # 점 i → 점 i+1
        segment, dist = short_route_osm(star_points[i], star_points[i+1])
        full_route.extend(segment)
        total_distance += dist
    # 마지막 → 첫 점 (closed loop)
    segment, dist = short_route_osm(star_points[-1], star_points[0])
    full_route.extend(segment)
    total_distance += dist
    return full_route, total_distance
```

**면접 어필 포인트**:
- **OpenStreetMap을 NetworkX 그래프로 사전 캐싱** (`graphml` 파일) → 매 요청마다 도로망 fetch 안 함, 응답 속도 향상
- **`ox.distance.nearest_nodes`** — 이미지에서 나온 임의의 위경도 점을 실제 도로 위의 가장 가까운 노드로 스냅
- **Dijkstra 최단 경로** (`nx.shortest_path`) — 점들을 도로를 따라 자연스럽게 연결
- **Closed loop 처리** — 마지막 점에서 시작점으로 돌아오는 segment 추가해 출발지에서 출발지로 돌아오는 동선 완성

### 💖 ④ 사전 정의 모양 — 파라메트릭 방정식 (`default_shape.py`)

**Heart 모양** — 진짜 수학적 하트 방정식:
```python
# default_shape.py:5~57
t = np.linspace(0, 2*np.pi, num_points)
x = 16 * np.sin(t)**3
y = 13*np.cos(t) - 5*np.cos(2*t) - 2*np.cos(3*t) - np.cos(4*t)
```

**Star 모양** — 황금비율 적용:
```python
# default_shape.py:90~134
angles = [math.radians(90 + (i * 72)) for i in range(5)]       # 외부 5점
inner_angles = [math.radians(90 + 36 + (i * 72)) for i in range(5)]  # 내부 5점
inner_size_km = size_km * 0.382   # 황금비율 (1/φ²)
```

**면접 어필 포인트**: 단순한 좌표 나열이 아니라 **파라메트릭 방정식**과 **황금비율**을 적용해 시각적으로 자연스러운 모양 생성.

### 🐳 ⑤ Dockerfile + AWS EC2 배포

```dockerfile
# BackEnd_code/Dockerfile (요지)
FROM python:3.x-slim
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

- 컨테이너로 EC2에 배포해 환경 일관성 확보
- 운영 명령: `python -m uvicorn main:app --reload --host 0.0.0.0 --port 8080` (main.py 라인 16)

---

## 🛠 13. 백엔드 기술 스택

| 영역 | 라이브러리 | 활용 |
|---|---|---|
| Web 프레임워크 | FastAPI 0.115 + uvicorn 0.32 | 비동기 REST API |
| 데이터 검증 | pydantic 2.9 | Request/Response 스키마 |
| **이미지 처리** | **opencv-python 4.10** | Canny edge, findContours, approxPolyDP |
| **지리공간 그래프** | **osmnx 1.9 + networkx 3.3** | OSM 도로망 + Dijkstra 최단 경로 |
| 지리공간 데이터 | geopandas 0.14, shapely 2.0, fiona 1.10 | GIS 데이터 처리 |
| 시각화 | folium 0.18 | 지도 시각화 (디버깅용) |
| GPS | haversine 2.8 | 위경도 거리 계산 |
| ML | scikit-learn 1.5, scipy 1.14 | 분석·전처리 |
| DB | PyMySQL 1.1 | AWS RDS 연결 |
| AWS | boto3 1.35 | S3 클라이언트 |
| 배포 | Docker, uvicorn, uvloop | EC2 컨테이너 |

---

## 🎙 14. 백엔드 관련 예상 면접 Q&A

**Q1. "이미지를 어떻게 러닝 경로로 변환하나요? 전체 알고리즘을 설명해주세요."**
> "5단계로 동작합니다. ① OpenCV의 Canny edge로 외곽선만 추출하고, ② `findContours`로 가장 큰 윤곽을 선택해 배경 노이즈를 제거합니다. ③ Douglas-Peucker 알고리즘(`cv2.approxPolyDP`)으로 수천 점의 컨투어를 수십 개로 단순화해 후속 그래프 탐색 비용을 줄였습니다. ④ 픽셀 좌표를 위경도로 변환할 때 위도 1°≈111km, 경도는 `cos(위도)` 보정을 적용해 한국 위도(37°)에서 1°≈88km로 정확히 계산합니다. ⑤ OSMnx로 사전 캐싱한 서울 보행 도로망 그래프에서 NetworkX의 Dijkstra로 각 점 쌍의 최단 경로를 잇고, 마지막에 시작점으로 돌아오는 closed loop을 만듭니다."

**Q2. "왜 매번 OSM API를 호출하지 않고 graphml로 캐싱했나요?"**
> "OSM API는 응답 속도가 일정하지 않고 트래픽이 증가하면 rate limit에 걸립니다. 서울 보행 도로망은 한 번 다운로드하면 자주 변하지 않는 데이터라, OSMnx의 `load_graphml`로 메모리에 로드해 매 요청마다 ms 단위로 응답할 수 있게 했습니다. 운영 환경에서는 도시별로 graphml을 미리 받아두고 사용자 위치에 따라 적절한 그래프를 로드하면 확장도 가능합니다."

**Q3. "왜 이미지 좌표를 12도 회전시켰나요?"**
> "서울 도로망은 정북-정남 방향이 아니라 일정 각도 기울어진 격자 구조가 많습니다. 이미지 윤곽선을 그대로 매핑하면 그림이 정북향으로 고정돼 도로를 따라가지 못하고 비효율적 경로가 나옵니다. 12도 회전은 실험적으로 강남·용산권 도로 방향과 가장 잘 맞는 각도를 찾은 값이고, 향후 위치별로 동적 계산하도록 개선할 수 있습니다."

**Q4. "Heart, Square, Star는 어떻게 자연스럽게 그렸나요?"**
> "단순 좌표 나열이 아니라 **파라메트릭 방정식**을 썼습니다. Heart는 `x = 16sin³(t)`, `y = 13cos(t) - 5cos(2t) - 2cos(3t) - cos(4t)`라는 진짜 수학적 하트 곡선입니다. Star는 **황금비율(0.382 = 1/φ²)**을 외부/내부 반지름 비율로 적용해 시각적으로 자연스러운 5각 별을 만들었습니다. 사용자 위치가 중심이 되도록 변환했습니다."

**Q5. "FastAPI를 선택한 이유는?"**
> "비동기 처리(`async/await`)가 표준이고, Pydantic으로 request/response 스키마 검증이 자동입니다. 이미지 업로드는 multipart 처리가 필요한데 FastAPI의 `UploadFile + File()`이 매우 간결합니다. 또 자동 생성되는 OpenAPI 문서가 Flutter 팀과의 API 명세 공유에 유용했습니다. Flask 대비 비동기 + 성능, Django 대비 가벼움이 장점이었습니다."

**Q6. "DB 스키마는 어떻게 설계했나요?"**
> "`user` 테이블 (user_id, email, pw, name, birthday, gender, profile_image)과 `run` 테이블 (user_id, route_id, distance) 두 축으로 시작했습니다. JOIN으로 사용자별 누적 거리를 집계해 마이페이지 그래프와 랭킹에 활용합니다. MVP 단계라 정규화에 우선을 두고 간단하게 유지했고, 다음 단계로 GPS 아트 작품 테이블, 크루 멤버십 테이블, 좋아요·댓글 테이블을 추가할 계획입니다."

**Q7. "EC2 + RDS + S3 운영 경험이 있군요. 어떤 점이 어려웠나요?"**
> "RDS 보안 그룹 설정에서 EC2 인스턴스만 허용하도록 IP 제한 거는 부분, S3 CORS 설정으로 Flutter에서 직접 이미지 URL 호출 가능하게 만드는 부분이 처음엔 막혔습니다. 또 Docker로 컨테이너화할 때 OSMnx와 GeoPandas의 의존성(GDAL, fiona 등) 때문에 이미지 크기가 커져 slim 베이스 이미지 + multi-stage build 검토가 필요했습니다."

**Q8. "현재 백엔드 코드에 부족한 부분은?"**
> "솔직히 말씀드리면, MVP 단계라 demo 흐름을 우선시한 코드가 일부 있습니다. 예를 들어 `main.py`의 `/upload_image`에서 사용자 위치를 받았는데도 용산 좌표(37.557195, 126.976003)로 하드코딩된 부분이 있고(라인 324), `/login` 엔드포인트가 인증 없이 success를 반환합니다(라인 67). 또한 `nx.shortest_path` 매 호출마다 graph 전역을 탐색해 점이 많아지면 O(N × ElogV)로 느려질 수 있어서, A* 알고리즘이나 graph 부분 추출로 최적화 여지가 있습니다."

---

## 🎯 15. 풀스택 어필 포인트 정리

| 영역 | 직접 구현·기여 |
|---|---|
| **이미지 처리** | OpenCV Canny edge + Douglas-Peucker로 컨투어 단순화 |
| **지리공간 알고리즘** | OSMnx + NetworkX Dijkstra로 도로 따라가는 폐곡선 경로 생성 |
| **수학** | 파라메트릭 곡선 (Heart), 황금비율 (Star), 위경도↔km 변환, 2D 회전행렬 |
| **API 설계** | FastAPI + Pydantic으로 10+ 엔드포인트 + multipart 이미지 업로드 |
| **AWS 인프라** | EC2 (서버) + RDS MySQL (DB) + S3 (이미지 스토리지) 통합 운영 |
| **DevOps** | Dockerfile로 컨테이너화, uvicorn으로 ASGI 운영 |
| **Flutter ↔ 백엔드** | HTTP multipart, JSON 직렬화, 12개 엔드포인트 통합 |

---

*Last updated: 2026-05-18 (백엔드 분석 추가)*
*Project repo (local): `/Users/imjinho/StudioProjects/RunInk/`*
*GitHub: https://github.com/jinho3501/Runink*
