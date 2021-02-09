//
//  CalendarViewController.swift
//  BookingProcedure
//
//  Created by Vitaliy on 2020-10-13.
//

import UIKit
import FSCalendar

class CalendarViewController: BaseMainViewController {

    // MARK: - IBOutlets
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var timeTableView: UITableView!
    
    // MARK: - Properties
    
    var salon: Salon?
    var hairdresser: Hairdresser?
    var bookedTimeSlots: [String]?
    
    // MARK: - Private Properties
    
    private var timeSlotsArray: [String] = []
    private var chosenTimeSlot: String = ""
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !isInputDataValid() {
            getBackToHairdresserVC()
        }
        
        calendar.delegate = self
        calendar.dataSource = self
        setUpCalendar()
        
        timeTableView.delegate = self
        timeTableView.dataSource = self
    }

    // MARK: - Navigation
    
    private func getBackToHairdresserVC() {
        guard let navController = self.navigationController else {
            Logger.error("Cannot get ref to navigationController.")
            return
        }
        navController.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let target = segue.destination as? ConfirmBookingViewController {
            target.salon = self.salon
            target.hairdresser = self.hairdresser
            target.booking = Booking(userId: "", hairdresserId: self.hairdresser!.id!, dateTime: self.chosenTimeSlot)
        }
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
        if self.bookedTimeSlots == nil {
            return false
        }
        
        return true
    }
    
    /// sets up calendar's properties
    private func setUpCalendar() {
        calendar.firstWeekday = 2
    }
    
    /// gets date as Date  and updates time table view for this date
    private func updateTimeTableViewForDate(date: Date) {
        timeSlotsArray.removeAll()
        
        let weekdayNumber = Calendar.current.component(.weekday, from: date) // пн=2, вт=3, ... сб=7, вс=1
        var startHour, endHour: Int
        switch weekdayNumber {
        case 1:    // sunday
            startHour = 10
            endHour = 10
        case 7:    // saturday
            startHour = 11
            endHour = 15
        default:
            startHour = 10
            endHour = 17
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        let stringDate = formatter.string(from: date)

        for hour in startHour..<endHour {
            timeSlotsArray.append("\(stringDate) \(hour):00")
        }
        timeTableView.reloadData()
    }

    // MARK: - IBActions
    
    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        backToFirstPage()
    }
}

extension CalendarViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timeSlotsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellForTimeSlot) as? TimeTableViewCell
        
        cell?.delegate = self
        
        let timeSlot = timeSlotsArray[indexPath.row]
        cell?.timeLabel.text = timeSlot
        cell?.bookButton.alpha = bookedTimeSlots!.contains(timeSlot) ? 0 : 1
        
        return cell!
    }
    
}

extension CalendarViewController: FSCalendarDelegate, FSCalendarDataSource {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        self.updateTimeTableViewForDate(date: date)
    }
    
    func minimumDate(for calendar: FSCalendar) -> Date {
        return Date()
    }
    
    func maximumDate(for calendar: FSCalendar) -> Date {
        return Date().addingTimeInterval((24 * 60 * 60) * 120)
    }
    
}

extension CalendarViewController: TimeTableViewCellDelegate {
    
    func didTapBookButton(stringTimeSlot: String) {
        self.chosenTimeSlot = stringTimeSlot
        self.performSegue(withIdentifier: Constants.segueToConfirmBookingVC, sender: self)
    }
    
}
