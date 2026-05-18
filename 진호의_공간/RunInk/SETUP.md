# 🔧 RunInk 셋업 가이드

이 저장소는 보안을 위해 **민감한 설정 파일과 API 키가 제외**되어 있습니다.
앱을 빌드하려면 아래 단계를 따라 본인의 키로 채워주세요.

---

## ⚙️ 사전 요구사항

| 도구 | 버전 |
|---|---|
| Flutter SDK | 3.5.3 이상 |
| Dart SDK | 3.x (Flutter에 포함) |
| Xcode | 15+ (iOS 빌드) |
| Android Studio | Hedgehog 이상 (Android 빌드) |
| CocoaPods | 1.15+ |

```bash
flutter doctor   # 환경 확인
```

---

## 1️⃣ Firebase 설정

### A. Firebase 프로젝트 생성
1. [Firebase Console](https://console.firebase.google.com/)에서 새 프로젝트 생성
2. iOS / Android 앱 등록 (번들 ID: 본인 설정에 맞게)
3. **Authentication** 활성화 — Email/Password + Google 로그인

### B. 설정 파일 다운로드 후 배치

| 파일 | 다운로드 위치 | 배치 경로 |
|---|---|---|
| `google-services.json` | Firebase Console → Android 앱 | `android/app/google-services.json` |
| `GoogleService-Info.plist` | Firebase Console → iOS 앱 | `ios/Runner/GoogleService-Info.plist` |

### C. `firebase_options.dart` 생성
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```
→ `lib/firebase_options.dart`가 자동 생성됩니다.

---

## 2️⃣ Google Maps API 키 발급

### A. [Google Cloud Console](https://console.cloud.google.com/)에서:
1. **Maps SDK for Android** 활성화
2. **Maps SDK for iOS** 활성화
3. API 자격증명 → API 키 생성

### B. **반드시 사용량 제한 설정** (비용 폭탄 방지!)
- **Application restrictions**:
  - Android: 패키지 이름 + SHA-1 fingerprint
  - iOS: Bundle ID
- **API restrictions**: Maps SDK 두 가지만 허용
- **Quota**: 일일 호출 수 상한 설정

### C. 키 입력
**Android** — `android/app/src/main/AndroidManifest.xml`
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="여기에_본인_API_키"/>
```

**iOS** — `ios/Runner/AppDelegate.swift`
```swift
GMSServices.provideAPIKey("여기에_본인_API_키")
```

---

## 3️⃣ 백엔드 URL 변경

본 앱은 자체 FastAPI 백엔드(AWS EC2)를 사용합니다. 백엔드 코드는 별도 저장소에 있으며, 본 저장소에는 클라이언트만 포함됩니다.

### 사용 중인 엔드포인트 12곳을 본인 서버 주소로 일괄 변경:

| 파일 | 라인 | 엔드포인트 |
|---|---|---|
| `lib/Bottom_Bar.dart` | 134 | `POST /center` |
| `lib/Image_route_page.dart` | 35 | `POST /upload_image` |
| `lib/Member/Introduce.dart` | 41 | `POST /signin` |
| `lib/Member/LoginScreen.dart` | 53 | `POST /login` |
| `lib/RunInk/MyPage/MyPage_setting.dart` | 36, 76, 121 | `POST /user`, `/rankings`, `/user` |
| `lib/RunInk/MyPage/MyPage.dart` | 60 | `GET /login` |
| `lib/RunInk/Event/Brand/Brand.dart` | 26 | `GET /load_image` |
| `lib/RunInk/Event/Ink/Ink.dart` | 28 | `POST /message` |
| `lib/RunInk/Event/Local/Local.dart` | 26 | `GET /local` |
| `lib/RunInk/Event/Anniversary/Anniversary.dart` | 26 | `GET /ann` |

> 💡 **권장**: 별도 `lib/config.dart` 파일을 만들어 `BASE_URL` 상수 하나로 중앙 관리하세요.
> ```dart
> // lib/config.dart
> const String baseUrl = String.fromEnvironment('BASE_URL', defaultValue: 'http://localhost:8000');
> ```
> 그 후 `flutter run --dart-define=BASE_URL=http://your-server:8000`

### 백엔드 API 스펙 (응답 구조)

**`POST /message`** — 위치 → 사전 정의 모양 경로
```json
{
  "status": "success",
  "heart_route":  { "heart_routes":  [[{"lat": ..., "lng": ...}, ...]] },
  "square_route": { "square_routes": [[...]] },
  "star_route":   { "star_routes":   [[...]] },
  "distance": {
    "heart_distance":  "5.2",
    "square_distance": "4.8",
    "star_distance":   "6.1"
  }
}
```

**`POST /upload_image`** — multipart 이미지 + 위치 → 커스텀 경로
- Fields: `file` (image), `content`, `lat`, `lng`
- Response:
```json
{
  "status": "success",
  "route": { "routes": [[{"lat": ..., "lng": ...}, ...]] },
  "distance": { "route_distance": 5.2 },
  "url": "https://..."
}
```

---

## 4️⃣ 의존성 설치 & 실행

```bash
# 1) Flutter 패키지
flutter pub get

# 2) iOS Pods
cd ios && pod install && cd ..

# 3) 앱 아이콘 생성 (선택)
dart run icons_launcher:create

# 4) 실행
flutter run
```

---

## 🐛 트러블슈팅

| 증상 | 해결 |
|---|---|
| `MissingPluginException: firebase_core` | `flutter clean && flutter pub get && cd ios && pod install` |
| 지도가 회색으로만 보임 | Google Maps API 키 미입력 또는 SDK 미활성화 |
| `PERMISSION_DENIED` (위치) | iOS `Info.plist`에 `NSLocationWhenInUseUsageDescription` 추가 확인 |
| 백엔드 통신 실패 | URL 12곳 모두 변경했는지 확인. HTTP 사용 시 iOS는 `App Transport Security` 예외 필요 |
| 이미지 업로드 실패 | `image_picker` iOS Privacy 권한 키 확인 (`NSPhotoLibraryUsageDescription`) |

---

## 🔒 보안 권장사항

본 코드를 fork하거나 참조할 때 다음 사항을 꼭 지켜주세요:

1. ✅ **API 키 노출 금지** — `.gitignore`로 보호되는 파일을 절대 commit 하지 마세요
2. ✅ **HTTPS 사용** — 운영 환경에서는 반드시 HTTPS로 백엔드 통신
3. ✅ **Firebase Security Rules** 설정 — 인증된 사용자만 본인 데이터 접근
4. ✅ **Firebase App Check** 활성화 — 비인가 클라이언트 차단
5. ✅ **Google Maps Quota** 설정 — 일일 사용량 상한으로 비용 폭탄 방지

---

## 📞 문의

본 프로젝트는 LG전자 DX School 1기 교육 과정의 산출물입니다.
질문은 GitHub Issues로 남겨주세요.
