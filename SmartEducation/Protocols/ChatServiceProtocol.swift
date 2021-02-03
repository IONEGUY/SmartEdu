//
//  ChatServiceProtocol.swift
//  SmartEducation
//
//  Created by MacBook on 12/24/20.
//

import Foundation
import RxSwift

protocol ChatServiceProtocol {
    var messagesChangedSubject: PublishSubject<(message: MessageDto, diffType: DiffType)> { get }
    var unreadMessagesCountSubject: PublishSubject<Int> { get }
    var messageTypingMembersSubject: PublishSubject<[String]> { get }
    
    func createListenerForUnreadMessagesCount()
    func createListenerForMessages()
    func createMessageTypingListener(for userName: String)
    
    func changeMessageTypingStatus(isTyping: Bool, for userName: String) -> Completable
    func updateUnreadMessagesCount(_ value: Int) -> Completable
    func recoverMessage(_ id: String) -> Completable
    
    func get(_ pageIndex: Int, _ pageSize: Int) -> Single<[MessageDto]>
    func remove(_ id: String) -> Completable
    func update(_ messageDto: MessageDto) -> Completable
    func send(_ messageDto: MessageDto) -> Completable
}
