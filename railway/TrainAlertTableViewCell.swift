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
        
        // Format for iPhone 5
        if UIScreen.main.sizeType == .iPhone5 {
            railwayImage.frame.size.width = 35
            railwayImage.frame.size.height = 35
            cityLabel.font = UIFont(name : cityLabel.font.fontName, size: 17)
            addressLabel.font = UIFont(name: addressLabel.font.fontName, size: 14)
            addressLabel.numberOfLines = 1
            addressLabel.adjustsFontSizeToFitWidth = true
            cityLabel.numberOfLines = 1
            cityLabel.adjustsFontSizeToFitWidth = true
            let margins = self.layoutMarginsGuide
            notificationCount.leadingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -60).isActive = true
            print("Setting the railway image size")
        } else {
            addressLabel.numberOfLines = 1
            addressLabel.adjustsFontSizeToFitWidth = true
            addressLabel.minimumScaleFactor = 0.5
            cityLabel.numberOfLines = 1
            cityLabel.adjustsFontSizeToFitWidth = true
            addressLabel.minimumScaleFactor = 0.5
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
