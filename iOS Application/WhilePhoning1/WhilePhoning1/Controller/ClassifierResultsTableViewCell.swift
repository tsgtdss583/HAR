//
//  ClassifierResultsTableViewCell.swift
//  MLClassifier
//
//  Created by tsige on 2019/02/10.
//  Copyright © 2019 tsige. All rights reserved.
//

import UIKit

class ClassifierResultsTableViewCell: UITableViewCell {

    @IBOutlet weak var predictedActivtyDisplayLabel: UILabel!
    @IBOutlet weak var confidenceLevelDisplayLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
