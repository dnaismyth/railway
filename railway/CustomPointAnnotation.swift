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
    var imageName: String!  // regular image name
    var activeImageName : String!   // annotation image for when the train crossing is active
    var trainCrossingId : Int!
    var notificationCount : UILabel = UILabel()
    var labelIsHidden : Bool = true
    var annotationButton : UIButton = UIButton() // button for map annotations
    var reportButton : UIButton = UIButton(type: UIButtonType.detailDisclosure) as UIButton // button to report train crossings
    var railwayImageName : String!
}
