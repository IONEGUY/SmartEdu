//
//  CredantialsServiceProtocol.swift
//  SmartEducation
//
//  Created by MacBook on 1/9/21.
//

import Foundation

protocol CredantialsServiceProtocol {
    func setCurrentUser(withId id: String) -> Bool
    
    func getCurrentUser() -> AppUser?
    
    func removeCurrentUser()
    
    func isUserLoggedIn() -> Bool
}
