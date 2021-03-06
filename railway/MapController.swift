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
    var trainCrossingData : NSMutableDictionary = [:]     // data from api call to retrieve all user train crossings
    var trainCrossingContent : [[String:AnyObject]] = []  // this will store the content of each train crossing
    var mapAnnotations:[Int : CustomPointAnnotation] = [:] // map pin annotiations for train crossing locations
    var firebaseData: [Int :TrainCrossingData]! = [:]   // store firebase data
    let rootRef = FIRDatabase.database().reference()    // reference to the firebase database
    var location : CLLocation?
    let defaultAudioId : Int = 1
    var circle : MKCircle = MKCircle()
    var radiusValue : Double = 5000.00
    let mileConversion : Double = 0.000621371 // (meters in one mile)
    var radiusIsShowing = false
    var sliderRect : CGRect = CGRect()
    
    @IBOutlet weak var radiusSlider: UISlider!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var inputLocationView: UIView!
    @IBOutlet weak var radiusButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.radiusSlider.setValue(Float(1), animated:true)
        radiusSlider.isHidden = true
        radiusSlider.layer.cornerRadius = 5.0
        self.sliderRect = radiusSlider.frame
        self.radiusSlider.transform = CGAffineTransform(scaleX: 0, y: 1);
        radiusButton.layer.cornerRadius = radiusButton.frame.width/2
        radiusButton.backgroundColor = UIColor.white
        //radiusButton.setBackgroundImage(UIImage(named: "distance"), for: .normal)
        let buttonImage : UIImageView = UIImageView(frame: CGRect(x:0, y:0 ,width: 32, height: 32))
        buttonImage.image = UIImage(named: "distance")?.withRenderingMode(.alwaysTemplate)
        buttonImage.tintColor = Constants.COLOR.midnight
        radiusButton.addSubview(buttonImage)
        buttonImage.center = CGPoint(x: radiusButton.bounds.midX, y: radiusButton.bounds.midY)
        radiusButton.alpha = 0.82
        self.hideRadiusSliderWhenTappedAround()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let notificationName = Notification.Name("RemoveMapData")
        NotificationCenter.default.addObserver(self, selector: #selector(self.removeMapData), name: notificationName, object: nil)
        //mapView.removeAnnotations(mapAnnotations)
        radiusSlider.isContinuous = false
        self.mapView.delegate = self
        self.mapView.isRotateEnabled = false
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        //self.setupAnnotationData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
    
    func addRadiusCircle(location: CLLocation, radius: Double){
        self.mapView.delegate = self
        circle = MKCircle(center: location.coordinate, radius:radius as CLLocationDistance)
        self.mapView.add(circle)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let circleRenderer = MKCircleRenderer(circle: overlay as! MKCircle)
        circleRenderer.strokeColor = UIColor.red
        circleRenderer.fillColor = UIColor(red: 255, green: 0, blue: 0, alpha: 0.1)
        circleRenderer.lineWidth = 1
        return circleRenderer
    }
    
    private func showAlert(alertTitle: String, alertMessage: String){
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc private func removeTrainCrossingAlert(_ sender: AnyObject?) -> Bool{
        let access_token : String = userDefaults.string(forKey: "access_token")!
        let trainCrossingId : Int = sender!.tag
        let formatUrl : String = Constants.API.removeTrainAlert.replacingOccurrences(of: "id", with: String(trainCrossingId))
        var removed : Bool = false
        DeleteRequest().HTTPDelete(getUrl: formatUrl, token: access_token, completionHandler: {
            (dictionary) -> Void in  OperationQueue.main.addOperation{
                let dataResponse : [String : AnyObject] = dictionary["data"] as! [String : AnyObject]
                if(dictionary["operationType"] as! String == "DELETE"){
                    let FCMTopic : String? = dataResponse["notificationTopic"] as? String
                    if(FCMTopic != nil){
                        print("Topic is: \(FCMTopic)")
                        FIRMessaging.messaging().unsubscribe(fromTopic: "/topics/".appending(FCMTopic!))
                        removed = true;
                        for view in (sender?.subviews)!{
                            view.removeFromSuperview()
                        }
                        self.buildAddTrainAlertButton(button: sender as! UIButton)
                        self.showAlert(alertTitle: "Train Alert Removed", alertMessage: "You will no longer receive notification activity from this train crossing.")
                    }
                }
            }
        })
        return removed
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
                for view in (sender?.subviews)!{
                    view.removeFromSuperview()
                }
                self.buildRemoveButton(button: sender as! UIButton)
                self.showAlert(alertTitle: "Train Alerted Added!", alertMessage: "You will now be eligible to report and recieve notification activity from this train crossing location.")
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
            if(!radiusIsShowing){
                addRadiusCircle(location: CLLocation(latitude: myLocation.latitude, longitude: myLocation.longitude), radius: radiusValue)
                self.radiusIsShowing = true
            }
            locationManager.stopUpdatingLocation()
            getAllTrainCrossingsNearby(latitude: latitude!, longitude: longitude!, radius : (radiusValue * mileConversion))
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
        let icon : UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 34, height: 34))
        if(cpa.imageName == "clearTrainCrossing"){
            icon.image = UIImage(named:cpa.imageName)//?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            //icon.tintColor = Constants.COLOR.defaultGreen
        } else {
            icon.image = UIImage(named:"hazardPin")//?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            //icon.tintColor = Constants.COLOR.hazardRed
        }
        icon.layer.zPosition = 1
        anView?.leftCalloutAccessoryView = formatLeftCalloutAccessory(railway: cpa.railwayImageName)
        anView?.rightCalloutAccessoryView = cpa.annotationButton
    
        for view in (anView?.subviews)! {
            view.removeFromSuperview()
        }
        anView?.addSubview(cpa.notificationCount)
        anView?.addSubview(icon)
        anView?.frame = CGRect(x: 0, y:0, width:32, height:32)
        anView?.canShowCallout = true
        return anView
    }
    
    private func formatLeftCalloutAccessory(railway: String) -> UILabel {
        let label = UILabel(frame: CGRect(x: 0, y:0, width: 40, height:40))
        label.textColor = UIColor.white
        label.text = railway
        label.backgroundColor = chooseBackgroundColor(railway: railway)
        label.clipsToBounds = true
        label.layer.cornerRadius = label.bounds.width/4
        label.font =  UIFont(name: Constants.FONT.navBarFont, size: 20) ?? UIFont.systemFont(ofSize: 20)
        label.textAlignment = NSTextAlignment.center
        return label
    }
    
    private func chooseBackgroundColor(railway : String) -> UIColor {
        var color : UIColor = Constants.COLOR.hazardRed
        switch(railway){
            
        case "VIA":
            color = Constants.COLOR.cautionYellow
        case "GO" :
            color = Constants.COLOR.defaultGreen
        case "AMT" :
            color = Constants.COLOR.lightBlue
        default :
            return Constants.COLOR.hazardRed
            
        }
        return color
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        let visibleRect = mapView.annotationVisibleRect
        
        for view:MKAnnotationView in views{
            let endFrame:CGRect = view.frame
            var startFrame:CGRect = endFrame
            startFrame.origin.y = visibleRect.origin.y - startFrame.size.height
            view.frame = startFrame;
            UIView.beginAnimations("drop", context: nil)
            UIView.setAnimationDuration(0.7)
            
            view.frame = endFrame;
            
            UIView.commitAnimations()
        }
    }
    
    //TODO: Change this to get nearby train crossings
    private func getAllTrainCrossingsNearby(latitude : Double, longitude : Double, radius : Double){
        print("calling get all nearby train crossings")
        let latitude : String = String(latitude)
        let longitude : String = String(longitude)
        let params : String = "?page=0&size=50&radius=".appending(String(radius)).appending("&lat=").appending(latitude).appending("&lon=").appending(longitude)   // radius = 3 miles
        let token : String? = userDefaults.string(forKey: "access_token")
        GetRequest().HTTPGet(getUrl: Constants.API.nearbyTrainCrossings.appending(params), token: token!, completionHandler : { (dictionary) -> Void in
            OperationQueue.main.addOperation{
                self.mapTrainCrossingCoordinates(trainCrossings: dictionary)
            }
        })
    }
    
    private func formatNotificationLabel(notifyLabel : UILabel){
        notifyLabel.frame = CGRect(x: -4, y: -7, width: 20, height: 20)
        notifyLabel.layer.zPosition = 0
        notifyLabel.backgroundColor = Constants.COLOR.midnight
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
            let isUserAlert : Bool = trainCrossing["markedForAlerts"] as! Bool
            let railwayName : String = trainCrossing["railway"] as! String
            annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            annotation.title = String(city).uppercased()
            annotation.subtitle = address
            annotation.imageName = "clearTrainCrossing"
            annotation.trainCrossingId = trainCrossing["id"] as! Int!
            annotation.railwayImageName = railwayName
            loadTrainCrossingData(trainCrossingId: annotation.trainCrossingId)
            annotation.annotationButton.tag = annotation.trainCrossingId
            self.setButtonDesign(isUserAlert: isUserAlert, annotation: annotation)
            self.mapAnnotations[annotation.trainCrossingId] = annotation
        }
        
        let pins = Array(mapAnnotations.values)
        self.mapView.addAnnotations(pins)   // add all of the annotations to the map
    }
    
    private func setButtonDesign(isUserAlert : Bool, annotation : CustomPointAnnotation){
        let button = annotation.annotationButton
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.layer.borderWidth = 1.3
        if(isUserAlert){
            buildRemoveButton(button: button)
        } else {
            buildAddTrainAlertButton(button: button)
        }
        
    }
    
    private func buildRemoveButton(button : UIButton){
        button.addTarget(self, action: #selector(self.removeTrainCrossingAlert(_:)), for: .touchUpInside)
        //button.layer.borderColor = UIColor(red:0.69, green:0.27, blue:0.27, alpha:1.0).cgColor
        button.backgroundColor = Constants.COLOR.hazardRed
        button.layer.masksToBounds = true
        button.layer.cornerRadius = button.frame.width/2
        self.buildRemoveIcon(button: button)
    }
    
    private func buildAddTrainAlertButton(button : UIButton){
        button.backgroundColor = Constants.COLOR.defaultGreen
        //button.layer.borderColor = UIColor(red:0.24, green:0.40, blue:0.13, alpha:1.0).cgColor
        button.addTarget(self, action: #selector(self.addTrainCrossingAlert(_:)), for: .touchUpInside)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = button.frame.width/2
        self.buildAddIcon(button: button)
    }
    
    private func buildAddIcon(button: UIButton){
        let imageView : UIImageView = UIImageView(image: UIImage(named:"addIcon")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate))
        imageView.frame = CGRect(x:0, y:0, width:30, height:30)
        imageView.tintColor = Constants.COLOR.greenComp
        imageView.addShadowView()
        button.addSubview(imageView)
        imageView.center = CGPoint(x: button.bounds.midX, y: button.bounds.midY)
    }
    
    private func buildRemoveIcon(button : UIButton) {
        let imageView : UIImageView = UIImageView(image: UIImage(named:"removeIcon")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate))
        imageView.frame = CGRect(x: 0, y:0, width: 30, height:30)
        imageView.tintColor = Constants.COLOR.redComp
        imageView.addShadowView()
        button.addSubview(imageView)
        imageView.center = CGPoint(x: button.bounds.midX, y: button.bounds.midY)
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
                    let isActive : Bool = snapshot.childSnapshot(forPath: "is_active").value as! Bool
                    self.mapView.removeAnnotation(self.mapAnnotations[trainCrossingId]!)
                    let annotation: CustomPointAnnotation = self.mapAnnotations[trainCrossingId]!
                    if(isActive){
                        annotation.imageName = "trainAlertPin"
                    }
                    annotation.notificationCount.text = String(notificationCount)
                    self.formatNotificationLabel(notifyLabel: annotation.notificationCount)
                    annotation.labelIsHidden = false
                    self.mapAnnotations[trainCrossingId] = annotation
                    self.mapView.addAnnotation(annotation)
                }
            }
        })
    }
    
    @IBAction func sliderInput(_ sender: UISlider) {
        if(mapView.annotations.count > 0){
            mapView.removeAnnotations(mapView.annotations)
        }
        self.mapView.removeOverlays(mapView.overlays)
        self.mapAnnotations.removeAll()
        self.trainCrossingContent.removeAll()
        self.trainCrossingData.removeAllObjects()
        radiusValue = (Double(sender.value))
        self.addRadiusCircle(location: location!, radius: radiusValue)
        locationManager.startUpdatingLocation()

    }
    
    @IBAction func toggleRadiusSlider(_ sender: UIButton) {
        print("Showing slider")
        radiusButton.isHidden = true
        radiusSlider.isHidden = false
        UIView.animate(withDuration: 0.4, animations: {
            self.radiusSlider.transform = CGAffineTransform(scaleX: 1, y: 1);
        }, completion: { (isFinished) in
            if(isFinished){
                UIView.animate(withDuration: 0.4, animations: {
                    self.radiusSlider.setValue(Float(self.radiusValue), animated:true)
                })
            }
        })
    }
    
    // Reset the view of the radius toggle button
    private func setDefaultToggleView(){
        if(radiusButton.isHidden){
            print("Setting default toggle view")
            
            UIView.animate(withDuration: 0.3, animations: {
                self.radiusSlider.setValue(Float(1), animated:true)
            }, completion: { (isFinished) in
                if(isFinished){
                    UIView.animate(withDuration:0.4, animations: {
                        self.radiusSlider.transform = CGAffineTransform(scaleX: 0.001, y: 1) // issue with unique scale factor of 0, set to 0.001 instead
                        self.radiusSlider.isHidden = true
                        self.radiusButton.isHidden = false
                    })
                }
            })
        }
    }
    
    func hideRadiusSliderWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MapController.dismissSlider))
        view.addGestureRecognizer(tap)
    }
    
    func dismissSlider() {
        setDefaultToggleView()
    }
    
    func removeMapData(notification: NSNotification){
        if(mapView.annotations.count > 0){
            mapView.removeAnnotations(mapView.annotations)
        }
        self.mapAnnotations.removeAll()
        self.trainCrossingContent.removeAll()
        self.trainCrossingData.removeAllObjects()
    }
    
}
