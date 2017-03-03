        //
//  CrossingsViewController.swift
//  railway
//
//  Created by Dayna Naismyth on 2017-02-15.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging
        
class CrossingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    typealias FinishedSettingData = () -> ()

    //MARK: Properties
    @IBOutlet weak var trainAlertTableView: UITableView!
    
    let userDefaults = Foundation.UserDefaults.standard
    var trainAlertData : NSDictionary = [:]     // data from api call to retrieve all user train alerts
    var trainAlertContent : [[String:AnyObject]] = []  // this will store the content of each train alert
    var firebaseData: [TrainCrossingData]! = []
    let rootRef = FIRDatabase.database().reference()    // reference to the firebase database

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Find user train alerts
        getUserTrainAlerts(completed :{
            () -> () in
                // Initialize data from realtime firebase database
                self.initializeFirebaseData()
                self.trainAlertTableView.delegate = self
                self.trainAlertTableView.dataSource = self
                self.trainAlertTableView.tableFooterView = UIView()
                let notificationName = Notification.Name("RefreshTrainAlertData")
                NotificationCenter.default.addObserver(self, selector: #selector(self.refreshTableView(notification:)), name: notificationName, object: nil)
                self.hideKeyboardWhenTappedAround()

        })
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
        print("Beginning to fill table view")
        let cell = tableView.dequeueReusableCell(withIdentifier: "trainAlertCell") as! TrainAlertTableViewCell
        print("Size of firebase data is \(firebaseData.count)")
        var alertInfo : [String : AnyObject] = trainAlertContent[indexPath.row]
        var trainCrossing : [String : AnyObject] = alertInfo["trainCrossing"] as! [String : AnyObject]
        var trainCrossingLocation : [String : AnyObject] = trainCrossing["location"] as! [String : AnyObject]
        let province : String = trainCrossingLocation ["province"] as! String
        let city : String = trainCrossingLocation ["city"] as! String
        let address : String = trainCrossingLocation["address"] as! String
        print("Index path row is : \(indexPath.row)")
        if(firebaseData.count > 0){
            let data : TrainCrossingData = firebaseData[indexPath.row]
            cell.notificationCount.text = String(data.getNotificationCount())
        }
        cell.locationTextField.text = city.appending(", ").appending(province)
        cell.addressTextField.text = address
        cell.tag = trainCrossing["id"] as! Int
        
        // TODO: Use this later to change the image icon
        let railway : String = trainCrossing["railway"] as! String
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
                self.trainAlertTableView.reloadData()
                print("Row removed")
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("I am touched")
        let cell = tableView.cellForRow(at: indexPath as IndexPath) as! TrainAlertTableViewCell
        viewTrainAlertSettings(cell: cell)
    }

    private func getUserTrainAlerts(completed : @escaping FinishedSettingData){
        let access_token :String? = userDefaults.string(forKey: "access_token")
        GetRequest().HTTPGet(getUrl: Constants.API.userTrainAlerts.appending("?page=0&size=50"), token: access_token!, completionHandler: { (dictionary) -> Void in
            OperationQueue.main.addOperation{
                
                self.trainAlertData = (dictionary.value(forKey: "page") as! NSDictionary?)!
                self.trainAlertContent = self.trainAlertData["content"] as! [[String:AnyObject]]
                self.trainAlertTableView.reloadData()
                print("Content size: \(self.trainAlertContent.count)")
                completed()
            }
        })
    }
    
    @objc private func refreshTableView(notification: NSNotification){
        print("Begin refreshing table data...")
        self.getUserTrainAlerts(completed: {() -> () in
            print("Finished refreshing")
        })
    }
    
    private func removeTrainAlert(trainCrossingId : Int) -> Bool{
        var removed : Bool = false
        let access_token : String = userDefaults.string(forKey: "access_token")!
        let url : String = Constants.API.removeTrainAlert.replacingOccurrences(of: "id", with: String(trainCrossingId))
        DeleteRequest().HTTPDelete(getUrl: url, token: access_token, completionHandler: {
            (dictionary) -> Void in  OperationQueue.main.addOperation{
                let dataResponse : [String : AnyObject] = dictionary["data"] as! [String : AnyObject]
                let FCMTopic : String? = dataResponse["notificationTopic"] as? String
                if(FCMTopic != nil){
                    print("Topic is: \(FCMTopic)")
                    FIRMessaging.messaging().unsubscribe(fromTopic: "/topics/".appending(FCMTopic!))
                    removed = true;
                }
            }
        })
        return removed
    }
    
    // View alert settings and pass through data
    private func viewTrainAlertSettings( cell : TrainAlertTableViewCell){
        let alertSettings = self.storyboard?.instantiateViewController(withIdentifier: "trainAlertSettings") as! TrainAlertSettingsViewController
        print("Location text field: \(cell.locationTextField.text!)")
        alertSettings.city = cell.locationTextField.text!
        alertSettings.address = cell.addressTextField.text!
        self.navigationController?.pushViewController(alertSettings, animated: true)
    }
    
    // Call to initialize data from firebase database, this will be used to keep track of
    // Active train crossings and notification counts
    private func initializeFirebaseData(){
        print("Beginning to initialize firebase data")
        for dictionary in trainAlertContent {
            var trainCrossing : [String : AnyObject] = dictionary["trainCrossing"] as! [String : AnyObject]
            let id : Int = trainCrossing["id"] as! Int
            print("Id is: \(id)")
            loadTrainCrossingData(trainCrossingId: id)
        }
    }
    
    // Load train crossing data from Firebase Database
    private func loadTrainCrossingData(trainCrossingId : Int){
        self.firebaseData.removeAll()
        let key : String = "traincrossing_".appending(String(trainCrossingId))
        let trainCrossingData = rootRef.child("traincrossing")
        let childNode = trainCrossingData.child(key)    // find a child node by the train crossing id
        let model = TrainCrossingData()
        childNode.observe(.value, with: { (snapshot) in
            print(snapshot)
            model.setIsActive(isActive: snapshot.childSnapshot(forPath: "is_active").value as! Bool)
            model.setNotificationCount(notificationCount: snapshot.childSnapshot(forPath: "notification_count").value as! Int)
            self.firebaseData.append(model)
            self.trainAlertTableView.reloadData()
        })

    }

}
