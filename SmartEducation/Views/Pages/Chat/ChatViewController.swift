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

    var viewModel: ChatViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let header = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 80))
        header.backgroundColor = .white
        view.addSubview(header)
        
        let rightBarButtonItem = UIBarButtonItem()
        rightBarButtonItem.title = "Log out"
        rightBarButtonItem.onTap { [unowned self] in self.viewModel?.logOut() }
        navigationItem.rightBarButtonItem = rightBarButtonItem
                
        messagesCollectionView.register(ActivityIndicatorView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: ActivityIndicatorView.typeName)
        showMessageTimestampOnSwipeLeft = true
        createTitle()
        configueMessagesViewControllerDelegates()
        removeAvatarFromCell()
        configueMessageInputBar()
        initSubscriptions()
    }
    
    private func initSubscriptions() {        
        viewModel?.messages
            .observeOn(MainScheduler.instance)
            .skip(1)
            .take(1)
            .subscribe { [unowned self] _ in
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToBottom()
            }
            .disposed(by: disposeBag)
        
        viewModel?.messages
            .observeOn(MainScheduler.instance)
            .skip(2)
            .subscribe { [unowned self] _ in
                self.messagesCollectionView.reloadData()
            }
            .disposed(by: disposeBag)
        
        viewModel?.activityIndicatorIsHidden
            .observeOn(MainScheduler.instance)
            .subscribe { [unowned self] in self.activityIndicatorView?.isHidden = $0 }
            .disposed(by: disposeBag)
        
        viewModel?.updateMessageInputView
            .observeOn(MainScheduler.instance)
            .subscribe { [unowned self] messageText in
                updateMessageInputView(messageText)
            }
            .disposed(by: disposeBag)
        
        viewModel?.updateMessageCollectionAfterloadMore
            .observeOn(MainScheduler.instance)
            .subscribe { [unowned self] (offset: Int) in
                let indexPath = IndexPath(row: offset, section: 0)
                self.messagesCollectionView.scrollToItem(at: indexPath,
                                                         at: .top, animated: false)
            }
            .disposed(by: disposeBag)
        
        viewModel?.messageAdded
            .observeOn(MainScheduler.instance)
            .subscribe { [unowned self] _ in
                self.messagesCollectionView.scrollToBottom()
            }
            .disposed(by: disposeBag)
    }
    
    private func createTitle() {
        navigationItem.titleView = UIImageView(image: UIImage(named: "hakima_title"))
    }
    
    private func updateMessageInputView(_ messageText: String = .empty) {
        guard let viewModel = viewModel else { return }
        if viewModel.isEditing {
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
        viewModel?.isEditing = false
        updateMessageInputView()
    }
    
    func headerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize(width: view.bounds.width, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil,
                                          previewProvider: nil,
                                          actionProvider: { [weak self] _ in
            return self?.makeContextMenu(for: indexPath.row)
        })
    }
    
    func makeContextMenu(for row: Int) -> UIMenu {
        var actions = [UIAction]()
        for item in viewModel?.messageActions ?? [] {
            let action = UIAction(title: item.title, identifier: nil, discoverabilityTitle: nil) { [unowned self] _ in
                guard let value = self.viewModel?.messages.value[row]
                else { return }
                item.action.onNext(value)
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
            return activityIndicatorView ?? ActivityIndicatorView()
        default:
            return UICollectionReusableView()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if messagesCollectionView.contentOffset.y <= 0 {
            viewModel?.loadMore.onNext(nil)
        }
    }
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate,
                              MessagesDisplayDelegate, InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView,
                  didPressSendButtonWith text: String) {
        inputBar.inputTextView.text = .empty
        viewModel?.sendButtonPressed.onNext(text)
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
