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
    private var pageSize = 40
    
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
    var messageAdded = PublishSubject<Any?>()
    var messageActions: [ContextMenuItem<Message>]
    
    init(chatService: ChatServiceProtocol,
         credantialsService: CredantialsServiceProtocol) {
        self.chatService = chatService
        self.credantialsService = credantialsService
        
        messageActions = [
            ContextMenuItem<Message>(title: "Edit",
                                     action: toogleEditMode),
            ContextMenuItem<Message>(title: "Remove",
                                     action: removeMessage)
        ]
        
        getMessages()
        initSubscriptions()
        
        currentMessageSender = chatService.getCurretSender()
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
                self.activityIndicatorIsHidden.accept(pagingResult.results.isEmpty)
                self.currentPage += 1
                completion()
            }
            .disposed(by: disposeBag)
    }
    
    private func initSubscriptions() {
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
                    chatService.update(currentUpdatingMessageId, newText: messageText).observeOn(MainScheduler.instance)
                        .subscribe { [unowned self] in
                            let index = self.messages.value.firstIndex {
                                $0.messageId == self.currentUpdatingMessageId } ?? 0
                            var messages = self.messages.value
                            messages[index].kind = .text(messageText)
                            self.messages.accept(messages)
                        }
                        .disposed(by: disposeBag)
                    isEditing = false
                    self.updateMessageInputView.onNext(.empty)
                } else {
                    chatService.send(messageText: messageText)
                        .observeOn(MainScheduler.instance)
                        .subscribe { (message: Message) in
                            var messages = self.messages.value
                            messages.append(message)
                            self.messages.accept(messages)
                            messageAdded.onNext(nil)
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
