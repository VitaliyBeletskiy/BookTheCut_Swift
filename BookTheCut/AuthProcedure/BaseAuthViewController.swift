//
//  BaseAuthViewController.swift
//  LoginProcedure
//
//  Created by Vitaliy on 2020-10-07.
//

import UIKit
import Firebase

class BaseAuthViewController: UIViewController {
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let dbRef: DatabaseReference! = Database.database().reference()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Navigation
    
    /// dismisses current AuthNavController returning to presenting VC
    func dismissAuthNavController() {
        Spinner.stop()
        guard let authNavController = self.navigationController else {
            Logger.error("Failed getting reference to current NavController")
            fatalError("Failed getting reference to current NavController")
        }
        authNavController.dismiss(animated: true, completion: nil)
    }
    
    /// updates global user variable with input fields, writes userId to UserDefaults
    /// and dismisses current AuthNavController returning to presenting VC
    func saveUserAndDismissAuthNavController(id: String, name: String, email: String) {
        appDelegate.user = User(id: id, name: name, email: email)
        dismissAuthNavController()
    }
    
    // MARK: - General
    
    /// shows informational UIAlertAction with one button "Close"
    func showInfoAlert(title: String = "Title", message: String = "Message") {
        Spinner.stop()
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    func setGlobalUser(id: String, name: String, email: String) {
        appDelegate.user = User(id: id, name: name, email: email)
    }
    
    // TODO: не очень мне это нравится, надо переписать
    /// adds newly created user to FirebaseDB.[Users]
    func addUserToDatabase(id: String, name: String, email: String) {
        
        self.dbRef.child(Constants.fbDbTableUsers).child(id).setValue(["name": name, "email": email]) { (error, reference) in
            
            if let err = error {
                Logger.error("Error while adding the user to to Firebase.[Users]: \(err.localizedDescription)")
                // Failed to add the user to FirebaseDB.[Users], so delete this user from FirebaseAuth
                let user = Auth.auth().currentUser
                user?.delete { error in
                    if let err = error {
                        Logger.error("Error while deleting the user from FirebaseAuth: \(err.localizedDescription)")
                        return
                    } else {
                        self.showInfoAlert(title: "Error", message: Constants.generalFirebaseError)
                    }
                }
                Spinner.stop()
                return
            }
            // user has been sucessfully added to Firebase.[Users]
            // update global variable 'user' and exit
            self.saveUserAndDismissAuthNavController(id: id, name: name, email: email)
        }
    }
    
}

/// in order to hide keyboard when typing in UITextField is done
extension BaseAuthViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
}
