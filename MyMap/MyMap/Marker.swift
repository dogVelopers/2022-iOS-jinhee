//
//  Marker.swift
//  MyMap
//
//  Created by Jinhee on 2022/07/16.
//

import UIKit
import MapKit
import Foundation

class Mark: NSObject, MKAnnotation {
    let title: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
    
    init(title: String?, subtitle: String?, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        
        super.init()
    }
}

