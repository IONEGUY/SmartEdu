//
//  ChatViewController.swift
//  SmartEducation
//
//  Created by MacBook on 11/17/20.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import RxSwift
import SnapKit

class ChatViewController: MessagesViewController, MVVMViewController {
    typealias ViewModelType = ChatViewModel

    private var activityIndicatorView: ActivityIndicatorView?
    private var chatService = ChatService()
    private var disposeBag = DisposeBag()
    private var contextMenuItems = [ContextMenuItem<Message>]()
    private var isPageRefreshing = false
    private var currentPage = 1
    private var pageSize = 40
    private var currentUpdatingMessageId: String = .empty

    var viewModel: ChatViewModel?
    var messages: [Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let header = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 80))
        header.backgroundColor = .white
        view.addSubview(header)
        
        contextMenuItems = [
            ContextMenuItem<Message>(title: "Edit", action: { [weak self] in
                self?.toggleEditMode(for: $0)
            }),
            ContextMenuItem<Message>(title: "Remove", action: { [weak self] in
                self?.removeMessage($0.messageId)
            })
        ]
        
        messagesCollectionView.register(ActivityIndicatorView.self,
                                        forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                        withReuseIdentifier: ActivityIndicatorView.typeName)
        showMessageTimestampOnSwipeLeft = true
        createTitle()
        configueMessagesViewControllerDelegates()
        removeAvatarFromCell()
        configueMessageInputBar()
        getAllMessages {
            self.messagesCollectionView.scrollToBottom() }
    }
    
    private func removeMessage(_ id: String) {
        chatService.remove(id)
            .observeOn(MainScheduler.instance)
            .subscribe(onCompleted: { [weak self] in
            let index = self?.messages.firstIndex { $0.messageId == id } ?? 0
            self?.messages.remove(at: index)
            self?.messagesCollectionView.reloadData()
        }).disposed(by: disposeBag)
    }

    private func createTitle() {
        navigationItem.titleView = UIImageView(image: UIImage(named: "hakima_title"))
    }
    
    private func toggleEditMode(for message: Message) {
        isEditing = true
        currentUpdatingMessageId = message.messageId
        let messageInput = messageInputBar.inputTextView
        messageInput.text = message.kind.get() as? String
        messageInput.becomeFirstResponder()
        
        toggleCancelButtonVisibility()
    }
    
    private func toggleCancelButtonVisibility() {
        if isEditing {
            let cancelButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            cancelButton.setImage(UIImage(systemName: "multiply.circle"), for: .normal)
            cancelButton.contentVerticalAlignment = .fill
            cancelButton.contentHorizontalAlignment = .fill
            cancelButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
            cancelButton.onTap { [weak self] in self?.cancleEditing() }
            messageInputBar.leftStackView.addSubview(cancelButton)
            messageInputBar.setLeftStackViewWidthConstant(to: 50, animated: false)
        } else {
            messageInputBar.inputTextView.text = .empty
            messageInputBar.leftStackView.subviews.forEach { $0.removeFromSuperview() }
            messageInputBar.setLeftStackViewWidthConstant(to: 0, animated: false)
            messageInputBar.inputTextView.resignFirstResponder()
        }
    }
    
    private func cancleEditing() {
        isEditing = false
        toggleCancelButtonVisibility()
    }

    private func getAllMessages(_ completion: @escaping () -> Void = {}) {
        chatService.get(pageIndex: currentPage, pageSize: pageSize)
            .observeOn(MainScheduler.instance)
            .subscribe { [weak self] (pagingResult: PagingResult<Message>) in
                    if !pagingResult.results.isEmpty {
                        self?.messages.insert(contentsOf: pagingResult.results, at: 0)
                        self?.messagesCollectionView.reloadData()
                        completion()
                    } else {
                        self?.activityIndicatorView?.isHidden = true
                    }
        }.disposed(by: disposeBag)
    }
    
    func headerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize(width: view.bounds.width, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil,
                                          previewProvider: nil,
                                          actionProvider: { [weak self] suggestedActions in
            return self?.makeContextMenu(for: indexPath.row)
        })
    }
    
    func makeContextMenu(for row: Int) -> UIMenu {
        var actions = [UIAction]()
        for item in self.contextMenuItems {
            let action = UIAction(title: item.title, identifier: nil, discoverabilityTitle: nil) { [unowned self] _ in
                DispatchQueue.main.async {
                    item.action(self.messages[row])
                }
            }
            actions.append(action)
        }
        let cancel = UIAction(title: "Cancel", attributes: .destructive) { _ in}
        actions.append(cancel)
        return UIMenu(title: "", children: actions)
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            activityIndicatorView = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: ActivityIndicatorView.typeName,
                for: indexPath) as? ActivityIndicatorView

            activityIndicatorView?.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40)
            return activityIndicatorView ?? UICollectionReusableView()
        default:
            return UICollectionReusableView()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if messagesCollectionView.contentOffset.y <= 0 {
           if !isPageRefreshing {
                isPageRefreshing = true
                activityIndicatorView?.isHidden = false
                let oldContentSizeHeight =
                    messagesCollectionView.contentSize.height
                loadMore(oldContentSizeHeight)
            }
        }
    }
    
    private func loadMore(_ offset: CGFloat) {
        currentPage += 1
        let oldMessagesCount = messages.count
        getAllMessages { [unowned self] in
            let previousTopCellIndex = messages.count - oldMessagesCount
            let indexPath = IndexPath(row: previousTopCellIndex, section: 0)
            self.messagesCollectionView.scrollToItem(at: indexPath,
                                                     at: .top, animated: false)
            self.isPageRefreshing = false
        }
    }
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate,
                              MessagesDisplayDelegate, InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView,
                  didPressSendButtonWith text: String) {
        inputBar.inputTextView.text = .empty
        if isEditing {
            chatService.update(currentUpdatingMessageId, newText: text).observeOn(MainScheduler.instance)
                .subscribe(onCompleted: { [unowned self] in
                    let index = self.messages.firstIndex {
                        $0.messageId == self.currentUpdatingMessageId } ?? 0
                    self.messages[index].kind = .text(text)
                    self.messagesCollectionView.reloadData()
                })
                .disposed(by: disposeBag)
            cancleEditing()
        } else {
            let message = Message(sender: MessageSender(senderId: "1",
                                                        displayName: .empty),
                                  messageId: UUID().uuidString,
                                  sentDate: Date(),
                                  kind: .text(text))
            chatService.send(message: text)
                .observeOn(MainScheduler.instance)
                .subscribe(onSuccess: { [weak self] (messageText) in
                    self?.messages.append(message)
                    self?.messagesCollectionView.reloadData()
            }).disposed(by: disposeBag)
        }
    }

    func currentSender() -> SenderType {
        return MessageSender(senderId: "1", displayName: .empty)
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return 1
    }
    
    func numberOfItems(inSection section: Int,
                       in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }

    func messageForItem(at indexPath: IndexPath,
                        in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.row]
    }
    
    private func configueMessageInputBar() {
        let messageInput = messageInputBar.inputTextView
        messageInput.placeholder = "Message"
        messageInput.textContainerInset.left = 10
        messageInput.textContainerInset.right = 12
        messageInput.placeholderLabelInsets.left = 12
        messageInput.backgroundColor = UIColor(hex: 0xF2F3F5)
        messageInput.applyRoundedStyle(borderColor: UIColor(hex: 0xE1E3E6),
                                       cornerRadius: 18,
                                       borderWidth: 1)
        
        messageInputBar.sendButton.setImage(UIImage(named: "send"), for: .normal)
        messageInputBar.sendButton.setTitle(.empty, for: .normal)
    }
    
    private func removeAvatarFromCell() {
        if let layout =
            messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.setMessageIncomingAvatarSize(.zero)
            layout.setMessageOutgoingAvatarSize(.zero)
        }
    }
    
    private func configueMessagesViewControllerDelegates() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
    }
}

class ActivityIndicatorView: UICollectionReusableView {
    override func prepareForReuse() {
        super.prepareForReuse()
        
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.color = .black
        activityIndicator.startAnimating()
        addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        setNeedsUpdateConstraints()
    }
}

extension MessageKind {
    func get() -> Any? {
        switch self {
        case .text(let value):
            return value
        default:
            return nil
        }
    }
}
