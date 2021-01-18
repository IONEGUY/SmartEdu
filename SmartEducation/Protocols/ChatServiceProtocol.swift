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
    
    func getCurretSender() -> SenderType?
    func createListenerForMessages()
    func get(pageIndex: Int, pageSize: Int) -> Single<PagingResult<Message>>
    func remove(_ id: String) -> Single<String>
    func update(_ id: String, newText: String) -> Single<Void>
    func send(messageText: String) -> Single<Message>
}
