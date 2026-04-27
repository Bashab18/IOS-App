import Flutter
import UIKit
import workmanager_apple

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Register workmanager background task identifiers with BGTaskScheduler
    WorkmanagerPlugin.registerTask(withIdentifier: "be.tramckrijte.workmanager.iOSBackgroundAppRefresh")
    WorkmanagerPlugin.registerTask(withIdentifier: "be.tramckrijte.workmanager.iOSBackgroundProcessingTask")
    WorkmanagerPlugin.registerTask(withIdentifier: "syncHealthData")
    WorkmanagerPlugin.registerTask(withIdentifier: "syncYesterdayHealthData")

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
