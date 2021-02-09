//
//  Salon.swift
//  MapProcedure
//
//  Created by Vitaliy on 2020-10-16.
//

import Foundation

class Salon {
    var id: String?
    var name: String?
    var address: String?
    var latitude: Double?
    var longitude: Double?
    var toString: String {
        return "id = \(self.id ?? ""), name = \(self.name ?? ""), address = \(self.address ?? ""), latitude = \(self.latitude ?? 0.0), longitude = \(self.longitude ?? 0.0)"
    }
    
    init(id: String, name: String, address: String, latitude: Double, longitude: Double) {
        self.id = id
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
    }
    
    init(id: String, snapshotData: NSDictionary) {
        self.id = id
        self.name = snapshotData["name"] as? String ?? ""
        self.address = snapshotData["address"] as? String ?? ""
        self.latitude = snapshotData["latitude"] as? Double ?? 0.0
        self.longitude = snapshotData["longitude"] as? Double ?? 0.0
    }
}
