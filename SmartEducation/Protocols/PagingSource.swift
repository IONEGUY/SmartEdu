//
//  PagingSource.swift
//  SmartEducation
//
//  Created by MacBook on 1/28/21.
//

import Foundation
import RxSwift

protocol PagingSource {
    associatedtype T
    func get(_ pageIndex: Int, _ pageSize: Int, sortBy: String, asc: Bool) -> Single<[T]>
}
