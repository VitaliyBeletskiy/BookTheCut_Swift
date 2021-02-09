//
//  TimeTableViewCell.swift
//  BookingProcedure
//
//  Created by Vitaliy on 2020-10-14.
//

import UIKit

class TimeTableViewCell: UITableViewCell {

    // MARK: - IBOutlets
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var bookButton: UIButton!

    // MARK: - Public Properties
    
    weak var delegate: TimeTableViewCellDelegate?
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //add
        bookButton.backgroundColor = #colorLiteral(red: 1, green: 0.8633085489, blue: 0, alpha: 1);
        bookButton.layer.cornerRadius = bookButton.frame.height / 2
        bookButton.setTitleColor(UIColor.black, for: .normal)
        
        bookButton.layer.shadowColor = UIColor.black.cgColor
        bookButton.layer.shadowRadius = 4
        bookButton.layer.shadowOpacity = 0.5
        bookButton.layer.shadowOffset = CGSize(width: 0, height: 0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: - IBActions

    @IBAction func bookTapped(_ sender: UIButton) {
        delegate?.didTapBookButton(stringTimeSlot: timeLabel.text ?? "")
    }
    
}
