//
//  HairdresserTableViewCell.swift
//  BookTheCut
//
//  Created by Vitaliy on 2020-10-21.
//

import UIKit

class HairdresserTableViewCell: UITableViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var hairdresserLabel: UILabel!    
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()

        hairdresserLabel.backgroundColor = UIColor.ourYellow
        hairdresserLabel.layer.cornerRadius = 12
        hairdresserLabel.layer.masksToBounds = true
        hairdresserLabel.layer.shadowColor = UIColor.black.cgColor
        hairdresserLabel.layer.shadowRadius = 4
        hairdresserLabel.layer.shadowOpacity = 0.5
        hairdresserLabel.layer.shadowOffset = CGSize(width: 0, height: 0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
