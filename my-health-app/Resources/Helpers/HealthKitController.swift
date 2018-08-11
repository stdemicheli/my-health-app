//
//  HealthKitHelper.swift
//  my-health-app
//
//  Created by De MicheliStefano on 05.08.18.
//  Copyright © 2018 De MicheliStefano. All rights reserved.
//

import Foundation
import UIKit
import HealthKit

// TODO: Think about whether delegate is actually needed
protocol HealthKitControllerDelegate: class {
}

class HealthKitController {
    
    // MARK: - Init
    
    init(healthTypesToWrite: Set<HKSampleType>, healthTypesToRead: Set<HKObjectType>) {
        self.healthTypesToWrite = healthTypesToWrite
        self.healthTypesToRead = healthTypesToRead
    }
    
    // MARK: - Properties
    
    var healthTypesToWrite: Set<HKSampleType>
    var healthTypesToRead: Set<HKObjectType>
    var healthStore: HKHealthStore? {
        return HKHealthStore.isHealthDataAvailable() ? HKHealthStore() : nil
    }
    weak var delegate: HealthKitControllerDelegate?
    
    private enum HealthkitSetupError: Error {
        case notAvailableOnDevice
        case dataTypeNotAvailable
    }
    
    // MARK: - Methods
    
    func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Void) {
        guard let healthStore = self.healthStore else {
            NSLog("HealthKit is not available on this device")
            completion(false, HealthkitSetupError.notAvailableOnDevice)
            return
        }
        
        healthStore.requestAuthorization(toShare: self.healthTypesToWrite, read: self.healthTypesToRead) { (success, error) in
            completion(success, error)
        }
    }
    
    // Check authorization status for a single HKObject
    func handleHealthKitAuth(forObject type: HKObjectType) {
        guard let healthStore = healthStore else { return }
        let authStatus = healthStore.authorizationStatus(for: type)
        
        if authStatus == .sharingDenied {
            alertUserAboutRestrictedHKAccess()
        } else if authStatus == .notDetermined {
            healthStore.requestAuthorization(toShare: nil, read: Set([type]), completion: { (success, error) in
                if !success {
                    NSLog("Error occured while requesting authorization for HKHealthStore: \(String(describing: error))")
                }
            })
        }
    }
    
    func getSleepAnalysis(from startDate: Date, to endDate: Date, completion: @escaping (Error?) -> Void) {
        if let sleepType = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis) {
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            
            // let noon = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date())!
            let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
            let yesterdayPredicate = HKQuery.predicateForSamples(withStart: yesterday, end: Date(), options: .strictEndDate)
            
            let sampleQuery = HKSampleQuery(sampleType: sleepType, predicate: yesterdayPredicate, limit: 30, sortDescriptors: [sortDescriptor]) { (query, samples, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        NSLog("Error retrieving sleep data: \(error)")
                        completion(error)
                        return
                    }
                    
                    guard let samples = samples else {
                        NSLog("Could not retrieve sample using query: \(query)")
                        completion(NSError())
                        return
                    }
                    
                    guard let categorySamples = samples as? [HKCategorySample] else { return }
                    let filteredCategorySamples = self.filterOverlappingTimeIntervals(in: categorySamples)
                    
                    print(Double(self.getSleepTimeInterval(for: HKCategoryValueSleepAnalysis.asleep.rawValue, in: filteredCategorySamples) / 3600))
                    print(Double(self.getSleepTimeInterval(for: HKCategoryValueSleepAnalysis.inBed.rawValue, in: filteredCategorySamples) / 3600))
                    print(Double(self.timeToFallAsleep(in: filteredCategorySamples) / 60))
                    
                    for sample in filteredCategorySamples {
                        let value = (sample.value == HKCategoryValueSleepAnalysis.asleep.rawValue) ? "asleep" : "inBed"
                        print("HealthKit sleep: \(sample.startDate) \(sample.endDate) - value: \(value)")
                    }
                    
                }
            }
            healthStore?.execute(sampleQuery)
        }
    }
    
    private func getSleepTimeInterval(for HKCategory: Int, in samples: [HKCategorySample]) -> TimeInterval {
        var timeAsleep: TimeInterval = 0.0
        for sample in samples {
            if sample.value == HKCategory {
                timeAsleep += sample.endDate.timeIntervalSince(sample.startDate)
            }
        }
        return timeAsleep
    }
    
    private func filterOverlappingTimeIntervals(in samples: [HKCategorySample]) -> [HKCategorySample] {
        var filteredSamples: [HKCategorySample] = []
        for (index, sample) in samples.enumerated() {
            if index == samples.count - 1 { break }
            if max(sample.startDate, samples[index + 1].startDate) < min(sample.endDate, samples[index + 1].endDate) {
                filteredSamples.append(sample)
            }
        }
        return filteredSamples
    }
    
    private func timeToFallAsleep(in samples: [HKCategorySample]) -> TimeInterval {
        let timeFellAsleep = samples.filter { $0.value == HKCategoryValueSleepAnalysis.asleep.rawValue }
                                    .map { $0.startDate }
                                    .reduce(Date()) { $0 > $1 ? $1 : $0 }
        
        let gotInBed = samples.filter { $0.value == HKCategoryValueSleepAnalysis.inBed.rawValue }
                              .map { $0.startDate }
                              .reduce(Date()) { $0 > $1 ? $1 : $0 }
        
        return timeFellAsleep.timeIntervalSince(gotInBed)
    }
    
    func getMostRecentSample(for sampleType: HKSampleType, completion: @escaping (HKQuantitySample?, Error?) -> Void) {
        let mostRecentPredicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictEndDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let limit = 1
        let sampleQuery = HKSampleQuery(sampleType: sampleType,
                                        predicate: mostRecentPredicate,
                                        limit: limit,
                                        sortDescriptors: [sortDescriptor]) { (query, samples, error) in
                                            
            DispatchQueue.main.async {
                guard   let samples = samples,
                        let mostRecentSample = samples.first as? HKQuantitySample else {
                            completion(nil, error)
                            return
                        }
                completion(mostRecentSample, nil)
            }
                                            
        }
        
        healthStore?.execute(sampleQuery)
    }
    
    private func alertUserAboutRestrictedHKAccess() {
        if let delegate = delegate as? UIViewController {
            let alert = UIAlertController(title: "Can\'t access health data", message: "Please go to your settings and allow the app access to your health data.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                NSLog("User has pressed ok alert occured.")
            }))
            delegate.present(alert, animated: true, completion: nil)
        }
    }
}
