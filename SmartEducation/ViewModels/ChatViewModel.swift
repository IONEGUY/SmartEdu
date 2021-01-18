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
    
    var isEditing = false
    var isPageRefreshing = false
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
    var unreadMessages = BehaviorRelay<[Message]>(value: [Message]())
    var messageActions: [ContextMenuItem<Message>]
    
    init(chatService: ChatServiceProtocol,
         credantialsService: CredantialsServiceProtocol) {
        self.chatService = chatService
        self.credantialsService = credantialsService
        
        messageActions = [
            ContextMenuItem<Message>(title: "Edit", image: "pencil", action: toogleEditMode),
            ContextMenuItem<Message>(title: "Remove", image: "trash", action: removeMessage)
        ]
        
        getMessages()
        initSubscriptions()
        
        currentMessageSender = chatService.getCurretSender()
        chatService.createListenerForMessages()
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
        Router.popTo(LoginViewController.self)
    }
    
    func getMessages(_ completion: @escaping () -> Void = {}) {
        chatService.get(pageIndex: currentPage, pageSize: pageSize)
            .subscribe { [unowned self] (pagingResult: PagingResult<Message>) in
                var messages = self.messages.value
                messages.insert(contentsOf: pagingResult.results, at: 0)
                self.messages.accept(messages)
                self.currentPage += 1
                self.activityIndicatorIsHidden.accept(true)
                completion()
            }
            .disposed(by: disposeBag)
    }
    
    func removeMessageFromUnreaded(_ messageId: String?) {
        guard let messageId = messageId else { return }
        var unreadMessages = self.unreadMessages.value
        if let index = unreadMessages.firstIndex(where: { $0.messageId == messageId }) {
            unreadMessages.remove(at: index)
            self.unreadMessages.accept(unreadMessages)
        }
    }
    
    private func initSubscriptions() {
        chatService.messagesChanged
            .skip(1)
            .filter { [unowned self] in
                $0.message.sender.senderId != chatService.getCurretSender()?.senderId }
            .subscribe(onNext: { [unowned self] (message: Message, diffType: DiffType) in
                switch diffType {
                case .added:
                    var messages = self.messages.value
                    messages.append(message)
                    self.messages.accept(messages)
                    var unreadMessages = self.unreadMessages.value
                    unreadMessages.append(message)
                    self.unreadMessages.accept(unreadMessages)
                case .modified:
                    var messages = self.messages.value
                    if let index = messages.firstIndex(where: { $0.messageId == message.messageId }) {
                        messages[index].kind = message.kind
                        self.messages.accept(messages)
                    }
                case .removed:
                    var messages = self.messages.value
                    if let index = messages.firstIndex(where: { $0.messageId == message.messageId }) {
                        messages.remove(at: index)
                        self.messages.accept(messages)
                    }
                }
            })
            .disposed(by: disposeBag)
        removeMessage
            .subscribe { [unowned self] (message) in
                self.chatService.remove(message.messageId).subscribe { (id: String) in
                    let index = self.messages.value
                        .firstIndex(where: { (message: Message) in message.messageId == id }) ?? 0
                    var messages = self.messages.value
                    messages.remove(at: index)
                    self.messages.accept(messages)
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
        
        sendButtonPressed
            .subscribe { [unowned self] (messageText: String) in
                if isEditing {
                    chatService.update(currentUpdatingMessageId, newText: messageText)
                        .subscribe(onDisposed:  { [unowned self] in
                            let index = self.messages.value.firstIndex {
                                $0.messageId == self.currentUpdatingMessageId } ?? 0
                            var messages = self.messages.value
                            messages[index].kind = .text(messageText)
                            self.messages.accept(messages)
                        })
                        .disposed(by: disposeBag)
                    isEditing = false
                    self.updateMessageInputView.onNext(.empty)
                } else {
                    chatService.send(messageText: messageText)
                        .subscribe { (message: Message) in
                            var messages = self.messages.value
                            messages.append(message)
                            self.messages.accept(messages)
                            messageSent.onNext(nil)
                    }
                    .disposed(by: disposeBag)
                }
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
