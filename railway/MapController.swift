//
//  MapController.swift
//  railway
//
//  Created by Dayna Naismyth on 2017-01-28.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseMessaging
import Firebase

class MapController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    //MARK: Properties
    let userDefaults = Foundation.UserDefaults.standard
    let locationManager = CLLocationManager()
    let enableLocation = false;
    var trainCrossingData : NSDictionary = [:]     // data from api call to retrieve all user train crossings
    var trainCrossingContent : [[String:AnyObject]] = []  // this will store the content of each train crossing
    var mapAnnotations:[Int : CustomPointAnnotation] = [:] // map pin annotiations for train crossing locations
    var firebaseData: [Int :TrainCrossingData]! = [:]   // store firebase data
    let rootRef = FIRDatabase.database().reference()    // reference to the firebase database
    var location : CLLocation?
    let defaultAudioId : Int = 1
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var inputLocationView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("View is loaded")
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //mapView.removeAnnotations(mapAnnotations)
        self.mapView.delegate = self
        self.mapView.isRotateEnabled = false
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        //self.setupAnnotationData()
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
    
    @objc private func addTrainCrossingAlert(_ sender: AnyObject?){
        let access_token : String = userDefaults.string(forKey: "access_token")!
        let trainCrossingId : Int = sender!.tag
        let formatUrl : String = Constants.API.addTrainAlert.replacingOccurrences(of: "id", with: String(trainCrossingId))
        let data : [String:AnyObject] = [
            "id" : self.defaultAudioId as AnyObject
        ]
        PostRequest().jsonPost(postUrl: formatUrl, token: access_token, body: data, completionHandler: {
            (dictionary) -> Void in OperationQueue.main.addOperation{
                print(dictionary)
                let dataResponse : [String : AnyObject] = dictionary["data"] as! [String : AnyObject]
                let FCMTopic : String = dataResponse["notificationTopic"] as! String
                let notificationName = Notification.Name("RefreshTrainAlertData")   // refresh table view
                FIRMessaging.messaging().subscribe(toTopic: "/topics/".appending(FCMTopic))
                NotificationCenter.default.post(name: notificationName, object: nil)
            }
        })
    }
    
    // Called every time user's location is updated
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last!
        
        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.1, 0.1)
        let latitude: Double? = location!.coordinate.latitude
        let longitude : Double? = location!.coordinate.longitude
        let myLocation : CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude!, longitude!)
        print("My Location is: \(myLocation)")
        let region:MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        
        mapView.setRegion(region, animated: true)
        self.mapView.showsUserLocation = true
        if((latitude != nil) && (longitude != nil)){
            locationManager.stopUpdatingLocation()
            getAllTrainCrossingsNearby(latitude: latitude!, longitude: longitude!)
        }

    }
    
    // Check the current location enabled status, if there is no access - prompt user with display to input
    // their current address or address of interest
    private func getLocationEnabledStatus(){
        let isEnabled = CLLocationManager.locationServicesEnabled()
        if isEnabled || !isEnabled {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                buildLocationFromUserInput()
                print("No access")
            case .authorizedAlways, .authorizedWhenInUse:
                buildLocationFromUserInput()
                print("Access")
            }
        } else {
            print("Location services are not enabled")
        }
    }
    
    private func buildLocationFromUserInput(){
        print(InputLocationView().getCityInput())
        print(InputLocationView().getAddressInput())
    }
    
    // Return the current window height
    private func windowHeight() -> CGFloat {
        return UIScreen.main.bounds.size.height
    }
    
    // Return the current window width
    private func windowWidth() -> CGFloat {
        return UIScreen.main.bounds.size.width
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        //let screenSize: CGRect = UIScreen.main.bounds
    }
    
    // Custom annotation view
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if !(annotation is CustomPointAnnotation) {
            return nil
        }
        
        let reuseId = "trainPin"
        
        var anView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        }
        else {
            anView?.annotation = annotation
        }
        
        let cpa = annotation as! CustomPointAnnotation
        let icon : UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
        icon.image = UIImage(named:cpa.imageName)
        icon.layer.zPosition = 1
        cpa.annotationButton.addTarget(self, action: #selector(self.addTrainCrossingAlert(_:)), for: .touchUpInside)
        anView?.rightCalloutAccessoryView = cpa.annotationButton
        anView?.rightCalloutAccessoryView = cpa.reportButton
        anView?.addSubview(cpa.notificationCount)
        anView?.addSubview(icon)
        anView?.frame = CGRect(x: 0, y:0, width:32, height:32)
        anView?.canShowCallout = true
        return anView
    }
    
    //TODO: Change this to get nearby train crossings
    private func getAllTrainCrossingsNearby(latitude : Double, longitude : Double){
        print("calling get all nearby train crossings")
        let latitude : String = String(latitude)
        let longitude : String = String(longitude)
        let params : String = "?page=0&size=50&radius=3&lat=".appending(latitude).appending("&lon=").appending(longitude)
        let token : String? = userDefaults.string(forKey: "access_token")
        GetRequest().HTTPGet(getUrl: Constants.API.nearbyTrainCrossings.appending(params), token: token!, completionHandler : { (dictionary) -> Void in
            OperationQueue.main.addOperation{
                self.mapTrainCrossingCoordinates(trainCrossings: dictionary)
            }
        })
    }
    
    private func formatNotificationLabel(notifyLabel : UILabel){
        notifyLabel.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        notifyLabel.layer.zPosition = 0
        notifyLabel.backgroundColor = UIColor(red:0.32, green:0.49, blue:0.69, alpha:1.0)
        notifyLabel.textColor = UIColor.white
        //notifyLabel.tag = 30
        notifyLabel.textAlignment = NSTextAlignment.center
        notifyLabel.font =  UIFont(name: Constants.FONT.navBarFont, size: 16) ?? UIFont.systemFont(ofSize: 16)
        notifyLabel.layer.cornerRadius = notifyLabel.bounds.width/2
        notifyLabel.clipsToBounds = true
        notifyLabel.isHidden = false
        notifyLabel.layer.zPosition = 2
    }
    
    private func mapTrainCrossingCoordinates(trainCrossings : NSDictionary){
        self.trainCrossingContent = trainCrossings["data"] as! [[String:AnyObject]]
        for trainCrossing in self.trainCrossingContent {
            let annotation = CustomPointAnnotation()
            var location : [String : AnyObject] = trainCrossing["location"] as! [String:AnyObject]
            let latitude : Double = location["latitude"] as! Double
            let longitude : Double = location["longitude"] as! Double
            let city : String = location["city"] as! String
            let address : String = location["address"] as! String
            
            annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            annotation.title = city
            annotation.subtitle = address
            annotation.imageName = "mapPin"
            annotation.trainCrossingId = trainCrossing["id"] as! Int!
            loadTrainCrossingData(trainCrossingId: annotation.trainCrossingId)
            annotation.annotationButton.tag = annotation.trainCrossingId
            self.mapAnnotations[annotation.trainCrossingId] = annotation
        }
        
        let pins = Array(mapAnnotations.values)
        self.mapView.addAnnotations(pins)   // add all of the annotations to the map
    }
    
    // Load train crossing data from Firebase Database
    private func loadTrainCrossingData(trainCrossingId : Int){
        let key : String = "traincrossing_".appending(String(trainCrossingId))
        let trainCrossingData = rootRef.child("traincrossing")
        let childNode = trainCrossingData.child(key)    // find a child node by the train crossing id
        childNode.observe(.value, with: { (snapshot) in
            print(snapshot)
            if(snapshot.hasChild("is_active") && snapshot.hasChild("notification_count")){
                let notificationCount : Int = snapshot.childSnapshot(forPath: "notification_count").value as! Int
                if(notificationCount > 0){
                    self.mapView.removeAnnotation(self.mapAnnotations[trainCrossingId]!)
                    let annotation: CustomPointAnnotation = self.mapAnnotations[trainCrossingId]!
                    annotation.notificationCount.text = String(notificationCount)
                    self.formatNotificationLabel(notifyLabel: annotation.notificationCount)
                    annotation.labelIsHidden = false
                    self.mapAnnotations[trainCrossingId] = annotation
                    self.mapView.addAnnotation(annotation)
                }
            }
        })
    }
}
