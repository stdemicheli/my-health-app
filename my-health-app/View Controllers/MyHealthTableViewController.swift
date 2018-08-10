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
            self.loadAndDisplayRestingHeartRate()
        }
    }
    
    // MARK: - Methods
    
    @IBAction func getCalendar(_ sender: Any) {
    }
    
    private func updateHealthInfo() {
        loadAndDisplayRestingHeartRate()
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
            self.tableView.reloadData()
            print("Resting Heart Rate loaded.")
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

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyHealthCell", for: indexPath) as! MyHealthTableViewCell

        if let restingHeartRate = myHealth.restingHeartRate {
            cell.metricValueTextLabel?.text = String(format: "%.1f", restingHeartRate)
            cell.metricTypeTextLabel?.text = "BPM"
            cell.metricTitleTextLabel?.text = "Resting Heart Rate"
        }

        return cell
    }

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
    
    var myHealthController = MyHealthController()
    var healthKitController: HealthKitController {
        return HealthKitController(healthTypesToWrite: healthKitTypesToWrite, healthTypesToRead: healthKitTypesToRead)
    }
    var localNotificationHelper = LocalNotificationHelper()
    
    // To be moved to myHealthController
    let healthKitTypesToWrite: Set<HKSampleType>  = Set([
        HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
        HKObjectType.quantityType(forIdentifier: .heartRate)!])
    
    let healthKitTypesToRead: Set<HKObjectType> = Set([
        HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
        HKObjectType.quantityType(forIdentifier: .heartRate)!])

}
