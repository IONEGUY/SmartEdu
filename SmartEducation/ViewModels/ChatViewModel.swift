//
//  ChatViewModel.swift
//  SmartEducation
//
//  Created by MacBook on 11/17/20.
//

import Foundation
import RxSwift
import RxCocoa
import MessageKit

class ChatViewModel {
    private let chatManager: ChatManagerProtocol
    private let credantialsService: CredantialsServiceProtocol
    private let disposeBag = DisposeBag()
    private var currentUpdatingMessageId: String = .empty
    private var loadMoreEnabled = true
    private var pageIndex = 0
    private var pageSize = 20
    
    var isPageRefreshing = false
    var unreadMessagesIds = Set<String>()
    var isMessageTyping = false
    var currentMessageSender: SenderType?
    var messages = BehaviorRelay<[Message]>(value: [Message]())
    var activityIndicatorIsHidden = BehaviorRelay<Bool>(value: true)
    var isMessageEditingModeEnabled = BehaviorRelay<Bool>(value: false)
    var toogleEditMode = PublishSubject<Message>()
    var removeMessage = PublishSubject<Message>()
    var recoverMessage = PublishSubject<Message>()
    var updateMessageInputView = PublishSubject<String>()
    var sendButtonPressed = PublishSubject<MessageKind>()
    var loadMore = PublishSubject<Any?>()
    var updateMessageCollectionAfterloadMore = PublishSubject<Int>()
    var messageSent = PublishSubject<Any?>()
    var unreadMessagesCount = BehaviorRelay<Int>(value: 0)
    var setFocusOnMessageAtIndex = PublishRelay<Int>()
    var decreaseUnreadMessagesCount = PublishSubject<String>()
    var correctUnreadMessagesCount = PublishSubject<String>()
    var typingIndicatorHidden = BehaviorRelay<Bool>(value: true)
    var typingName = PublishRelay<String>()
    var messageText = PublishSubject<String?>()
    
    init(chatManager: ChatManagerProtocol,
         credantialsService: CredantialsServiceProtocol) {
        self.chatManager = chatManager
        self.credantialsService = credantialsService

        initSubscriptions()
        
        currentMessageSender = chatManager.getCurretSender()
    }
    
    func createContextMenu(for index: Int) -> UIContextMenuConfiguration? {
        if !isMessageFromCurrentSender(index) { return nil }
        return UIContextMenuConfiguration(identifier: nil,
                                          previewProvider: nil,
                                          actionProvider: { [unowned self] _ in
            var actions = createActionsForMessage(index: index).map { item in
                UIAction(title: item.title,
                         image: UIImage(systemName: item.image),
                         identifier: nil,
                         discoverabilityTitle: nil) { _ in
                    item.action.onNext(messages.value[index])
                }
            }
            actions.append(UIAction(title: "Cancel", attributes: .destructive) {_ in})
            return UIMenu(title: .empty, children: actions)
        })
    }
    
    func logOut() {
        credantialsService.removeCurrentUser()
        Router.changeRootVC(LoginViewController.self)
    }
    
    func getMessages(_ pageIndex: Int, _ pageSize: Int) -> Completable {
        return chatManager.get(pageIndex: pageIndex, pageSize: pageSize)
            .do(onSuccess: { [unowned self] _ in activityIndicatorIsHidden.accept(true) })
            .map { $0.reversed() }
            .map { [unowned self] in
                var messages = self.messages.value
                messages.insert(contentsOf: $0, at: 0)
                setAvatarVisibilityForEachMessage(messages)
            }.asCompletable()
    }

    func increaseUnreadMessagesCount() {
        unreadMessagesCount.accept(unreadMessagesCount.value + 1)
    }
    
    func isLastMessageFromCurrentSender() -> Bool {
        return messages.value.last?.sender.senderId == chatManager.getCurretSender().senderId
    }
    
    func isMessageFromCurrentSender(_ index: Int) -> Bool {
        messages.value[index].sender.senderId == currentMessageSender?.senderId
    }
    
