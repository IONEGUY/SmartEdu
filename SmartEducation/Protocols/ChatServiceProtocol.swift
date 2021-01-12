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
    func getCurretSender() -> SenderType?
    func get(pageIndex: Int, pageSize: Int) -> Single<PagingResult<Message>>
    func remove(_ id: String) -> Single<String>
    func update(_ id: String, newText: String) -> Completable
    func send(messageText: String) -> Single<Message>
}
