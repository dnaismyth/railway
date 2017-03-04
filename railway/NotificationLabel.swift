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
    
    @IBInspectable var maskTobounds : Bool = true
    @IBInspectable var borderWidth : Float = 1.0
    @IBInspectable var borderColor : UIColor = UIColor.clear
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.commonInit()
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    func commonInit(){
        self.layer.cornerRadius = self.bounds.width/2
        self.clipsToBounds = maskTobounds
        self.textColor = UIColor.white
        self.setProperties(borderWidth: borderWidth, borderColor:borderColor)
    }
    
    func setProperties(borderWidth: Float, borderColor: UIColor) {
        self.layer.borderWidth = CGFloat(borderWidth)
        self.layer.borderColor = borderColor.cgColor
    }

}
