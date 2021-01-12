//
//  UserSettings.swift
//  SmartEducation
//
//  Created by MacBook on 1/9/21.
//

import Foundation
import RxSwift

class CredantialsService: CredantialsServiceProtocol {
    private let allowedIds = ["1", "2"]
    
    private let repository: RepositoryProtocol
    
    init(repository: RepositoryProtocol) {
        self.repository = repository
    }
    
    func setCurrentUser(withId id: String) -> Bool {
        if !allowedIds.contains(id) { return false }
        let appUser = AppUser(id: id)
        return CacheHelper.setValue(forKey: "app_user", value: appUser)
    }
    
    func getCurrentUser() -> AppUser? {
        return CacheHelper.getValue(forKey: "app_user")
    }
    
    func removeCurrentUser() {
        CacheHelper.removeValue(forKey: "app_user")
    }
    
    func isUserLoggedIn() -> Bool {
        return getCurrentUser() != nil
    }
}
