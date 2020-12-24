//
//  ContextMenuItem.swift
//  SmartEducation
//
//  Created by MacBook on 12/23/20.
//

import Foundation

struct ContextMenuItem<T> {
    var title: String
    var action: (T) -> Void
}