    func endMesageTyping() {
        chatManager.changeMessageTypingStatus(isTyping: false)
            .subscribe().disposed(by: disposeBag)
    }
    
    private func createActionsForMessage(index: Int) -> [ContextMenuItem<Message>] {
        return messages.value[index].isDeleted
        ? [ContextMenuItem<Message>(title: "Recover", image: "arrow.clockwise",
                                    action: recoverMessage)]
        : [ContextMenuItem<Message>(title: "Edit", image: "pencil",
                                        action: toogleEditMode),
           ContextMenuItem<Message>(title: "Remove", image: "trash",
                                        action: removeMessage)]
    }
    
    private func setAvatarVisibilityForEachMessage(_ messages: [Message]) {
        var messages = messages
        if messages.count == 0 { return }
        for index in 0...messages.count - 1 {
            if index >= 1 &&
                messages[index - 1].sender.senderId == messages[index].sender.senderId {
                messages[index].avatarHidden = true
            }
            
            if messages[index].isDeleted {
                messages[index].kind = .text("message deleted")
            }
        }
        self.messages.accept(messages)
    }
    
    private func setReadStatusToMessages(_ unreadMessagesCount: Int) {
        self.unreadMessagesCount.accept(unreadMessagesCount)
        var messages = self.messages.value
        if messages.count == 0 { return }
        for index in 0...messages.count - 1 {
            messages[index].isRead = index < messages.count - unreadMessagesCount
        }

        self.messages.accept(messages)
    }
    
    private func findMessageIndexAndExecute(_ messageId: String, action: (Int) -> Void) {
        action(findMessageIndex(messageId))
    }
    
    private func findMessageIndex(_ messageId: String) -> Int {
        if let index = messages.value.firstIndex(where: { $0.messageId == messageId }) {
            return index
        }
        
        return 0
    }
    
