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

class MapController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    //MARK: Properties
    let userDefaults = Foundation.UserDefaults.standard
    let locationManager = CLLocationManager()
    let enableLocation = false;
    var trainCrossingData : NSDictionary = [:]     // data from api call to retrieve all user train crossings
    var trainCrossingContent : [[String:AnyObject]] = []  // this will store the content of each train crossing
    var mapAnnotations:[MKPointAnnotation] = [] // map pin annotiations for train crossing locations
    var location : CLLocation?
    let defaultAudioId : Int = 1
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var inputLocationView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("View is loaded")
        self.mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
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
                let notificationName = Notification.Name("RefreshTrainAlertData")
                NotificationCenter.default.post(name: notificationName, object: nil)
            }
        })
    }
    
    // Called every time user's location is updated
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last!
        
        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
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
                //InputLocationView().setupView()
                buildLocationFromUserInput()
                print("No access")
            case .authorizedAlways, .authorizedWhenInUse:
                //InputLocationView().setupView()
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
    
    // Custom annotation view
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if !(annotation is CustomPointAnnotation) {
            return nil
        }
        
        let reuseId = "trainPin"
        
        var anView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            anView?.canShowCallout = true
        }
        else {
            anView?.annotation = annotation
        }
        
        let cpa = annotation as! CustomPointAnnotation
        anView?.image = UIImage(named:cpa.imageName)
        cpa.annotationButton.addTarget(self, action: #selector(self.addTrainCrossingAlert(_:)), for: .touchUpInside)
        anView?.rightCalloutAccessoryView = cpa.annotationButton
        
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
            annotation.imageName = "trainIcon"
            annotation.trainCrossingId = trainCrossing["id"] as! Int!
            annotation.annotationButton.tag = trainCrossing["id"] as! Int!
            self.mapAnnotations.append(annotation)
            
        }
        self.mapView.addAnnotations(self.mapAnnotations)

    }
    
}
