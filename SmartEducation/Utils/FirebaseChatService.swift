//
//  ChatService.swift
//  SmartEducation
//
//  Created by MacBook on 11/17/20.
//

import Foundation
import RxSwift
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class FirebaseChatService: ChatServiceProtocol {
    private let messagesCollectionName = "messages1"
    
    private let firestore = Firestore.firestore()

    var messagesChangedSubject: PublishSubject<(message: MessageDto, diffType: DiffType)> = {
        return PublishSubject<(message: MessageDto, diffType: DiffType)>()
    }()
    
    var unreadMessagesCountSubject: PublishSubject<Int> = {
        return PublishSubject<Int>()
    }()
    
    var messageTypingMembersSubject: PublishSubject<[String]> = {
        return PublishSubject<[String]>()
    }()

    func createListenerForUnreadMessagesCount() {
        firestore.collection("chats").document("chat")
            .addSnapshotListener { [weak self] documentSnapshot, error in
                if let unreadMessagesCount = documentSnapshot?.data()?["unreadMessagesCount"] as? Int {
                    self?.unreadMessagesCountSubject.onNext(unreadMessagesCount)
                }
        }
    }

    func createListenerForMessages() {
        firestore.collection(messagesCollectionName)
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let diff = querySnapshot?.documentChanges.last,
                      let diffType = self?.convertFirebaseDiffTypeToAppDiffType(diff.type),
                      let messageDto = self?.convertSnapshotDataToMessageDto(diff.document)
                else { return }
                self?.messagesChangedSubject.onNext((messageDto, diffType))
        }
    }
    
    func createMessageTypingListener(for userName: String) {
        firestore.collection("chats").document("chat").collection("typingMembers")
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard var typingNames = querySnapshot?.documents.map(\.documentID)
                else { return }
                typingNames.removeAll { $0 == userName}
                self?.messageTypingMembersSubject.onNext(typingNames)
        }
    }
    
    func changeMessageTypingStatus(isTyping: Bool, for userName: String) -> Completable {
        return Completable.create { [weak self] completable in
            let documentRef = self?.firestore.collection("chats")
                .document("chat").collection("typingMembers")
                .document(userName)
            isTyping
                ? documentRef?.setData([String : Any]())
                : documentRef?.delete()
            return Disposables.create()
        }
    }
    
    func updateUnreadMessagesCount(_ value: Int) -> Completable {
        return Completable.create { [unowned self] completable in
            firestore.collection("chats")
                .document("chat").updateData(["unreadMessagesCount": value]) { error in
                    if let error = error {
                        completable(.error(error))
                    } else {
                        completable(.completed)
                    }
            }
            return Disposables.create()
        }
    }
    
    func recoverMessage(_ id: String) -> Completable {
        return changeIsDeletedStatus(id, isDeleted: false)
    }
    
    func get(_ pageIndex: Int, _ pageSize: Int) -> Single<[MessageDto]> {
        return Single.create { [unowned self] single in
            firestore.collection(messagesCollectionName)
                .order(by: "sentDate", descending: true)
                .getDocuments { (snapshot, error) in
                if let error = error {
                    single(.failure(error))
                } else {
                    let dtos = snapshot?.documents
                        .paging(pageIndex: pageIndex, pageSize: pageSize)
                        .map(convertSnapshotDataToMessageDto) ?? []
                    single(.success(dtos))
                }
            }

            return Disposables.create()
        }
    }

    func remove(_ id: String) -> Completable {
        return changeIsDeletedStatus(id, isDeleted: true)
    }

    func update(_ messageDto: MessageDto) -> Completable {
        return Completable.create { [unowned self] completable in
            firestore.collection(messagesCollectionName)
                .document(messageDto.id).updateData(["text": messageDto.text]) { error in
                    if let error = error {
                        completable(.error(error))
                    } else {
                        completable(.completed)
                    }
            }

            return Disposables.create()
        }
    }

    func send(_ messageDto: MessageDto) -> Completable {
        return Completable.create { [unowned self] completable in
            try? firestore.collection(messagesCollectionName)
                .document(messageDto.id).setData(from: messageDto) { error in
                    if let error = error {
                        completable(.error(error))
                    } else {
                        completable(.completed)
                    }
            }

            return Disposables.create()
        }
    }
    
    private func changeIsDeletedStatus(_ id: String, isDeleted: Bool) -> Completable {
        return Completable.create { [unowned self] completable in
            firestore.collection(messagesCollectionName)
                .document(id).updateData(["isDeleted": isDeleted]) { error in
                    if let error = error {
                        completable(.error(error))
                    } else {
                        completable(.completed)
                    }
            }

            return Disposables.create()
        }
    }
    
    private func convertSnapshotDataToMessageDto(_ snapshot: QueryDocumentSnapshot) -> MessageDto {
        guard let dto = try? snapshot.data(as: MessageDto.self) else {
            return MessageDto()
        }
        
        dto.id = snapshot.documentID
        dto.isDeleted = snapshot.data()["isDeleted"] as? Bool ?? false
        return dto
    }
    
    private func convertFirebaseDiffTypeToAppDiffType(_ diff: DocumentChangeType) -> DiffType {
        switch diff {
        case .added: return .added
        case .modified: return .modified
        case .removed: return .removed
        }
    }
}
