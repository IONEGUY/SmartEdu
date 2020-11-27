//
//  ChatMessageInputView.swift
//  SmartEducation
//
//  Created by MacBook on 11/16/20.
//

import UIKit

@IBDesignable class ChatMessageInputView: UIView, UITextViewDelegate {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var messageActionButton: UIButton!
    @IBOutlet weak var messageInput: UITextView!
    @IBOutlet weak var messageInputPlaceholderLabel: UILabel!

    weak var delegate: ChatMessageInputViewDelegate?
    private var recognizing = false

    private var messageActionType: MessageActionType = .dictation
    private var voiceRecognizionService = VoiceRecognizionService()

    override init(frame: CGRect) {
        super.init(frame: frame)

        initUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        initUI()
    }

    @IBAction func messageActionButtonPressed() {
        switch messageActionType {
        case .dictation:
            if !recognizing {
                messageActionButton.applyPulseAnimation()
                recognizing = true
                voiceRecognizionService.startRecording(insertRecognizedSpeech)
            } else {
                voiceRecognizionService.stopRecording()
                recognizing = false
                messageActionButton.removePulseAnimation()
                updateMessageActionButton()
            }
        case .send:
            delegate?.sendMessageButtonPressed(messageInput.text)
            clearMessageInput()
            textViewDidChange(UITextView())
        }
    }

    func clearMessageInput() {
        messageInput.text = nil
    }

    func textViewDidChange(_ textView: UITextView) {
        updatePlaceholderLabelVisibility()
        updateMessageActionButton()
    }

    private func initUI() {
        loadView()
        setupMessageInput()
    }

    private func loadView() {
        Bundle.main.loadNibNamed(ChatMessageInputView.typeName, owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    private func setupMessageInput() {
        messageInput.delegate = self
        messageInput.textContainerInset.left = 12
        messageInput.textContainerInset.right = 12
        messageInput.applyRoundedStyle()
        messageInput.layer.borderWidth = 1
        messageInput.layer.borderColor = UIColor(hex: 0xE1E3E6).cgColor
    }

    private func insertRecognizedSpeech(_ text: String?) {
        messageInput.text = text ?? String.empty
        updatePlaceholderLabelVisibility()
    }

    private func updatePlaceholderLabelVisibility() {
        messageInputPlaceholderLabel.isHidden = !messageInput.text.isEmpty
    }

    private func updateMessageActionButton() {
        if recognizing { return }
        let textEmpty = messageInput.text.isEmptyOrWhitespace()
        messageActionType = textEmpty ? .dictation : .send
        let image = textEmpty ? UIImage(systemName: "mic") : UIImage(named: "send")
        messageActionButton.setImage(image, for: [.normal])
    }

    func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
