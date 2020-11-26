//
//  chatMessageInputViewDelegete.swift
//  SmartEducation
//
//  Created by MacBook on 11/19/20.
//

import Foundation

protocol ChatMessageInputViewDelegate: class {
    func sendMessageButtonPressed(_ message: String)
}
