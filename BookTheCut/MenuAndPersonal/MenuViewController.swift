//
//  MenuViewController.swift
//  BookTheCut
//
//  Created by Vitaliy on 2020-10-23.
//

import UIKit

class MenuViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    private let bookingButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.ourYellow
        button.setTitleColor(UIColor.black, for: .normal)
        button.layer.cornerRadius = button.frame.height / 2
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.5
        button.layer.shadowOffset = CGSize(width: 0, height: 0)
        button.setTitle("My Bookings", for: [])
        button.contentHorizontalAlignment = .center
        button.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let accountButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.ourYellow
        button.setTitleColor(UIColor.black, for: .normal)
        button.layer.cornerRadius = button.frame.height / 2
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.5
        button.layer.shadowOffset = CGSize(width: 0, height: 0)
        button.setTitle("Account", for: [])
        button.contentHorizontalAlignment = .center
        button.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let logoutButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.ourYellow
        button.setTitleColor(UIColor.black, for: .normal)
        //button.layer.masksToBounds = true
        button.layer.cornerRadius = button.frame.height / 2
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.5
        button.layer.shadowOffset = CGSize(width: 0, height: 0)
        button.setTitle("Logout", for: [])
        button.contentHorizontalAlignment = .center
        button.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.ourYellow
        button.setTitleColor(UIColor.black, for: .normal)
        //button.layer.masksToBounds = true
        button.layer.cornerRadius = button.frame.height / 2
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.5
        button.layer.shadowOffset = CGSize(width: 0, height: 0)
        button.setTitle("Login", for: [])
        button.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let loggedView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.alpha = 1
        return view
    }()
    
    private let notLoggedView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.alpha = 1
        return view
    }()
    
    
    // MARK: - Private Properties
    
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // MARK: - Properties
    
    var delegate: MenuDelegate?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.delegate?.shadeScreen()
        
        if let _ = appDelegate.user {
            loggedView.alpha = 1
            notLoggedView.alpha = 0
        } else {
            loggedView.alpha = 0
            notLoggedView.alpha = 1
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.delegate?.unshadeScreen()
    }
    
    // MARK: - Private Methods
    
    private func setupViews() {
        self.view.backgroundColor  = .darkGray
        
        let safeArea = view.safeAreaLayoutGuide
        
        view.addSubview(loggedView)

        NSLayoutConstraint.activate([
            loggedView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 0),
            loggedView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: 0),
            loggedView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 0),
            loggedView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: 0)
        ])

        loggedView.addSubview(bookingButton)
        loggedView.addSubview(accountButton)
        loggedView.addSubview(logoutButton)

        NSLayoutConstraint.activate([
            bookingButton.leadingAnchor.constraint(equalTo: loggedView.leadingAnchor, constant: 10),
            bookingButton.trailingAnchor.constraint(equalTo: loggedView.trailingAnchor, constant: -10),
            bookingButton.topAnchor.constraint(equalTo: loggedView.topAnchor, constant: 20)
        ])
        NSLayoutConstraint.activate([
            accountButton.leadingAnchor.constraint(equalTo: loggedView.leadingAnchor, constant: 10),
            accountButton.trailingAnchor.constraint(equalTo: loggedView.trailingAnchor, constant: -10),
            accountButton.topAnchor.constraint(equalTo: bookingButton.bottomAnchor, constant: 20)
        ])
        NSLayoutConstraint.activate([
            logoutButton.leadingAnchor.constraint(equalTo: loggedView.leadingAnchor, constant: 10),
            logoutButton.trailingAnchor.constraint(equalTo: loggedView.trailingAnchor, constant: -10),
            logoutButton.bottomAnchor.constraint(equalTo: loggedView.bottomAnchor, constant: -10)
        ])
        
        view.addSubview(notLoggedView)

        NSLayoutConstraint.activate([
            notLoggedView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 0),
            notLoggedView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: 0),
            notLoggedView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 0),
            notLoggedView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: 0)
        ])

        notLoggedView.addSubview(loginButton)

        NSLayoutConstraint.activate([
            loginButton.leadingAnchor.constraint(equalTo: notLoggedView.leadingAnchor, constant: 10),
            loginButton.trailingAnchor.constraint(equalTo: notLoggedView.trailingAnchor, constant: -10),
            loginButton.bottomAnchor.constraint(equalTo: notLoggedView.bottomAnchor, constant: -10)
        ])
    }
    
    // MARK: - IBActions
    
    @objc private func menuButtonTapped(sender: UIButton!) {
        
        switch sender {
        case bookingButton:
            delegate?.buttonTapped(action: Constants.menuActionBookings)
        case accountButton:
            delegate?.buttonTapped(action: Constants.menuActionAccount)
        case logoutButton:
            delegate?.buttonTapped(action: Constants.menuActionLogout)
        case loginButton:
            delegate?.buttonTapped(action: Constants.menuActionLogin)
        default:
            Logger.error("Unknown button.")
            return
        }
    }
}
