import UIKit
import Flutter
import FirebaseCore
import GoogleMaps
import FirebaseAuth
import awesome_notifications
//import shared_preferences_ios

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("KEY HERE")
    GeneratedPluginRegistrant.register(with: self)

      SwiftAwesomeNotificationsPlugin.setPluginRegistrantCallback { registry in
               SwiftAwesomeNotificationsPlugin.register(
                 with: registry.registrar(forPlugin: "io.flutter.plugins.awesomenotifications.AwesomeNotificationsPlugin")!)
//               FLTSharedPreferencesPlugin.register(
//                 with: registry.registrar(forPlugin: "io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin")!)
           }



      if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
           let firebaseAuth = Auth.auth()
           firebaseAuth.setAPNSToken(deviceToken, type: AuthAPNSTokenType.unknown)
 }
 override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
           let firebaseAuth = Auth.auth()
           if (firebaseAuth.canHandleNotification(userInfo)){
               print(userInfo)
               return
           }
}
}

