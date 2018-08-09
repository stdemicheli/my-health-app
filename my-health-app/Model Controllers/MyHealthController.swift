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
    

    
    // MARK: - Properties
    
    let healthKitTypesToWrite: Set<HKSampleType>  = Set([
                        HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
                        HKObjectType.quantityType(forIdentifier: .heartRate)!])
    
    let healthKitTypesToRead: Set<HKObjectType> = Set([
                        HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
                        HKObjectType.quantityType(forIdentifier: .heartRate)!])
    
}
