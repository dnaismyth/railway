//
//  TrainAlertTableViewCell.swift
//  railway
//
//  Created by Dayna Naismyth on 2017-02-18.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit

class TrainAlertTableViewCell: UITableViewCell {
    
    //MARK: Properties
    @IBOutlet weak var railwayImage: UIImageView!
    @IBOutlet weak var notificationCount: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!

    
    let userDefaults = Foundation.UserDefaults.standard

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
