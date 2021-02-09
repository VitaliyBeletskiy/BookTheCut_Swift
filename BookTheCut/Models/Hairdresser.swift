//
//  Hairdresser.swift
//  BookTheCut
//
//  Created by Vitaliy on 2020-10-19.
//

import Foundation

class Hairdresser {
    var id: String?
    var salonId: String?
    var name: String?
    var toString: String {
        return "id = \(self.id ?? ""), salonId = \(self.salonId ?? ""), name = \(self.name ?? "")"
    }

    init(id: String, salonId: String, name: String) {
        self.id = id
        self.salonId = salonId
        self.name = name
    }
    
    init(id: String, snapshotData: NSDictionary) {
        self.id = id
        self.name = snapshotData["name"] as? String ?? ""
        self.salonId = snapshotData["salonId"] as? String ?? ""
    }
}
