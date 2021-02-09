//
//  BookingConfirmedViewController.swift
//  BookTheCut
//
//  Created by Vitaliy on 2020-10-19.
//

import UIKit

class BookingConfirmedViewController: UIViewController {

    // MARK: - IBOutlets
    
    @IBOutlet weak var confirmedLabel: UILabel!
    @IBOutlet weak var okButton: UIButton!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        okButton.backgroundColor = UIColor.ourYellow
        okButton.layer.cornerRadius = okButton.frame.height / 2
        okButton.setTitleColor(UIColor.black, for: .normal)
        okButton.layer.shadowColor = UIColor.black.cgColor
        okButton.layer.shadowRadius = 4
        okButton.layer.shadowOpacity = 0.5
        okButton.layer.shadowOffset = CGSize(width: 0, height: 0)  
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide the navigation bar on this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - IBActions
    
    @IBAction func okTapped(_ sender: UIButton) {
        // get a ref to current Navigation Controller
        guard let navController = self.navigationController else {
            Logger.error("Cannot get ref to navigationController.")
            return
        }
        navController.popToRootViewController(animated: true)
    }
    
}
