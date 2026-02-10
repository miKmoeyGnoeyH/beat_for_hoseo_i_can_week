//
//  HealthKitStepManager.swift
//  Runner
//
//  Created by 김현겸 on 2/9/26.
//

import Foundation
import HealthKit

final class HealthKitStepManager {

    static let shared = HealthKitStepManager()

    // MARK: - Core objects
    private let store = HKHealthStore()
    private let defaults = UserDefaults.standard

    // ✅ stepType 정의 (이게 빠져 있었음)
    private let stepType: HKQuantityType = {
        guard let type = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            fatalError("StepCount type is not available")
        }
        return type
    }()

    // MARK: - Storage keys
    private let keyTodaySteps = "hk_today_steps"
    private let keyLastUpdate = "hk_last_update_ts"

    // MARK: - ObserverQuery
    private var observerQuery: HKObserverQuery?

    private init() {}

    // MARK: - Permission
    func isStepAuthGranted() -> Bool {
        return store.authorizationStatus(for: stepType) == .sharingAuthorized
    }

    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, nil)
            return
        }

        store.requestAuthorization(
            toShare: [],
            read: [stepType]
        ) { success, error in
            completion(success, error)
        }
    }

    // MARK: - Today steps (00:00 ~ now)
    func fetchTodaySteps(completion: @escaping (Int) -> Void) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())

        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: Date(),
            options: .strictStartDate
        )

        let query = HKStatisticsQuery(
            quantityType: stepType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, _ in
            let sum = result?
                .sumQuantity()?
                .doubleValue(for: HKUnit.count()) ?? 0
            completion(Int(sum))
        }

        store.execute(query)
    }

    // MARK: - Background delivery
    func startBackgroundDelivery() {

        let query = HKObserverQuery(
            sampleType: stepType,
            predicate: nil
        ) { [weak self] _, completionHandler, _ in
            guard let self = self else {
                completionHandler()
                return
            }

            self.fetchTodaySteps { steps in
                self.defaults.set(steps, forKey: self.keyTodaySteps)
                self.defaults.set(
                    Date().timeIntervalSince1970,
                    forKey: self.keyLastUpdate
                )
                completionHandler() // ⚠️ 필수
            }
        }

        observerQuery = query
        store.execute(query)

        store.enableBackgroundDelivery(
            for: stepType,
            frequency: .immediate
        ) { success, error in
            if let error = error {
                print("❌ enableBackgroundDelivery error:", error)
            } else {
                print("✅ Background delivery enabled:", success)
            }
        }
    }

    func stopBackgroundDelivery() {
        if let q = observerQuery {
            store.stop(q)
        }
        observerQuery = nil
        store.disableAllBackgroundDelivery { _, _ in }
    }

    // MARK: - Cached values for Flutter
    func getCachedTodaySteps() -> Int {
        defaults.integer(forKey: keyTodaySteps)
    }

    func getCachedLastUpdate() -> Double {
        defaults.double(forKey: keyLastUpdate)
    }
}
