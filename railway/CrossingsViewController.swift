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
    @IBOutlet weak var placeholderView: UIView!
    
    let userDefaults = Foundation.UserDefaults.standard
    var trainAlertData : NSDictionary = [:]     // data from api call to retrieve all user train alerts
    var trainAlertContent : [[String:AnyObject]] = []  // this will store the content of each train alert
    var firebaseData: [Int :TrainCrossingData]! = [:]
    let rootRef = FIRDatabase.database().reference()    // reference to the firebase database
    var nibView : UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let view : PlaceholderView = PlaceholderView()
        nibView = view.loadViewFromNib()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let notificationName = Notification.Name("RemoveMapData")   // remove map data
        NotificationCenter.default.post(name: notificationName, object: nil)
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
        cell.latitude = trainCrossingLocation["latitude"] as! Double
        cell.longitude = trainCrossingLocation["longitude"] as! Double
        cell.cityLabel.text = city.appending(", ").appending(province)
        cell.addressLabel.text = address
        cell.lastFlaggedActive = trainCrossing["lastFlaggedActive"] as! String
        let trainCrossingId : Int = trainCrossing["id"] as! Int
        cell.tag = trainCrossingId
        let data : TrainCrossingData? = firebaseData[trainCrossingId]
        if(data != nil){
            if(data!.getNotificationCount() > 0){
                cell.cautionIcon.layer.isHidden = false
                cell.cautionIcon.image = UIImage(named: "cautionIcon")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                cell.cautionIcon.tintColor = Constants.COLOR.cautionYellow
                cell.notificationCount.text = String(data!.getNotificationCount())
                cell.notificationCount.layer.isHidden = false   // show notification
            } else {
                print ("I have zero notifications")
                cell.notificationCount.layer.isHidden = true    // hide notification
                cell.cautionIcon.layer.isHidden = true
            }
        }
        // TODO: Use this later to change the image icon
        let railway : String = trainCrossing["railway"] as! String
        cell.railwayImage.image = UIImage(named: railway)
        //setRailwayCellImage(railway: railway, cell: cell)
        formatCellLabels(cell: cell)
        return cell
        
    }

    
    private func formatCellLabels(cell : TrainAlertTableViewCell){
        cell.addressLabel.numberOfLines = 1
        cell.addressLabel.adjustsFontSizeToFitWidth = true
        cell.addressLabel.minimumScaleFactor = 0.5
        cell.cityLabel.numberOfLines = 1
        cell.cityLabel.adjustsFontSizeToFitWidth = true
        cell.addressLabel.minimumScaleFactor = 0.5
    }
    
    
    // Customize the delete button for the table view cell
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteButton = UITableViewRowAction(style: .default, title: "\u{267A}\n Remove") { action, indexPath in
            self.tableView(tableView, commit: UITableViewCellEditingStyle.delete, forRowAt: indexPath)
        }
        deleteButton.backgroundColor = Constants.COLOR.hazardRed
        return [deleteButton]
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
        self.firebaseData.removeAll()
        let access_token :String? = userDefaults.string(forKey: "access_token")
        GetRequest().HTTPGet(getUrl: Constants.API.userTrainAlerts.appending("?page=0&size=50"), token: access_token!, completionHandler: { (dictionary) -> Void in
            OperationQueue.main.addOperation{
                
                self.trainAlertData = (dictionary.value(forKey: "page") as! NSDictionary?)!
                self.trainAlertContent = self.trainAlertData["content"] as! [[String:AnyObject]]
                self.trainAlertTableView.reloadData()
                print("Content size: \(self.trainAlertContent.count)")
                if(self.trainAlertContent.count <= 0){
                    self.trainAlertTableView.isHidden = true    // show placeholder view if there is no selected alerts
                    self.placeholderView.isHidden = false
                    self.placeholderView.addSubview(self.nibView!)
                    self.nibView!.center = CGPoint(x: self.placeholderView.bounds.midX, y: self.placeholderView.bounds.midY)
                } else {
                    self.placeholderView.isHidden = true
                    self.trainAlertTableView.isHidden = false
                }
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
        print("Location text field: \(cell.cityLabel.text!)")
        alertSettings.city = cell.cityLabel.text!
        alertSettings.address = cell.addressLabel.text!
        alertSettings.trainCrossingId = cell.tag
        alertSettings.latitude = cell.latitude
        alertSettings.longitude = cell.longitude
        alertSettings.lastFlaggedActive = cell.lastFlaggedActive    // set the time in which the train crossing was last flagged as active
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
        print("Loading train crossing data")
        let key : String = "traincrossing_".appending(String(trainCrossingId))
        let trainCrossingData = rootRef.child("traincrossing")
        let childNode = trainCrossingData.child(key)    // find a child node by the train crossing id
        let model = TrainCrossingData()
        childNode.observe(.value, with: { (snapshot) in
            print(snapshot)
            if(snapshot.hasChild("is_active") && snapshot.hasChild("notification_count")){
                model.setIsActive(isActive: snapshot.childSnapshot(forPath: "is_active").value as! Bool)
                model.setNotificationCount(notificationCount: snapshot.childSnapshot(forPath: "notification_count").value as! Int)
            }
            model.setTrainCrossingId(trainCrossingId: trainCrossingId)
            self.firebaseData[trainCrossingId] = model
            self.trainAlertTableView.reloadData()
        })

    }

}
