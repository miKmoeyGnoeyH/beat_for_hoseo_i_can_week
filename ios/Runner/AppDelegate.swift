import UIKit
import Flutter
import HealthKit
import UserNotifications
import FirebaseMessaging

@main
@objc class AppDelegate: FlutterAppDelegate {
    
    private let channelName = "beat/healthkit_steps"
    private let permissionChannelName = "beat/permission"
    private let locationChannelName = "beat/campus_location"
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        let ok = super.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        GeneratedPluginRegistrant.register(with: self)
        
        UNUserNotificationCenter.current().delegate = self
        application.registerForRemoteNotifications()
        
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
                
            case "stopBGDelivery":
                HealthKitStepManager.shared.stopBackgroundDelivery()
                result(true)
                
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
            case "canReadSteps":
                HealthKitStepManager.shared.canReadSteps { ok in
                    result(ok)
                }
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        
        let locationChannel = FlutterMethodChannel(
            name: locationChannelName,
            binaryMessenger: messenger
        )
        
        locationChannel.setMethodCallHandler { call, result in
            switch call.method {
            case "start":
                CampusLocationManager.shared.start()
                result(true)
                
            case "stop":
                CampusLocationManager.shared.stop()
                result(true)
                
            case "isRunning":
                result(CampusLocationManager.shared.isRunning())
                
            case "isInsideCampus":
                CampusLocationManager.shared.requestInsideOnce { inside, err in
                        if let err = err {
                            result(err) // ✅ 에러로 올려
                            return
                        }
                        // inside가 nil이면(unknown) nil 반환 (Flutter에서 null 처리)
                        result(inside as Any)
                    }
                
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        
        CampusLocationManager.shared.bindFlutterChannel(messenger: messenger)
    }
    
    override func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken
        super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
    
    override func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        NSLog("APNs registration failed: \(error.localizedDescription)")
        super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
    }
}
