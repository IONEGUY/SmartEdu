//
//  MessageDto.swift
//  SmartEducation
//
//  Created by MacBook on 12/16/20.
//

import Foundation
import MessageKit

class MessageDto: BaseEntity {
    @objc dynamic var text: String = .empty
    @objc dynamic var sentDate = Date()
    @objc dynamic var senderId: String = .empty
}
