//
//  NotificationLabel.swift
//  railway
//
//  Created by Dayna Naismyth on 2017-03-03.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import Foundation
import UIKit

class NotificationLabel : UILabel {    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.commonInit()
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    func commonInit(){
            self.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            self.layer.zPosition = 0
            self.backgroundColor = UIColor(red:0.32, green:0.49, blue:0.69, alpha:1.0)
            self.textColor = UIColor.white
            self.textAlignment = NSTextAlignment.center
            self.font =  UIFont(name: Constants.FONT.navBarFont, size: 16) ?? UIFont.systemFont(ofSize: 16)
            self.layer.cornerRadius = self.bounds.width/2
            self.clipsToBounds = true
    }

}
