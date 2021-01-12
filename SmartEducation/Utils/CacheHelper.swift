//
//  CacheHelper.swift
//  SmartEducation
//
//  Created by MacBook on 1/9/21.
//

import Foundation

class CacheHelper {
    class func setValue<T: Codable>(forKey key: String, value: T) -> Bool {
        var success = false
        if let encoded = try? JSONEncoder().encode(value) {
            UserDefaults.standard.set(encoded, forKey: key)
            success = true
        }
        
        return success
    }
    
    class func getValue<T: Codable>(forKey key: String) -> T? {
        guard let data = UserDefaults.standard.object(forKey: key) as? Data,
              let model = try? JSONDecoder().decode(T.self, from: data) else {
            return nil
        }
        
        return model
    }
    
    class func removeValue(forKey key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
