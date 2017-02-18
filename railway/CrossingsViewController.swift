    //
//  CrossingsViewController.swift
//  railway
//
//  Created by Dayna Naismyth on 2017-02-15.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit

class CrossingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //MARK: Properties
    @IBOutlet weak var trainAlertTableView: UITableView!
    let userDefaults = Foundation.UserDefaults.standard
    var trainAlertData : NSDictionary = [:]     // data from api call to retrieve all user train alerts
    var trainAlertContent : [[String:AnyObject]] = []  // this will store the content of each train alert

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTrainAlerts()
        self.trainAlertTableView.delegate = self
        self.trainAlertTableView.dataSource = self
        self.trainAlertTableView.tableFooterView = UIView()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trainAlertContent.count
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "trainAlertCell") as! TrainAlertTableViewCell
        var alertInfo : [String : AnyObject] = trainAlertContent[indexPath.row]
        var trainCrossing : [String : AnyObject] = alertInfo["trainCrossing"] as! [String : AnyObject]
        cell.locationTextField.text = trainCrossing ["railway"] as! String?
        return cell
        
    }

    private func getUserTrainAlerts(){
        let access_token :String? = userDefaults.string(forKey: "access_token")
        GetRequest().HTTPGet(getUrl: Constants.API.userTrainAlerts.appending("?page=0&size=50"), token: access_token!, completionHandler: { (dictionary) -> Void in
            OperationQueue.main.addOperation{
                
                self.trainAlertData = (dictionary.value(forKey: "page") as! NSDictionary?)!
                self.trainAlertContent = self.trainAlertData["content"] as! [[String:AnyObject]]
                self.trainAlertTableView.reloadData()
            }
        })
    }
    
    public func setUpTrainAlerts(){
        getUserTrainAlerts()
    }

}
