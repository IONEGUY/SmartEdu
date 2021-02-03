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
    var messageId = UUID().uuidString
    var sentDate = Date()
    var kind: MessageKind
    var avatarHidden = false
    var isRead = false
    var isDeleted = false
    
    static var empty: Message {
        return Message(sender: MessageSender(senderId: .empty,
                                             displayName: .empty),
                       kind: .text(.empty))
    }
}