    private func initSubscriptions() {
        messages
            .skip(1)
            .bind(to: chatManager.messages)
            .disposed(by: disposeBag)
        
        messageText
            .filter { [unowned self] _ in
                !isMessageEditingModeEnabled.value == true && !isMessageTyping }
            .map { [unowned self] _ in isMessageTyping = true }
            .map { true }
            .flatMap(chatManager.changeMessageTypingStatus)
            .subscribe()
            .disposed(by: disposeBag)
        
        messageText
            .filter { [unowned self] _ in
                !isMessageEditingModeEnabled.value && isMessageTyping }
            .map { [unowned self] _ in isMessageTyping = false }
            .debounce(.seconds(5),
                      scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
            .map { false }
            .flatMap(chatManager.changeMessageTypingStatus)
            .subscribe()
            .disposed(by: disposeBag)
        
        chatManager.messageTypingMembers?
            .share()
            .map { "\($0.joined(separator: ",")) is typing..." }
            .bind(to: typingName)
            .disposed(by: disposeBag)
        
        chatManager.messageTypingMembers?
            .share()
            .map { $0.isEmpty }
            .bind(to: typingIndicatorHidden)
            .disposed(by: disposeBag)
        
        decreaseUnreadMessagesCount
            .filter { [unowned self] in unreadMessagesIds.contains($0) }
            .do(onNext: { [unowned self] in unreadMessagesIds.remove($0) })
            .map { [unowned self] _ in unreadMessagesCount.value - 1 }
            .bind(to: unreadMessagesCount)
            .disposed(by: disposeBag)
        
        correctUnreadMessagesCount
            .map { [unowned self] in messages.value.count - findMessageIndex($0) - 1 }
            .filter { [unowned self] in $0 < unreadMessagesCount.value }
            .bind(to: unreadMessagesCount)
            .disposed(by: disposeBag)
        
        chatManager.unreadMessagesCount?
            .take(1)
            .do(afterNext: { [unowned self] _ in pageIndex += 1 })
            .subscribe { [unowned self] (value: Int) in
                let pageSize = value > self.pageSize ? value : self.pageSize
                getMessages(pageIndex, pageSize)
                    .subscribe { [unowned self] _ in
                        var index = messages.value.count - 1
                        if !isLastMessageFromCurrentSender() { index -= value }

                        setReadStatusToMessages(value)
                        setFocusOnMessageAtIndex.accept(index)
                    }
                    .disposed(by: disposeBag)
            }
            .disposed(by: disposeBag)

        chatManager.unreadMessagesCount?
            .filter { [unowned self] _ in isLastMessageFromCurrentSender() }
            .subscribe { [unowned self] in setReadStatusToMessages($0) }
            .disposed(by: disposeBag)
        
        chatManager.unreadMessagesCount?
            .filter { [unowned self] _ in !isLastMessageFromCurrentSender() }
            .bind(to: unreadMessagesCount)
            .disposed(by: disposeBag)
        
        unreadMessagesCount
            .map { $0 < 0 ? 0 : $0 }
            .subscribe { [unowned self] in
                unreadMessagesIds = Set(messages.value.suffix($0).map(\.messageId))
            }
            .disposed(by: disposeBag)
        
        unreadMessagesCount
            .skip(1)
            .filter { [unowned self] in !isLastMessageFromCurrentSender() && $0 >= 0 }
            .throttle(.seconds(1),
                      scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
            .flatMap(chatManager.updateUnreadMessagesCount)
            .subscribe()
            .disposed(by: disposeBag)
        
        chatManager.messageChanged?
            .skip(1)
            .subscribe { [unowned self] (message: Message, diffType: DiffType) in
                var messages = self.messages.value
                switch diffType {
                case .added:
                    messages.append(message)
                    self.messages.accept(messages)
                    
                    if isLastMessageFromCurrentSender() {
                        let lastMessageIndex = messages.count - 1
                        setFocusOnMessageAtIndex.accept(lastMessageIndex)
                        
                        increaseUnreadMessagesCount()
                        chatManager.updateUnreadMessagesCount(unreadMessagesCount.value)
                            .subscribe().disposed(by: disposeBag)
                    }
                case .modified:
                    findMessageIndexAndExecute(message.messageId) {
                        messages[$0] = message
                    }
                    self.messages.accept(messages)
                case .removed:
                    break
                }
                setAvatarVisibilityForEachMessage(messages)
            }
            .disposed(by: disposeBag)
        
        sendButtonPressed
            .subscribe { [unowned self] (messageKind: MessageKind) in
                if isMessageEditingModeEnabled.value == true {
                    chatManager.update(currentUpdatingMessageId, messageKind)
                        .subscribe().disposed(by: disposeBag)
                    updateMessageInputView.onNext(.empty)
                    isMessageEditingModeEnabled.accept(false)
                } else {
                    chatManager.send(messageKind)
                        .subscribe().disposed(by: disposeBag)
                }
            }
            .disposed(by: disposeBag)
        
        removeMessage
            .map(\.messageId)
            .flatMap(chatManager.remove)
            .subscribe()
            .disposed(by: disposeBag)
        
        toogleEditMode
            .do(onNext: { [unowned self] in
                isMessageEditingModeEnabled.accept(true)
                currentUpdatingMessageId = $0.messageId
            })
            .map { $0.kind.get() }
            .bind(to: updateMessageInputView)
            .disposed(by: disposeBag)
        
        recoverMessage
            .map(\.messageId)
            .flatMap(chatManager.recoverMessage)
            .subscribe()
            .disposed(by: disposeBag)
        
        loadMore
            .filter { [unowned self] _ in !isPageRefreshing }
            .do(onNext: { [unowned self] _ in
                activityIndicatorIsHidden.accept(false)
                isPageRefreshing = true })
            .map { [unowned self] _ in messages.value.count }
            .subscribe { [unowned self] (oldMessagesCount: Int) in
                getMessages(pageIndex, pageSize)
                    .subscribe { [unowned self] _ in
                        let offset = messages.value.count - oldMessagesCount
                        isPageRefreshing = false
                        if offset != 0 {
                            pageIndex += 1
                            updateMessageCollectionAfterloadMore.onNext(offset)
                        }
                    }
                    .disposed(by: disposeBag)
            }
            .disposed(by: disposeBag)
    }
}
