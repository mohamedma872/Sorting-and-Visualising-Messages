//
//  MessageModel.swift
//  test
//
//  Created by Bassuni on 10/23/18.
//  Copyright © 2018 user147796. All rights reserved.
//

import Foundation
import MapKit

class MessageModel :NSObject , MKAnnotation
{
    var messageid : Int?
    var message: String?
    var sentiment : String?
    var PlaceName: String?
    
     var Lat: CLLocationDegrees = 0
     var lon: CLLocationDegrees = 0
    
    // This property must be key-value observable, which the `@objc dynamic` attributes provide.
    @objc dynamic var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: Lat, longitude: lon)
        }
        set {
            // For most uses, `coordinate` can be a standard property declaration without the customized getter and setter shown here.
            // The custom getter and setter are needed in this case because of how it loads data from the `Decodable` protocol.
            Lat = newValue.latitude
            lon = newValue.longitude
        }
    }
}
