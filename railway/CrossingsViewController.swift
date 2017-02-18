//
//  CrossingsViewController.swift
//  railway
//
//  Created by Dayna Naismyth on 2017-02-15.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit

class CrossingsViewController: UIViewController {
    
    let userDefaults = Foundation.UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        getUserTrainAlerts()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    private func getUserTrainAlerts(){
        let access_token :String? = userDefaults.string(forKey: "access_token")
        GetRequest().HTTPGet(getUrl: Constants.API.userTrainAlerts.appending("?page=0&size=50"), token: access_token!)
    }

}
