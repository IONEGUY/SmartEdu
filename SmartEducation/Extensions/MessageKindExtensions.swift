//
//  MessageKindExtensions.swift
//  SmartEducation
//
//  Created by MacBook on 12/30/20.
//

import Foundation
import MessageKit

extension MessageKind {
    func get() -> Any? {
        switch self {
        case .text(let value):
            return value
        default:
            return nil
        }
    }
}
