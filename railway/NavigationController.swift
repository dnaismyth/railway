//
//  NavigationController.swift
//  railway
//
//  Created by Dayna Naismyth on 2017-03-03.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.formatNavigationBar()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    private func formatNavigationBar(){
        //self.navigationBar.barTintColor = UIColor.lightGray
        let navbarFont = UIFont(name: Constants.FONT.navBarFont, size: 20) ?? UIFont.systemFont(ofSize: 20)
        let barbuttonFont = UIFont(name: Constants.FONT.navBarFont, size: 20) ?? UIFont.systemFont(ofSize: 20)
        
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: navbarFont, NSForegroundColorAttributeName:UIColor.black]
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: barbuttonFont, NSForegroundColorAttributeName:UIColor.black], for: UIControlState.normal)
    }

}
