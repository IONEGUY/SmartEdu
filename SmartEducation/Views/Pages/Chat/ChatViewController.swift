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
import RxCocoa
import SnapKit

class ChatViewController: MessagesViewController, MVVMViewController {
    typealias ViewModelType = ChatViewModel

    private var activityIndicatorView: ActivityIndicatorView?
    private var disposeBag = DisposeBag()
    
    private let floatingButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 25
        button.backgroundColor = .blue
        button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        button.isHidden = true
        button.centerVertically(padding: 0)
        return button
    }()
    
    private let typingIndicator: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        return label
    }()

    var viewModel: ChatViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        createTitle()
        createRightBarButtonItem()
        createFloatingButton()
        createNavBarBackgroundView()
        configueMessagesViewController()
        removeAvatarFromIncomingMessageCell()
        configueMessageInputBar()
        initSubscriptions()
    }
    
    private func initSubscriptions() {
        guard let viewModel = viewModel else { return }
        
        viewModel.typingIndicatorHidden
            .bind(to: typingIndicator.rx.isHidden)
            .disposed(by: disposeBag)
        viewModel.typingName
            .bind(to: typingIndicator.rx.text).disposed(by: disposeBag)
        
        viewModel.typingIndicatorHidden
            .skip(1)
            .observe(on: MainScheduler.instance)
            .filter { [unowned self] _ in isLastMessageVisible() }
            .subscribe { [unowned self] _ in
                messagesCollectionView.scrollToBottom(animated: false) }
            .disposed(by: disposeBag)
        
        messageInputBar.inputTextView.rx.text
            .distinctUntilChanged()
            .filter { $0 != nil && !$0!.isEmptyOrWhitespace() }
            .bind(to: viewModel.messageText).disposed(by: disposeBag)
        
        viewModel.setFocusOnMessageAtIndex
            .observe(on: MainScheduler.instance)
            .subscribe { [unowned self] (index: Int) in
                messagesCollectionView.scrollToItem(at: IndexPath(row: index, section: 0),
                                                    at: .bottom,
                                                    animated: false)
                if viewModel.isLastMessageFromCurrentSender() { return }
                guard let messageId = getMessageByPoint()?.messageId else { return }
                viewModel.correctUnreadMessagesCount.onNext(messageId)
            }
            .disposed(by: disposeBag)
        
        viewModel.messages
            .observe(on: MainScheduler.instance)
            .subscribe { [unowned self] _ in messagesCollectionView.reloadData() }
            .disposed(by: disposeBag)

        viewModel.activityIndicatorIsHidden
            .observe(on: MainScheduler.instance)
            .subscribe { [unowned self] in
                self.activityIndicatorView?.isHidden = $0
            }
            .disposed(by: disposeBag)
                
        viewModel.updateMessageInputView
            .observe(on: MainScheduler.instance)
            .map(updateMessageInputView)
            .subscribe()
            .disposed(by: disposeBag)
        
        viewModel.updateMessageCollectionAfterloadMore
            .observe(on: MainScheduler.instance)
            .map { IndexPath(row: $0, section: 0) }
            .subscribe { [unowned self] in
                messagesCollectionView.scrollToItem(at: $0, at: .top, animated: false)
            }
            .disposed(by: disposeBag)
        
        viewModel.unreadMessagesCount
            .observe(on: MainScheduler.instance)
            .filter { _ in !viewModel.isLastMessageFromCurrentSender() }
            .subscribe { [unowned self] (value: Int) in
                if isLastMessageVisible() {
                    guard let lastMessageId = viewModel.messages.value.last?.messageId
                    else { return }
                    viewModel.decreaseUnreadMessagesCount.onNext(lastMessageId)
                    self.messagesCollectionView.scrollToBottom(animated: true)
                }
                
                if value == 0 {
                    floatingButton.isHidden = true
                } else {
                    floatingButton.isHidden = false
                    floatingButton.setTitle(String(value), for: .normal)
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.isMessageEditingModeEnabled
            .filter { $0 == false }
            .subscribe(on: MainScheduler.instance)
            .map { _ in String.empty }
            .map(updateMessageInputView)
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    private func createNavBarBackgroundView() {
        let navBarBackgroundView = UIView(frame: CGRect(x: 0, y: 0,
                                                        width: view.bounds.width,
                                                        height: 70))
        navBarBackgroundView.backgroundColor = .white
        view.addSubview(navBarBackgroundView)
    }
    
    private func createRightBarButtonItem() {
        let rightBarButtonItem = UIBarButtonItem()
        rightBarButtonItem.title = "Log out"
        rightBarButtonItem.onTap { [unowned self] in self.viewModel?.logOut() }
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    private func createFloatingButton() {
        floatingButton.onTap { [unowned self] in
            messagesCollectionView.scrollToBottom(animated: true)
            viewModel?.unreadMessagesCount.accept(0)
        }
        
        view.addSubview(floatingButton)
        
        floatingButton.snp.makeConstraints { (make) in
            make.width.height.equalTo(50)
            make.bottom.equalToSuperview().inset(70)
            make.right.equalToSuperview().inset(20)
        }
    }
    
    private func isLastMessageVisible() -> Bool {
        return messagesCollectionView.contentOffset.y +
            messagesCollectionView.bounds.height -
            messagesCollectionView.contentSize.height > -messageInputBar.bounds.height
    }
    
    private func createTitle() {
        navigationItem.titleView = UIImageView(image: UIImage(named: "hakima_title"))
    }
    
    private func updateMessageInputView(_ messageText: String = .empty) {
        guard let viewModel = viewModel else { return }
        if viewModel.isMessageEditingModeEnabled.value == true {
            let messageInput = messageInputBar.inputTextView
            messageInput.text = messageText
            messageInput.becomeFirstResponder()
            
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
        viewModel?.isMessageEditingModeEnabled.accept(false)
        updateMessageInputView()
    }
    
    func headerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize(width: view.bounds.width, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration? {
        return viewModel?.createContextMenu(for: indexPath.row)
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

            activityIndicatorView?.frame = CGRect(x: 0, y: 0,
                                                  width: self.view.frame.width,
                                                  height: 40)
            return activityIndicatorView ?? ActivityIndicatorView()
        default:
            return UICollectionReusableView()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let message = getMessageByPoint() {
            if isFromCurrentSender(message: message) { return }
            viewModel?.decreaseUnreadMessagesCount.onNext(message.messageId)
        }
        
        if messagesCollectionView.contentOffset.y <= -20 {
            viewModel?.loadMore.onNext(nil)
        }
    }
    
    private func getMessageByPoint() -> Message? {
        let cellPoint = CGPoint(x: messagesCollectionView.bounds.midX,
                                y: messagesCollectionView.contentOffset.y +
                                    (messagesCollectionView.bounds.height - 84))
        
        if let indexPath = messagesCollectionView.indexPathForItem(at: cellPoint) {
            return viewModel?.messages.value[indexPath.row]
        }
        
        return Message.empty
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let hidden = viewModel?.messages.value[indexPath.row].avatarHidden else { return }
        avatarView.isHidden = hidden
    }
    
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return isFromCurrentSender(message: message) &&
            !((message as? Message)?.isDeleted ?? false) ? 15 : 0
    }
    
    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if isFromCurrentSender(message: message) {
            let statusString = viewModel?.messages.value[indexPath.row].isRead == true
                ? "read" : "sent"
            return NSAttributedString(string: statusString,
                                      attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 10)])
        }
        
        return nil
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in  messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return viewModel?.messages.value[indexPath.row].isDeleted ?? false
            ? .clear
            : isFromCurrentSender(message: message)
                ? UIColor(hex: 0x64C466)
                : UIColor(hex: 0xE5E5EA)
    }
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return viewModel?.messages.value[indexPath.row].isDeleted ?? false
            ? .black
            : isFromCurrentSender(message: message)
                ? .white
                : .black
    }
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate,
                              MessagesDisplayDelegate, InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView,
                  didPressSendButtonWith text: String) {
        inputBar.inputTextView.text = .empty
        viewModel?.sendButtonPressed.onNext(.text(text))
        viewModel?.endMesageTyping()
    }

    func currentSender() -> SenderType {
        guard let sender = viewModel?.currentMessageSender else {
            fatalError()
        }
        
        return sender
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return 1
    }
    
    func numberOfItems(inSection section: Int,
                       in messagesCollectionView: MessagesCollectionView) -> Int {
        return viewModel?.messages.value.count ?? 0
    }

    func messageForItem(at indexPath: IndexPath,
                        in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return viewModel?.messages.value[indexPath.row] ?? .empty
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
        messageInputBar.topStackView.addArrangedSubview(typingIndicator)
    }
    
    private func removeAvatarFromIncomingMessageCell() {
        if let layout =
            messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.setMessageOutgoingAvatarSize(.zero)
        }
    }
    
    private func configueMessagesViewController() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        
        messagesCollectionView.register(ActivityIndicatorView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: ActivityIndicatorView.typeName)

        showMessageTimestampOnSwipeLeft = true
    }
}

class ActivityIndicatorView: UICollectionReusableView {
    override func prepareForReuse() {
        super.prepareForReuse()
        
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.transform = CGAffineTransform(scaleX: 2, y: 2)
        activityIndicator.color = .black
        activityIndicator.startAnimating()
        addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        setNeedsUpdateConstraints()
    }
}
