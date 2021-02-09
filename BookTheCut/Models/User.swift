//
//  User.swift
//  BookTheCut
//
//  Created by Vitaliy on 2020-10-19.
//

import Foundation

class User {
    var id: String
    var name: String
    var email: String
    var toSting: String {
        return "id = \(self.id), name = \(self.name), email = \(self.email)"
    }
    var hasAllFields: Bool {
        let anyIsEmpty = self.id.isEmpty  || self.name.isEmpty  || self.email.isEmpty
        return !anyIsEmpty
    }
    
    init(id: String, name: String, email: String) {
        self.id = id
        self.name = name
        self.email = email
    }
    
    convenience init() {
        self.init(id: "", name: "", email: "")
    }

}
