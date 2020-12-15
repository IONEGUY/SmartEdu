//
//  Message.swift
//  SmartEducation
//
//  Created by MacBook on 12/14/20.
//

import Foundation
import MessageKit

struct Message: MessageType {
    var sender: SenderType
    
    var messageId: String
    
    var sentDate: Date
    
    var kind: MessageKind
}
