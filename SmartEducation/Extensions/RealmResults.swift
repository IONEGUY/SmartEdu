//
//  RealmResults.swift
//  SmartEducation
//
//  Created by MacBook on 12/16/20.
//

import Foundation
import RealmSwift

extension Results {
    func paging(pageIndex: Int, pageSize: Int) -> [Element] {
        var slice = [Element]()
        let lowerBound = (pageIndex) * pageSize
        var upperBound = lowerBound + pageSize
        
        if lowerBound > count - 1 {
            return []
        }
        
        if upperBound > count - 1 {
            upperBound = count
        }
        
        for index in lowerBound ..< upperBound {
            let item = self[index]
            slice.append(item)
        }

        return slice
    }
}

extension Array {
    func paging(pageIndex: Int, pageSize: Int) -> [Element] {
        var slice = [Element]()
        let lowerBound = (pageIndex) * pageSize
        var upperBound = lowerBound + pageSize
        
        if lowerBound > count - 1 {
            return []
        }
        
        if upperBound > count - 1 {
            upperBound = count
        }
        
        for index in lowerBound ..< upperBound {
            let item = self[index]
            slice.append(item)
        }

        return slice
    }
}
