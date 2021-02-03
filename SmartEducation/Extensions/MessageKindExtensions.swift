//
//  MessageKindExtensions.swift
//  SmartEducation
//
//  Created by MacBook on 12/30/20.
//

import Foundation
import MessageKit

extension MessageKind {
    func get<T>() -> T {
        var value: T?
        switch self {
        case .text(let val):
            value = val as? T
        case .attributedText(let val):
            value = val as? T
        default:
            fatalError("unexpected message kind")
        }
        
        guard let messageKindValue = value else {
            fatalError("failed to convert message kind value to generic type")
        }
        
        return messageKindValue
    }
}
