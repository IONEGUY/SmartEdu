//
//  ChatManagerProtocol.swift
//  SmartEducation
//
//  Created by MacBook on 1/25/21.
//

import Foundation
import RxSwift
import RxCocoa
import MessageKit

protocol ChatManagerProtocol {
    var messageChanged: Observable<(message: Message, diffType: DiffType)>? { get }
    var unreadMessagesCount: Observable<Int>? { get }
    var messageTypingMembers: Observable<[String]>? { get }
    var messages: BehaviorRelay<[Message]> { get }
    
    func getCurretSender() -> SenderType
    func changeMessageTypingStatus(isTyping: Bool) -> Completable
    func updateUnreadMessagesCount(_ value: Int) -> Completable
    func recoverMessage(_ id: String) -> Completable
    
    func get(pageIndex: Int, pageSize: Int) -> Single<[Message]>
    func remove(_ id: String) -> Completable
    func update(_ id: String, _ messageKind: MessageKind) -> Completable
    func send(_ messageKind: MessageKind) -> Completable
}
