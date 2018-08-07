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
        initializeHealthKit()
    }
    
    // MARK: - Methods
    @IBAction func getCalendar(_ sender: Any) {
        healthKitController.createTypeObject()
    }
    
    private func initializeHealthKit() {
        // Check whether HealthKit is both enabled and available on the device
        if HKHealthStore.isHealthDataAvailable() {
            // Instantiate a HKHealthStore object
            healthKitController.delegate = self
            healthKitController.healthStore = HKHealthStore()
            healthKitController.handleInitialHealthKitAuth(for: myHealthController.healthTypes)
            // Do some more stuff
            // Once user grants permission to share a data type, we can read/create new samples
            // Everytime we want to save data to our app, we must check its authorizationStatus
        }
    }
    
    private func handleLocalNotificationAuth() {
        localNotificationHelper.getAuthorizationStatus(completion: { (status) in
            if status == .authorized {
                // check if daily notifications have been set (userdefaults)
                // else, schedulenotification
            } else {
                self.localNotificationHelper.requestAuthorization(completion: { (success) in
                    if success {
                        // check if daily notifications have been set (userdefaults)
                        // else, schedulenotification
                    }
                })
            }
        })
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyHealthCell", for: indexPath)

        // Configure the cell...

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
    
    var myHealthController = MyHealthController()
    var healthKitController = HealthKitController()
    var localNotificationHelper = LocalNotificationHelper()

}
