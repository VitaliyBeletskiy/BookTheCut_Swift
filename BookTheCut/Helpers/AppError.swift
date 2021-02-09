//
//  AppError.swift
//  BookTheCut
//
//  Created by Vitaliy on 2020-10-19.
//

import Foundation

enum AppError: Error {
    
    // Authentication procedure errors
    case FirebaseRequestError
    case UserWithPassword
    case UserAlreadyExists
}

extension AppError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .FirebaseRequestError:
            return NSLocalizedString("An error happened while connecting to the server. Try again later.", comment: "Cannot connect to server.")
        case .UserWithPassword:
            return NSLocalizedString("An account with this email already exists. Try to log in with a password.", comment: "Sing In with password.")
        case .UserAlreadyExists:
            return NSLocalizedString("An account with this email already exists. Try another method.", comment: "User already exists.")
        }
    }
    
}
