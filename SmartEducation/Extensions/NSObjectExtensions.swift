//
//  NSObjectExtensions.swift
//  SmartEducation
//
//  Created by MacBook on 11/3/20.
//

import UIKit

extension NSObject {
    static var typeName: String {
        return String(describing: self)
    }
}
