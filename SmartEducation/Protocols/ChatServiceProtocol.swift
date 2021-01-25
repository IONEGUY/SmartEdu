//
//  ChatServiceProtocol.swift
//  SmartEducation
//
//  Created by MacBook on 12/24/20.
//

import Foundation
import RxSwift
import RxCocoa
import MessageKit

protocol ChatServiceProtocol {
    var messagesChanged: Observable<(message: Message, diffType: DiffType)> { get }
    var unreadMessagesCount: Observable<Int> { get }
    var messageTypingMembers: Observable<[String]> { get }
    
    func createListenerForUnreadMessagesCount()
    func createListenerForMessages()
    func createMessageTypingListener()
    
    func startMessageTyping() -> Completable
    func endMessageTyping() -> Completable
    func getCurretSender() -> SenderType?
    func getUnreadMessagesCount() -> Single<Int>
    func updateUnreadMessagesCount(_ value: Int) -> Completable
    func get(pageIndex: Int, pageSize: Int) -> Single<PagingResult<Message>>
    func remove(_ id: String) -> Single<String>
    func update(_ id: String, newText: String) -> Single<Void>
    func send(messageText: String) -> Single<Message>
}
