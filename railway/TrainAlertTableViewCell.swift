//
//  TrainAlertTableViewCell.swift
//  railway
//
//  Created by Dayna Naismyth on 2017-02-18.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit

class TrainAlertTableViewCell: UITableViewCell {
    
    @IBOutlet weak var locationTextField: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func removeAlertButton(_ sender: UIButton) {
        print("Removing alert")
    }

}
