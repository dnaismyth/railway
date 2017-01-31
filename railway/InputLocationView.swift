//
//  InputLocationView.swift
//  railway
//
//  Created by Dayna Naismyth on 2017-01-29.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class InputLocationView: UIView, UITextFieldDelegate{
    
    //MARK: Properties
    var view: UIView!
    var city: String!
    var address: String!
    
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)!
        setupView()
    }
    
    func setupView(){
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.isHidden = false
        self.addSubview(view)
        
    }
    
    func loadViewFromNib() -> UIView{
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName:"InputLocationView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    func getCityInput() -> String {
        return "Port Coquitlam"
    }
    
    func getAddressInput() -> String {
        return "34-2450 Lobb Avenue"
    }
    
}
