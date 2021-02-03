//
//  ChatManager.swift
//  SmartEducation
//
//  Created by MacBook on 1/25/21.
//

import Foundation
import RxSwift
import RxCocoa
import RealmSwift
import MessageKit

class ChatManager: ChatManagerProtocol {
    private let repository: RepositoryProtocol
    private let credantialsService: CredantialsServiceProtocol
    private let chatService: ChatServiceProtocol
    private let disposeBag = DisposeBag()
    
    private var currentMessageSender: SenderType?
    
    var messageChanged: Observable<(message: Message, diffType: DiffType)>?
    var unreadMessagesCount: Observable<Int>?
    var messageTypingMembers: Observable<[String]>?
    var messages = BehaviorRelay<[Message]>(value: [])
    
    init(repository: RepositoryProtocol,
         credantialsService: CredantialsServiceProtocol,
         chatService: ChatServiceProtocol) {
        self.repository = repository
        self.credantialsService = credantialsService
        self.chatService = chatService
        
        prepare()
    }
    
    private func prepare() {
        messageChanged = chatService.messagesChangedSubject.map(createMessagesChangedItem).asObservable()
        unreadMessagesCount = chatService.unreadMessagesCountSubject.asObservable()
        messageTypingMembers = chatService.messageTypingMembersSubject.asObservable()
        
        chatService.createListenerForMessages()
        chatService.createListenerForUnreadMessagesCount()
        chatService.createMessageTypingListener(for: getCurretSenderName())
        
        messages
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .skip(1)
            .filter { !$0.isEmpty && Connectivity.isConnectedToInternet }
            .map(convertMessageToMessageDtoCollection)
            .flatMap(repository.merge)
            .subscribe()
            .disposed(by: disposeBag)
    }
        
    func getCurretSender() -> SenderType {
        if let currentMessageSender = currentMessageSender {
            return currentMessageSender
        } else {
            guard let senderId = credantialsService.getCurrentUser()?.id else {
                fatalError("failed to retrieve credantials")
            }
            let messageSender = MessageSender(senderId: senderId,
                                              displayName: "User \(senderId)")
            currentMessageSender = messageSender
            return messageSender
        }
    }
    
    func changeMessageTypingStatus(isTyping: Bool) -> Completable {
        return chatService.changeMessageTypingStatus(isTyping: isTyping,
                                                     for: getCurretSenderName())            
    }
    
    func updateUnreadMessagesCount(_ value: Int) -> Completable {
        return chatService.updateUnreadMessagesCount(value)
    }
    
    func recoverMessage(_ id: String) -> Completable {
        return chatService.recoverMessage(id)
    }
    
    func get(pageIndex: Int, pageSize: Int) -> Single<[Message]> {
        return (Connectivity.isConnectedToInternet
            ? chatService.get(pageIndex, pageSize)
            : repository.get(pageIndex, pageSize, sortBy: "sentDate", asc: false))
        .map(convertMessageDtoToModelCollection)
    }
    
    func remove(_ id: String) -> Completable {
        return chatService.remove(id)
    }
    
    func update(_ id: String, _ messageKind: MessageKind) -> Completable {
        let messageDto = MessageDto()
        messageDto.id = id
        messageDto.text = messageKind.get()
        return chatService.update(messageDto)
    }
    
    func send(_ messageKind: MessageKind) -> Completable {
        let messageDto = MessageDto()
        messageDto.text = messageKind.get()
        messageDto.senderId = getCurretSenderId()
        return chatService.send(messageDto)
    }
    
    private func createMessagesChangedItem(_ messagesChangedItem: (MessageDto, DiffType)) -> (Message, DiffType) {
        return (convertMessageDtoToModel(messagesChangedItem.0), messagesChangedItem.1)
    }
    
    private func convertMessageDtoToModel(_ messageDto: MessageDto) -> Message {
        return Message(sender: MessageSender(senderId: messageDto.senderId,
                                             displayName: getCurretSenderName()),
                       messageId: messageDto.id,
                       sentDate: messageDto.sentDate,
                       kind: .text(messageDto.text),
                       isDeleted: messageDto.isDeleted)
    }
    
    private func convertMessageToMessageDto(_ message: Message) -> MessageDto {
        let messageDto = MessageDto()
        messageDto.text = message.kind.get()
        messageDto.id = message.messageId
        messageDto.senderId = message.sender.senderId
        messageDto.sentDate = message.sentDate
        messageDto.isDeleted = message.isDeleted
        return messageDto
    }
    
    private func convertMessageDtoToModelCollection(_ messageDtos: [MessageDto]) -> [Message] {
        return messageDtos.map(convertMessageDtoToModel)
    }
    
    private func convertMessageToMessageDtoCollection(_ messages: [Message]) -> [MessageDto] {
        return messages.map(convertMessageToMessageDto)
    }
    
    private func getCurretSenderId() -> String {
        return getCurretSender().senderId
    }
    
    private func getCurretSenderName() -> String {
        return getCurretSender().displayName
    }
}

extension ObservableType where Element: Sequence, Element.Iterator.Element: Equatable {
    func distinctUntilChanged(_ r: Bool) -> Observable<Element>  {
        return distinctUntilChanged { (lhs, rhs) -> Bool in
            return Array(lhs) == Array(rhs)
        }
    }
}
