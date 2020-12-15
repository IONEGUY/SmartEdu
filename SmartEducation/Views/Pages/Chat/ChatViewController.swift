//
//  ChatViewController.swift
//  SmartEducation
//
//  Created by MacBook on 11/17/20.
//

import UIKit
import MessageKit
import InputBarAccessoryView

class ChatViewController: MessagesViewController, MVVMViewController {
    typealias ViewModelType = ChatViewModel

    private var chatService = ChatService()
    
    var viewModel: ChatViewModel?
    var messages: [Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        createTitle()
        getAllMessages()
        chatService.addGreetingMessageAndSay()
        
        configueMessagesViewControllerDelegates()
        removeAvatarFromCell()
        configueMessageInputBar()
    }

    private func createTitle() {
        navigationItem.titleView = UIImageView(image: UIImage(named: "hakima_title"))
    }

    private func getAllMessages() {
        messages = chatService.getAllMessages()
    }
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate,
                              MessagesDisplayDelegate, InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView,
                  didPressSendButtonWith text: String) {
        chatService.addOutgoingMessage(message: text)
        let avatarMessage = chatService.addIncomingMessage(keyMessage: text)
        SpeechSynthesizerService().synthesize(avatarMessage)
        getAllMessages()
        messagesCollectionView.reloadData()
        inputBar.inputTextView.text = .empty
    }
    
    func currentSender() -> SenderType {
        return ChatService.currentUser
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }

    func messageForItem(at indexPath: IndexPath,
                        in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
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
