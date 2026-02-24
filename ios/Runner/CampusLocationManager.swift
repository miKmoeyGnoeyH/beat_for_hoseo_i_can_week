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
    
    private var pendingLocationCompletion: ((Bool?, FlutterError?) -> Void)?
    private var locationTimeoutTimer: Timer?
    
    private let keyLastInside = "campus_last_inside"
    private let keyRunning = "campus_location_running"
    
    private var flutterChannel: FlutterMethodChannel?
    
    // ✅ one-shot이 desiredAccuracy를 바꿨으면 원복하기 위한 저장
    private var savedDesiredAccuracy: CLLocationAccuracy?
    private var savedDistanceFilter: CLLocationDistance?
    
    private override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.distanceFilter = 30
        manager.pausesLocationUpdatesAutomatically = true
        manager.allowsBackgroundLocationUpdates = true
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }
    
    // MARK: - Public
    
    func isRunning() -> Bool {
        return defaults.bool(forKey: keyRunning)
    }
    
    func start() {
        let status = manager.authorizationStatus
        if status == .denied || status == .restricted {
            stop()
            return
        }
        
        if status == .notDetermined {
            manager.requestAlwaysAuthorization()
            return
        }
        
        defaults.set(true, forKey: keyRunning)
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
        if status == .denied || status == .restricted {
            stop()
            return
        }
        
        if isRunning() {
            self.manager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        
        // ✅ accuracy/age filter (중요)
        let age = -loc.timestamp.timeIntervalSinceNow
        guard age < 5 else {
            print("LOC ignored (too old): age=\(age)")
            return
        }
        
        guard loc.horizontalAccuracy > 0, loc.horizontalAccuracy < 50 else {
            print("LOC ignored (low accuracy): acc=\(loc.horizontalAccuracy)")
            return
        }
        
        let inside = isInsideCampus(lat: loc.coordinate.latitude, lng: loc.coordinate.longitude)
        
        print("LOC lat=\(loc.coordinate.latitude), lng=\(loc.coordinate.longitude)")
        print("inside=\(inside)")
        
        let hadLast = defaults.object(forKey: keyLastInside) != nil
        let lastInside = defaults.bool(forKey: keyLastInside)
        
        defaults.set(inside, forKey: keyLastInside)
        
        if let cb = pendingLocationCompletion {
            pendingLocationCompletion = nil
            locationTimeoutTimer?.invalidate()
            locationTimeoutTimer = nil
            
            // ✅ one-shot이 바꿔둔 값 원복
            if let acc = savedDesiredAccuracy { self.manager.desiredAccuracy = acc }
            if let df = savedDistanceFilter { self.manager.distanceFilter = df }
            savedDesiredAccuracy = nil
            savedDistanceFilter = nil
            
            cb(inside, nil)
            return
        }
        
        // ✅ running 이벤트 처리
        guard isRunning() else { return }
        
        if !hadLast { return }              // 최초는 이벤트 안 쏨
        if lastInside == inside { return }  // 변화 없으면 스팸 방지
        
        if inside { notifyEntered() } else { notifyLeft() }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let cb = pendingLocationCompletion {
            pendingLocationCompletion = nil
            locationTimeoutTimer?.invalidate()
            locationTimeoutTimer = nil
            
            // ✅ one-shot이 바꿔둔 값 원복
            if let acc = savedDesiredAccuracy { self.manager.desiredAccuracy = acc }
            if let df = savedDistanceFilter { self.manager.distanceFilter = df }
            savedDesiredAccuracy = nil
            savedDistanceFilter = nil
            
            // ✅ continuous가 아니면 stop
            if !isRunning() {
                self.manager.stopUpdatingLocation()
            }
            
            cb(nil, FlutterError(code: "LOCATION_ERROR",
                                 message: error.localizedDescription,
                                 details: nil))
            return
        }
    }
    
    // MARK: - Immediate State Query
    func requestInsideOnce(timeout: TimeInterval = 6.0,
                           completion: @escaping (Bool?, FlutterError?) -> Void) {
        DispatchQueue.main.async {
            let status = self.manager.authorizationStatus
            if status == .denied || status == .restricted {
                completion(nil, FlutterError(code: "LOCATION_DENIED", message: "Location denied", details: nil))
                return
            }
            if status == .notDetermined {
                self.manager.requestAlwaysAuthorization()
                completion(nil, FlutterError(code: "LOCATION_NOT_DETERMINED", message: "Not determined", details: nil))
                return
            }
            if self.pendingLocationCompletion != nil {
                completion(nil, FlutterError(code: "LOCATION_IN_PROGRESS", message: "Already in progress", details: nil))
                return
            }
            
            self.pendingLocationCompletion = completion
            
            // ✅ one-shot 정확도 temporarily up
            self.savedDesiredAccuracy = self.manager.desiredAccuracy
            self.savedDistanceFilter = self.manager.distanceFilter
            
            self.manager.desiredAccuracy = kCLLocationAccuracyBest
            self.manager.distanceFilter = kCLDistanceFilterNone
            
            self.locationTimeoutTimer?.invalidate()
            self.locationTimeoutTimer = Timer.scheduledTimer(withTimeInterval: timeout, repeats: false) { [weak self] _ in
                guard let self else { return }
                let cb = self.pendingLocationCompletion
                self.pendingLocationCompletion = nil
                
                let fallback: Bool? = self.defaults.object(forKey: self.keyLastInside) != nil
                ? self.defaults.bool(forKey: self.keyLastInside)
                : nil
                
                cb?(fallback, FlutterError(code: "LOCATION_TIMEOUT",
                                           message: "Timed out waiting for location",
                                           details: nil))
            }
            
            self.manager.requestLocation() // ✅ one-shot
        }
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
    
    // x = lng, y = lat 기준 Ray Casting
    private func isInsidePolygon(lat: Double, lng: Double, polygon: [(Double, Double)]) -> Bool {
        let x = lng
        let y = lat
        
        var inside = false
        var j = polygon.count - 1
        
        for i in 0..<polygon.count {
            // polygon은 (lat, lng)로 저장되어 있으니
            let yi = polygon[i].0   // lat
            let xi = polygon[i].1   // lng
            let yj = polygon[j].0
            let xj = polygon[j].1
            
            // y가 edge를 가로지르는지 + 교차점 x가 현재 x보다 큰지
            let intersect = ((yi > y) != (yj > y)) &&
            (x < (xj - xi) * (y - yi) / (yj - yi) + xi)
            
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
