//
//  CustomPointAnnotation.swift
//  railway
//
//  Created by Dayna Naismyth on 2017-02-19.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit
import MapKit

class CustomPointAnnotation: MKPointAnnotation {
    var imageName: String!
    var trainCrossingId : Int!
    var annotationButton : UIButton = UIButton(type : UIButtonType.contactAdd) as UIButton // button for map annotations
}
