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
    }

}
