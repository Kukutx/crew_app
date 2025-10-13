import Flutter
import UIKit

import FirebaseCore
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Use Firebase library to configure APIs
    FirebaseApp.configure()
    GMSServices.provideAPIKey("AIzaSyAlMh5fDNbAFn5Bxzdcrucc8jPg4k1_ONU")
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
