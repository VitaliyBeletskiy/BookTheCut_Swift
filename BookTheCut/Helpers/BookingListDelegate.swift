//
//  SimpleDelegate.swift
//  BookTheCut
//
//  Created by Vitaliy on 2020-10-26.
//

import Foundation

/// a simple delegate with only one method to perform some action in View Controller
protocol BookingListDelegate {
    
    func didChooseBooking(booking: Booking)
    
}
