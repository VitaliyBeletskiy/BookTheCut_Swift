//
//  Constants.swift
//  BookTheCut
//
//  Created by Vitaliy on 2020-10-19.
//

import Foundation

struct Constants {
    
    // to prevent accidental initialization
    private init() {}
    
    // FirebaseDataBase string literals
    static let fbDbTableUsers = "Users"
    static let fbDbTableSalons = "Salons"
    static let fbDbTableHairdressers = "Hairdressers"
    static let fbDbTableBookings = "Bookings"
    
    // Auth.Storyboard string literals
    static let authStoryboard = "Auth"
    static let authNavController = "AuthNavController"
    static let authVC = "AuthVC"
    static let createAccountVC = "CreateAccountVC"
    static let unwindFromAuthStoryboard = "UnwindFromAuthStoryboard"
    
    // Main.Stroyboard string literals
    static let segueToMapVC = "GoToMapVC"
    static let segueToHairdresserVC = "GoToHairdresserVC"
    static let segueToCalendarVC = "GoToCalendarVC"
    static let segueToConfirmBookingVC = "GoToConfirmBookingVC"
    static let segueToBookingConfirmedVC = "GoToBookingConfirmedVC"
    static let segueToAccountVC = "GoToAccountVC"
    static let segueToBookingListVC = "GoToBookingListVC"
    static let segueToManageBookingVC = "GoToManageBookingVC"
    
    static let cellForHairdresser = "HairdresserCell"
    static let cellForTimeSlot = "TimeSlotCell"
    static let cellForBooking = "BookingCell"
    
    static let menuActionBookings = "bookings"
    static let menuActionAccount = "account"
    static let menuActionLogout = "logout"
    static let menuActionLogin = "login"
    
    static let cancelBookingTitle = "Cancel Booking?"
    static let cancelBookingMessage = "This booking will be cancelled."
    
    static let notLoggedInTitle = "You are not logged in."
    static let notLoggedInMessage = "You need to log in to confirm your booking."
    
    static let deleteAccountTitle = "Warning! Deleting account!"
    static let deleteAccountMessage = "By deleting account, your bookings and credentials will be deleted PERMANENTLY. This operation CANNOT be undone!"
    
    // Error messages
    static let generalFirebaseError = "An error happened while connecting to the server. Check your network connection or try again later."
}
