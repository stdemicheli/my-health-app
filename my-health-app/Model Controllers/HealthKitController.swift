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

protocol HealthKitControllerDelegate {
    
}

class HealthKitController {
    
    // Check whether initial authorization has been done
    func handleInitialHealthKitAuth(for healthTypes: Set<HKObjectType>) {
        guard let healthStore = healthStore else { return }
        let userDefaults = UserDefaults.standard
        // Check if authorizedHealthTypes have been previously saved in userDefaults
        let authorizedHealthTypes = userDefaults.array(forKey: types.authorizedHealthTypes)
        
        if authorizedHealthTypes == nil {
            healthStore.requestAuthorization(toShare: nil, read: healthTypes, completion: { (success, error) in
                if !success {
                    NSLog("Error occured while requesting authorization for HKHealthStore: \(String(describing: error))")
                }
                // Save a list of authorizedHealthType identifiers in userDefaults
                let healthTypeIdentifiers = self.getHKObjectTypeIdentifiers(for: healthTypes)
                userDefaults.set(healthTypeIdentifiers, forKey: self.types.authorizedHealthTypes)
            })
        }
    }
    
    // Check authorization status for a single HKObject
    func handleHealthKitAuth(for type: HKObjectType) {
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
    
    func alertUserAboutRestrictedHKAccess() {
        if let delegate = delegate as? UIViewController {
            let alert = UIAlertController(title: "Can\'t access health data", message: "Please go to your settings and allow the app access to your health data.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                NSLog("User has pressed ok alert occured.")
            }))
            delegate.present(alert, animated: true, completion: nil)
        }
    }
    
    private func getHKObjectTypeIdentifiers(for set: Set<HKObjectType>) -> [String] {
        return Array(set).map { $0.identifier }
    }
    
    // Testing purposes
    func createTypeObject() {
        guard let sampleType = HKSampleType.quantityType(forIdentifier: .restingHeartRate) else {
            fatalError("*** This method should never fail ***")
        }
        let calendar = NSCalendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month, .day], from: now)
        guard let startDate = calendar.date(from: components) else {
            fatalError("*** Unable to create the start date ***")
        }
        let newStartDate = calendar.date(byAdding: .day, value: -1, to: startDate)
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)
        
        let predicate = HKQuery.predicateForSamples(withStart: newStartDate, end: endDate, options: [])
        
        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil, resultsHandler: { (query, results, error) in
            guard let samples = results as? [HKQuantitySample] else { fatalError("An error occured while fetching HK data") }
            print(samples)
        })
        
        healthStore?.execute(query)
        
        //HKObjectType.quantityType(forIdentifier: .restingHeartRate)
    }
    
    var delegate: HealthKitControllerDelegate?
    var healthStore: HKHealthStore?
    var types = Types()
    
}
