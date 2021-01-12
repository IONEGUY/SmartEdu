//
//  BaseEntity.swift
//  SmartEducation
//
//  Created by MacBook on 12/16/20.
//

import Foundation
import RealmSwift

class BaseEntity: Object {
    @objc dynamic var id = UUID().uuidString
    
    override static func primaryKey() -> String {
        return "id"
    }
}
