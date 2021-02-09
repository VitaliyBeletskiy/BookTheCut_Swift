//
//  SalonOnMap.swift
//  MapProcedure
//
//  Created by Vitaliy on 2020-10-16.
//

import UIKit
import MapKit

class SalonOnMap: NSObject, MKAnnotation {
    let id: String?
    let title: String?                            // MKAnnotation
    let locationName: String?
    let coordinate: CLLocationCoordinate2D        // MKAnnotation
    var subtitle: String? { return locationName } // MKAnnotation
    var image: UIImage { return #imageLiteral(resourceName: "pin") }
    
    init(id: String?, title: String?, locationName: String?, coordinate: CLLocationCoordinate2D) {
        self.id = id
        self.title = title
        self.locationName = locationName
        self.coordinate = coordinate
        
        super.init()
    }
}
