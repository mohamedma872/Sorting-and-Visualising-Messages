//
//  MessageModel.swift
//  test
//
//  Created by Bassuni on 10/23/18.
//  Copyright © 2018 user147796. All rights reserved.
//

import Foundation
import MapKit

class MessageModel : MKPointAnnotation
{
    var messageid : Int?
    var message: String?
    var sentiment : String?
    var PlaceName: String?
    var customimage : String?
   
    
    // This property must be key-value observable, which the `@objc dynamic` attributes provide.
 
}
