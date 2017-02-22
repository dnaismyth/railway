//
//  TrainAlertSettingsViewController.swift
//  railway
//
//  Created by Dayna Naismyth on 2017-02-21.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit

class TrainAlertSettingsViewController: UIViewController {
    
    var city : String = ""
    var address : String = ""
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Initialize labels with string passed through
        cityLabel.text = city
        addressLabel.text = address
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
