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
        if let restingHeartRate = myHealthController.myHealth.restingHeartRate {
            restingHRLabel.text = String(format: "%.1f", restingHeartRate)
        }
        
        if let timeAsleep = myHealthController.myHealth.timeAsleep {
            timeAsleepLabel.text = "\(String(format: "%.1f", timeAsleep)) hr"
        }

        if let timeToFallAsleep = myHealthController.myHealth.timeToFallAsleep {
            timeToFallAsleepLabel.text = "\(String(format: "%.0f", timeToFallAsleep)) min"
        }
    }
    
    private func updateHealthInfo() {
        myHealthController.loadAndDisplayRestingHeartRate() { () in self.updateLabels() }
        myHealthController.loadAndDisplaySleepAnalyisis() { () in self.updateLabels() }
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
        return HealthKitController(typesToWrite: HealthKitConstants().typesToWrite, typesToRead: HealthKitConstants().typesToRead)
    }
    let localNotificationHelper = LocalNotificationHelper()

    @IBOutlet weak var restingHRLabel: UILabel!
    @IBOutlet weak var timeAsleepLabel: UILabel!
    @IBOutlet weak var timeToFallAsleepLabel: UILabel!
    
    
}
