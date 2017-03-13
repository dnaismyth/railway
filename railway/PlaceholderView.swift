//
//  PlaceholderView.swift
//  railway
//
//  Created by Dayna Naismyth on 2017-03-12.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit

@IBDesignable class PlaceholderView: UIView {
    
    var view: UIView!
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)!
        setupView()
    }
    
    func setupView(){
//        view = loadViewFromNib()
//        view.frame = bounds
//        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        view.isHidden = false
//        self.addSubview(view)
        
    }
    
    func loadViewFromNib() -> UIView{
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName:"emptyPlaceholderView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }

}
