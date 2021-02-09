//
//  MainViewController.swift
//  LoginProcedure
//
//  Created by Vitaliy on 2020-10-05.
//

import UIKit
import Firebase
import PromiseKit
import SideMenu

class MainViewController: BaseMainViewController {
    
    // MARK: - IBOutlets

    @IBOutlet weak var manButton: UIButton!
    @IBOutlet weak var womanButton: UIButton!
    @IBOutlet weak var childButton: UIButton!
    @IBOutlet weak var beardButton: UIButton!
    @IBOutlet weak var shade: UIView!
    
    // MARK: - Private Properties
    
    private var sideMenu: SideMenuNavigationController?
    private var salonArray: [Salon] = []
    private var isUpdateFromDbInProgress = false  // helper to process first Firebase asynс call in viewDidLoad()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        womanButton.layer.shadowColor = UIColor.black.cgColor
        womanButton.layer.shadowRadius = 8
        womanButton.layer.shadowOpacity = 1
        womanButton.layer.shadowOffset = CGSize(width: 0, height: 0)
   
        manButton.layer.shadowColor = UIColor.black.cgColor
        manButton.layer.shadowRadius = 8
        manButton.layer.shadowOpacity = 1
        manButton.layer.shadowOffset = CGSize(width: 0, height: 0)

        childButton.layer.shadowColor = UIColor.black.cgColor
        childButton.layer.shadowRadius = 8
        childButton.layer.shadowOpacity = 1
        childButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        beardButton.layer.shadowColor = UIColor.black.cgColor
        beardButton.layer.shadowRadius = 8
        beardButton.layer.shadowOpacity = 1
        beardButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        // connect side menu
        let menuVC = MenuViewController()
        menuVC.delegate = self
        sideMenu = SideMenuNavigationController(rootViewController: menuVC)
        sideMenuSetup()
        
        // try to restore user
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        isUpdateFromDbInProgress = true
        updateUserFromDatabase(userId: userId).done {
            self.isUpdateFromDbInProgress = false
            Spinner.stop()
            //self.welcomeUser()
        }.catch { error in
            Logger.error("\(error.localizedDescription)")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isUpdateFromDbInProgress { Spinner.start(self) }
        // welcomeUser()
    }
    
    // MARK: - Navigation
      
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let target = segue.destination as? MapViewController {
             target.salonArray = self.salonArray
        }
    }
    
    // MARK: - Private Methods
    
    private func sideMenuSetup() {
        sideMenu?.leftSide = true
        SideMenuManager.default.leftMenuNavigationController = sideMenu
        SideMenuManager.default.addPanGestureToPresent(toView: self.view)
    }
    
    /// Updates welcome label
//    private func welcomeUser() {
//        guard let userName = self.appDelegate.user?.name else {
//            self.welcomeLabel.text = "Welcome to BookTheCut"
//            return
//        }
//        self.welcomeLabel.text = "Hello, \(userName)"
//    }
    
    /// Reads User's data from FBDatabase.[Users] to property 'user'
    private func updateUserFromDatabase(userId: String) -> Promise<Void> {
        return Promise { seal in
            self.dbRef.child(Constants.fbDbTableUsers).child(userId).observeSingleEvent(of: .value, with: { snapshot in
                
                guard let values = snapshot.value as? NSDictionary else {
                    Logger.error("Snapshot.value doesn't contain any data.")
                    seal.reject(AppError.FirebaseRequestError)
                    return
                }
                let userName = values["name"] as? String ?? ""
                let userEmail = values["email"] as? String ?? ""
                self.appDelegate.user = User(id: userId, name: userName, email: userEmail)
                seal.fulfill_()
            }) { error in
                Logger.error("\(error.localizedDescription)")
                seal.reject(AppError.FirebaseRequestError)
            }
        }
    }
    
    /// retrieves the array of salons for particular service ID
    private func getSalonListFromFirebase(serviceId: String) -> Promise<Void> {
        return Promise {seal in
            let query = dbRef.child(Constants.fbDbTableSalons).queryOrdered(byChild: "services/\(serviceId)").queryEqual(toValue: true)
            query.observeSingleEvent(of: .value) { snapshot in
                guard let values = snapshot.value as? NSDictionary else {
                    // If there are no records, then Snap (Salons) <null>
                    seal.fulfill_()
                    return
                }
                for (key, value) in values {
                    guard let salonId = key as? String, let dataForSalon = value as? NSDictionary else{
                        Logger.error("Cannot get data for Salon().")
                        seal.reject(AppError.FirebaseRequestError)
                        return
                    }
                    self.salonArray.append(Salon(id: salonId, snapshotData: dataForSalon))
                }
                seal.fulfill_()
            } withCancel: { error in
                seal.reject(error)
            }
        }
    }
    
    /// performs user logout
    private func logout() {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            Logger.error("Error: while signing out: \(signOutError)")
        }
        // reset user (in case we just logout)
        self.appDelegate.user = nil
        //welcomeUser()
    }
    
    // MARK: - IBActions
    
    @IBAction func menuButtonTapped(_ sender: UIBarButtonItem) {
        present(sideMenu!, animated: true)
        
    }
    
    @IBAction func bookTapped(_ sender: UIButton) {
        // choose service
        var serviceId = ""
        switch sender {
        case manButton:
            serviceId = "-MK6Kl82WkUIiEfPkwVg"
        case womanButton:
            serviceId = "-MK6KweMMuC7YSImGO3D"
        case childButton:
            serviceId = "-MK6L2vBVwSVXi5U72NM"
        case beardButton:
            serviceId = "-MK6LBlA7BnTnwoKPUMq"
        default:
            Logger.error("Unknown button.")
            return
        }
        Spinner.start(self)
        salonArray.removeAll()
        getSalonListFromFirebase(serviceId: serviceId).done{
            Spinner.stop()
            if self.salonArray.count == 0 {
                // TODO: inform user that the array is empty
                return
            }
            self.performSegue(withIdentifier: Constants.segueToMapVC, sender: self)
        }.catch { error in
            Spinner.stop()
            Logger.error("\(error.localizedDescription)")
        }
    }
    
}

extension MainViewController: MenuDelegate {
    
    func shadeScreen() {
        shade.alpha = 0.5
    }
    
    func unshadeScreen() {
        shade.alpha = 0
    }
    
    func buttonTapped(action: String) {
        sideMenu?.dismiss(animated: true, completion: nil)
        
        switch action{
        case Constants.menuActionBookings:
            performSegue(withIdentifier: Constants.segueToBookingListVC, sender: self)
        case Constants.menuActionAccount:
            performSegue(withIdentifier: Constants.segueToAccountVC, sender: self)
        case Constants.menuActionLogout:
            logout()
        case Constants.menuActionLogin:
            transitionToAuthProcedure()
        default:
            Logger.error("Unknown action.")
            return
        }
    }
    
}
