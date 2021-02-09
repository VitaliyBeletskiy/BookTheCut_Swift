//
//  BookingTableViewCell.swift
//  BookTheCut
//
//  Created by Vitaliy on 2020-10-25.
//

import UIKit

class BookingTableViewCell: UITableViewCell {

    static func nib() -> UINib {
        return UINib(nibName: "BookingTableViewCell", bundle: nil)
    }
    
    // MARK: - IBOutlets

    @IBOutlet weak var timeLabel: UILabel!
    
    // MARK: - Properties
    
    var delegate: BookingListDelegate?
    var booking: Booking?
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: - IBActions
    
    @IBAction func manageTapped(_ sender: UIButton) {
        delegate?.didChooseBooking(booking: booking!)
    }

}
