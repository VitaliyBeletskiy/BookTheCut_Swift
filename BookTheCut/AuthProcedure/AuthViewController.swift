//
//  AuthViewController.swift
//  LoginProcedure
//
//  Created by Vitaliy on 2020-10-05.
//

import UIKit

class AuthViewController: BaseAuthViewController {

    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var createNewAccButton: UIButton!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createNewAccButton.backgroundColor = UIColor.black
        createNewAccButton.layer.cornerRadius = createNewAccButton.frame.height / 2
        createNewAccButton.setTitleColor(UIColor.white, for: .normal)
        createNewAccButton.layer.shadowColor = UIColor.yellow.cgColor
        createNewAccButton.layer.shadowRadius = 4
        createNewAccButton.layer.shadowOpacity = 0.5
        createNewAccButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        logInButton.backgroundColor = UIColor.ourYellow
        logInButton.layer.cornerRadius = logInButton.frame.height / 2
        logInButton.setTitleColor(UIColor.black, for: .normal)
        logInButton.layer.shadowColor = UIColor.black.cgColor
        logInButton.layer.shadowRadius = 4
        logInButton.layer.shadowOpacity = 0.5
        logInButton.layer.shadowOffset = CGSize(width: 0, height: 0)
    }

//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        // Hide the navigation bar on this VCz
//        self.navigationController?.setNavigationBarHidden(true, animated: animated)
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        // Show the navigation bar on other VCs
//        self.navigationController?.setNavigationBarHidden(false, animated: animated)
//    }
    
    // MARK: - IBActions
    
    @IBAction func cancelTapped(_ sender: UIButton) {
        dismissAuthNavController()
    }
}
