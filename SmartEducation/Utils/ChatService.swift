//
//  ChatService.swift
//  SmartEducation
//
//  Created by MacBook on 11/17/20.
//

import Foundation

class ChatService {
    static var messages: [MessageCellModel] = []
    
    func getAllMessages() -> [MessageCellModel] {
        return ChatService.messages
    }
    
    func clearMessages() {
        ChatService.messages = []
    }
    
    func getLastIncomingMsssage() -> MessageCellModel? {
        return ChatService.messages.filter { $0.messageType == MessageType.incoming }.last
    }
    
    func addIncomingMessage(keyMessage: String) -> String {
        var keyWord = String.empty
        StringResources.predefinedMessages.keys.forEach { key in
            if keyMessage.uppercased().contains(key) {
                keyWord = key
            }
        }
        let avatarMessage = StringResources.predefinedMessages[keyWord]
            ?? StringResources.unknownQuestionMessage
        ChatService.messages.append(MessageCellModel(messageType: .incoming,
                                                     text: avatarMessage,
                                                     sentTime: Date()))
        return avatarMessage
    }
    
    func addOutgoingMessage(message: String) {
        ChatService.messages.append(MessageCellModel(messageType: .outgoing,
                                                     text: message,
                                                     sentTime: Date()))
    }
    
    func addGreetingMessageAndSay() {
        if ChatService.messages.isEmpty {
            SpeechSynthesizerService().synthesize(StringResources.greetingMessage)
            ChatService.messages.append(MessageCellModel(messageType: .incoming,
                                                         text: StringResources.greetingMessage,
                                                         sentTime: Date()))
        }
    }
}
