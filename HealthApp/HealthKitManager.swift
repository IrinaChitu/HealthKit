//
//  HealthKitManager.swift
//  HealthApp
//
//  Created by Irina Chitu on 30.09.2024.
//

import Foundation
import HealthKit
import SwiftUI

class HealthKitManager: ObservableObject {
    var healthStore: HKHealthStore?
    let stepCountType = HKQuantityType(.stepCount)
    
    @Published var permissionsTriggered: Bool = false
    @Published var stepsCount: Int = 0
    
    init() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
        }
    }
    
    func requestAuthorization() {
        // Request authorization for steps quantity type.
        healthStore?.requestAuthorization(toShare: nil, read: [stepCountType]) { (success, error) in
            if (!success) {
                // Handle error.
                return
            }
            DispatchQueue.main.async { [weak self] in
                self?.permissionsTriggered = true
                Task {
                    await self?.fetchStepsData()
                    self?.observeStepsData()
                }
                
            }
        }
    }
    
    func fetchStepsData() async {
        guard let healthStore else { return }
        // Create the descriptor.
        let now = Date()
        let yesterday = Calendar.current.date(byAdding: DateComponents(day: -1), to: now)!
        let startOfYesterday = Calendar.current.startOfDay(for: yesterday)
        let predicate = HKQuery.predicateForSamples(withStart: startOfYesterday, end: now, options: .strictStartDate)

        let descriptor = HKSampleQueryDescriptor(
            predicates:[.quantitySample(type: stepCountType, predicate: predicate)],
            sortDescriptors: [SortDescriptor(\.endDate, order: .reverse)],
            limit: nil)


        // Launch the query and wait for the results.
        // The system automatically sets results to [HKQuantitySample].
        let results = try? await descriptor.result(for: healthStore)

        if let steps = results?.compactMap({ $0.quantity.doubleValue(for: .count()) }).reduce(0, +) {
            DispatchQueue.main.async { [weak self] in
                self?.stepsCount = Int(exactly: steps)!
            }
        }
    }
    
    func observeStepsData() {
        let query = HKObserverQuery(sampleType: stepCountType, predicate: nil) { (query, completionHandler, errorOrNil) in
            if let error = errorOrNil {
                // Properly handle the error.
                return
            }
            print("Data was updated")
            Task {
                await self.fetchStepsData()
            }
                
            // Take whatever steps are necessary to update your app.
            // This often involves executing other queries to access the new data.
            
            // If you have subscribed for background updates you must call the completion handler here.
            // This lets HealthKit know that your app successfully received the background delivery.
            // If you don’t call the update’s completion handler, HealthKit continues to attempt to launch your app
            //  If your app fails to respond three times, HealthKit assumes your app can’t receive data and stops sending background updates.
             completionHandler()
        }
        
        healthStore?.execute(query)
    }
}
