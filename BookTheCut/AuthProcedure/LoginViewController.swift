//
//  LoginViewController.swift
//  LoginProcedure
//
//  Created by Vitaliy on 2020-10-05.
//

import UIKit
import Firebase
import GoogleSignIn
import PromiseKit

class LoginViewController: BaseAuthViewController {

    // MARK: - IBOutlets

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailImageView: UIImageView!
    @IBOutlet weak var passwordImageView: UIImageView!
    @IBOutlet weak var eyeButton: UIButton!
    @IBOutlet weak var logInButton: UIButton!
    
    //@IBOutlet weak var googleSignInButton: GIDSignInButton!
    
    // MARK: - Private Properties

    private var email: String = ""
    private var password: String = ""
    private var localUser = User()    // temp variable to this class
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
        //GIDSignIn.sharedInstance().signIn()   пока не понимаю, зачем это тут. Автологин?

        logInButton.backgroundColor = UIColor.ourYellow
        logInButton.layer.cornerRadius = logInButton.frame.height / 2
        logInButton.setTitleColor(UIColor.black, for: .normal)
        logInButton.layer.shadowColor = UIColor.black.cgColor
        logInButton.layer.shadowRadius = 4
        logInButton.layer.shadowOpacity = 0.5
        logInButton.layer.shadowOffset = CGSize(width: 0, height: 0)

//        googleSignInButton.layer.cornerRadius = googleSignInButton.frame.height / 4
//        googleSignInButton.layer.shadowColor = UIColor.black.cgColor
//        googleSignInButton.layer.shadowRadius = 4
//        googleSignInButton.layer.shadowOpacity = 0.5
//        googleSignInButton.layer.shadowOffset = CGSize(width: 0, height: 0)

        emailTextField.leftViewMode = .always
        emailImageView.image = UIImage(systemName: "envelope")?.withTintColor(UIColor.iconGray, renderingMode: .alwaysOriginal)
        emailImageView.frame = CGRect(x: 0, y: 0, width: emailTextField.frame.height, height: emailTextField.frame.height)
        emailTextField.leftView = emailImageView
        emailTextField.delegate = self

        passwordTextField.leftViewMode = .always
        passwordImageView.image = UIImage(systemName: "lock")?.withTintColor(UIColor.iconGray, renderingMode: .alwaysOriginal)
        passwordImageView.frame = CGRect(x: 0, y: 0, width: passwordTextField.frame.height, height: passwordTextField.frame.height)
        passwordTextField.leftView = passwordImageView
        passwordTextField.rightViewMode = .always
        eyeButton.setImage(UIImage(systemName: "eye")?.withTintColor(UIColor.iconGray, renderingMode: .alwaysOriginal), for: [])
        eyeButton.frame = CGRect(x: 0, y: 0, width: passwordTextField.frame.height, height: passwordTextField.frame.height)
        passwordTextField.rightView = eyeButton
        passwordTextField.isSecureTextEntry = true
        passwordTextField.delegate = self
    }
    
    // MARK: - IBActions
    
    
    @IBAction func eyeButtonTapped(_ sender: UIButton) {
        passwordTextField.isSecureTextEntry.toggle()
    }
    
    @IBAction func logInTapped(_ sender: UIButton) {

        Spinner.start(self)
        self.email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
        self.password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let err = error {
                Logger.error("\(err.localizedDescription)")
                self.showInfoAlert(title: "Error", message: err.localizedDescription)
                return
            }
            guard let userId = result?.user.uid else {
                Logger.error("AuthResult doesn't contain userId.")
                self.showInfoAlert(title: "Error", message: Constants.generalFirebaseError)
                return
            }
            // read user data from FirebaseDB.[Users]
            self.dbRef.child(Constants.fbDbTableUsers).child(userId).observeSingleEvent(of: .value) { snapshot in
                guard let values = snapshot.value as? NSDictionary else {
                    Logger.error("Snapshot.value doesn't contain any data.")
                    self.showInfoAlert(title: "Error", message: Constants.generalFirebaseError)
                    return
                }
                let userName = values["name"] as? String ?? ""
                let userEmail = values["email"] as? String ?? ""
                // save data and dismiss currentNavC returning to presenting VC
                self.saveUserAndDismissAuthNavController(id: userId, name: userName, email: userEmail)
            } withCancel: { error in
                Logger.error("\(error.localizedDescription)")
                self.showInfoAlert(title: "Error", message: Constants.generalFirebaseError)
            }
        }
    }
}

