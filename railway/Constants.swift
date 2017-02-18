//
//  Constants.swift
//  railway
//
//  Created by Dayna Naismyth on 2017-02-12.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import Foundation

struct Constants {
    
    // API Related constants
    struct API {
        static let baseUrl = "http://localhost:8080"
        static let login = "/oauth/token"
        static let allTrainCrossings = "/api/traincrossings"
        static let userTrainAlerts = "/api/trainalerts"
    }
    
    struct TOKEN {
        static let basic_token = "Basic cmFpbHdheXNlcnZpY2UtaW9zOmtKRktDdDJFenNXM2oyYTQ=";
    }
}
