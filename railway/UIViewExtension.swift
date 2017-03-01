//
//  UIViewExtension.swift
//  railway
//
//  Created by Dayna Naismyth on 2017-02-28.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import Foundation
import UIKit

extension UIView{
    
    func addShadowView(width:CGFloat=0.2, height:CGFloat=1.2, Opacidade:Float=0.6, maskToBounds:Bool=false, radius:CGFloat=0.6){
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowOffset = CGSize(width: width, height: height)
        self.layer.shadowRadius = radius
        self.layer.shadowOpacity = Opacidade
        self.layer.masksToBounds = maskToBounds
    }
    
    func addRadius(radius:CGFloat=13.0){
        self.layer.cornerRadius = radius
    }
}
