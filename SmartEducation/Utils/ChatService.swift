//
//  ChatService.swift
//  SmartEducation
//
//  Created by MacBook on 11/17/20.
//

import Foundation
import RxSwift
import RealmSwift

class ChatService {
    private var repository = Repository()

    func setMessagesChangedObserver(_ block: @escaping () -> Void) {
        repository.setCollectionChangedObserver(MessageDto.self) { block() }
    }
    
    func get(pageIndex: Int, pageSize: Int) -> Single<PagingResult<Message>> {
        return repository.get(MessageDto.self).map { (results) in
            return results?
                .sorted(byKeyPath: "sentDate", ascending: false)
                .paginate(pageIndex: pageIndex, pageSize: pageSize)
                .reversed()
                .map { [unowned self] in self.mapMessageDtoToModel($0) } ?? []
        }.map { [weak self] messages in
            let count = self?.repository.itemsCount(MessageDto.self) ?? 0
            return PagingResult(totalResultsCount: count,
                                results: messages)
        }
    }

    func get() -> Single<[Message]> {
        return repository.get(MessageDto.self).map { (results) in
            return results?
                .sorted(byKeyPath: "sentDate", ascending: false)
                .map { [unowned self] in self.mapMessageDtoToModel($0) } ?? []
        }
    }
    
    func remove(_ id: String) -> Completable {
        let entity = MessageDto()
        entity.id = id
        return repository.delete(item: entity)
    }
    
    func update(_ id: String, newText: String) -> Completable {
        let entity = MessageDto()
        entity.id = id
        return repository.update(item: entity) { oldMessage in
            oldMessage.text = newText
        }
    }

    func send(message: String) -> Single<String> {
        let messageDto = MessageDto()
        messageDto.text = message
        messageDto.senderId = "1"
        return repository.add(item: messageDto).map { _ in message }
    }

    private func mapMessageDtoToModel(_ messageDto: MessageDto) -> Message {
        return Message(sender: MessageSender(senderId: messageDto.senderId,
                                             displayName: .empty),
                       messageId: messageDto.id,
                       sentDate: messageDto.sentDate,
                       kind: .text(messageDto.text))
    }
}