/// Google Sign In procedure
extension LoginViewController: GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        
        Spinner.start(self)

        if let err = error {  // if user tapped "Cancel" during the process - it's error as well
            Logger.error("\(err.localizedDescription)")
            Spinner.stop()
            return
        }
        
        firstly {
            authUserAlreadyExists(googleUser: user)
        }.then { googleUser in
            self.firebaseSignInWithGoogleUser(googleUser: googleUser)
        }.then { userId in
            self.getUsersRecordByUserId(userId: userId)
        }.done { _ in
            self.saveUserAndDismissAuthNavController(id: self.localUser.id, name: self.localUser.name, email: self.localUser.email)
        }.catch { error in
            // TODO: здесь как-то надо разделять ошибки или всё уже кастомизировано???
            self.showInfoAlert(title: "Error", message: error.localizedDescription)
        }
    }
    
}

extension LoginViewController {
    
    /// checks if this email already exists in Firebase.Auth
    private func authUserAlreadyExists(googleUser: GIDGoogleUser) -> Promise<GIDGoogleUser> {
        return Promise { seal in
            Auth.auth().fetchSignInMethods(forEmail: googleUser.profile.email) { (result, error) in
                
                if let err = error {
                    Logger.error("\(err.localizedDescription)")
                    seal.reject(AppError.FirebaseRequestError)
                    return
                }
               
                if result == nil {
                    seal.fulfill(googleUser)
                    return
                }
                
                switch result![0] {
                case "google.com":
                    seal.fulfill(googleUser)
                case "password":
                    seal.reject(AppError.UserWithPassword)
                default:
                    seal.reject(AppError.UserAlreadyExists)
                }
            }
        }
    }
    
    /// logs in Google user with Firebase.Auth
    private func firebaseSignInWithGoogleUser(googleUser: GIDGoogleUser!) -> Promise<String> {
        return Promise { seal in
            guard let authentication = googleUser.authentication else {
                Logger.error("Error getting googleUser.authentication.")
                seal.reject(AppError.FirebaseRequestError)
                return
            }
            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
            Auth.auth().signIn(with: credential) { (result, error) in
                if let err = error {
                    Logger.error("\(err.localizedDescription)")
                    seal.reject(AppError.FirebaseRequestError)
                    return
                }
                // get FirebaseAuth User Id
                guard let userId = Auth.auth().currentUser?.uid else {
                    Logger.error("Cannot get Auth.auth().currentUser or Auth.auth().currentUser?.uid.")
                    seal.reject(AppError.FirebaseRequestError)
                    return
                }
                
                self.localUser.id = userId
                self.localUser.name = googleUser.profile.name
                self.localUser.email = googleUser.profile.email
                
                seal.fulfill(userId)
            }
        }
    }
    
    /// get a record from FBDatabase.[Users] for the logged in user, returns true if user exists, otherwise false
    private func getUsersRecordByUserId(userId: String) -> Promise<Bool> {
        return Promise { seal in
            self.dbRef.child(Constants.fbDbTableUsers).child(self.localUser.id).observeSingleEvent(of: .value, with: { snapshot in
                
                if let values = snapshot.value as? NSDictionary {  // there was a record in FirebaseDB.[Users]
                    self.localUser.name = values["name"] as! String
                    seal.fulfill(true)
                } else {  // there was NO record in FirebaseDB.[Users]
                    seal.fulfill(false)
                }
            }) { error in
                Logger.error("\(error.localizedDescription)")
                seal.reject(AppError.FirebaseRequestError)
                return
            }
        }
    }

}
