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
    private var lastDocumentSnapshot: DocumentSnapshot?
    
    private var currentMessageSender: SenderType?
    private let messagesChangedSubject = PublishSubject<(message: Message, diffType: DiffType)>()
    
    var messagesChanged: Observable<(message: Message, diffType: DiffType)> {
        return messagesChangedSubject.asObservable()
    }
    
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
    
    func createListenerForMessages() {
        firestore.collection("messages").addSnapshotListener { [unowned self] querySnapshot, error in
            guard let snapshot = querySnapshot else {
                if let error = error { messagesChangedSubject.onError(error) }
                return
            }
            
            guard let diff = snapshot.documentChanges.last,
                  let messageDto = try? diff.document.data(as: MessageDto.self) else { return }
            let message = Message(sender: MessageSender(senderId: messageDto.senderId),
                                  messageId: diff.document.documentID,
                                  sentDate: messageDto.sentDate,
                                  kind: .text(messageDto.text))
            var diffType: DiffType
            switch diff.type {
                case .added: diffType = DiffType.added
                case .modified: diffType = DiffType.modified
                case .removed: diffType = DiffType.removed
            }
            messagesChangedSubject.onNext((message, diffType))
        }
    }

    func get(pageIndex: Int, pageSize: Int) -> Single<PagingResult<Message>> {
        return Single.create { [unowned self] single in
            let collection = self.firestore.collection("messages")
            var query: Query

            if let lastDocumentSnapshot = lastDocumentSnapshot {
                query = collection
                    .order(by: "sentDate", descending: true)
                    .limit(to: pageSize)
                    .start(afterDocument: lastDocumentSnapshot)
            } else {
                query = collection
                    .order(by: "sentDate", descending: true)
                    .limit(to: pageSize)
            }
            
            query.getDocuments { (snapshot, error) in
                if let error = error {
                    single(.failure(error))
                } else {
                    guard let documents = snapshot?.documents else { return }
                    var messages = [Message]()
                    for document in documents {
                        guard let messageDto = try? document.data(as: MessageDto.self) else { continue }
                        messages.append(Message(sender: MessageSender(senderId: messageDto.senderId),
                                                messageId: document.documentID,
                                                sentDate: messageDto.sentDate,
                                                kind: .text(messageDto.text)))

                    }
                    
                    let pagingResult = PagingResult(totalResultsCount: documents.count,
                                                    results: messages.reversed())
                    self.lastDocumentSnapshot = documents.last
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
        return Single.create { [weak self] single in
            self?.firestore.collection("messages")
                .document(id).delete { error in
                    if let error = error {
                        single(.failure(error))
                    } else {
                        single(.success(id))
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
                .document(message.messageId).setData(from: messageDto) { error in
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
