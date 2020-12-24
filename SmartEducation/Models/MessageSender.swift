//
//  MessageSender.swift
//  SmartEducation
//
//  Created by MacBook on 12/14/20.
//

import Foundation
import MessageKit

struct MessageSender: SenderType {
    public let senderId: String
    public let displayName: String
}
