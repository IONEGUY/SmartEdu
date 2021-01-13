//
//  ChatViewController.swift
//  SmartEducation
//
//  Created by MacBook on 11/17/20.
//

import UIKit
import IQKeyboardManagerSwift

class ChatViewController: BaseViewController, MVVMViewController,
                          ChatMessageInputViewDelegate {
    typealias ViewModelType = ChatViewModel

    @IBOutlet weak var messagesTableView: UITableView!
    @IBOutlet weak var messageInput: ChatMessageInputView!

    private var messages: [MessageCellModel] = []
    private var chatService = ChatService()
    var viewModel: ChatViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        createTitle()
        chatService.addGreetingMessageAndSay()
        initMessagesTableView()
        getAllMessages()
        messageInput.delegate = self
        messagesTableView.transform = CGAffineTransform(scaleX: 1, y: -1)
    }

    private func createTitle() {
        navigationItem.titleView = UIImageView(image: UIImage(named: "hakima_title"))
    }

    func sendMessageButtonPressed(_ message: String) {
        chatService.addOutgoingMessage(message: message)
        let avatarMessage = chatService.addIncomingMessage(keyMessage: message)
        SpeechSynthesizerService().synthesize(avatarMessage)
        getAllMessages()
        messagesTableView.reloadData()
    }

    private func getAllMessages() {
        messages = chatService.getAllMessages().reversed()
    }

    private func initMessagesTableView() {
        messagesTableView
            .register(MessageTableViewCell.self,
                      forCellReuseIdentifier: MessageTableViewCell.typeName)
        messagesTableView
            .numberOfRows { [weak self] _ in
                self?.messages.count ?? 0 }
            .cellForRow { [weak self] indexPath in
                guard let message = self?.messages[indexPath.row] else { return UITableViewCell() }
                let cell =
                    self?.messagesTableView.dequeueReusableCell(withIdentifier: MessageTableViewCell.typeName,
                                                                for: indexPath)
                (cell as? MessageTableViewCell)?.initialize(withData: message)
                cell?.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
                return cell ?? UITableViewCell() }
            .reloadData()
    }
}
