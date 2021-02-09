//
//  AccountViewController.swift
//  BookTheCut
//
//  Created by Vitaliy on 2020-10-24.
//

import UIKit
import PromiseKit
import FirebaseAuth

class AccountViewController: BaseMainViewController {

    // MARK: - IBOutlets
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var buttonStackView: UIStackView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var deleteAccButton: UIButton!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resetFields()
        
        nameTextField.delegate = self
        
        cancelButton.backgroundColor = UIColor.ourRed
        cancelButton.layer.cornerRadius = cancelButton.frame.height / 2
        cancelButton.setTitleColor(UIColor.black, for: .normal)
        cancelButton.layer.shadowColor = UIColor.black.cgColor
        cancelButton.layer.shadowRadius = 4
        cancelButton.layer.shadowOpacity = 0.5
        cancelButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        saveButton.backgroundColor = UIColor.ourYellow
        saveButton.layer.cornerRadius = cancelButton.frame.height / 2
        saveButton.setTitleColor(UIColor.black, for: .normal)
        saveButton.layer.shadowColor = UIColor.black.cgColor
        saveButton.layer.shadowRadius = 4
        saveButton.layer.shadowOpacity = 0.5
        saveButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        deleteAccButton.backgroundColor = UIColor.ourYellow
        deleteAccButton.layer.cornerRadius = cancelButton.frame.height / 2
        deleteAccButton.setTitleColor(UIColor.black, for: .normal)
        deleteAccButton.layer.shadowColor = UIColor.black.cgColor
        deleteAccButton.layer.shadowRadius = 4
        deleteAccButton.layer.shadowOpacity = 0.5
        deleteAccButton.layer.shadowOffset = CGSize(width: 0, height: 0)
    }
    
    // MARK: - Navigation
    
    private func getBackToMainVC() {
        guard let navController = self.navigationController else {
            Logger.error("Cannot get ref to navigationController.")
            return
        }
        navController.popViewController(animated: true)
    }
    
    // MARK: - Private Methods
    
    private func resetFields() {
        nameTextField.text = appDelegate.user!.name
        nameTextField.isUserInteractionEnabled = false
        
        buttonStackView.alpha = 0
    }
    
    /// updates fields 'name' and 'email' in FBDatabase.[Users] for current user
    private func updateUserInFirebase(newName: String) -> Promise<Void> {
        return Promise { seal in
            let query = dbRef.child(Constants.fbDbTableUsers).child(self.appDelegate.user!.id)
            let fieldUpdates = ["name": newName]
            query.updateChildValues(fieldUpdates) { (error, _) in
                if error != nil {
                    Logger.error("Error while updating user.")
                    seal.reject(error!)
                    return
                }
                seal.fulfill_()
            }
        }
    }
    
    private func deleteAccount() {
        guard let userId = Auth.auth().currentUser?.uid else {
            Logger.error("Cannot get current user ID.")
            return
        }
        
        Auth.auth().currentUser?.delete(completion: { (error) in
            if let error = error as NSError? {
                switch AuthErrorCode(rawValue: error.code) {
                case .requiresRecentLogin:
                    self.showInfoAlert(title: "Warning!", message: "Deleting a user is a security sensitive operation that requires a recent login from the user. Please log out and log in first.")
                default:
                    Logger.error("Error message: \(error.localizedDescription)")
                }
            } else {
                // Delete from [Users]
                self.dbRef.child(Constants.fbDbTableUsers).child(userId).removeValue()
                
                // Delete from [Bookings]
                let query = self.dbRef.child(Constants.fbDbTableBookings).queryOrdered(byChild: "userId").queryEqual(toValue: userId)
                query.observeSingleEvent(of: .value) { snapshot in
                    guard let bookingData = snapshot.value as? NSDictionary else {
                        Logger.error("Error while reading from [Bookings] by userId")
                        return
                    }
                    var bookingIdArray: [String] = []
                    for (key, _) in bookingData {
                        guard let bookingId = key as? String else {
                            Logger.error("Error while reading booking's IDs from DB.")
                            continue
                        }
                        bookingIdArray.append(bookingId)
                    }
                    for bookingId in bookingIdArray {
                        self.dbRef.child(Constants.fbDbTableBookings).child(bookingId).removeValue()
                    }
                }
                // Reset global user reference
                self.appDelegate.user = nil
                // Back to the main screen
                self.backToFirstPage()
            }
        })
    }
    
    // MARK: - IBActions
    
    @IBAction func editTapped(_ sender: UIBarButtonItem) {
        nameTextField.isUserInteractionEnabled = true
        buttonStackView.alpha = 1
    }

    @IBAction func cancelTapped(_ sender: UIButton) {
        resetFields()
    }
    
    @IBAction func saveTapped(_ sender: UIButton) {
        let newName = (nameTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        if newName.isEmpty {
            showInfoAlert(title: "Warning!", message: "Name field must not be empty.")
            return
        }
        
        // update the user record in FBDatabase.[Users]
        Spinner.start(self)
        firstly {
            updateUserInFirebase(newName: newName)
        }.done {
            self.appDelegate.user!.name = newName
            self.resetFields()
            Spinner.stop()
        }.catch { error in
            self.resetFields()
            Spinner.stop()
            Logger.error("Some user's fields are empty.")
            // TODO: inform user
        }
    }
    
    @IBAction func deleteAccTapped(_ sender: UIButton) {
        showDeleteAccAlert(callback: deleteAccount)
    }
    
}

/// in order to hide keyboard when typing in UITextField is done
extension AccountViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
}
