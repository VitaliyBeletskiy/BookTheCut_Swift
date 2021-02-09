//
//  BaseMainViewController.swift
//  BookTheCut
//
//  Created by Vitaliy on 2020-10-26.
//

import UIKit
import FirebaseDatabase
import PromiseKit

class BaseMainViewController: UIViewController {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let dbRef: DatabaseReference! = Database.database().reference()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Navigation
    
    func transitionToAuthProcedure() {
        let authStoryboard = UIStoryboard(name: Constants.authStoryboard, bundle: Bundle.main)
        guard let authNavController = authStoryboard.instantiateViewController(identifier: Constants.authNavController) as? UINavigationController else {
            Logger.error("Failed to get the reference for AuthNavigationController.")
            return
        }
        authNavController.modalPresentationStyle = .fullScreen
        present(authNavController, animated: false, completion: nil)
    }
    
    /// transition to rootVC of this NavController (It should be MainViewController)
    func backToFirstPage() {
        guard let navController = self.navigationController else {
            Logger.error("Failed getting ref to current NavController.")
            return
        }
        navController.popToRootViewController(animated: true)
    }
    
    // MARK: - General Functions
    
    /// shows informational UIAlertAction with one button "Close"
    func showInfoAlert(title: String = "Title", message: String = "Message") {
        Spinner.stop()
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    /// shows UIAlertAction if user is not logged in
    func showNotLoggedInAlert() {
        Spinner.stop()
        let alert = UIAlertController(title: Constants.notLoggedInTitle,
                                      message: Constants.notLoggedInMessage,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Log In", style: .default, handler: { _ in
            self.transitionToAuthProcedure()
        }))
        self.present(alert, animated: true)
    }
    
    /// shows UIAlertAction if user wants to delete account
    func showDeleteAccAlert(callback: @escaping () -> Void) {
        Spinner.stop()
        let alert = UIAlertController(title: Constants.deleteAccountTitle,
                                      message: Constants.deleteAccountMessage,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { _ in
            callback()
        }))
        self.present(alert, animated: true)
    }
}
