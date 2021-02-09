//
//  ManageBookingViewController.swift
//  BookTheCut
//
//  Created by Vitaliy on 2020-10-26.
//

import UIKit
import PromiseKit

class ManageBookingViewController: BaseMainViewController {

    // MARK: - IBOutlets
    
    @IBOutlet weak var salonLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var hairdresserLabel: UILabel!
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var cancelBookingButton: UIButton!
    
    // MARK: - Properties
    
    var booking: Booking?
    var salon: Salon?
    var hairdresser: Hairdresser?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // check input data
        if !isInputDataValid() {
            getBackToBookingListVC()
        }
        
        //add
        cancelBookingButton.backgroundColor = UIColor.ourRed
        cancelBookingButton.layer.cornerRadius = cancelBookingButton.frame.height / 2
        cancelBookingButton.setTitleColor(UIColor.black, for: .normal)
        cancelBookingButton.layer.shadowColor = UIColor.black.cgColor
        cancelBookingButton.layer.shadowRadius = 4
        cancelBookingButton.layer.shadowOpacity = 0.5
        cancelBookingButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        self.updateLabels()
    }
    
    // MARK: - Navigation
    
    private func getBackToBookingListVC() {
        guard let navController = self.navigationController else {
            Logger.error("Cannot get ref to navigationController.")
            return
        }
        navController.popViewController(animated: true)
    }
    
    // MARK: - Private Methods
    
    /// checks if input data exists
    private func isInputDataValid() -> Bool {
        if self.booking == nil {
            return false
        }
        return true
    }
    
    private func updateLabels() {
        salonLabel.text = self.salon?.name
        addressLabel.text = self.salon?.address
        hairdresserLabel.text = self.hairdresser?.name
        dateTimeLabel.text = self.booking?.dateTime
    }
    
    /// asks if user wants to cancel (delele) this booking
    private func askUserConfirmation() {
        let alert = UIAlertController(title: Constants.cancelBookingTitle, message: Constants.cancelBookingMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            firstly {
                self.deleteBookingFromFirebase(bookingId: self.booking!.id)
            }.done {
                self.getBackToBookingListVC()
            }.catch { error in
                self.showInfoAlert(title: "Error", message: Constants.generalFirebaseError)
            }
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    /// deletes a booking record from FBDatabase.[Bookings]
    private func deleteBookingFromFirebase(bookingId: String) -> Promise<Void> {
        return Promise {seal in
            dbRef.child(Constants.fbDbTableBookings).child("\(bookingId)").removeValue { (error, _) in
                if error != nil {
                    Logger.error("\(error!.localizedDescription)")
                    seal.reject(error!)
                    return
                }
                seal.fulfill_()
            }
        }
    }
    
    // MARK: - IBActions

    // user wants to cancel (delete) current booking
    @IBAction func cancelTapped(_ sender: Any) {
        askUserConfirmation()
    }
}
