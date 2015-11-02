//
//  CustomPointAnnotation.swift
//  MapKitDemo
//
//  Created by Oliver Poole on 02/11/2015.
//  Copyright © 2015 ASOPGM. All rights reserved.
//

import UIKit
import MapKit

class DirectionsPointAnnotation: NSObject, MKAnnotation {
    
    var title: String?
    var coordinate: CLLocationCoordinate2D
    var placemark: MKPlacemark
    
    init(title: String, coordinate: CLLocationCoordinate2D, placemark: MKPlacemark) {
        self.title = title
        self.coordinate = coordinate
        self.placemark = placemark
    }
}
