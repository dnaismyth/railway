//
//  TrainAlertSettingsViewController.swift
//  railway
//
//  Created by Dayna Naismyth on 2017-02-21.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase

class TrainAlertSettingsViewController: UIViewController, MKMapViewDelegate {
    
    let userDefaults = Foundation.UserDefaults.standard
    
    var city : String = ""
    var address : String = ""
    var trainCrossingId : Int = -1
    var latitude : Double = Double()
    var longitude : Double = Double()
    var lastFlaggedActive : String = String()
    var annotation = CustomPointAnnotation()
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var lastActiveLabel: UILabel!
    @IBOutlet weak var trainMap: MKMapView!
    
    let rootRef = FIRDatabase.database().reference()    // reference to the firebase database

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.trainMap.delegate = self
        self.trainMap.isRotateEnabled = false
        self.trainMap.showsUserLocation = false
        // Initialize labels with string passed through
        cityLabel.text = city
        addressLabel.text = address
        lastActiveLabel.numberOfLines = 1
        lastActiveLabel.adjustsFontSizeToFitWidth = true
        lastActiveLabel.minimumScaleFactor = 0.5
        if((String(lastFlaggedActive)?.characters.count)! > 0){
            lastActiveLabel.text = "Last active alert on ".appending(lastFlaggedActive)
        } else {
            lastActiveLabel.isHidden = true
        }
        print(trainCrossingId)
        self.setupAnnotation()
    }
    
    private func setupAnnotation(){
        let coordinate : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.008, 0.008)
        annotation.coordinate = coordinate
        annotation.imageName = "clearTrainCrossing"
        let region:MKCoordinateRegion = MKCoordinateRegionMake(coordinate, span)
        trainMap.setRegion(region, animated: true)
        self.trainMap.showAnnotations(trainMap.annotations, animated: true)
        self.trainMap.addAnnotation(annotation)
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
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is CustomPointAnnotation) {
            return nil
        }
        
        let reuseId = "pin"
        
        var anView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        }
        else {
            anView?.annotation = annotation
        }
        
        let cpa = annotation as! CustomPointAnnotation
        let icon : UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 38, height: 38))
        icon.image = UIImage(named:cpa.imageName)?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        icon.tintColor = Constants.COLOR.defaultGreen
        icon.layer.zPosition = 1
        
        for view in (anView?.subviews)! {
            view.removeFromSuperview()
        }
        anView?.addSubview(icon)
        anView?.frame = CGRect(x: 0, y:0, width:32, height:32)
        anView?.canShowCallout = false
        return anView
    }
    
    @IBAction func sendAlertButton(_ sender: UIButton) {
        if(trainCrossingId >= 0){
            sendTrainCrossingAlert(trainCrossingId: trainCrossingId)
        } else {
            print("Error sending train alert")
        }
    }
    
    // Send a train crossing report
    private func sendTrainCrossingAlert(trainCrossingId : Int){
        let access_token = userDefaults.string(forKey:"access_token")
        let params : [String : AnyObject] = [:]
        let url : String = Constants.API.reportTrainCrossing.replacingOccurrences(of: "id", with: String(trainCrossingId))
        PostRequest().jsonPost(postUrl: url, token: access_token!, body: params) { (dictionary) in
            if(dictionary["operationType"] != nil){
                let operationType : String = dictionary["operationType"] as! String
                if(operationType == "CREATE"){
                    self.showAlert(alertTitle: "Report Sent!", alertMessage: "Thank you for your report.  Other users watching this train crossing will receive your notification.")
                    self.updateFirebaseNotificationCount(trainCrossingId: trainCrossingId)   // increment notification count
                } else if (operationType == "NO_CHANGE"){
                    self.showAlert(alertTitle: "Error", alertMessage: "Oops!  It appears that you have sent too many reports at this time.  Please try again later.")
                }

            } else {
                self.showAlert(alertTitle: "Error", alertMessage: "An error occurred while trying to send this report.  Please try again later.")
            }
        }
    }
    
    private func showAlert(alertTitle: String, alertMessage: String){
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func updateFirebaseNotificationCount(trainCrossingId : Int){
        let key = "traincrossing_".appending(String(trainCrossingId))
        let trainCrossingData = rootRef.child("traincrossing")
        let childNode = trainCrossingData.child(key)    // find a child node by the train crossing id
        childNode.observeSingleEvent(of: .value, with: { snapshot in
            if(snapshot.hasChild("notification_count")){
                var notificationCount : Int = snapshot.childSnapshot(forPath: "notification_count").value as! Int
                notificationCount += 1
                childNode.child("notification_count").setValue(notificationCount)
            } else {
                let newNotification = 1
                childNode.child("notification_count").setValue(newNotification)
            }
        })
        
    }
}
