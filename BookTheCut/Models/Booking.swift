//
//  Booking.swift
//  BookingProcedure
//
//  Created by Vitaliy on 2020-10-14.
//  

import Foundation

class Booking {
    var id: String
    var userId: String
    var hairdresserId: String
    var dateTime: String
    var toString: String {
        return "id = \(self.id), userId = \(self.userId), hairdresserId = \(self.hairdresserId), dateTime = \(self.dateTime)"
    }
    
    init(id: String, userId: String, hairdresserId: String, dateTime: String) {
        self.id = id
        self.userId = userId
        self.hairdresserId = hairdresserId
        self.dateTime = dateTime
    }
    
    convenience init(userId: String, hairdresserId: String, dateTime: String) {
        self.init(id: "", userId: userId, hairdresserId: hairdresserId, dateTime: dateTime)
    }
    
    convenience init() {
        self.init(id: "", userId: "", hairdresserId: "", dateTime: "")
    }
    
}
