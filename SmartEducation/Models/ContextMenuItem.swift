//
//  ContextMenuItem.swift
//  SmartEducation
//
//  Created by MacBook on 12/23/20.
//

import Foundation
import RxSwift

struct ContextMenuItem<T> {
    var title: String
    var image: String
    var action: PublishSubject<T>
}
