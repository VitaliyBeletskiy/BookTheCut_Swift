//
//  SalonMarkerView.swift
//  MapProcedure
//
//  Created by Vitaliy on 2020-10-17.
//

import UIKit
import MapKit

// can do the same in MKMapViewDelegate in method mapView(_:viewFor:)
class SalonMarkerView: MKAnnotationView {
    
    override var annotation: MKAnnotation? {
        willSet {
            // run a check in order not to affect other annotations
            guard let salonOnMap = newValue as? SalonOnMap else {
                return
            }
            canShowCallout = true
            // add
            let bookButton = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 50, height: 40)))
            // add
            bookButton.layer.cornerRadius = 7
            bookButton.layer.shadowColor = UIColor.darkGray.cgColor
            bookButton.layer.shadowRadius = 4
            bookButton.layer.shadowOpacity = 0.5
            bookButton.layer.shadowOffset = CGSize(width: 0, height: 0)
            // add
            bookButton.backgroundColor = .darkGray
            bookButton.setTitle("Book", for: .normal)
            rightCalloutAccessoryView = bookButton
            
            image = salonOnMap.image
        }
    }
    
}
