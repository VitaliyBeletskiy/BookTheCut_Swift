//
//  HairdresserViewController.swift
//  BookTheCut
//
//  Created by Vitaliy on 2020-10-19.
//

import UIKit
import FirebaseDatabase
import PromiseKit

class HairdresserViewController: BaseMainViewController {

    // MARK: - IBOutlets
    
    @IBOutlet weak var salonLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var hairdresserTableView: UITableView!
    
    // MARK: - Properties
    
    var salon: Salon?
    var hairdresserArray: [Hairdresser]?
    
    // MARK: - Private Properties
    
    private var chosenHairdresser: Hairdresser?
    private var bookedTimeSlots: [String] = []
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !isInputDataValid() {
            getBackToMapVC()
        }
        
        hairdresserTableView.dataSource = self
        hairdresserTableView.delegate = self
        
        hairdresserTableView.layer.masksToBounds = true
        hairdresserTableView.layer.cornerRadius = 4
        hairdresserTableView.layer.borderWidth = 2
        hairdresserTableView.layer.borderColor = UIColor.darkGray.cgColor
        
        salonLabel.text  = salon?.name
        salonLabel.textColor = UIColor.white
        salonLabel.shadowColor = UIColor.black
        salonLabel.font = UIFont.boldSystemFont(ofSize: 28.0)

        addressLabel.text = salon?.address
        addressLabel.textColor = UIColor.lightGray
        addressLabel.shadowColor = UIColor.black
        addressLabel.font = UIFont.boldSystemFont(ofSize: 13.0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    // MARK: - Navigation
    
    private func getBackToMapVC() {
        guard let navController = self.navigationController else {
            Logger.error("Cannot get ref to navigationController.")
            return
        }
        navController.popViewController(animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let target = segue.destination as? CalendarViewController {
            target.salon = self.salon
            target.hairdresser = self.chosenHairdresser
            target.bookedTimeSlots = self.bookedTimeSlots
        }
    }
    
    // MARK: - Private Methods
    
    /// checks if input data exists
    private func isInputDataValid() -> Bool {

        if self.salon == nil {
            return false
        }
        if self.hairdresserArray == nil || self.hairdresserArray!.count == 0 {
            return false
        }
        
        return true
    }
    
    private func getBookingsFromFirebase(hairdresserId: String) -> Promise<[String]> {
        return Promise {seal in
            // TODO: названия в константы
            dbRef.child(Constants.fbDbTableBookings).queryOrdered(byChild: "hairdresserId").queryEqual(toValue: hairdresserId).observeSingleEvent(of: .value) { snapshot in
                guard let dataDict = snapshot.value as? [String:[String:String]] else {
                    seal.fulfill([])
                    return
                }
                var timeSlotsArray: [String] = []
                for (_, value) in dataDict {
                    timeSlotsArray.append(value["dateTime"] ?? "")
                }
                seal.fulfill(timeSlotsArray)
            } withCancel: { error in
                seal.reject(error)
            }
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        backToFirstPage()
    }
}

extension HairdresserViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hairdresserArray!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellForHairdresser) as? HairdresserTableViewCell
        cell?.hairdresserLabel.text = hairdresserArray![indexPath.row].name
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let chosenHairdresser = hairdresserArray?[indexPath.row] else {
            Logger.error("Cannot get a hairdresser.")
            return
        }
        self.chosenHairdresser = chosenHairdresser
        
        // read the schedule for particular hairdresser
        Spinner.start(self)
        bookedTimeSlots.removeAll()
        firstly {
            getBookingsFromFirebase(hairdresserId: chosenHairdresser.id!)
        }.done { bookings in
            Spinner.stop()
            self.bookedTimeSlots = bookings
            self.performSegue(withIdentifier: Constants.segueToCalendarVC, sender: self)
        }.catch { error in
            Spinner.stop()
            Logger.error("\(error.localizedDescription)")
        }
    }
    
}
