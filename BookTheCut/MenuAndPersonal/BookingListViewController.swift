//
//  BookingListViewController.swift
//  BookTheCut
//
//  Created by Vitaliy on 2020-10-25.
//

import UIKit
import PromiseKit

class BookingListViewController: BaseMainViewController {

    // MARK: - IBOutlets
    
    @IBOutlet weak var bookingTableView: UITableView!
    @IBOutlet weak var noBookingLabel: UILabel!
    
    // MARK: - Private Properties

    private var bookingArray: [Booking] = []
    private var chosenBooking: Booking?
    private var hairdresser: Hairdresser?
    private var salon: Salon?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bookingTableView.register(BookingTableViewCell.nib(), forCellReuseIdentifier: Constants.cellForBooking)
        bookingTableView.delegate = self
        bookingTableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Spinner.start(self)
        firstly {
            getBookingListFromFirebase(userId: self.appDelegate.user!.id)
        }.done {
            Spinner.stop()
            if self.bookingArray.count > 0 {
                self.bookingTableView.reloadData()
            } else {
                self.setViewsForNoBooking()
            }
        }.catch { error in
            Spinner.stop()
            Logger.error("\(error)")
            self.setViewsForNoBooking()
        }
    }
    
    // MARK: - Navigation
    
    private func getBackToMainVC() {
        guard let navController = self.navigationController else {
            Logger.error("Cannot get ref to navigationController.")
            return
        }
        navController.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let target = segue.destination as? ManageBookingViewController {
            target.booking = self.chosenBooking
            target.hairdresser = self.hairdresser
            target.salon = self.salon
        }
    }
    
    // MARK: - Private Methods

    /// hides bookingTableView and shows noBookingLabel
    private func setViewsForNoBooking() {
        self.bookingTableView.alpha = 0
        self.noBookingLabel.alpha = 1
    }
    
    /// gets Bookings from FBDatabase.[Bookings] for particular user and add them to bookingArray
    private func getBookingListFromFirebase(userId: String) -> Promise<Void> {
        return Promise {seal in
            
            self.bookingArray.removeAll()
            
            let query = dbRef.child(Constants.fbDbTableBookings).queryOrdered(byChild: "userId").queryEqual(toValue: userId)
            query.observeSingleEvent(of: .value) { snapshot in
                guard let bookingData = snapshot.value as? NSDictionary else {
                    seal.reject(AppError.FirebaseRequestError)
                    return
                }
                for (key, value) in bookingData {
                    guard let bookingDict = value as? NSDictionary,
                          let bookingId = key as? String,
                          let hairdresserId = bookingDict["hairdresserId"] as? String,
                          let dateTime = bookingDict["dateTime"] as? String else {
                        continue
                    }
                    self.bookingArray.append(Booking(id: bookingId, userId: userId, hairdresserId: hairdresserId, dateTime: dateTime))
                }
                seal.fulfill_()
            } withCancel: { error in
                seal.reject(error)
            }
        }
    }
    
    /// gets hairdresser data  from FBDatabase.[Hairdressers]
    private func getHairdresserFromFirebase(hairdresserId: String) -> Promise<Hairdresser> {
        return Promise { seal in
            let query = dbRef.child(Constants.fbDbTableHairdressers).child(hairdresserId)
            query.observeSingleEvent(of: .value) { snapshot in
                guard let valueDict = snapshot.value as? NSDictionary else {
                    Logger.error("Snapshot is empty.")
                    seal.reject(AppError.FirebaseRequestError)
                    return
                }
                seal.fulfill(Hairdresser(id: hairdresserId, snapshotData: valueDict))
            } withCancel: { error in
                seal.reject(error)
            }
        }
    }
    
    /// gets salon data  from FBDatabase.[Salons]
    private func getSalonFromFirebase(salonId: String) -> Promise<Salon> {
        return Promise { seal in
            let query = dbRef.child(Constants.fbDbTableSalons).child(salonId)
            query.observeSingleEvent(of: .value) { snapshot in
                guard let valueDict = snapshot.value as? NSDictionary else {
                    Logger.error("Snapshot is empty.")
                    seal.reject(AppError.FirebaseRequestError)
                    return
                }
                seal.fulfill(Salon(id: salonId, snapshotData: valueDict))
            } withCancel: { error in
                seal.reject(error)
            }
        }
    }

}

extension BookingListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookingArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellForBooking, for: indexPath) as? BookingTableViewCell
        cell?.delegate = self
        cell?.booking = bookingArray[indexPath.row]
        cell?.timeLabel.text = bookingArray[indexPath.row].dateTime
        return cell!
    }
    
}

extension BookingListViewController: BookingListDelegate {
    
    func didChooseBooking(booking: Booking) {
        self.chosenBooking = booking
        
        Spinner.start(self)
        firstly {
            getHairdresserFromFirebase(hairdresserId: self.chosenBooking!.hairdresserId)
        }.then { hairdresser -> Promise<Salon> in
            self.hairdresser = hairdresser
            return self.getSalonFromFirebase(salonId: self.hairdresser!.salonId!)
        }.done { salon in
            Spinner.stop()
            self.salon = salon
            self.performSegue(withIdentifier: Constants.segueToManageBookingVC, sender: self)
        }.catch {error in
            Spinner.stop()
            // TODO: inform user?
            Logger.error("\(error.localizedDescription)")
        } 
    }
    
}
