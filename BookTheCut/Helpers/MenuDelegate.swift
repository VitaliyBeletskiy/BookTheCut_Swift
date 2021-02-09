//
//  MenuDelegate.swift
//  BookTheCut
//
//  Created by Vitaliy on 2020-10-23.
//

import Foundation

protocol MenuDelegate {
    
    func shadeScreen()
    
    func unshadeScreen()

    func buttonTapped(action: String)
}
