//
//  RealmExtensions.swift
//  SmartEducation
//
//  Created by MacBook on 12/24/20.
//

import Foundation
import Realm
import RealmSwift

extension Realm {
    func writeAsync(_ block: @escaping ((Realm) -> Void), _ completion: @escaping () -> Void) {
        DispatchQueue.global(qos: .background).async {
            autoreleasepool {
                do {
                    guard let realm = try? Realm() else { return }

                    try realm.write {
                        block(realm)
                        try realm.commitWrite()
                    }
                    
                    realm.refresh()
                    completion()
                } catch let error {
                    fatalError(error.localizedDescription)
                }
            }
        }
    }
}
