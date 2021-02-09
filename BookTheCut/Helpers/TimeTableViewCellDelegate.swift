//
//  TimeTableViewCellDelegate.swift
//  BookingProcedure
//
//  Created by Vitaliy on 2020-10-14.
//

import Foundation

protocol TimeTableViewCellDelegate: AnyObject {
    
    func didTapBookButton(stringTimeSlot: String)
    
}
