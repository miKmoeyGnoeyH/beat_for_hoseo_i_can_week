//
//  CampusLocationManager.swift
//  Runner
//
//  Created by 김현겸 on 2/20/26.
//

import Foundation
import CoreLocation
import UserNotifications
import UIKit
import Flutter

final class CampusLocationManager: NSObject, CLLocationManagerDelegate {

    static let shared = CampusLocationManager()

    private let manager = CLLocationManager()
    private let defaults = UserDefaults.standard

    private let keyLastInside = "campus_last_inside"
    private let keyRunning = "campus_location_running"
    
    private var flutterChannel: FlutterMethodChannel?

    private override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.distanceFilter = 30 // meters
        manager.pausesLocationUpdatesAutomatically = true

        // 백그라운드 허용
        manager.allowsBackgroundLocationUpdates = true

        // 알림 권한 (한 번만 받아도 됨)
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    // MARK: - Public

    func isRunning() -> Bool {
        return defaults.bool(forKey: keyRunning)
    }

    func start() {
        // 권한이 없으면 시작하지 않음
        let status = manager.authorizationStatus
        if status == .denied || status == .restricted {
            stop()
            return
        }

        // iOS14+에서는 authorizationStatus 보고 요청 가능
        if status == .notDetermined {
            // Always를 원하면 Always 요청 (사용자 플로우에 맞춰 조정 가능)
            manager.requestAlwaysAuthorization()
            return
        }

        // WhenInUse만이면 백그라운드에서 제한될 수 있음.
        // 그래도 포그라운드라도 동작시키려면 시작은 가능.
        defaults.set(true, forKey: keyRunning)

        // 초기 inside 값 없으면 현재 위치 한번 받고 저장
        manager.startUpdatingLocation()
    }

    func stop() {
        manager.stopUpdatingLocation()
        defaults.set(false, forKey: keyRunning)
    }

    // MARK: - Flutter Channel
    func bindFlutterChannel(messenger: FlutterBinaryMessenger) {
        flutterChannel = FlutterMethodChannel(
            name: "beat/campus_location",
            binaryMessenger: messenger
        )
    }
    
    // MARK: - CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus

        // 권한이 꺼지면 자동 중지
        if status == .denied || status == .restricted {
            stop()
            return
        }

        // 권한이 허용으로 바뀌었고, 실행 상태면 다시 시작
        if isRunning() {
            self.manager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard isRunning() else { return }
        guard let loc = locations.last else { return }

        let inside = isInsideCampus(lat: loc.coordinate.latitude, lng: loc.coordinate.longitude)

        // 최초 값 저장
        if defaults.object(forKey: keyLastInside) == nil {
            defaults.set(inside, forKey: keyLastInside)
            return
        }

        let lastInside = defaults.bool(forKey: keyLastInside)
        if lastInside == inside { return } // 변화 없으면 스팸 방지

        defaults.set(inside, forKey: keyLastInside)

        if inside {
            notifyEntered()
        } else {
            notifyLeft()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // 위치 실패 시에도 필요하면 중지/로깅
        // print("Location error: \(error)")
    }

    // MARK: - Notification (localized)

    private func isKorean() -> Bool {
        // 앱/시스템 언어 기준
        let lang = Locale.preferredLanguages.first ?? "en"
        return lang.lowercased().hasPrefix("ko")
    }

    private func notifyLeft() {
        let (title, body) = isKorean()
        ? ("BEAT", "캠퍼스 범위를 벗어났습니다.")
        : ("BEAT", "You have left the campus area.")

        pushNotification(id: "campus_left", title: title, body: body)
        
        flutterChannel?.invokeMethod("campusOut", arguments: nil)
    }

    private func notifyEntered() {
        let (title, body) = isKorean()
        ? ("BEAT", "캠퍼스 범위에 진입했습니다.")
        : ("BEAT", "You have entered the campus area.")

        pushNotification(id: "campus_entered", title: title, body: body)
        
        flutterChannel?.invokeMethod("campusIn", arguments: nil)
    }

    private func pushNotification(id: String, title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        // 즉시 표시
        let req = UNNotificationRequest(identifier: id, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(req, withCompletionHandler: nil)
    }

    // MARK: - Polygon

    private func isInsideCampus(lat: Double, lng: Double) -> Bool {
        return isInsidePolygon(lat: lat, lng: lng, polygon: Self.asanArea)
            || isInsidePolygon(lat: lat, lng: lng, polygon: Self.cheonanArea)
    }

    // Ray casting (lat=x, lng=y처럼 취급)
    private func isInsidePolygon(lat: Double, lng: Double, polygon: [(Double, Double)]) -> Bool {
        var inside = false
        var j = polygon.count - 1

        for i in 0..<polygon.count {
            let xi = polygon[i].0, yi = polygon[i].1
            let xj = polygon[j].0, yj = polygon[j].1

            let intersect = ((yi > lng) != (yj > lng)) &&
                (lat < (xj - xi) * (lng - yi) / (yj - yi) + xi)

            if intersect { inside.toggle() }
            j = i
        }

        return inside
    }

    // MARK: - Campus Polygons (lat, lng)

    static let asanArea: [(Double, Double)] = [
        (36.738665, 127.077041),
        (36.738750, 127.076391),
        (36.739498, 127.075712),
        (36.739439, 127.074505),
        (36.740096, 127.074337),
        (36.739655, 127.073618),
        (36.740085, 127.072995),
        (36.738334, 127.071278),
        (36.735504, 127.070047),
        (36.735225, 127.070037),
        (36.735188, 127.070396),
        (36.735417, 127.071305),
        (36.735013, 127.072693),
        (36.735409, 127.072880),
        (36.734680, 127.074740),
        (36.733959, 127.074943),
        (36.732805, 127.076793),
        (36.733010, 127.077406),
        (36.734392, 127.076388),
        (36.735113, 127.076939),
        (36.735218, 127.076731),
        (36.736264, 127.077744),
        (36.737103, 127.077636),
    ]

    static let cheonanArea: [(Double, Double)] = [
        (36.830327274558805, 127.18020021753239),
        (36.83009097680529, 127.18003992692661),
        (36.82990371331767, 127.18022724802745),
        (36.82876674420636, 127.17977900834666),
        (36.82839453209551, 127.18159404825123),
        (36.826534838425715, 127.18235186916161),
        (36.82608035605323, 127.18197528960386),
        (36.82530941393403, 127.18229852140279),
        (36.82545220384936, 127.1832011762635),
        (36.82589369313384, 127.18323585563941),
        (36.82641869776802, 127.18462142354441),
        (36.8283930017052, 127.1840544914855),
        (36.828461000619335, 127.18378563032861),
        (36.82863829677594, 127.18276039787843),
        (36.829313469671476, 127.1817195240613),
        (36.829603672754665, 127.18198363368744),
    ]
}
