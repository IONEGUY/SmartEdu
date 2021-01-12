//
//  ChatService.swift
//  SmartEducation
//
//  Created by MacBook on 11/17/20.
//

import Foundation
import RxSwift
import RxCocoa
import RealmSwift
import MessageKit
import Alamofire
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class ChatService: ChatServiceProtocol {
    private let repository: RepositoryProtocol
    private let credantialsService: CredantialsServiceProtocol
    private let firestore = Firestore.firestore()
    
    private var currentMessageSender: SenderType?
    
    init(repository: RepositoryProtocol,
         credantialsService: CredantialsServiceProtocol) {
        self.repository = repository
        self.credantialsService = credantialsService
    }
    
    func getCurretSender() -> SenderType? {
        guard let appUser = credantialsService.getCurrentUser() else {
            fatalError("failed to retrieve current app user")
        }
        currentMessageSender = currentMessageSender ?? MessageSender(senderId: appUser.id)
        return currentMessageSender
    }

    func get(pageIndex: Int, pageSize: Int) -> Single<PagingResult<Message>> {
        return Single.create { single in
            self.firestore.collection("messages")
                .order(by: "sentDate", descending: true)
                .getDocuments { (snapshot, error) in
                if let error = error {
                    single(.failure(error))
                } else {
                    guard let documents = snapshot?.documents else { return }
                    var messages = [Message]()
                    for document in documents {
                        guard let messageDto = try? document.data(as: MessageDto.self) else { continue }
                        messages.append(Message(sender: MessageSender(senderId: messageDto.senderId),
                                                messageId: messageDto.id,
                                                sentDate: messageDto.sentDate,
                                                kind: .text(messageDto.text)))

                    }
                    
                    let pagingResult = PagingResult(totalResultsCount: documents.count,
                                                    results: messages)
                    single(.success(pagingResult))
                }
            }
            
            return Disposables.create()
        }
        
//        return repository.get(MessageDto.self).map { (results) in
//            return results?
//                .sorted(byKeyPath: "sentDate", ascending: false)
//                .paginate(pageIndex: pageIndex, pageSize: pageSize)
//                .reversed()
//                .map { [unowned self] in self.mapMessageDtoToModel($0) } ?? []
//        }.map { [weak self] messages in
//            let count = self?.repository.itemsCount(MessageDto.self) ?? 0
//            return PagingResult(totalResultsCount: count,
//                                results: messages)
//        }
    }
    
    func remove(_ id: String) -> Single<String> {
        let entity = MessageDto()
        entity.id = id
        return Single.create { [weak self] single in
            self?.firestore.collection("messages")
                .document(id).delete() { error in
                    if let error = error {
                        single(.failure(error))
                    } else {
                        single(.success(.empty))
                    }
                }
            
            return Disposables.create()
        }
        //return repository.delete(item: entity)
    }
    
    func update(_ id: String, newText: String) -> Single<Void> {
        let entity = MessageDto()
        entity.id = id
        return Single.create { [weak self] single in
            self?.firestore.collection("messages")
                .document(id).updateData(["text" : newText]) { error in
                    if let error = error {
                        single(.failure(error))
                    } else {
                        single(.success(Void()))
                    }
            }
            
            return Disposables.create()
        }
//        return repository.update(item: entity) { oldMessage in
//            oldMessage.text = newText
//        }
    }

    func send(messageText: String) -> Single<Message> {
        guard let sender = currentMessageSender else { fatalError() }
        
        let message = Message(sender: sender, kind: .text(messageText))
        
        let messageDto = MessageDto()
        messageDto.text = messageText
        messageDto.senderId = sender.senderId
        
        return Single.create { [weak self] single in
            try? self?.firestore.collection("messages")
                .document(messageDto.id).setData(from: messageDto) { error in
                    if let error = error {
                        single(.failure(error))
                    } else {
                        single(.success(message))
                    }
            }
            
            return Disposables.create()
        }
//        return repository.add(item: messageDto).asObservable().map { (never) in
//            return message
//        }.asSingle()
    }

    private func mapMessageDtoToModel(_ messageDto: MessageDto) -> Message {
        return Message(sender: MessageSender(senderId: messageDto.senderId),
                       messageId: messageDto.id,
                       sentDate: messageDto.sentDate,
                       kind: .text(messageDto.text))
    }
}
