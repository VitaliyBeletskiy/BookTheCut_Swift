//
//  ConfirmBookingViewController.swift
//  BookingProcedure
//
//  Created by Vitaliy on 2020-10-14.
//

import UIKit
import PromiseKit

class ConfirmBookingViewController: BaseMainViewController {

    // MARK: - IBOutlets
    
    @IBOutlet weak var confirmationLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!

    // MARK: - Properties
    
    var salon: Salon?
    var hairdresser: Hairdresser?
    var booking: Booking?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !isInputDataValid() {
            getBackToCalendarVC()
        }
        
        cancelButton.backgroundColor = UIColor.ourRed
        cancelButton.layer.cornerRadius = cancelButton.frame.height / 2
        cancelButton.setTitleColor(UIColor.white, for: .normal)
        cancelButton.layer.shadowColor = UIColor.black.cgColor
        cancelButton.layer.shadowRadius = 4
        cancelButton.layer.shadowOpacity = 0.5
        cancelButton.layer.shadowOffset = CGSize(width: 0, height: 0)

        confirmButton.backgroundColor = UIColor.ourYellow
        confirmButton.layer.cornerRadius = confirmButton.frame.height / 2
        confirmButton.setTitleColor(UIColor.black, for: .normal)
        confirmButton.layer.shadowColor = UIColor.black.cgColor
        confirmButton.layer.shadowRadius = 4
        confirmButton.layer.shadowOpacity = 0.5
        confirmButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        confirmationLabel.text = "Your booking details:\nSalon:\n\(salon!.name!)\nAddress:\n \(salon!.address!)\nHairdresser:\n\(hairdresser!.name!)\nDate-time:\n\(booking!.dateTime)"
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
    
    // MARK: - Navigation
    
    private func getBackToCalendarVC() {
        guard let navController = self.navigationController else {
            Logger.error("Cannot get ref to navigationController.")
            return
        }
        navController.popViewController(animated: true)
    }
    
    // MARK: - Private Methods
    
    /// checks if input data exists
    private func isInputDataValid() -> Bool {

        if self.salon == nil {
            return false
        }
        if self.hairdresser == nil {
            return false
        }
        if self.booking == nil {
            return false
        }
        
        return true
    }
    
    /// adds (writes in) a new booking to FBDatabase.[Bookings] table
    private func addBookingToFirebase(booking: Booking) -> Promise<Void> {
        return Promise {seal in
            let query = dbRef.child(Constants.fbDbTableBookings).childByAutoId()
            query.setValue(["dateTime": booking.dateTime, "hairdresserId": booking.hairdresserId, "userId": booking.userId]) { (error, _) in
                if error != nil {
                    Logger.error("Cannot add new booking.")
                    seal.reject(error!)
                    return
                }
                seal.fulfill_()
            }
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func cancelTapped(_ sender: UIButton) {
        guard let navController = self.navigationController else {
            Logger.error("Cannot get ref to navigationController.")
            return
        }
        navController.popViewController(animated: true)
    }
        
    @IBAction func confirmTapped(_ sender: UIButton) {
        
        // check if user logged in
        guard let _ = appDelegate.user else {
            showNotLoggedInAlert()
            return
        }
        booking!.userId = appDelegate.user!.id
        
        Spinner.start(self)
        // write the booking into FBDatabase.[Bookings]
        firstly {
            addBookingToFirebase(booking: self.booking!)
        }.done {
            Spinner.stop()
            self.performSegue(withIdentifier: Constants.segueToBookingConfirmedVC, sender: self)
        }.catch { error in
            Spinner.stop()
            // TODO: handle error, inform user
        }
    }

}
