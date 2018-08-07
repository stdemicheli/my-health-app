//
//  MyHealthTableViewCell.swift
//  my-health-app
//
//  Created by De MicheliStefano on 05.08.18.
//  Copyright © 2018 De MicheliStefano. All rights reserved.
//

import UIKit

class MyHealthTableViewCell: UITableViewCell {

    
    // MARK: - Methods
    
    private func updateViews() {
        
    }
    
    
    // MARK: - Properties

    @IBOutlet weak var metricTitleTextLabel: UILabel!
    @IBOutlet weak var metricValueTextLabel: UILabel!
    @IBOutlet weak var metricTypeTextLabel: UILabel!
}
