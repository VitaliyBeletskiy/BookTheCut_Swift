//
//  CreateAccountViewController.swift
//  LoginProcedure
//
//  Created by Vitaliy on 2020-10-05.
//

import UIKit
import Firebase

class CreateAccountViewController: BaseAuthViewController {

    // MARK: - IBOutlets
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var reenterPasswordTextField: UITextField!
    @IBOutlet weak var createButton: UIButton!

    @IBOutlet weak var nameImageView: UIImageView!
    @IBOutlet weak var emailImageView: UIImageView!
    @IBOutlet weak var password1ImageView: UIImageView!
    @IBOutlet weak var password2ImageView: UIImageView!
    @IBOutlet weak var eye1Button: UIButton!
    @IBOutlet weak var eye2Button: UIButton!
    
    // MARK: - Private Properties
    
    private var id = ""
    private var name = ""
    private var email = ""
    private var password = ""
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //add Button Colors
        createButton.backgroundColor = UIColor.ourYellow
        createButton.layer.cornerRadius = createButton.frame.height / 2
        createButton.setTitleColor(UIColor.black, for: .normal)
        createButton.layer.shadowColor = UIColor.black.cgColor
        createButton.layer.shadowRadius = 4
        createButton.layer.shadowOpacity = 0.5
        createButton.layer.shadowOffset = CGSize(width: 0, height: 0)

        nameTextField.leftViewMode = .always
        nameImageView.image = UIImage(systemName: "person")?.withTintColor(UIColor.iconGray, renderingMode: .alwaysOriginal)
        nameImageView.frame = CGRect(x: 0, y: 0, width: nameTextField.frame.height, height: nameTextField.frame.height)
        nameTextField.leftView = nameImageView
        nameTextField.delegate = self

        emailTextField.leftViewMode = .always
        emailImageView.image = UIImage(systemName: "envelope")?.withTintColor(UIColor.iconGray, renderingMode: .alwaysOriginal)
        emailImageView.frame = CGRect(x: 0, y: 0, width: emailTextField.frame.height, height: emailTextField.frame.height)
        emailTextField.leftView = emailImageView
        emailTextField.delegate = self
           
        passwordTextField.leftViewMode = .always
        password1ImageView.image = UIImage(systemName: "lock")?.withTintColor(UIColor.iconGray, renderingMode: .alwaysOriginal)
        password1ImageView.frame = CGRect(x: 0, y: 0, width: passwordTextField.frame.height, height: passwordTextField.frame.height)
        passwordTextField.leftView = password1ImageView
        passwordTextField.rightViewMode = .always
        eye1Button.setImage(UIImage(systemName: "eye")?.withTintColor(UIColor.iconGray, renderingMode: .alwaysOriginal), for: [])
        eye1Button.frame = CGRect(x: 0, y: 0, width: passwordTextField.frame.height, height: passwordTextField.frame.height)
        passwordTextField.rightView = eye1Button
        passwordTextField.isSecureTextEntry = true
        passwordTextField.delegate = self
        
        reenterPasswordTextField.leftViewMode = .always
        password2ImageView.image = UIImage(systemName: "lock")?.withTintColor(UIColor.iconGray, renderingMode: .alwaysOriginal)
        password2ImageView.frame = CGRect(x: 0, y: 0, width: reenterPasswordTextField.frame.height, height: reenterPasswordTextField.frame.height)
        reenterPasswordTextField.leftView = password2ImageView
        reenterPasswordTextField.rightViewMode = .always
        eye2Button.setImage(UIImage(systemName: "eye")?.withTintColor(UIColor.iconGray, renderingMode: .alwaysOriginal), for: [])
        eye2Button.frame = CGRect(x: 0, y: 0, width: reenterPasswordTextField.frame.height, height: reenterPasswordTextField.frame.height)
        reenterPasswordTextField.rightView = eye2Button
        reenterPasswordTextField.isSecureTextEntry = true
        reenterPasswordTextField.delegate = self
    }

    // MARK: - Private Methods
     
    /// validates all TextFields
    private func validateUserInput() -> Bool {
        // get data from TextFields
        name = (nameTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        email = (emailTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
       
        password = (passwordTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let password2 = (reenterPasswordTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        // check if all Text Fields are not empty
        if name.isEmpty || email.isEmpty || password.isEmpty || password2.isEmpty {
            showInfoAlert(title: "Alert", message: "Please fill in all fields.")
            return false
        }
        
        // check if email address is valid
        if !Utilities.isValidEmail(email) {
            showInfoAlert(title: "Alert", message: "Please enter valid email address.")
            return false
        }
        
        // check if the password is at least 6 characters long
        if password.count < 6 {
            showInfoAlert(title: "Alert", message: "Password must have at least 6 characters.")
            return false
        }
        // check if passwords match
        if password != password2 {
            showInfoAlert(title: "Alert", message: "Passwords don't match.")
            return false
        }
        
        return true
    }
    
    // MARK: - IBActions

    @IBAction func eye1ButtonTapped(_ sender: UIButton) {
        passwordTextField.isSecureTextEntry.toggle()
    }
    
    @IBAction func eye2ButtonTapped(_ sender: UIButton) {
        reenterPasswordTextField.isSecureTextEntry.toggle()
    }
    
    /// create new user with email-password in FirebaseAuth
    @IBAction func createTapped(_ sender: UIButton) {
        
        // validate Text Fields
        if !validateUserInput() {
            return
        }
        Spinner.start(self)
        
        // register (create) this user with FirebaseAuth
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            
            if let err = error {
                Logger.error("\(err.localizedDescription)")
                self.showInfoAlert(title: "Error", message: err.localizedDescription)
                return
            }
            
            if let id = result?.user.uid {
                self.id = id
            } else {
                Logger.error("User Id doesn't exist.")
                self.showInfoAlert(title: "Error", message: Constants.generalFirebaseError)
                return
            }
            
            // create a new record in FirebaseDB.[Users]
            self.addUserToDatabase(id: self.id, name: self.name, email: self.email)
        }
    }
    
}
