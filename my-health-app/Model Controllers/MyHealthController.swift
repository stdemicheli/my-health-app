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
    
    // MARK: - Private Methods
    
    private func getHKObjectTypeIdentifiers(for set: Set<HKObjectType>) -> [String] {
        return Array(set).map { $0.identifier }
    }
    
    // MARK: - Properties
    
    
}
