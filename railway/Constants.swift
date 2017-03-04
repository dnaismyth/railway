//
//  Constants.swift
//  railway
//
//  Created by Dayna Naismyth on 2017-02-12.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import Foundation

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
        static let removeTrainAlert = "/api/traincrossings/id/trainalerts"
        static let addTrainAlert = "/api/traincrossings/id/trainalerts"
        static let nearbyTrainCrossings = "/api/nearby/traincrossings"
        static let storeDeviceToken = "/api/users/resources/tokens"
        static let getFirebaseToken = "/api/users/resources/firebase"
        
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
}
