//
//  MyHealthController.swift
//  my-health-app
//
//  Created by De MicheliStefano on 05.08.18.
//  Copyright © 2018 De MicheliStefano. All rights reserved.
//

import Foundation
import HealthKit

class MyHealthController {
    
    
    // MARK: - Public Methods
    
    func loadAndDisplayRestingHeartRate(completion: @escaping () -> Void) {
        healthKitController.getMostRecentSample(for: HKSampleType.quantityType(forIdentifier: .restingHeartRate)!) { (sample, error) in
            guard let sample = sample else {
                if let error = error {
                    NSLog("Error occured fetching health data: \(error)")
                }
                return
            }
            
            let unit = HKUnit.count().unitDivided(by: HKUnit.minute())
            let restingHeartRate = sample.quantity.doubleValue(for: unit)
            self.myHealth.restingHeartRate = restingHeartRate
            completion()
        }
    }
    
    func loadAndDisplaySleepAnalyisis(completion: @escaping () -> Void) {
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        
        healthKitController.getSleepAnalysis(from: yesterday, to: today) { (sample, error) in
            if let error = error {
                NSLog("Error occured fetching health data: \(error)")
                return
            }
            
            guard let sample = sample else {
                NSLog("Sample for Sleep Analysis could not be loaded")
                return
            }
            
            self.myHealth.timeToFallAsleep = Double(self.healthKitController.timeToFallAsleep(in: sample) / 60)
            self.myHealth.timeAsleep = Double(self.healthKitController.getSleepTimeInterval(for: HKCategoryValueSleepAnalysis.asleep.rawValue, in: sample) / 3600)
            completion()
        }
    }
    
    // MARK: - Private Methods
    
    private func getHKObjectTypeIdentifiers(for set: Set<HKObjectType>) -> [String] {
        return Array(set).map { $0.identifier }
    }
    
    // MARK: - Properties
    var myHealth = MyHealth()
    let healthKitController = HealthKitController(typesToWrite: HealthKitConstants().typesToWrite, typesToRead: HealthKitConstants().typesToRead)
    
}
