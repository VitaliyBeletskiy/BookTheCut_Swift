//
//  ForgotPasswordViewController.swift
//  BookTheCut
//
//  Created by Vitaliy on 2020-12-02.
//

import UIKit
import Firebase

class ForgotPasswordViewController: BaseAuthViewController {

    // MARK: - IBOutlets
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailImageView: UIImageView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //add Icons
        emailTextField.leftViewMode = .always
        emailImageView.image = UIImage(systemName: "envelope")?.withTintColor(UIColor.iconGray, renderingMode: .alwaysOriginal)
        emailImageView.frame = CGRect(x: 0, y: 0, width: emailTextField.frame.height, height: emailTextField.frame.height)
        emailTextField.leftView = emailImageView
        emailTextField.delegate = self
    }

    // MARK: - IBActions
    
    @IBAction func ResetPasswordTapped(_ sender: UIButton) {
        let email = (emailTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        // check if email Text Fields are not empty
        if email.isEmpty {
            showInfoAlert(title: "Alert", message: "Please enter email address.")
            return
        }        
        // check if email address is valid
        if !Utilities.isValidEmail(email) {
            showInfoAlert(title: "Alert", message: "Please enter valid email address.")
            return
        }
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let _ = error {
                Logger.error("\(error!.localizedDescription)")
                self.showInfoAlert(title: "Error", message: Constants.generalFirebaseError)
                return
            }
            guard let navController = self.navigationController else {
                Logger.error("Failed getting ref to current NavController.")
                return
            }
            navController.popToRootViewController(animated: true)
        }
    }
}
