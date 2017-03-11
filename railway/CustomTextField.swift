//
//  CustomTextField.swift
//  railway
//
//  Created by Dayna Naismyth on 2017-03-10.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit

class CustomTextField: UITextField {
    
    let inset: CGFloat = 35
    let offset : CGFloat = 28
    @IBInspectable var borderColor: UIColor = UIColor.clear


//    override var tintColor: UIColor! {
//        
//        didSet {
//            setNeedsDisplay()
//        }
//    }
    
    override func draw(_ rect: CGRect) {
        
        let startingPoint   = CGPoint(x: rect.minX + offset, y: rect.maxY)
        let endingPoint     = CGPoint(x: rect.maxX, y: rect.maxY)
        
        let path = UIBezierPath()
        
        path.move(to: startingPoint)
        path.addLine(to: endingPoint)
        path.lineWidth = 2.0
        
        borderColor.setStroke()
        
        path.stroke()
    }
    
    
    // placeholder position
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: inset , dy: 0)
    }
    
    // text position
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: inset, dy: 0)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: inset, dy: 0)
    }
}
