//
//  MyHealthTableViewController.swift
//  my-health-app
//
//  Created by De MicheliStefano on 05.08.18.
//  Copyright © 2018 De MicheliStefano. All rights reserved.
//

import UIKit
import HealthKit

class MyHealthTableViewController: UITableViewController, HealthKitControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        healthKitController.authorizeHealthKit { (authorized, error) in
            
            guard authorized else {
                
                let baseMessage = "HealthKit Authorization Failed"
                
                if let error = error {
                    print("\(baseMessage). Reason: \(error.localizedDescription)")
                } else {
                    print(baseMessage)
                }
                
                return
            }
            
            print("HealthKit Successfully Authorized.")
            self.updateHealthInfo()
        }
    }
    
    // MARK: - Methods
    
    @IBAction func getCalendar(_ sender: Any) {
    }
    
    private func updateLabels() {
        if let restingHeartRate = myHealth.restingHeartRate {
            restingHRLabel.text = String(format: "%.1f", restingHeartRate)
        }
    }
    
    private func updateHealthInfo() {
        loadAndDisplayRestingHeartRate()
        loadAndDisplaySleepAnalyisis()
    }
    
    private func loadAndDisplayRestingHeartRate() {
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
            self.updateLabels()
            print("Data loaded for: \(HKSampleType.quantityType(forIdentifier: .restingHeartRate)!.identifier)")
        }
    }
    
    private func loadAndDisplaySleepAnalyisis() {
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        
        healthKitController.getSleepAnalysis(from: yesterday, to: today) { (error) in
            if let error = error {
                NSLog("Error occured fetching health data: \(error)")
                return
            }
        }
    }
    
//    private func handleLocalNotificationAuth() {
//        localNotificationHelper.getAuthorizationStatus(completion: { (status) in
//            if status == .authorized {
//                // check if daily notifications have been set (userdefaults)
//                // else, schedulenotification
//            } else {
//                self.localNotificationHelper.requestAuthorization(completion: { (success) in
//                    if success {
//                        // check if daily notifications have been set (userdefaults)
//                        // else, schedulenotification
//                    }
//                })
//            }
//        })
//    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Properties
    
    private var myHealth = MyHealth()
    let myHealthController = MyHealthController()
    var healthKitController: HealthKitController {
        return HealthKitController(healthTypesToWrite: HealthKitConstants().healthKitTypesToWrite, healthTypesToRead: HealthKitConstants().healthKitTypesToRead)
    }
    let localNotificationHelper = LocalNotificationHelper()

    @IBOutlet weak var restingHRLabel: UILabel!
    @IBOutlet weak var hoursOfSleepLabel: UILabel!
    
}
