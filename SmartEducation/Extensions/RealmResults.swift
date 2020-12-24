//
//  RealmResults.swift
//  SmartEducation
//
//  Created by MacBook on 12/16/20.
//

import Foundation
import RealmSwift

extension Results {
    func paginate(pageIndex: Int, pageSize: Int) -> [ElementType] {
        var slice = [ElementType]()
        let lowerBound = (pageIndex - 1) * pageSize
        var upperBound = lowerBound + pageSize
        
        if lowerBound > self.count - 1 {
            return []
        }
        
        if upperBound > self.count - 1 {
            upperBound = self.count
        }
        
        for index in lowerBound ..< upperBound {
            let item = self[index]
            slice.append(item)
        }

        return slice
    }
}
