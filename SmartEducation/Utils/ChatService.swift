//
//  ChatService.swift
//  SmartEducation
//
//  Created by MacBook on 11/17/20.
//

import Foundation

class ChatService {
    static var messages: [Message] = []
    static var currentUser = MessageSender(senderId: UUID().uuidString)
    static var avatar = MessageSender(senderId: UUID().uuidString)

    func getAllMessages() -> [Message] {
        return ChatService.messages
    }

    func clearMessages() {
        ChatService.messages = []
    }

    func getLastIncomingMsssage() -> Message? {
        return ChatService.messages.filter {
            $0.sender.senderId == ChatService.avatar.senderId }.last
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
        ChatService.messages.append(Message(sender: ChatService.avatar,
                                            messageId: UUID().uuidString,
                                            sentDate: Date(),
                                            kind: .text(avatarMessage)))
        return avatarMessage
    }

    func addOutgoingMessage(message: String) {
        ChatService.messages.append(Message(sender: ChatService.currentUser,
                                            messageId: UUID().uuidString,
                                            sentDate: Date(),
                                            kind: .text(message)))
    }

    func addGreetingMessageAndSay() {
        if ChatService.messages.isEmpty {
            SpeechSynthesizerService().synthesize(StringResources.greetingMessage)
            ChatService.messages.append(Message(sender: ChatService.avatar,
                                                messageId: UUID().uuidString,
                                                sentDate: Date(),
                                                kind: .text(StringResources.greetingMessage)))
        }
    }
}
