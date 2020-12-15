//
//  VolumetricObjectsViewController.swift
//  SmartEducation
//
//  Created by MacBook on 11/8/20.
//

import UIKit
import SceneKit
import ARKit
import Closures
import SmartHitTest

class VolumetricModeViewController: BaseViewController, MVVMViewController,
                                    ChatMessageInputViewDelegate {
    typealias ViewModelType = VolumetricModeViewModel

    @IBOutlet weak var sceneView: ExtendedARSceneView!
    @IBOutlet weak var volumetricObjectsCollectionView: UICollectionView!
    @IBOutlet weak var planetsMode: UIImageView!
    @IBOutlet weak var videosMode: UIImageView!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var chatMessageInputView: ChatMessageInputView!
    @IBOutlet weak var lastMessageContainer: UIView!
    @IBOutlet weak var lastMessageSendTime: UILabel!
    @IBOutlet weak var lastMessageText: UILabel!
    @IBOutlet weak var messageInputCover: UIView!

    private var chatService = ChatService()
    private var arSceneSetup = false
    weak var viewModel: VolumetricModeViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        configueVolumetricObjectsCollectionView()
        addVolumetricItemTapHandlers(forViews: [planetsMode, videosMode, avatar])
        setupRightBarButtonItem(UIImage(named: "capture"))
        chatMessageInputView.delegate = self
        lastMessageContainer.layer.cornerRadius = 12

        let tapGestureRecognizer =
            UITapGestureRecognizer(target: self,
                                   action: #selector(self.navigateToChat(_:)))
        messageInputCover.addGestureRecognizer(tapGestureRecognizer)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if arSceneSetup { return }
        arSceneSetup.toggle()
        sceneView.setup()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        //It's workaround needed for avoid blocking ui after navigating to previous page or to next
        ARSCNView()
    }

    override func backButtonPressed() {
        chatService.clearMessages()
        Router.popTo(SpecificScienceViewController.self)
    }

    private func setupRightBarButtonItem(_ image: UIImage?) {
        let button = UIButton(type: .custom)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(rightBarButtonItemPressed),
                         for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        let barButton = UIBarButtonItem(customView: button)
        navigationItem.rightBarButtonItem = barButton
    }

    @objc private func rightBarButtonItemPressed() {
        Router.pop()
    }

    @objc private func navigateToChat(_ gesture: UITapGestureRecognizer) {
        Router.show(ChatViewController.self)
    }

    private func displayLastMessage() {
        lastMessageContainer.isHidden = false
        guard let lastMessage = ChatService().getLastIncomingMsssage() else { return }
        switch lastMessage.kind {
        case .text(let text):
            lastMessageText.text = text
        default:
            break
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        lastMessageSendTime.text = dateFormatter.string(from: lastMessage.sentTime)
    }

    func sendMessageButtonPressed(_ message: String) {
        chatService.addOutgoingMessage(message: message)
        let avatarMessage = chatService.addIncomingMessage(keyMessage: message)

        displayLastMessage()
        SpeechSynthesizerService().synthesize(avatarMessage)
    }

    private func addVolumetricItemTapHandlers(forViews views: [UIView]) {
        views.forEach { $0.addGestureRecognizer(
                UITapGestureRecognizer(target: self,
                                       action: #selector(self.volumetricItemTapped(_:))))
        }
    }

    @objc private func volumetricItemTapped(_ recognizer: UITapGestureRecognizer) {
        guard let image = recognizer.view as? UIImageView,
              let volumetricItem =
                VolumetricItem(rawValue: image.restorationIdentifier ?? String.empty)
            else { return }

        viewModel?.volumetricObjectsTypeChangedCommand?(volumetricItem)
        volumetricObjectsCollectionView.reloadData()
        setDefaultValuesToVolumetricItems()
        updateVolumetricItemsPresentation(volumetricItem, image)
    }

    private func setDefaultValuesToVolumetricItems() {
        planetsMode.tintColor = .black
        videosMode.tintColor = .black
        avatar.image = UIImage(named: "avatar")
    }

    private func updateVolumetricItemsPresentation(_ volumetricItem: VolumetricItem, _ image: UIImageView) {
        switch volumetricItem {
        case .volumetric, .videos:
            volumetricObjectsCollectionView.isHidden = false
            image.tintColor = .volumetricItemSelectedColor
        case .avatar:
            volumetricObjectsCollectionView.isHidden = true
            image.applyRoundedStyle()
            image.image = UIImage(named: "avatar")
            addVolumetricObjectOnPlane()
        }
    }

    private func addVolumetricObjectOnPlane(_ id: String? = nil) {
        guard let volumetricItem = viewModel?.volumetricItem else { return }
        if volumetricItem == .avatar {
            if messageInputCover == nil { return }
            messageInputCover?.removeFromSuperview()
            chatService.addGreetingMessageAndSay()
            displayLastMessage()
        }
        DispatchQueue.main.async { [weak self] in
            let newNode = SceneNodeBuilder.build(withId: id, volumetricItem)
            self?.sceneView.add(newNode)
        }
    }

    private func configueVolumetricObjectsCollectionView() {
        volumetricObjectsCollectionView.isHidden = true
        volumetricObjectsCollectionView.backgroundColor = .black
        volumetricObjectsCollectionView.alpha = 0.8
        volumetricObjectsCollectionView.contentInset = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 10)
        volumetricObjectsCollectionView.register(
            UINib(nibName: VolumetricObjectCollectionViewCell.typeName, bundle: nil),
            forCellWithReuseIdentifier: VolumetricObjectCollectionViewCell.typeName)

        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        volumetricObjectsCollectionView.collectionViewLayout = layout

        volumetricObjectsCollectionView
            .numberOfItemsInSection { [weak self] _ in
                self?.viewModel?.volumetricObjects.count ?? 0 }
            .cellForItemAt { [weak self] index in
                let cell = self?.volumetricObjectsCollectionView
                    .dequeueReusableCell(withReuseIdentifier: VolumetricObjectCollectionViewCell.typeName,
                                         for: index) as? VolumetricObjectCollectionViewCell
                let object = self?.viewModel?.volumetricObjects[index.row]
                cell?.setupView(object)
                return cell ?? UICollectionViewCell() }
            .didSelectItemAt { [weak self] index in
                guard let self = self, let viewModel = self.viewModel else { return }
                let object = viewModel.volumetricObjects[index.row]
                self.addVolumetricObjectOnPlane(object.id)
            }
            .reloadData()
    }
}
