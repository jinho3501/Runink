import Flutter
import UIKit
import GoogleMaps
import Firebase

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Google Maps API Key
    GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY_HERE")

    // Firebase 초기화
    FirebaseApp.configure()

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}