//
//  RxExtensions.swift
//  SmartEducation
//
//  Created by MacBook on 2/1/21.
//

import Foundation
import RxSwift
import RxCocoa

extension ObservableType where E: Sequence, E.Iterator.Element: Equatable {
    func distinctUntilChanged() -> Observable<E> {
        return distinctUntilChanged { (lhs, rhs) -> Bool in
            return Array(lhs) == Array(rhs)
        }
    }
}
