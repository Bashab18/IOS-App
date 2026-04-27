import Flutter
import UIKit
import workmanager_apple

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // iOSBackgroundAppRefresh is a BGAppRefreshTask — system-managed,
    // no explicit registration required.

    // Register BGProcessingTask identifiers with BGTaskScheduler.
    // Must be called before the end of application(_:didFinishLaunchingWithOptions:).
    WorkmanagerPlugin.registerBGProcessingTask(
      withIdentifier: "be.tramckrijte.workmanager.iOSBackgroundProcessingTask"
    )
    WorkmanagerPlugin.registerBGProcessingTask(withIdentifier: "syncHealthData")
    WorkmanagerPlugin.registerBGProcessingTask(withIdentifier: "syncYesterdayHealthData")

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
