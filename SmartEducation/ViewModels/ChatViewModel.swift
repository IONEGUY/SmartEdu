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
    private let chatService: ChatServiceProtocol
    private let credantialsService: CredantialsServiceProtocol
    private let disposeBag = DisposeBag()
    private var currentUpdatingMessageId: String = .empty
    private var loadMoreEnabled = true
    private var currentPage = 1
    private var pageSize = 20
    
    var lastReadMessageId: String?
    var isEditing = false
    var isPageRefreshing = false
    var unreadMessagesIds = Set<String>()
    var isMessageTyping = false
    var currentMessageSender: SenderType?
    var messages = BehaviorRelay<[Message]>(value: [Message]())
    var activityIndicatorIsHidden = BehaviorRelay<Bool>(value: true)
    var isMessageEditingModeEnabled = BehaviorRelay<Bool>(value: false)
    var toogleEditMode = PublishSubject<Message>()
    var removeMessage = PublishSubject<Message>()
    var updateMessageInputView = PublishSubject<String>()
    var sendButtonPressed = PublishSubject<String>()
    var loadMore = PublishSubject<Any?>()
    var updateMessageCollectionAfterloadMore = PublishSubject<Int>()
    var messageSent = PublishSubject<Any?>()
    var unreadMessagesCount = BehaviorRelay<Int>(value: 0)
    var messageActions: [ContextMenuItem<Message>]
    var setFocusOnMessageAtIndex = PublishRelay<Int>()
    var decreaseUnreadMessagesCount = PublishSubject<String>()
    var correctUnreadMessagesCount = PublishSubject<String?>()
    var typingIndicatorHidden = BehaviorRelay<Bool>(value: true)
    var typingName = PublishRelay<String>()
    var messageText = PublishSubject<String?>()
    
    init(chatService: ChatServiceProtocol,
         credantialsService: CredantialsServiceProtocol) {
        self.chatService = chatService
        self.credantialsService = credantialsService
        
        messageActions = [
            ContextMenuItem<Message>(title: "Edit", image: "pencil", action: toogleEditMode),
            ContextMenuItem<Message>(title: "Remove", image: "trash", action: removeMessage)
        ]
        
        initSubscriptions()
        
        currentMessageSender = chatService.getCurretSender()
        chatService.createListenerForMessages()
        chatService.createListenerForUnreadMessagesCount()
        chatService.createMessageTypingListener()
    }
    
    func createContextMenu(for index: Int) -> UIContextMenuConfiguration? {
        if messages.value[index].sender.senderId != chatService.getCurretSender()?.senderId { return nil }
        return UIContextMenuConfiguration(identifier: nil,
                                          previewProvider: nil,
                                          actionProvider: { [unowned self] _ in
            var actions = messageActions.map { item in
                UIAction(title: item.title,
                         image: UIImage(systemName: item.image),
                         identifier: nil,
                         discoverabilityTitle: nil) { _ in
                    item.action.onNext(messages.value[index])
                }
            }
            let cancel = UIAction(title: "Cancel", attributes: .destructive) { _ in}
            actions.append(cancel)
            return UIMenu(title: "", children: actions)
        })
    }
    
    func logOut() {
        credantialsService.removeCurrentUser()
        Router.changeRootVC(LoginViewController.self)
    }
    
    func getMessages(_ take: Int? = nil, _ completion: @escaping () -> Void = {}) {
        chatService.get(pageIndex: currentPage, pageSize: take ?? pageSize)
            .subscribe { [unowned self] (pagingResult: PagingResult<Message>) in
                var messages = self.messages.value
                messages.insert(contentsOf: pagingResult.results, at: 0)
                setAvatarVisibilityForEachMessage(messages)
                self.activityIndicatorIsHidden.accept(true)
                completion()
            }
            .disposed(by: disposeBag)
    }

    func increaseUnreadMessagesCount() {
        unreadMessagesCount.accept(unreadMessagesCount.value + 1)
    }
    
    func isLastMessageFromCurrentSender() -> Bool {
        return messages.value.last?.sender.senderId == chatService.getCurretSender()?.senderId
    }
    
    func endMesageTyping() {
        chatService.endMessageTyping()
            .subscribe().disposed(by: disposeBag)
    }
    
    private func setAvatarVisibilityForEachMessage(_ messages: [Message]) {
        var messages = messages
        if messages.count == 0 { return }
        for index in 0...messages.count - 1 {
            if index >= 1 &&
                messages[index - 1].sender.senderId == messages[index].sender.senderId {
                messages[index].avatarHidden = true
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
        if let index = messages.value.firstIndex(where: { $0.messageId == messageId }) {
            action(index)
        }
    }
    
    private func initSubscriptions() {
        messageText
            .filter { [unowned self] _ in !isEditing && !isMessageTyping }
            .map { [unowned self] _ in isMessageTyping = true }
            .flatMap(chatService.startMessageTyping)
            .subscribe()
            .disposed(by: disposeBag)
        
        messageText
            .filter { [unowned self] _ in !isEditing && isMessageTyping }
            .map { [unowned self] _ in isMessageTyping = false }
            .debounce(.seconds(5),
                      scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
            .flatMap(chatService.endMessageTyping)
            .subscribe()
            .disposed(by: disposeBag)
        
        chatService.messageTypingMembers
            .share()
            .map { "\($0.joined(separator: ",")) is typing..." }
            .bind(to: typingName)
            .disposed(by: disposeBag)
        
        chatService.messageTypingMembers
            .share()
            .map { $0.isEmpty }
            .bind(to: typingIndicatorHidden)
            .disposed(by: disposeBag)
        
        decreaseUnreadMessagesCount
            .filter { [unowned self] (messageId: String) in
                unreadMessagesIds.contains(messageId)
            }
            .subscribe { [unowned self] (messageId: String) in
                unreadMessagesIds.remove(messageId)
                unreadMessagesCount.accept(unreadMessagesCount.value - 1)
            }
            .disposed(by: disposeBag)
        
        correctUnreadMessagesCount
            .subscribe { [unowned self] (messageId: String?) in
                guard let messageIndex = messages.value.firstIndex(where: { $0.messageId == messageId })
                else { return }
                
                let actualUnreadMessagesCount = messages.value.count - messageIndex - 1
                if actualUnreadMessagesCount < unreadMessagesCount.value {
                    unreadMessagesCount.accept(actualUnreadMessagesCount)
                }
            }
            .disposed(by: disposeBag)

        chatService.unreadMessagesCount
            .skip(1)
            .distinctUntilChanged()
            .filter { [unowned self] _ in
                messages.value.last?.sender.senderId == chatService.getCurretSender()?.senderId }
            .subscribe { [unowned self] in setReadStatusToMessages($0) }
            .disposed(by: disposeBag)
        
        chatService.unreadMessagesCount
            .skip(1)
            .filter { [unowned self] _ in !isLastMessageFromCurrentSender() }
            .subscribe { [unowned self] in unreadMessagesCount.accept($0) }
            .disposed(by: disposeBag)
        
        unreadMessagesCount
            .subscribe { [unowned self] value in
                unreadMessagesIds = Set(messages.value.suffix(value).map { $0.messageId })
            }
            .disposed(by: disposeBag)
        
        unreadMessagesCount
            .skip(1)
            .filter { [unowned self] _ in !isLastMessageFromCurrentSender() }
            .throttle(.seconds(1),
                      scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
            .flatMap(chatService.updateUnreadMessagesCount)
            .subscribe()
            .disposed(by: disposeBag)
        
        chatService.getUnreadMessagesCount()
            .subscribe { [unowned self] (value: Int) in
                getMessages(value > pageSize ? value : pageSize) {
                    var index = messages.value.count - 1
                    if !isLastMessageFromCurrentSender() { index -= value }

                    unreadMessagesCount.accept(value)
                    setReadStatusToMessages(value)
                    setFocusOnMessageAtIndex.accept(index)
                }
            }
            .disposed(by: disposeBag)
        
        chatService.messagesChanged
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
                        chatService.updateUnreadMessagesCount(unreadMessagesCount.value)
                            .subscribe().disposed(by: disposeBag)
                    }
                case .modified:
                    findMessageIndexAndExecute(message.messageId) {
                        messages[$0].kind = message.kind
                    }
                    self.messages.accept(messages)
                case .removed:
                    findMessageIndexAndExecute(message.messageId) {
                        messages.remove(at: $0)
                    }
                    self.messages.accept(messages)
                }
                setAvatarVisibilityForEachMessage(messages)
            }
            .disposed(by: disposeBag)
        
        sendButtonPressed
            .subscribe { [unowned self] (messageText: String) in
                if isEditing {
                    chatService.update(currentUpdatingMessageId, newText: messageText)
                        .subscribe().disposed(by: disposeBag)
                    isEditing = false
                    self.updateMessageInputView.onNext(.empty)
                } else {
                    chatService.send(messageText: messageText)
                        .subscribe().disposed(by: disposeBag)
                }
            }
            .disposed(by: disposeBag)
        
        removeMessage
            .subscribe { [unowned self] (message) in
                self.chatService.remove(message.messageId).subscribe { (id: String) in
                    let index = self.messages.value
                        .firstIndex(where: { (message: Message) in message.messageId == id }) ?? 0
                    var messages = self.messages.value
                    messages.remove(at: index)
                    setAvatarVisibilityForEachMessage(messages)
                }
                .disposed(by: disposeBag)
            }
            .disposed(by: disposeBag)
        
        toogleEditMode
            .subscribe { [unowned self] (message: Message) in
                isEditing = true
                self.currentUpdatingMessageId = message.messageId
                let text = message.kind.get() as? String ?? .empty
                self.updateMessageInputView.onNext(text)
            }
            .disposed(by: disposeBag)
        
        loadMore
            .subscribe(onNext: { [unowned self] _ in
                if !self.isPageRefreshing && loadMoreEnabled {
                    self.isPageRefreshing = true
                    let oldMessagesCount = self.messages.value.count
                    self.activityIndicatorIsHidden.accept(false)
                    self.getMessages {
                        self.isPageRefreshing = false
                        let offset = self.messages.value.count - oldMessagesCount
                        self.loadMoreEnabled = offset != 0
                        self.updateMessageCollectionAfterloadMore.onNext(offset)
                    }
                }
            })
            .disposed(by: disposeBag)
    }
}
