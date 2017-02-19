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
        var trainCrossingLocation : [String : AnyObject] = trainCrossing["location"] as! [String : AnyObject]
        let province : String = trainCrossingLocation ["province"] as! String
        let city : String = trainCrossingLocation ["city"] as! String
        let address : String = trainCrossingLocation["address"] as! String
        cell.locationTextField.text = city.appending(", ").appending(province)
        cell.addressTextField.text = address
        cell.tag = trainCrossing["id"] as! Int
        
        // TODO: Use this later to change the image icon
        var railway : String = trainCrossing["railway"] as! String
        setRailwayCellImage(railway: railway, cell: cell)
        return cell
        
    }
    
    private func setRailwayCellImage(railway : String, cell : TrainAlertTableViewCell){
        switch(railway){
            case "CN":
                cell.railwayImage.image = #imageLiteral(resourceName: "CNRailway")
                break
            case "VIA":
                cell.railwayImage.image = #imageLiteral(resourceName: "VIARailway")
                break
            case "GO":
                cell.railwayImage.image = #imageLiteral(resourceName: "GORailway")
                break
            case "CP":
                cell.railwayImage.image = #imageLiteral(resourceName: "CPRailway")
                break
            default:
                break
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            let cell = tableView.cellForRow(at: indexPath as IndexPath) as! TrainAlertTableViewCell
            let idToRemove : Int = cell.tag
            print("Removing id \(idToRemove)")
            let removed : Bool = removeTrainAlert(trainCrossingId : idToRemove)
            trainAlertContent.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.right)
            if(removed){
                self.refreshTableView()
                print("Row removed")
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    private func getUserTrainAlerts(){
        let access_token :String? = userDefaults.string(forKey: "access_token")
        GetRequest().HTTPGet(getUrl: Constants.API.userTrainAlerts.appending("?page=0&size=50"), token: access_token!, completionHandler: { (dictionary) -> Void in
            OperationQueue.main.addOperation{
                
                self.trainAlertData = (dictionary.value(forKey: "page") as! NSDictionary?)!
                self.trainAlertContent = self.trainAlertData["content"] as! [[String:AnyObject]]
                self.refreshTableView()
            }
        })
    }
    
    public func setUpTrainAlerts(){
        getUserTrainAlerts()
    }
    
    public func refreshTableView(){
        self.trainAlertTableView.reloadData()
    }
    
    private func removeTrainAlert(trainCrossingId : Int) -> Bool{
        var removed : Bool = false
        let access_token : String = userDefaults.string(forKey: "access_token")!
        let url : String = Constants.API.removeTrainAlert.replacingOccurrences(of: "id", with: String(trainCrossingId))
        DeleteRequest().HTTPDelete(getUrl: url, token: access_token, completionHandler: {
            (dictionary) -> Void in  OperationQueue.main.addOperation{
                if((dictionary["operationType"]! as AnyObject).isEqual("DELETE")){
                    print("Removing alert")
                    removed = true
                }
            }
        })
        return removed
    }

}
