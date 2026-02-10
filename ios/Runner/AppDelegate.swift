import UIKit
import Flutter
import HealthKit

@main
@objc class AppDelegate: FlutterAppDelegate {

  private let channelName = "beat/healthkit_steps"
  private let permissionChannelName = "beat/permission"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    let ok = super.application(application, didFinishLaunchingWithOptions: launchOptions)
      
      GeneratedPluginRegistrant.register(with: self)

    // ✅ UIScene 환경에서도 안전하게 messenger 확보
    guard let registrar = self.registrar(forPlugin: "AppDelegateChannels") else {
      return ok
    }

    registerChannels(messenger: registrar.messenger())

    return ok
  }

  private func registerChannels(messenger: FlutterBinaryMessenger) {

    let stepChannel = FlutterMethodChannel(
      name: channelName,
      binaryMessenger: messenger
    )

    stepChannel.setMethodCallHandler { call, result in
      switch call.method {
      case "requestAuth":
        HealthKitStepManager.shared.requestAuthorization { ok, _ in
          result(ok)
        }

      case "startBGDelivery":
        HealthKitStepManager.shared.startBackgroundDelivery()
        result(true)

      case "getTodaySteps":
        HealthKitStepManager.shared.fetchTodaySteps { steps in
          result(steps)
        }

      case "getCachedTodaySteps":
        result(HealthKitStepManager.shared.getCachedTodaySteps())

      case "getCachedLastUpdate":
        result(HealthKitStepManager.shared.getCachedLastUpdate())

      default:
        result(FlutterMethodNotImplemented)
      }
    }

    let permissionChannel = FlutterMethodChannel(
      name: permissionChannelName,
      binaryMessenger: messenger
    )

    permissionChannel.setMethodCallHandler { call, result in
      switch call.method {
      case "isHealthHealthKitGranted":
        result(HealthKitStepManager.shared.isStepAuthGranted())
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
