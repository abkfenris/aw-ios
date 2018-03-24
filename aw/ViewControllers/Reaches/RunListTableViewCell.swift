//
//  RunListTableViewCell.swift
//  aw
//
//  Created by Alex Kerney on 3/24/18.
//  Copyright © 2018 Alex Kerney. All rights reserved.
//

import UIKit

class RunListTableViewCell: UITableViewCell {

    @IBOutlet weak var conditionColorView: UIView!
    @IBOutlet weak var riverName: UILabel!
    @IBOutlet weak var sectionLabel: UILabel!
    @IBOutlet weak var difficultyLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setup(reach: Reach) {
        
        
        let condition = AWApiHelper.shared.conditionFromApi(condition: reach.condition ?? "")
        
        conditionColorView.backgroundColor = condition.color
        
        riverName.text = reach.name
        sectionLabel.text = reach.section
        difficultyLabel.text = "Level: \(reach.lastGageReading ?? "Unknown") Class: \(reach.difficulty ?? "Unknown")"
        difficultyLabel.textColor = condition.color
    }

}
