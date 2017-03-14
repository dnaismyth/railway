//
//  Constants.swift
//  railway
//
//  Created by Dayna Naismyth on 2017-02-12.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import Foundation
import UIKit

// Application Constants
struct Constants {
    
    // API Related constants
    struct API {
        //static let baseUrl = "http://10.0.9.100:8080" // starbucks
        static let baseUrl = "http://192.168.1.73:8080"
        //static let baseUrl = "http://localhost:8080"
        static let login = "/oauth/token"
        static let signup = "/api/signup"
        static let allTrainCrossings = "/api/traincrossings"
        static let userTrainAlerts = "/api/trainalerts"
        static let reportTrainCrossing = "/api/traincrossings/id/reports"
        static let removeTrainAlert = "/api/traincrossings/id/trainalerts"
        static let addTrainAlert = "/api/traincrossings/id/trainalerts"
        static let nearbyTrainCrossings = "/api/nearby/traincrossings"
        static let storeDeviceToken = "/api/users/resources/tokens"
        static let getFirebaseToken = "/api/users/resources/firebase"
        static let updateLanguageKey = "/api/users/langkey"
        static let updateEmailPrefs = "/api/users/emailupdates"
        static let updatePassword = "/api/users/password"
        static let logout = "/api/logout"
        static let requestPasswordReset = "/api/account/reset_password"
        
    }
    
    struct TOKEN {
        static let basic_token = "Basic cmFpbHdheXNlcnZpY2UtaW9zOmtKRktDdDJFenNXM2oyYTQ=";
    }
    
    struct PLATFORM {
        static let apple = "APNS"
    }
    
    struct FIREBASE {
        static let databaseUrl = "https://traincrossing-9cf80.firebaseio.com/"
    }
    
    struct FONT {
        static let navBarFont = "Helvetica"
    }
    
    struct COLOR {
        static let defaultColor : UIColor = UIColor(red:0.20, green:0.37, blue:0.95, alpha:1.0)
        static let compColor : UIColor = UIColor(red:0.14, green:0.54, blue:0.72, alpha:0.7)
        static let defaultGreen : UIColor = UIColor(red:0.00, green:0.60, blue:0.20, alpha:1.0)
        static let hazardRed : UIColor = UIColor(red:0.80, green:0.00, blue:0.00, alpha:1.0)
        static let redComp : UIColor = UIColor(red:0.40, green:0.00, blue:0.00, alpha:1.0)
        static let greenComp : UIColor = UIColor(red:0.00, green:0.40, blue:0.00, alpha:1.0)
        static let cautionYellow : UIColor = UIColor(red:1.00, green:0.80, blue:0.00, alpha:1.0)
        static let midnight : UIColor = UIColor(red:0.00, green:0.00, blue:0.50, alpha:1.0)
    }
}
