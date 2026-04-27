import Flutter
import UIKit
import workmanager_apple

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // BGTaskScheduler identifiers MUST be registered before the app finishes
    // launching — this is a hard system requirement.
    // iOSBackgroundAppRefresh is system-managed; no explicit call needed for it.
    WorkmanagerPlugin.registerBGProcessingTask(
      withIdentifier: "be.tramckrijte.workmanager.iOSBackgroundProcessingTask"
    )
    WorkmanagerPlugin.registerBGProcessingTask(withIdentifier: "syncHealthData")
    WorkmanagerPlugin.registerBGProcessingTask(withIdentifier: "syncYesterdayHealthData")

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // UIScene lifecycle: plugin registration moves here so it works correctly
  // with the scene-based window lifecycle introduced in iOS 13+.
  func didInitializeImplicitFlutterEngine(
    _ engineBridge: FlutterImplicitEngineBridge
  ) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
