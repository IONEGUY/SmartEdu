//
//  PagingResult.swift
//  SmartEducation
//
//  Created by MacBook on 12/23/20.
//

import Foundation

struct PagingResult<T> {
    var totalResultsCount: Int
    var results: [T]
}
