//
//  TrainAlertSettingsViewController.swift
//  railway
//
//  Created by Dayna Naismyth on 2017-02-21.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit

class TrainAlertSettingsViewController: UIViewController {
    
    let userDefaults = Foundation.UserDefaults.standard
    
    var city : String = ""
    var address : String = ""
    var trainCrossingId : Int = -1
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Initialize labels with string passed through
        cityLabel.text = city
        addressLabel.text = address
        print(trainCrossingId)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override open var shouldAutorotate: Bool {
        return false
    }
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override open var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    @IBAction func sendAlertButton(_ sender: UIButton) {
        if(trainCrossingId >= 0){
            sendTrainCrossingAlert(trainCrossingId: trainCrossingId)
        } else {
            print("Error sending train alert")
        }
    }
    
    private func sendTrainCrossingAlert(trainCrossingId : Int){
        let access_token = userDefaults.string(forKey:"access_token")
        let params : [String : AnyObject] = [:]
        let url : String = Constants.API.reportTrainCrossing.replacingOccurrences(of: "id", with: String(trainCrossingId))
        PostRequest().jsonPost(postUrl: url, token: access_token!, body: params) { (dictionary) in
            print("Finished reporting")
        }
    }
}
