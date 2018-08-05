//
//  MyHealth.swift
//  my-health-app
//
//  Created by De MicheliStefano on 05.08.18.
//  Copyright © 2018 De MicheliStefano. All rights reserved.
//

import Foundation
import HealthKit

struct MyHealth {
    
    init(someHealthObject: UUID) {
        self.someHealthObject = HKQuery.predicateForObject(with: someHealthObject)
    }
    
    var someHealthObject: NSPredicate
    
}
